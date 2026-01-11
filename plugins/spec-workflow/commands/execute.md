---
name: spec-workflow-execute
description: Guia a execução de uma task planejada, lendo sua Spec e coordenando a implementação. Gerencia dependências, subtarefas e atualiza notas progressivamente.
version: 2.1.0
category: workflow
triggers:
  - "/spec-execute"
  - "executar task"
  - "iniciar implementação"
  - "implementar feature"
arguments:
  - name: task-id
    description: ID da task a ser executada (ex: task-1). Se omitido, o agente buscará a tarefa com status 'inprogress'.
    required: false
---

# Spec-Execute: Execução de Task com Gerenciamento Completo

Este comando guia a execução de uma task planejada (Main Task ou Subtask), gerenciando dependências, notas incrementais e status via MCP.

## Procedimento de Execução OBRIGATÓRIO

### Fase 1: Localização e Seleção da Tarefa

**1. Buscar Tarefa:**

Se `task-id` foi fornecido:
```javascript
const task = backlog_task_get("{{task-id}}")
```

Se NÃO foi fornecido (auto-seleção):
```javascript
// Tentar encontrar subtask em progresso (prioridade máxima)
let tasks = backlog_task_list({ status: "In Progress" })

if (tasks.length > 0) {
  task = tasks[0]
  console.log(`📌 Retomando subtask em progresso: ${task.id}`)
} else {
  // Listar subtasks pendentes de tarefas principais em progresso
  // ...
}
```

### Fase 2: Verificar e Gerenciar Dependências

**CRÍTICO**: Antes de iniciar, verificar se todas as dependências da task (especialmente se for uma subtask) estão concluídas.

```javascript
if (task.dependencies && task.dependencies.length > 0) {
  // ... verificação de blockers ...
}
```

### Fase 3: Leitura da Especificação (Spec)

**1. Identificar Spec vinculada:**

```javascript
// Buscar spec (.backlog) na main task ou subtask
const specMatch = task.description?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/) ||
                  task.notes?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/)

// Se for subtask, buscar na parent task
if (!specMatch && task.parent) {
  const parentTask = backlog_task_get(task.parent)
  // ... buscar spec no parent ...
}
```

### Fase 4: Atualizar Status para "In Progress"

```javascript
backlog_task_update(task.id, {
  status: "In Progress",
  notes: task.notes + `\n\n## 🚀 Início da Execução (${timestamp})\n` +
         `Iniciada por @Claude\n`
})
```

### Fase 5: Gerenciamento de Subtarefas

**Nota**: A maioria das subtarefas (passos de implementação) já deve ter sido criada durante o `/spec-plan`.

1. **Executar em Ordem**: Seguir a sequência planejada das subtasks.
2. **Criar se Necessário**: Se durante a execução for identificada a necessidade de quebrar mais o trabalho, use `backlog_task_create` com `parent: task.id`.

### Fase 6: Implementação com Subagentes (OU Delegar ao Gemini)

**1. Escolher Especialista:***

- Claude (Sonnet) para orquestração e testes.
- **Gemini-3-Flash** para codificação intensiva (via `gemini-orchestrator`).

**2. Instruir Agente com Contexto da Spec:***

```javascript
// Exemplo de prompt com spec
`Implemente a subtask ${task.id} seguindo a spec ${specPath}.`
```

### Fase 7: Atualizar Notas Progressivamente

**Durante a execução, registrar observações incrementalmente:***

```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 📝 Atualização (${timestamp})\n` +
         `- Implementado módulo de autenticação\n` +
         `- Testes unitários adicionados`
})
```

### Fase 8: Marcar ACs como Concluídos

À medida que os critérios de aceite de cada subtask são atendidos, marque-os como concluídos.

### Fase 9: Finalização da Subtask

Mudar status para "In Review" e sugerir `/spec-review`.

---

## Regras de Ouro

1. **Dependências Primeiro**: NUNCA ignorar dependências bloqueadas.
2. **Spec é Lei**: Implementação DEVE seguir 100% a Spec.
3. **Notas Incrementais**: Documente o progresso e decisões importantes.
4. **MCP-Only**: PROIBIDO editar arquivos .backlog ou .md do backlog manualmente.