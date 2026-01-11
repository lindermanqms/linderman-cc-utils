---
name: spec-board
description: Exibe quadro Kanban interativo do backlog no terminal, mostrando tasks organizadas por status (To Do, In Progress, In Review, Done, Blocked)
version: 1.0.0
category: workflow
triggers:
  - "/spec-board"
  - "mostrar quadro kanban"
  - "visualizar backlog"
  - "ver quadro de tarefas"
  - "board"
---

# Spec-Board: Visualização Kanban do Backlog

Este comando exibe o quadro Kanban interativo do backlog no terminal, permitindo visualizar todas as tasks organizadas por status e filtrar por labels, milestones, prioridades e assignees.

## Workflow de Visualização

### Passo 1: Executar Comando CLI do Backlog

**Comando básico (sem filtros):**

```bash
backlog board
```

**Com filtros:**

```bash
# Filtrar por milestone
backlog board --milestone "v1.0 - MVP"

# Filtrar por label
backlog board --label backend

# Filtrar por assignee
backlog board --assignee "@Claude"

# Filtrar por prioridade
backlog board --priority high

# Combinar filtros
backlog board --milestone "v1.0 - MVP" --priority high --label backend
```

### Passo 2: Capturar e Processar Output

**O comando `backlog board` retorna um quadro Kanban interativo no terminal:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          BACKLOG KANBAN BOARD                                │
│                       Project: linderman-cc-utils                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   TO DO (3)  │ IN PROGRESS  │  IN REVIEW   │    DONE (5)  │  BLOCKED (1) │
│              │     (2)      │     (1)      │              │              │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│              │              │              │              │              │
│ task-10      │ task-5       │ task-3       │ task-1       │ task-7       │
│ Sistema de   │ Integração   │ Refatoração  │ Setup inicial│ Migração DB  │
│ Autenticação │ com Redis    │ de Auth      │              │              │
│ [HIGH]       │ [HIGH]       │ [MEDIUM]     │ [CRITICAL]   │ [MEDIUM]     │
│ @Claude      │ @Claude      │ @Claude      │ @Claude      │ @Claude      │
│ v1.0-MVP     │ v1.0-MVP     │ v1.0-MVP     │ v1.0-MVP     │ v2.0         │
│              │              │              │              │ ⚠️ Blocked   │
│              │              │              │              │              │
│ task-11      │ task-6       │              │ task-2       │              │
│ Configurar   │ Implementar  │              │ Criar docs   │              │
│ CI/CD        │ Rate Limit   │              │              │              │
│ [MEDIUM]     │ [HIGH]       │              │ [LOW]        │              │
│ @Claude      │ @Claude      │              │ @Claude      │              │
│ v1.0-MVP     │ v1.0-MVP     │              │ v1.0-MVP     │              │
│              │              │              │              │              │
│ task-12      │              │              │ task-4       │              │
│ Testes E2E   │              │              │ Config Repo  │              │
│ [LOW]        │              │              │              │              │
│ @Claude      │              │              │ @Claude      │              │
│ v2.0         │              │              │ v1.0-MVP     │              │
│              │              │              │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘

Ações disponíveis:
  ↑/↓/←/→  Navegar entre tasks
  Enter    Ver detalhes da task
  m        Mover task para outra coluna
  f        Filtrar (labels/milestone/assignee/priority)
  r        Atualizar board
  q        Sair

Pressione 'h' para ajuda completa
```

### Passo 3: Apresentar ao Usuário (Formatado)

**Processar o output do CLI e apresentar de forma estruturada:**

```javascript
// Executar comando via Bash
const boardOutput = await execCommand("backlog board --format json")

// Processar JSON retornado
const board = JSON.parse(boardOutput)

// Apresentar ao usuário de forma formatada
console.log("📊 **Quadro Kanban do Backlog**")
console.log(`   Projeto: ${board.project}`)
console.log(`   Última atualização: ${board.lastUpdate}`)
console.log("")

// Para cada coluna do board
for (const status of ["To Do", "In Progress", "In Review", "Done", "Blocked"]) {
  const tasks = board.tasks.filter(t => t.status === status)

  console.log(`\n### ${status.toUpperCase()} (${tasks.length} tasks)`)
  console.log("")

  if (tasks.length === 0) {
    console.log("   _Nenhuma task_")
    continue
  }

  tasks.forEach(task => {
    const priorityEmoji = {
      critical: "🔴",
      high: "🟠",
      medium: "🟡",
      low: "🟢"
    }[task.priority]

    console.log(`   ${priorityEmoji} **${task.id}**: ${task.title}`)
    console.log(`      Prioridade: ${task.priority.toUpperCase()}`)
    console.log(`      Assignee: ${task.assignee}`)
    if (task.milestone) {
      console.log(`      Milestone: ${task.milestone}`)
    }
    if (task.labels.length > 0) {
      console.log(`      Labels: ${task.labels.join(", ")}`)
    }
    if (task.dependencies && task.dependencies.length > 0) {
      console.log(`      Dependências: ${task.dependencies.join(", ")}`)
    }
    if (task.status === "Blocked") {
      console.log(`      ⚠️ **BLOQUEADA**`)
    }
    console.log("")
  })
}
```

### Passo 4: Estatísticas e Insights (Opcional)

**Adicionar análise quantitativa:**

```javascript
// Calcular estatísticas
const stats = {
  total: board.tasks.length,
  byStatus: {},
  byPriority: {},
  byMilestone: {},
  blocked: board.tasks.filter(t => t.status === "Blocked").length
}

board.tasks.forEach(task => {
  stats.byStatus[task.status] = (stats.byStatus[task.status] || 0) + 1
  stats.byPriority[task.priority] = (stats.byPriority[task.priority] || 0) + 1
  if (task.milestone) {
    stats.byMilestone[task.milestone] = (stats.byMilestone[task.milestone] || 0) + 1
  }
})

// Apresentar
console.log("\n---")
console.log("\n## 📈 Estatísticas do Backlog")
console.log("")
console.log(`**Total de tasks:** ${stats.total}`)
console.log("")
console.log("**Por Status:**")
Object.entries(stats.byStatus).forEach(([status, count]) => {
  const percentage = ((count / stats.total) * 100).toFixed(1)
  console.log(`   - ${status}: ${count} tasks (${percentage}%)`)
})
console.log("")
console.log("**Por Prioridade:**")
Object.entries(stats.byPriority).forEach(([priority, count]) => {
  console.log(`   - ${priority.toUpperCase()}: ${count} tasks`)
})
console.log("")
if (Object.keys(stats.byMilestone).length > 0) {
  console.log("**Por Milestone:**")
  Object.entries(stats.byMilestone).forEach(([milestone, count]) => {
    console.log(`   - ${milestone}: ${count} tasks`)
  })
}
console.log("")
if (stats.blocked > 0) {
  console.log(`⚠️ **Tasks bloqueadas:** ${stats.blocked}`)
}
```

## Filtros Disponíveis

### Por Milestone

```bash
/spec-board --milestone "v1.0 - MVP"
```

Mostra apenas tasks do milestone especificado.

### Por Label

```bash
/spec-board --label backend
```

Mostra apenas tasks com o label especificado.

### Por Assignee

```bash
/spec-board --assignee "@Claude"
```

Mostra apenas tasks atribuídas ao assignee especificado.

### Por Prioridade

```bash
/spec-board --priority high
```

Mostra apenas tasks com a prioridade especificada (critical, high, medium, low).

### Combinação de Filtros

```bash
/spec-board --milestone "v1.0 - MVP" --priority high
```

Combina múltiplos filtros para refinar a visualização.

## Saída Esperada Completa

```markdown
📊 **Quadro Kanban do Backlog**
   Projeto: linderman-cc-utils
   Última atualização: 2026-01-09 15:30:00

### TO DO (3 tasks)

   🟠 **task-10**: Sistema de Autenticação JWT
      Prioridade: HIGH
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: backend, security, api

   🟡 **task-11**: Configurar Pipeline de CI/CD
      Prioridade: MEDIUM
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: devops, automation

   🟢 **task-12**: Testes E2E
      Prioridade: LOW
      Assignee: @Claude
      Milestone: v2.0
      Labels: testing

### IN PROGRESS (2 tasks)

   🟠 **task-5**: Integração com Redis para sessões
      Prioridade: HIGH
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: backend, cache
      Dependências: task-1

   🟠 **task-6**: Implementar Rate Limiting
      Prioridade: HIGH
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: backend, security

### IN REVIEW (1 task)

   🟡 **task-3**: Refatoração do Módulo de Autenticação
      Prioridade: MEDIUM
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: backend, refactor

### DONE (5 tasks)

   🔴 **task-1**: Setup Inicial do Projeto
      Prioridade: CRITICAL
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: setup

   🟢 **task-2**: Criar Documentação Base
      Prioridade: LOW
      Assignee: @Claude
      Milestone: v1.0 - MVP
      Labels: documentation

   ... (outras 3 tasks)

### BLOCKED (1 task)

   🟡 **task-7**: Migração de Banco de Dados
      Prioridade: MEDIUM
      Assignee: @Claude
      Milestone: v2.0
      Labels: backend, database
      Dependências: task-15
      ⚠️ **BLOQUEADA**

---

## 📈 Estatísticas do Backlog

**Total de tasks:** 12

**Por Status:**
   - To Do: 3 tasks (25.0%)
   - In Progress: 2 tasks (16.7%)
   - In Review: 1 task (8.3%)
   - Done: 5 tasks (41.7%)
   - Blocked: 1 task (8.3%)

**Por Prioridade:**
   - CRITICAL: 1 task
   - HIGH: 4 tasks
   - MEDIUM: 4 tasks
   - LOW: 3 tasks

**Por Milestone:**
   - v1.0 - MVP: 10 tasks
   - v2.0: 2 tasks

⚠️ **Tasks bloqueadas:** 1

---

## 🎯 Próximas Ações Sugeridas

Com base no quadro atual:
1. Priorizar task-10 (Sistema de Autenticação) - alta prioridade
2. Revisar task-3 (Refatoração) - aguardando review
3. Resolver bloqueio de task-7 (completar task-15 primeiro)
```

## Ações Interativas (CLI Nativo)

Quando executado diretamente no terminal (`backlog board`), o usuário pode:

- **Navegar**: Usar setas para mover entre tasks
- **Ver Detalhes**: Pressionar Enter para ver detalhes completos de uma task
- **Mover Tasks**: Pressionar 'm' para mover task entre colunas (atualiza status)
- **Filtrar**: Pressionar 'f' para aplicar filtros interativamente
- **Atualizar**: Pressionar 'r' para recarregar board
- **Sair**: Pressionar 'q' para sair

## Quando Usar?

- **Planejamento de Sprint**: Início de ciclo de desenvolvimento
- **Daily Standup**: Visualizar progresso diário
- **Revisão Semanal**: Analisar distribuição de tasks
- **Identificação de Gargalos**: Detectar acúmulo em colunas específicas
- **Priorização**: Visualizar prioridades e reordenar se necessário
- **Desbloqueio**: Identificar tasks bloqueadas rapidamente

## Notas Importantes

- **CLI Obrigatório**: Este comando requer que o CLI `backlog` esteja instalado e acessível
- **Validação**: Verificar se CLI está instalado antes de executar (via `/spec-init`)
- **Formato JSON**: Usar flag `--format json` para processar output programaticamente
- **Atualização em Tempo Real**: O board reflete estado atual do `Backlog.md`
- **Filtros Múltiplos**: Combinar filtros para análises específicas
- **Visualização Complementar**: Usar junto com `backlog browser` para interface web
- **Performance**: Com muitas tasks (>50), considerar filtrar por milestone ou label
- **Estatísticas**: Análise quantitativa ajuda a identificar distribuição de trabalho
- **Tasks Bloqueadas**: Sempre revisar tasks bloqueadas para resolver dependências
- **Integração com Workflow**: Usar após `/spec-plan` para visualizar novas tasks no contexto geral
