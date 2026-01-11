---
name: spec-workflow-execute
description: Guia a execução de uma task planejada, lendo sua Spec e coordenando a implementação. Gerencia dependências, subtarefas e atualiza notas progressivamente.
version: 2.0.0
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

Este comando guia a execução de uma task planejada, gerenciando dependências, subtare fas, notas incrementais e status via MCP.

## Procedimento de Execução OBRIGATÓRIO

### Fase 1: Localização e Seleção da Tarefa

**1. Buscar Tarefa:**

Se `task-id` foi fornecido:
```javascript
const task = backlog_task_get("{{task-id}}")
```

Se NÃO foi fornecido (auto-seleção):
```javascript
// Tentar encontrar task em progresso
let tasks = backlog_task_list({ status: "In Progress" })

if (tasks.length > 0) {
  // Assumir a primeira task em progresso
  task = tasks[0]
  console.log(`📌 Retomando task em progresso: ${task.id}`)
} else {
  // Listar tasks pendentes
  tasks = backlog_task_list({ status: "To Do" })

  if (tasks.length === 0) {
    throw new Error("❌ Nenhuma task disponível para execução!")
  }

  // Apresentar opções ao usuário ordenadas por prioridade
  console.log("📋 Tasks disponíveis:")
  tasks
    .sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority])
    .forEach(t => console.log(`- ${t.id}: ${t.title} (${t.priority})`))

  // Perguntar ao usuário ou iniciar a de maior prioridade
  // ...
}
```

### Fase 2: Verificar e Gerenciar Dependências (NOVO)

**CRÍTICO**: Antes de iniciar, verificar se todas as dependências estão concluídas:

```javascript
if (task.dependencies && task.dependencies.length > 0) {
  console.log(`🔗 Task possui ${task.dependencies.length} dependências`)

  // Verificar status de cada dependência
  const blockers = []
  for (const depId of task.dependencies) {
    const depTask = backlog_task_get(depId)
    if (depTask.status !== "Done") {
      blockers.push(depTask)
    }
  }

  if (blockers.length > 0) {
    console.log("⚠️ ATENÇÃO: Task bloqueada por dependências pendentes!")
    console.log("\n❌ Dependências não concluídas:")
    blockers.forEach(b => console.log(`   - ${b.id}: ${b.title} (${b.status})`))

    // Perguntar ao usuário
    const options = [
      "Bloquear task (mudar status para 'Blocked')",
      "Prosseguir mesmo assim (não recomendado)",
      "Executar dependência primeiro"
    ]

    // Aguardar decisão...

    // Se escolher bloquear:
    backlog_task_update(task.id, {
      status: "Blocked",
      notes: task.notes + `\n\n## ⚠️ Bloqueio (${timestamp})\n` +
             `Bloqueada por: ${blockers.map(b => b.id).join(", ")}`
    })
    return // Interromper execução
  } else {
    console.log("✅ Todas as dependências concluídas!")
  }
}
```

### Fase 3: Leitura da Especificação (Spec)

**1. Identificar Spec vinculada:**

```javascript
// Tentar extrair spec da description ou notes
const specMatch = task.description?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/) ||
                  task.notes?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/)

if (!specMatch) {
  console.warn("⚠️ Spec não encontrada! Task sem especificação detalhada.")
  // Perguntar se quer continuar sem spec ou criar spec primeiro
} else {
  const specPath = specMatch[1]
  console.log(`📄 Lendo spec: ${specPath}`)
}
```

**2. Ler Spec via MCP:**

```javascript
const spec = backlog_doc_get(specId)
console.log("📖 Spec carregada:")
console.log(`   - Título: ${spec.title}`)
console.log(`   - Status: ${spec.metadata.status}`)
console.log(`   - Versão: ${spec.metadata.version}`)
```

**3. Validar ACs da task com os da Spec:**

```javascript
// Os ACs da task devem estar alinhados com os da Spec
// Se houver divergência, avisar
```

### Fase 4: Atualizar Status para "In Progress"

```javascript
backlog_task_update(task.id, {
  status: "In Progress",
  notes: task.notes + `\n\n## 🚀 Início da Execução (${timestamp})\n` +
         `Iniciada por @Claude\n` +
         `Spec: ${specPath || "N/A"}`
})
```

### Fase 5: Criar Subtarefas (SE NECESSÁRIO)

**Se a task for complexa e precisar ser quebrada:**

```javascript
// Exemplo: Dividir "Sistema de Autenticação" em subtarefas

const subtasks = [
  {
    title: "Implementar endpoint /auth/login",
    type: "chore",
    parent: task.id,
    acceptance_criteria: ["[ ] Endpoint retorna JWT válido"]
  },
  {
    title: "Configurar middleware de autenticação",
    type: "chore",
    parent: task.id,
    acceptance_criteria: ["[ ] Middleware valida JWT corretamente"]
  },
  {
    title: "Implementar refresh token",
    type: "chore",
    parent: task.id,
    acceptance_criteria: ["[ ] Refresh token funcional"]
  }
]

for (const sub of subtasks) {
  const subtaskId = backlog_task_create({
    title: sub.title,
    type: sub.type,
    status: "To Do",
    parent: task.id,  // Vincula à task pai
    priority: task.priority,  // Herda prioridade
    labels: [...task.labels, "subtask"],
    acceptance_criteria: sub.acceptance_criteria
  })

  console.log(`   ✅ Subtask criada: ${subtaskId}`)
}
```

**Registrar criação de subtarefas:**

```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 📋 Subtarefas Criadas (${timestamp})\n` +
         subtasks.map((s, i) => `${i+1}. ${s.title}`).join("\n")
})
```

### Fase 6: Implementação com Subagentes

**1. Escolher Especialista:**

Dependendo da tecnologia:
- Python → `python-pro`
- TypeScript/JavaScript → `typescript-pro` ou `javascript-pro`
- Django → `django-pro`
- FastAPI → `fastapi-pro`
- Geral → `general-purpose`

**2. Instruir Agente:**

```javascript
// Lançar agente com contexto completo
Task(subagent_type: "python-pro", {
  prompt: `
Implemente a seguinte task:

**Task**: ${task.title} (${task.id})
**Prioridade**: ${task.priority}
**Milestone**: ${task.milestone}

**Especificação completa:**
${spec.content}

**Acceptance Criteria:**
${task.acceptance_criteria.join("\n")}

**Plano de implementação:**
${task.plan}

**Requisitos:**
- Seguir Constituição: Ler backlog/docs/doc-001...
- Escrever testes unitários
- Documentar código quando necessário
- NÃO duplicar código existente
`
})
```

### Fase 7: Atualizar Notas Progressivamente (NOVO)

**Durante a execução, registrar observações incrementalmente:**

```javascript
// Após cada etapa significativa:

backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 📝 Atualização (${timestamp})\n` +
         `- Implementado módulo de autenticação\n` +
         `- Configurado Redis para sessões\n` +
         `- Encontrado bloqueio: dependency X não instalada (resolvido)`
})
```

**Exemplos de atualizações:**
- Módulos implementados
- Testes adicionados
- Bugs encontrados e resolvidos
- Decisões técnicas tomadas
- Refatorações realizadas
- Performance otimizada

### Fase 8: Marcar ACs como Concluídos (Progressivamente)

**À medida que ACs são atendidos:**

```bash
# Via CLI (mais simples):
backlog task edit {{task-id}} --check-ac "Login deve retornar JWT válido"
backlog task edit {{task-id}} --check-ac "Refresh token implementado"
```

**Ou via MCP:**

```javascript
// Atualizar array de acceptance_criteria
const updatedACs = task.acceptance_criteria.map(ac =>
  ac.includes("Login deve retornar JWT") ? ac.replace("[ ]", "[x]") : ac
)

backlog_task_update(task.id, {
  acceptance_criteria: updatedACs
})
```

### Fase 9: Finalização da Execução

**Quando tudo estiver implementado:**

1. **Verificar que TODOS os ACs estão marcados como [x]**
2. **Executar testes** (se aplicável)
3. **Commitar código no Git**
4. **NÃO mudar status para "Done"** - isso é feito via `/spec-retro`
5. **Mudar status para "In Review"**:

```javascript
backlog_task_update(task.id, {
  status: "In Review",
  notes: task.notes + `\n\n## ✅ Implementação Concluída (${timestamp})\n` +
         `Pronta para revisão via /spec-review`
})
```

### Saída Esperada

```markdown
✅ Task Executada com Sucesso!

📋 **Task**: {{task-id}} - {{título}}
   - Status: To Do → In Progress → In Review
   - Prioridade: {{priority}}
   - Milestone: {{milestone}}

🔗 **Dependências**: {{dependencies ou "Nenhuma" ou "Todas concluídas"}}

📄 **Spec**: {{spec-path}}
   - Versão: {{version}}
   - ACs da spec: {{N critérios}}

📝 **Subtarefas Criadas**: {{N subtarefas ou "Nenhuma"}}
   {{lista de subtarefas se aplicável}}

✅ **Acceptance Criteria**: {{X de N}} concluídos
   {{lista de ACs com status [x] ou [ ]}}

🔨 **Implementação**:
   - Módulos implementados: {{lista}}
   - Testes adicionados: {{sim/não}}
   - Commits realizados: {{hashes se aplicável}}

📋 **Notas**: {{resumo das notas incrementais}}

🎯 **Próximos Passos:**
   1. Revisar conformidade: /spec-review {{task-id}}
   2. Se aprovado: /spec-retro {{task-id}}
   3. Visualizar progresso: backlog board
```

## Regras de Ouro

1. **Dependências Primeiro**: NUNCA ignorar dependências bloqueadas sem aviso explícito
2. **Spec é Lei**: Implementação DEVE seguir 100% a Spec. Divergências requerem atualização da Spec primeiro.
3. **ACs são Contratos**: Se os Critérios de Aceite não forem atendidos, task não pode ser marcada como concluída.
4. **Notas Incrementais**: Atualizar `notes` progressivamente documenta o progresso e decisões.
5. **Subtarefas para Complexidade**: Tasks complexas devem ser quebradas em subtarefas rastreáveis.
6. **MCP-Only**: PROIBIDO editar arquivos .backlog manualmente. Use ferramentas MCP.
7. **Não Pular /spec-review**: Execução → Review → Retro (nesta ordem)

## Notas Importantes

- **Gestão de Dependências**: O comando agora detecta e bloqueia automaticamente tasks com dependências não concluídas
- **Subtarefas Hierárquicas**: Campo `parent` vincula subtarefas à task principal para rastreabilidade
- **Notas como Diário**: Atualizações incrementais em `notes` criam um histórico completo da implementação
- **Status Progressivo**: To Do → In Progress → In Review → Done (via /spec-retro)
- **CLI para ACs**: Usar `backlog task edit --check-ac` é mais rápido que atualizar via MCP
- **Subagentes Especializados**: Escolher o subagente certo melhora qualidade e velocidade
