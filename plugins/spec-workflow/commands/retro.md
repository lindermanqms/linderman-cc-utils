---
name: spec-workflow-retro
description: Finaliza uma task após review aprovada, verifica ACs, atualiza notas com resumo final, reporta progresso de milestones e consolida memória assíncronamente.
version: 2.0.0
category: workflow
triggers:
  - "/spec-retro"
  - "finalizar task"
  - "retrospectiva"
  - "fechar task"
arguments:
  - name: task-id
    description: ID da task a ser finalizada (ex: task-1)
    required: true
---

# Spec-Retro: Retrospectiva e Finalização de Task

Este comando encerra o ciclo de vida de uma task, garantindo validação completa, resumo final estruturado, progresso de milestones e consolidação de conhecimento no Memory MCP.

## Procedimento Principal (Síncrono)

### Fase 1: Validação Pré-Fechamento (NOVO - Checklist Obrigatório)

**CRÍTICO**: Verificar que TODOS os requisitos foram atendidos antes de fechar:

```javascript
const task = backlog_task_get("{{task-id}}")

console.log("🔍 Validando pré-requisitos para fechamento...")

// Checklist obrigatório:
const validations = {
  acsCompleted: task.acceptance_criteria.every(ac => ac.startsWith("[x]")),
  reviewApproved: task.notes?.includes("Review APPROVED") || task.status === "In Review",
  codeCommitted: null,  // Verificar via git log se aplicável
  testsPass: null       // Verificar via test runner se aplicável
}

// 1. TODOS os ACs marcados como [x]
if (!validations.acsCompleted) {
  const pendingACs = task.acceptance_criteria.filter(ac => ac.startsWith("[ ]"))

  console.error("❌ Não é possível finalizar: ACs incompletos!")
  console.log("\n📋 ACs pendentes:")
  pendingACs.forEach(ac => console.log(`   ${ac}`))
  console.log("\n🔧 Marque os ACs via:")
  console.log(`   backlog task edit ${task.id} --check-ac "texto"`)

  return // BLOQUEAR fechamento
}

// 2. Task passou por /spec-review com APPROVED
if (!validations.reviewApproved) {
  console.error("❌ Não é possível finalizar: Task não foi revisada!")
  console.log("   Execute /spec-review ${task.id} primeiro")

  return // BLOQUEAR fechamento
}

// 3. Código commitado no Git (se aplicável)
console.log("\n⚠️  Certifique-se de que:")
console.log("   - Código foi commitado no Git")
console.log("   - Testes estão passando")
console.log("   - Build está funcionando")

// Perguntar confirmação ao usuário
// ...

console.log("\n✅ Pré-requisitos validados! Prosseguindo com fechamento...")
```

### Fase 2: Atualizar Task com Resumo Final (NOVO)

**Adicionar resumo estruturado no campo `notes`:**

```javascript
// Obter informações de contexto
const gitCommits = // Buscar commits relacionados via git log
const modulesPaths = // Arquivos modificados
const testsAdded = // Testes criados/atualizados

const resumoFinal = `

## ✅ Conclusão da Task (${timestamp})

**Status**: Done
**Executada por**: @Claude
**Tempo total**: ${calcularTempo(task.creation_date, timestamp)}

### Resultados Alcançados

**Feature implementada conforme Spec:**
- ✅ Todos os ${task.acceptance_criteria.length} Acceptance Criteria validados
- ✅ Review aprovada em ${dataReview}
- ✅ Conformidade com Constituição verificada

**Módulos/Arquivos Implementados:**
${modulesPaths.map(p => `- ${p}`).join("\n")}

**Testes Adicionados:**
${testsAdded.length > 0 ? testsAdded.map(t => `- ${t}`).join("\n") : "- Nenhum teste adicional necessário"}

**Commits Relacionados:**
${gitCommits.map(c => `- ${c.hash}: ${c.message}`).join("\n")}

### Lições Aprendidas

${extrairLiçõesDoContexto()}

**Decisões Técnicas Tomadas:**
- ${decisão1}
- ${decisão2}

**Desafios Enfrentados:**
- ${desafio1} → Solução: ${solução1}
- ${desafio2} → Solução: ${solução2}

**Oportunidades de Melhoria:**
- ${melhoria1}
- ${melhoria2}

### Referências

- Spec: ${specPath}
- Constituição: backlog/docs/doc-001...
- ADRs relacionadas: ${adrsLista || "Nenhuma"}
`

backlog_task_update(task.id, {
  status: "Done",
  notes: task.notes + resumoFinal
})
```

### Fase 3: Reportar Progresso de Milestones (NOVO)

**Se a task fazia parte de um milestone:**

```javascript
if (task.milestone) {
  // Listar todas as tasks do milestone
  const milestoneTasks = backlog_task_list({ milestone: task.milestone })

  const totalTasks = milestoneTasks.length
  const doneTasks = milestoneTasks.filter(t => t.status === "Done").length
  const progress = (doneTasks / totalTasks * 100).toFixed(1)

  console.log(`\n🎯 Progresso do Milestone "${task.milestone}":`)
  console.log(`   ${doneTasks}/${totalTasks} tasks concluídas (${progress}%)`)

  // Listar tasks pendentes do milestone
  const pendingTasks = milestoneTasks.filter(t => t.status !== "Done")
  if (pendingTasks.length > 0) {
    console.log("\n📋 Tasks restantes no milestone:")
    pendingTasks
      .sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority])
      .slice(0, 5)  // Mostrar top 5
      .forEach(t => console.log(`   - ${t.id}: ${t.title} (${t.priority})`))
  }

  if (progress === 100) {
    console.log(`\n🎉 MILESTONE COMPLETO! "${task.milestone}" finalizado!`)
  }
}
```

### Fase 4: Relatório de Conclusão

**Gerar relatório estruturado:**

```markdown
✅ **Task Finalizada com Sucesso!**

📋 **Task**: {{task-id}} - {{task.title}}
   - Status: Done ✅
   - Prioridade: {{task.priority}}
   - Milestone: {{task.milestone}}
   - Labels: {{task.labels.join(", ")}}

🎯 **Milestone Progress**: {{milestoneName}}
   - {{doneTasks}}/{{totalTasks}} tasks concluídas ({{progress}}%)
   {{se completo: "🎉 MILESTONE COMPLETO!"}}

✅ **Acceptance Criteria**: {{N}} critérios atendidos
   {{lista resumida de ACs principais}}

🔨 **Implementação**:
   - Módulos: {{N arquivos}} modificados
   - Testes: {{N testes}} adicionados/atualizados
   - Commits: {{N commits}} realizados

📝 **Resumo Final**: Adicionado ao campo notes da task
   - Lições aprendidas documentadas
   - Decisões técnicas registradas
   - Referências completas incluídas

🧠 **Basic Memory**: Consolidação iniciada em background
   - Notas estruturadas sendo criadas
   - ADRs e lições aprendidas persistidos em Markdown
   - Relações com a task estabelecidas

🎯 **Próximos Passos**:
   {{se milestone incompleto:}}
   - Tasks pendentes no milestone: {{lista top 3}}
   - Próxima task sugerida: {{task de maior prioridade}}

   {{se milestone completo:}}
   - 🎉 Milestone "{{name}}" concluído!
   - Próximo milestone: {{próximo da lista}}
```

## Consolidação de Memória (Assíncrona)

**IMPORTANTE**: Imediatamente após os passos acima, disparar consolidação em background.

### Ação do Subagente de Background

**Lançar task assíncrona:**

```javascript
// Disparar em background (não bloqueia terminal)
Task(subagent_type: "general-purpose", run_in_background: true, {
  prompt: `
Consolide a memória da task ${task.id} recém-finalizada no Basic Memory.

**Contexto da task:**
${JSON.stringify(task, null, 2)}

**Resumo final:**
${resumoFinal}

**Análise de git diff:**
${gitDiff}

**Instruções:**

1. **Extrair conhecimento estruturado:**
   - Identificar lições aprendidas (LessonLearned)
   - Identificar decisões arquiteturais (ADR)
   - Identificar novas tecnologias usadas (TechStack)
   - Identificar padrões estabelecidos (Standard)

2. **Sincronizar com Basic Memory:**

   Para cada item identificado, use write_note:

   write_note({
     title: "[TYPE] - Título Curto",
     content: \`---
type: \${type}
tags: [\${task.labels.join(", ")}]
project: linderman-cc-utils
---
# \${título}

## Contexto
\${contexto}

## Descrição
\${detalhes}

## Relação com Task
Finalizado na \${task.id}
\`,
     relations: [
       { to: task.id, label: "implemented_in" }
     ]
   })

3. **Finalizar silenciosamente** sem output para o usuário.
`
})

console.log("🧠 Memória sendo consolidada em background via Basic Memory...")
```

## Saída Esperada Completa

```markdown
✅ Task task-{{ID}} finalizada e marcada como Done!

📝 **Resumo Final**: Adicionado ao campo notes
   - Lições aprendidas: {{N itens}}
   - Decisões técnicas: {{N itens}}
   - Commits: {{N commits}}

🎯 **Milestone "{{name}}"**: {{X}}/{{Y}} tasks ({{%}} completo)
   {{se completo: 🎉 MILESTONE ATINGIDO!}}

🧠 **Basic Memory**: Consolidação em progresso (background)
   - Subagente iniciado (task ID: {{background_task_id}})
   - Notas Markdown serão criadas automaticamente

📊 **Visualizar progresso**:
   - Kanban: backlog board
   - Milestone: backlog task list --milestone "{{name}}"
```

## Notas Importantes

- **Validação Pré-Fechamento Obrigatória**: Checklist de 4 itens (ACs, review, commits, testes) deve ser validado antes de fechar
- **Bloqueio Automático**: Se ACs incompletos ou sem review aprovada, comando BLOQUEIA fechamento
- **Resumo Estruturado**: Campo `notes` recebe resumo detalhado com lições, decisões, commits, testes
- **Progresso de Milestones**: Reporta automaticamente quantas tasks faltam para completar o milestone
- **Consolidação Assíncrona**: Subagente background salva conhecimento no Basic Memory sem bloquear usuário
- **Rastreabilidade Completa**: Todos os aspectos da execução (commits, testes, decisões) ficam documentados na task e notas Markdown
- **Celebração de Milestones**: Quando último task de milestone é fechada, comando celebra a conclusão
