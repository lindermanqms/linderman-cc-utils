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

### 🚨 Fase 2: Validar Dependencies (OBRIGATÓRIO - Bloqueio Automático)

**CRÍTICO**: Antes de iniciar, verificar se todas as dependências da task estão concluídas. SE houver dependências pendentes, BLOQUEAR execução.

```javascript
if (task.dependencies && task.dependencies.length > 0) {
  console.log(`\n🔗 Validando ${task.dependencies.length} dependência(s)...`)

  const blockers = []
  const completed = []

  for (const depId of task.dependencies) {
    const depTask = backlog_task_get(depId)

    if (!depTask) {
      console.warn(`   ⚠️ ${depId} não encontrada (pode ter sido deletada)`)
      continue
    }

    if (depTask.status !== "Done") {
      blockers.push({
        id: depId,
        title: depTask.title,
        status: depTask.status
      })
    } else {
      completed.push(depId)
    }
  }

  // Reportar dependências concluídas
  if (completed.length > 0) {
    console.log(`   ✅ ${completed.length} dependência(s) já concluída(s):`)
    completed.forEach(depId => {
      const depTask = backlog_task_get(depId)
      console.log(`      - ${depId}: ${depTask.title}`)
    })
  }

  // SE houver blockers, BLOQUEAR execução
  if (blockers.length > 0) {
    console.error("\n❌ BLOCKED: Dependências pendentes detectadas!")
    console.error("\n📋 Tasks que precisam ser concluídas primeiro:")
    blockers.forEach(b => {
      const statusEmoji = {
        "To Do": "📝",
        "In Progress": "🔄",
        "In Review": "👀",
        "Blocked": "🚫"
      }[b.status] || "❓"

      console.error(`   ${statusEmoji} **${b.id}**: ${b.title}`)
      console.error(`      Status: ${b.status}`)
    })

    console.error("\n🔧 Ações necessárias:")
    console.error("   1. Executar as tasks dependentes primeiro:")
    blockers.forEach(b => {
      console.error(`      /spec-execute ${b.id}`)
    })
    console.error("\n   2. OU remover dependência se desnecessária:")
    console.error(`      backlog_task_edit("${task.id}", {`)
    console.error(`        remove_dependencies: ["${blockers[0].id}"]`)
    console.error(`      })`)

    // BLOQUEAR execução
    throw new Error(`Task ${task.id} está BLOQUEADA por ${blockers.length} dependência(s) pendente(s). Execute as tasks listadas acima primeiro.`)
  }

  console.log("\n✅ Todas as dependências estão validadas!")
}
```

### 📋 Fase 3: Ler e Seguir Plan (OBRIGATÓRIO)

**CRÍTICO**: Ler o Plan da task e seguir a estratégia de implementação documentada.

```javascript
if (task.plan) {
  console.log("\n📋 **Plan de Implementação Encontrado:**")
  console.log("─".repeat(60))
  console.log(task.plan)
  console.log("─".repeat(60))

  // Analisar estrutura do plan
  const planLines = task.plan.split('\n')
  const sections = planLines.filter(line => line.startsWith('##'))

  console.log(`\n✋ O Plan contém ${sections.length} seções de implementação`)

  // Exibir passos principais
  console.log("\n🎯 **Passos Identificados no Plan:**")
  sections.forEach((section, index) => {
    const cleanSection = section.replace(/^##\s*/, '').trim()
    console.log(`   ${index + 1}. ${cleanSection}`)
  })

  // Perguntar confirmação (opcional)
  console.log("\n✅ Seguir este plan durante implementação?")

} else {
  console.log("\n⚠️ Esta task NÃO possui um Plan de Implementação.")
  console.log("   Recomendado criar um Plan ANTES de implementar:")
  console.log(`\n   backlog_task_edit("${task.id}", {`)
  console.log(`     plan: \``)
  console.log(`   ## Estratégia de Implementação`)
  console.log(`   ### Passo 1: ...`)
  console.log(`   ### Passo 2: ...`)
  console.log(`   \``)
  console.log(`   })`)

  // Opcional: Bloquear execução sem plan
  // if (complexityScore > 5) {
  //   throw new Error("Plan OBRIGATÓRIO para tasks com complexidade > 5")
  // }
}
```

### Fase 4: Leitura do Plan (Spec)

**⚠️ IMPORTANTE: Specs são os PLANS das tasks (campo `plan`)**

```javascript
// A Spec está no CAMPO PLAN da task (não é arquivo separado)
let planContent = task.plan || ""

// Se for subtask sem plan próprio, buscar na parent task
if (!planContent && task.parent) {
  const parentTask = backlog_task_get(task.parent)
  planContent = parentTask.plan || ""
}

// Se ainda não encontrou, avisar
if (!planContent) {
  console.warn("⚠️ Esta task não possui um Plan (Spec) no campo 'plan'.")
  console.warn("   Recomendado criar um Plan antes de implementar.")
}
```

**NOTA: Distinção entre Specs e Documentos**

- **Spec (Plan)** = Campo `plan` da task (estratégia de implementação)
- **Documentos** = Artefatos permanentes em `docs/standards/*.backlog` (constituição, padrões)

### Fase 5: Atualizar Status para "In Progress"

```javascript
backlog_task_update(task.id, {
  status: "In Progress",
  notes: task.notes + `\n\n## 🚀 Início da Execução (${timestamp})\n` +
         `Iniciada por @Claude\n`
})
```

### 🚨 Fase 6: Gerenciamento de Subtarefas (OBRIGATÓRIO)

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
      `[ ] Implementação conforme Plan (Spec)`,
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

### 🚨 Fase 7: Implementação com Subagentes (OU Delegar ao Gemini)

#### ⚠️ REGRA DE OURO: PASSAR CONTEXTO COMPLETO ⚠️

**NUNCA** resuma a spec para o subagente. **SEMPRE** passe o CONTEÚDO INTEGRAL.

#### 1. Escolher Especialista

- **Claude (Sonnet)** para orquestração e testes
- **Gemini-3-Flash** para codificação intensiva (via `gemini-orchestrator`)

#### 2. OBRIGATÓRIO: Passar Contexto COMPLETO

**NUNCA** faça isso:
```javascript
// ❌ ERRADO - Resumo vago
`Implemente a subtask ${task.id}.`
```

**SEMPRE** faça isso:
```javascript
// ✅ CORRETO - Contexto COMPLETO
const planContent = task.plan || parentTask.plan || ""

const promptParaAgente = `
# Task: ${task.title}

## Plan (Spec) COMPLETO:
${planContent}

## Todos os Acceptance Criteria:
${task.acceptance_criteria.map((ac, i) => `${i + 1}. ${ac}`).join('\n')}

## Contexto do Projeto:
${projectContext}

## Padrões Conhecidos:
${memoryPatterns}

## Implementar:
- Seguir 100% do Plan acima
- NÃO resumir requisitos
- NÃO omitir detalhes
- Validar TODOS os ACs antes de finalizar
`
```

**Por que contexto COMPLETO é OBRIGATÓRIO?**

- ✅ Subagente tem TODOS os requisitos
- ✅ Nada é perdido em resumos
- ✅ ACs podem ser validados corretamente
- ✅ Implementação segue o Plan (Spec) exatamente

#### 3. ⚠️ OBRIGATÓRIO: Especificar Arquivos Permitidos

**CRÍTICO**: SEMPRE especificar quais arquivos o agente Gemini PODE e NÃO PODE mexer para evitar sobreposição de tarefas.

```javascript
// ✅ CORRETO - Especificar arquivos explicitamente
const promptParaAgente = `
# Task: ${task.title}

## 📁 ARQUIVOS QUE VOCÊ PODE MODIFICAR:
- src/auth/models.ts
- src/auth/services.ts
- src/auth/middleware.ts

## 🚫 ARQUIVOS PROIBIDOS (NÃO MODIFICAR):
- src/auth/routes.ts (outro agente está responsável)
- src/auth/controllers.ts (outro agente está responsável)
- src/main.ts (NÃO modificar sem permissão)

## ⚠️ REGRA:
- MODIFICAR APENAS os arquivos listados em "ARQUIVOS PERMITIDOS"
- SE precisar modificar arquivo proibido, PEÇA PERMISSÃO PRIMEIRO
- NUNCA modifique arquivos que outros agentes estão usando simultaneamente

## Implementação:
...
`
```

**Por que especificar arquivos é OBRIGATÓRIO?**

- ✅ **Evita conflitos**: Múltiplos agentes não modificam o mesmo arquivo
- ✅ **Delimitação clara**: Cada agente sabe exatamente o que pode tocar
- ✅ **Paralelização**: Diferentes agentes podem trabalhar em paralelo sem conflito
- ✅ **Segurança**: Arquivos críticos (main.ts, config) não são modificados acidentalmente

**Como identificar quais arquivos especificar:**

```javascript
// 1. Ler o Plan da task
const planContent = task.plan

// 2. Extrair arquivos mencionados no Plan
const arquivosMencionados = planContent.match(/[\w-/]+\.(ts|js|tsx|jsx)/g) || []

// 3. Listar arquivos permitidos
const arquivosPermitidos = [
  ...arquivosMencionados,
  // Arquivos relacionados à task
]

// 4. Listar arquivos proibidos (se necessário)
const arquivosProibidos = [
  // Arquivos que outros agentes estão usando
  "src/routes.ts",  // Outro agente
  "src/config.ts",   // Crítico
]

// 5. Montar prompt
promptParaAgente += `
## 📁 ARQUIVOS PERMITIDOS:
${arquivosPermitidos.map(f => `- ${f}`).join('\n')}

## 🚫 ARQUIVOS PROIBIDOS:
${arquivosProibidos.map(f => `- ${f}`).join('\n')}
`
```

**Exemplo Prático:**

```javascript
// Task: Implementar Models e Services de Autenticação

const promptParaGemini = `
# Task: Implementar Models e Services de Autenticação

## 📁 ARQUIVOS QUE VOCÊ PODE MODIFICAR:
- src/auth/models/user.ts
- src/auth/models/session.ts
- src/auth/services/auth.service.ts
- src/auth/services/token.service.ts

## 🚫 ARQUIVOS PROIBIDOS (NÃO MODIFICAR):
- src/auth/routes/auth.routes.ts (agente task-12)
- src/auth/controllers/auth.controller.ts (agente task-12)
- src/auth/middleware/auth.middleware.ts (agente task-13)
- src/main.ts (ARQUIVO CRÍTICO - proibido)

## ⚠️ INSTRUÇÕES:
1. Criar/modificar APENAS os arquivos listados em "PERMITIDOS"
2. SE precisar de routes/controllers/middleware, AVISE PRIMEIRO
3. NUNCA modifique main.ts

## Plan:
...
`
```

#### 4. 🤖 REGRAS PARA AGENTES GEMINI (OBRIGATÓRIO)

**⚠️ CONDICIONAL: Aplica-se APENAS quando delegando para agentes Gemini**

**Quando delegar uma task para um agente Gemini (via `gemini-orchestrator`), o agente DEVE:**

**A) AO ASSUMIR A TASK (Início):**
```javascript
// Agente Gemini DEVE executar IMEDIATAMENTE:
backlog_task_update(task.id, {
  status: "In Progress",
  notes: task.notes + `\n\n## 🤖 Assumida por Gemini-3-Flash\n${timestamp}\nVia gemini-orchestrator\n`
})
```

**B) AO CONCLUIR A TASK (Fim):**
```javascript
// Agente Gemini DEVE executar ANTES de finalizar:
// 1. Marcar ACs como concluídos
backlog_task_edit(task.id, {
  check_acceptance_criteria: [1, 2, 3]  // Todos os ACs implementados
})

// 2. Atualizar status
backlog_task_update(task.id, {
  status: "Done",  // OU "In Review" se requer revisão
  notes: task.notes + `\n\n## ✅ Concluída por Gemini-3-Flash\n${timestamp}\nTodos os ACs marcados como [x]\nBacklog atualizado.\n`
})

// 3. Informar explicitamente
console.log("✅ Task concluída E backlog atualizado!")
```

**C) REPORTAR OBRIGATORIAMENTE:**
```javascript
// Agente Gemini DEVE sempre informar ao final:
"✅ Task ${task.id} concluída com sucesso!
📋 Backlog atualizado:
   - Status: Done
   - ACs: Todos marcados como [x]
   - Notes: Progresso registrado"
```

**⚠️ POR QUE ESSA REGRA É OBRIGATÓRIA?**

- ✅ **Rastreio**: Sabe-se que Gemini está trabalhando na task
- ✅ **Transparência**: Progresso visível no backlog
- ✅ **Comunicação**: Claude Code sabe o status atual
- ✅ **Não duplicidade**: Evita atualizações manuais

**EXEMPLO COMPLETO DE WORKFLOW COM GEMINI:**

```javascript
// 1. Claude Code delega para Gemini
/gemini-orchestrator "Implementar task-10"

// 2. Gemini ASSUME a task (executa automaticamente)
backlog_task_update("task-10", {
  status: "In Progress",
  notes: "## 🤖 Assumida por Gemini-3-Flash\n2026-01-13 10:30\nVia gemini-orchestrator"
})

// 3. Gemini IMPLEMENTA

// 4. Gemini CONCLUI (executa automaticamente)
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1, 2, 3, 4, 5]
})

backlog_task_update("task-10", {
  status: "Done",
  notes: "...✅ Concluída por Gemini-3-Flash\n2026-01-13 12:45\nACs: 5/5 completos\nBacklog atualizado."
})

// 5. Gemini REPORTA
"✅ Task task-10 concluída!
📋 Backlog atualizado:
   - Status: Done
   - ACs: 5/5 [x]
   - Implementação completa"
```

**⚠️ SE GEMINI NÃO ATUALIZAR O BACKLOG:**

```javascript
// Claude Code DEVE cobrar:
"⚠️ Gemini concluiu a task mas NÃO atualizou o backlog!
   Por favor, execute:
   1. backlog_task_update('task-10', { status: 'Done' })
   2. backlog_task_edit('task-10', { check_acceptance_criteria: [1,2,3,4,5] })"
```

### Fase 8: Atualizar Notas Progressivamente

**Durante a execução, registrar observações incrementalmente:***

```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 📝 Atualização (${timestamp})\n` +
         `- Implementado módulo de autenticação\n` +
         `- Testes unitários adicionados`
})
```

### Fase 9: Marcar ACs como Concluídos (OBRIGATÓRIO)

#### ⚠️ USE `task_edit` PARA MARCAR ACS INDIVIDUAIS ⚠️

**NUNCA** edite o campo `acceptance_criteria` completo. **SEMPRE** use `backlog_task_edit` para marcar ACs individualmente.

**Marcar AC específico como concluído:**
```javascript
// Durante implementação, marcar AC #1 como [x]
backlog_task_edit(task.id, {
  check_acceptance_criteria: [1]  // Marca AC #1 como [x]
})
```

**Marcar múltiplos ACs:**
```javascript
// Marcar ACs #1 e #3 como [x]
backlog_task_edit(task.id, {
  check_acceptance_criteria: [1, 3]
})
```

**Desmarcar AC (se necessário):**
```javascript
// Se precisar reabrir um AC
backlog_task_edit(task.id, {
  uncheck_acceptance_criteria: [2]  // Marca AC #2 como [ ]
})
```

**Adicionar novo AC durante execução:**
```javascript
// Se descobrir requisito faltando
backlog_task_edit(task.id, {
  add_acceptance_criteria: ["[ ] Novo AC descoberto durante implementação"]
})
```

**Remover AC inválido:**
```javascript
// Se AC estiver duplicado ou incorreto
backlog_task_edit(task.id, {
  remove_acceptance_criteria: [5]  // Remove AC #5
})
```

**Adicionar dependências:**
```javascript
// Se descobrir que precisa de outra task
backlog_task_edit(task.id, {
  add_dependencies: ["task-20", "task-25"]
})
```

#### Exemplo Prático de Marcação de ACs

```javascript
// Implementando feature de autenticação

// 1. Após criar models User e Session
backlog_task_edit(task.id, {
  check_acceptance_criteria: [1]
})

// 2. Após implementar JWT service
backlog_task_edit(task.id, {
  check_acceptance_criteria: [2]
})

// 3. Após criar middleware
backlog_task_edit(task.id, {
  check_acceptance_criteria: [3]
})

// 4. Verificar progresso
const updatedTask = backlog_task_get(task.id)
const completed = updatedTask.acceptance_criteria.filter(ac => ac.startsWith("[x]")).length
console.log(`Progresso: ${completed}/${updatedTask.acceptance_criteria.length} ACs completados`)
```

#### Por que `task_edit` é OBRIGATÓRIO?

- ✅ **Rastreio preciso** - Sabe exatamente qual AC foi completado
- ✅ **Sem conflitos** - Evita sobrescrever ACs de outras sessões
- ✅ **Validação fácil** - `/spec-review` pode contar ACs [x] automaticamente
- ✅ **Histórico preservado** - Notas incrementais mostram evolução

### Fase 10: Finalização da Subtask

Mudar status para "In Review" e sugerir `/spec-review`.

---

## Regras de Ouro

1. **Dependências Primeiro**: NUNCA ignorar dependências bloqueadas.
2. **Spec é Lei**: Implementação DEVE seguir 100% a Spec.
3. **Notas Incrementais**: Documente o progresso e decisões importantes.
4. **MCP-Only**: PROIBIDO editar arquivos .backlog ou .md do backlog manualmente.