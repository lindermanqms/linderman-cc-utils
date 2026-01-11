---
name: spec-replan
description: Reestrutura o backlog em resposta a uma mudança crítica de cenário. Analisa impacto em dependências e milestones, identifica tarefas obsoletas para arquivar, specs que precisam de reescrita e novas lacunas.
version: 2.0.0
category: workflow
triggers:
  - "/spec-replan"
  - "replanejar"
  - "mudar plano"
  - "reestruturar backlog"
arguments:
  - name: change-description
    description: Descrição da mudança crítica que motiva o replanejamento
    required: true
---

# Spec-Replan: Reestruturação Estratégica do Backlog

Este comando é utilizado quando o cenário do projeto muda drasticamente (mudança de tecnologia, novos requisitos de negócio, pivot de arquitetura) e o plano atual não é mais válido.

## Workflow de Replanejamento

### Fase 1: Triagem e Análise de Impacto

1. **Entenda a Mudança:** Analise profundamente a descrição fornecida: `{{change-description}}`.
2. **Audit do Backlog:**
   - Use `backlog_task_list` para identificar tarefas em aberto (`todo`, `in_progress`).
   - Identifique quais tarefas são diretamente impactadas pela mudança.
3. **Verificação da Constituição:**
   - Verifique se a mudança conflita com os padrões atuais (arquivos em `docs/standards/` ou `backlog/docs/`).

### Fase 2: Auditoria de Impacto (APRIMORADO)

**Verificar impacto em múltiplas dimensões:**

#### 2.1 Tasks com Dependências (NOVO)

```javascript
// Encontrar tasks que dependem de tasks identificadas como obsoletas
const obsoleteTasks = [] // tasks classificadas para arquivar
const impactedTasks = backlog_task_list().filter(t =>
  t.dependencies && t.dependencies.some(dep => obsoleteTasks.includes(dep))
)

console.log(`⚠️ ${impactedTasks.length} tasks possuem dependências de tasks obsoletas`)
impactedTasks.forEach(t => {
  console.log(`   - ${t.id}: ${t.title}`)
  console.log(`     Depende de: ${t.dependencies.filter(d => obsoleteTasks.includes(d)).join(", ")}`)
})
```

**Ações para tasks impactadas:**
- Remover dependências obsoletas
- Substituir por novas tasks (se aplicável)
- Bloquear task até resolução

#### 2.2 Milestones Afetados (NOVO)

```javascript
const allImpactedTasks = [...obsoleteTasks, ...mutantTasks]

// Listar milestones com tasks obsoletas/mutantes
const affectedMilestones = [...new Set(
  allImpactedTasks
    .filter(t => t.milestone)
    .map(t => t.milestone)
)]

console.log(`\n📊 Milestones afetados: ${affectedMilestones.length}`)

for (const milestone of affectedMilestones) {
  const milestoneTasks = backlog_task_list({ milestone })
  const obsoleteCount = milestoneTasks.filter(t => obsoleteTasks.includes(t.id)).length
  const mutantCount = milestoneTasks.filter(t => mutantTasks.includes(t.id)).length

  console.log(`\n🎯 Milestone "${milestone}":`)
  console.log(`   - Obsoletas: ${obsoleteCount}`)
  console.log(`   - Mutantes: ${mutantCount}`)
  console.log(`   - Impacto total: ${obsoleteCount + mutantCount}/${milestoneTasks.length} tasks`)
}
```

#### 2.3 Classificação de Sobrevivência

Para cada tarefa impactada, classifique-a em uma destas categorias:

- 🛑 **OBSOLETA (Archive):** A tarefa perdeu o sentido ou foi cancelada.
- ✏️ **MUTANTE (Update):** A tarefa ainda é necessária, mas seus Critérios de Aceite ou Spec precisam de revisão.
- ✨ **LACUNA (New):** O novo cenário exige novas tarefas que não estavam mapeadas.

### Fase 3: Relatório de Cirurgia (Surgery Report - APRIMORADO)

Apresente um plano de ação para o usuário aprovar:

```markdown
🚨 **Relatório de Impacto: Mudança de Cenário**

**Cenário Atualizado:** {{change-description}}

---

## 📊 Análise de Impacto

**Tasks Afetadas:**
- 🛑 Obsoletas: {{N tasks}} (serão arquivadas)
- ✏️ Mutantes: {{N tasks}} (requerem atualização)
- ✨ Lacunas: {{N novas tasks}} (precisam ser criadas)

**Dependências Impactadas:**
- {{N tasks}} possuem dependências de tasks obsoletas
- Ações necessárias: Remover ou substituir dependências

**Milestones Afetados:**
{{Para cada milestone:}}
- 🎯 **{{milestone-name}}**:
  - Obsoletas: {{N}} tasks
  - Mutantes: {{N}} tasks
  - Impacto: {{X%}} do milestone
  {{se impacto > 50%: "⚠️ MILESTONE CRITICAMENTE AFETADO"}}

---

## 1. Documentação (A Constituição)

- [ ] Atualizar `backlog/docs/doc-001 - Constituição do Projeto.md`
- [ ] Criar ADR via `backlog_decision_create` registrando mudança
- [ ] Atualizar padrões em `docs/standards/` (se aplicável)

---

## 2. Ações Destrutivas (Limpeza)

**🛑 Arquivar/Cancelar:**
{{Para cada obsoleta:}}
- `{{task-id}}`: {{task-title}}
  - Motivo: {{razão de cancelamento}}
  - Impacto: {{tasks dependentes se houver}}

---

## 3. Ações de Modificação (Refinamento)

**✏️ Atualizar Tasks e Specs:**
{{Para cada mutante:}}
- `{{task-id}}`: {{task-title}}
  - O que muda: {{descrição de mudanças}}
  - Novos ACs: {{lista se aplicável}}
  - Nova prioridade: {{se aplicável}}
  - Remover dependências: {{se aplicável}}

---

## 4. Ações Construtivas (Novas Tasks)

**✨ Criar:**
{{Para cada lacuna:}}
- `{{título-nova-task}}`
  - Descrição: {{descrição breve}}
  - Prioridade: {{prioridade sugerida}}
  - Milestone: {{milestone sugerido}}
  - Dependências: {{se aplicável}}

---

## 5. Ajustes de Dependências

**🔗 Dependências a Corrigir:**
{{Para cada task com dependência obsoleta:}}
- `{{task-id}}`: Remover dependência de `{{obsolete-task-id}}`
  {{se houver substituta: "Adicionar dependência de `{{new-task-id}}`"}}
```

### Fase 4: Execução do Plano (APRIMORADO)

Após a aprovação do usuário:

**1. Arquivar tasks obsoletas:**

```javascript
for (const taskId of obsoleteTasks) {
  backlog_task_archive(taskId)  // Arquiva em vez de deletar
  console.log(`   ✅ Arquivada: ${taskId}`)
}
```

**2. Atualizar tasks mutantes:**

```javascript
for (const task of mutantTasks) {
  backlog_task_update(task.id, {
    title: task.newTitle || task.title,
    acceptance_criteria: task.newACs || task.acceptance_criteria,
    plan: task.newPlan || task.plan,
    priority: task.newPriority || task.priority,
    labels: task.newLabels || task.labels,
    dependencies: task.newDependencies || task.dependencies,  // Atualizar dependências
    notes: task.notes + `\n\n## 🔄 Replanejamento (${timestamp})\n` +
           `Motivo: ${change-description}\n` +
           `Mudanças aplicadas:\n` +
           `${listarMudanças(task)}`
  })
  console.log(`   ✅ Atualizada: ${task.id}`)
}
```

**3. Criar novas lacunas:**

```javascript
for (const newTask of lacunas) {
  const taskId = backlog_task_create({
    title: newTask.title,
    type: newTask.type || "feature",
    status: "To Do",
    priority: newTask.priority || "medium",
    labels: [...newTask.labels, "replan-gap"],
    milestone: newTask.milestone,
    dependencies: newTask.dependencies || [],
    notes: `Criada durante replanejamento devido a: ${change-description}`
  })
  console.log(`   ✅ Criada: ${taskId}`)
}
```

**4. Corrigir dependências impactadas:**

```javascript
for (const task of impactedTasks) {
  const cleanedDeps = task.dependencies.filter(d => !obsoleteTasks.includes(d))

  backlog_task_update(task.id, {
    dependencies: cleanedDeps,
    notes: task.notes + `\n\n## 🔗 Dependências Atualizadas (${timestamp})\n` +
           `Removidas dependências obsoletas: ${obsoleteTasks.join(", ")}`
  })
}
```

**5. Registrar decisão arquitetural:**

```javascript
backlog_decision_create({
  title: `Replanejamento: ${change-description}`,
  context: `Mudança crítica de cenário que impactou ${obsoleteTasks.length + mutantTasks.length} tasks`,
  decision: `${descreção da decisão tomada}`,
  consequences: `
- ${obsoleteTasks.length} tasks arquivadas
- ${mutantTasks.length} tasks atualizadas
- ${lacunas.length} novas tasks criadas
- ${affectedMilestones.length} milestones impactados
  `,
  alternatives: `${alternativas consideradas se aplicável}`,
  status: "accepted"
})
```

## Notas Importantes

- **Seja Radical:** Se uma tarefa não agrega mais valor no novo cenário, arquive-a sem hesitação.
- **Transparência:** Sempre registre o "Porquê" da mudança para consulta futura.
- **Consistência:** Garanta que a documentação de padrões acompanhe o novo plano.
