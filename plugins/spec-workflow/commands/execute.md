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

### 🚨 Fase 5: Gerenciamento de Subtarefas (OBRIGATÓRIO)

#### ⚠️ REGRA DE OURO DA SUBDIVISÃO ⚠️

**TODA task com >3 ACs ou afetando >2 arquivos DEVE ser subdividida.**

**NUNCA** tente implementar tasks gigantes de uma vez. Isso leva a:
- ❌ Esquecimento de requisitos importantes
- ❌ Perda de argumentos e contexto
- ❌ Implementação incompleta ou errada
- ❌ Dificuldade de rastrear progresso

#### Critério de Subdivisão OBRIGATÓRIA

**SE** a task atende **QUALQUER** destes critérios:
- ✅ **>3 Acceptance Criteria**
- ✅ **Afecta >2 arquivos**
- ✅ **Estimativa >4 horas**
- ✅ **Múltiplas responsabilidades**

**ENTÃO: DEVE subdividir em subtarefas atômicas.**

#### Processo de Subdivisão

**1. Verificar critério:**
```javascript
const deveSubdividir = task.acceptance_criteria?.length > 3 ||
                       task.affected_files?.length > 2 ||
                       task.estimated_hours > 4
```

**2. SE SIM, criar subtarefas:**
```javascript
// Exemplo: subdividir task de autenticação
const subtasks = [
  { title: "Criar models User e Session", parent: task.id },
  { title: "Implementar JWT service", parent: task.id },
  { title: "Criar middleware de autenticação", parent: task.id },
  { title: "Adicionar rotas de login/logout", parent: task.id },
  { title: "Escrever testes", parent: task.id }
]

subtasks.forEach((sub, index) => {
  backlog_task_create({
    title: sub.title,
    parent: sub.parent,
    type: "subtask",
    status: "To Do",
    priority: task.priority,
    labels: task.labels,
    acceptance_criteria: [
      `[ ] Implementação conforme spec`,
      `[ ] Testes passando`,
      `[ ] Code review aprovado`
    ]
  })
})
```

**3. SE NÃO, justificar no notes:**
```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n**Por que não subdividir?**\nTask tem apenas 2 ACs e afeta 1 arquivo. Subdivisão desnecessária.\n`
})
```

#### Executar em Ordem

Após subdivisão (ou verificação de que não é necessária):
1. Listar subtarefas em ordem de dependência
2. Executar cada subtask sequencialmente
3. Marcar como concluída antes de iniciar próxima

### 🚨 Fase 6: Implementação com Subagentes (OU Delegar ao Gemini)

#### ⚠️ REGRA DE OURO: PASSAR CONTEXTO COMPLETO ⚠️

**NUNCA** resuma a spec para o subagente. **SEMPRE** passe o CONTEÚDO INTEGRAL.

#### 1. Escolher Especialista

- **Claude (Sonnet)** para orquestração e testes
- **Gemini-3-Flash** para codificação intensiva (via `gemini-orchestrator`)

#### 2. OBRIGATÓRIO: Passar Contexto COMPLETO

**NUNCA** faça isso:
```javascript
// ❌ ERRADO - Resumo vago
`Implemente a subtask ${task.id} seguindo a spec ${specPath}.`
```

**SEMPRE** faça isso:
```javascript
// ✅ CORRETO - Contexto COMPLETO
const specContent = await fs.readFile(specPath, 'utf-8')

const promptParaAgente = `
# Task: ${task.title}

## Spec COMPLETA (CONTEÚDO INTEGRAL):
${specContent}

## Todos os Acceptance Criteria:
${task.acceptance_criteria.map((ac, i) => `${i + 1}. ${ac}`).join('\n')}

## Contexto do Projeto:
${projectContext}

## Padrões Conhecidos:
${memoryPatterns}

## Implementar:
- Seguir 100% a spec acima
- NÃO resumir requisitos
- NÃO omitir detalhes
- Validar TODOS os ACs antes de finalizar
`
```

**Por que contexto COMPLETO é OBRIGATÓRIO?**

- ✅ Subagente tem TODOS os requisitos
- ✅ Nada é perdido em resumos
- ✅ ACs podem ser validados corretamente
- ✅ Implementação segue spec exatamente

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