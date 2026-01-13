---
name: spec-review
description: Examina a conformidade do código com a "Constituição" do projeto e os requisitos específicos da task. Valida ACs automaticamente.
version: 2.0.0
category: workflow
triggers:
  - "/spec-review"
  - "revisar task"
  - "review de código"
arguments:
  - name: task-id
    description: ID da task a ser revisada
    required: true
---

# Spec-Review: Auditoria de Conformidade e Qualidade

Este comando realiza uma revisão rigorosa antes da finalização de uma task, garantindo que o código não apenas funcione, mas siga todos os padrões estabelecidos e tenha TODOS os ACs concluídos.

## Instruções para o Agente

### 0. 🚨 FLUXOGRAMA DE STATUS OBRIGATÓRIO 🚨

```
┌─────────────────────────────────────────────────────────────┐
│                   FLUXO DE STATUS OBRIGATÓRIO               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  To Do ──────► In Progress ─────► In Review ─────► Done    │
│   │              │                   │              │      │
│   │              │                   │              │      │
│   ▼              ▼                   ▼              ▼      │
│ Blocked      (trabalho)        (revisão)      (concluída) │
│                                                             │
│  Regras:                                                   │
│  1. Task DEVE estar "In Progress" ANTES de execução        │
│  2. Mudar para "In Review" AO CHAMAR /spec-review         │
│  3. Apenas "Done" APÓS TODOS os ACs marcados [x]          │
│  4. "Blocked" se dependência impedir progresso             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### ⚠️ REGRA DE OURO DO STATUS ⚠️

**NUNCA** pule etapas do fluxo:

| De | Para | Quando | Comando |
|-----|------|--------|---------|
| **To Do** | **In Progress** | Ao iniciar execução | `/spec-execute` |
| **In Progress** | **In Review** | Ao completar implementação | `/spec-review` (automático) |
| **In Review** | **Done** | Após revisão aprovada | `/spec-retro` |
| **In Review** | **In Progress** | Se revisão rejeitada | `/spec-execute` |
| **Qualquer** | **Blocked** | Se dependência bloquear | Manual |

**VERIFICAÇÃO OBRIGATÓRIA ANTES DE /SPEC-REVIEW:**
```javascript
if (task.status !== "In Progress") {
  throw new Error(`❌ Task deve estar "In Progress" antes de /spec-review. Status atual: "${task.status}"`)
}

// Mudar para "In Review" ANTES de iniciar revisão
backlog_task_update(task.id, { status: "In Review" })
```

---

### 1. Preparação e Leitura

**Buscar task:**
```javascript
const task = backlog_task_get("{{task-id}}")
```

**Ler Spec associada:**
```javascript
// Extrair path da spec
const specMatch = task.description?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/) ||
                  task.notes?.match(/specs\/(SPEC-\d+-[\w-]+\.backlog)/)

if (specMatch) {
  const spec = backlog_doc_get(specId)
}
```

**Ler Constituição do projeto:**
```javascript
const constituicao = backlog_doc_list({ path: "docs/standards/" })
// Ler doc-001 - Constituição do Projeto
// Ler outros padrões relevantes
```

### 2. Auditoria Técnica

#### 2.1 Verificação de Status

**Verificar que task está em "In Review":**
```javascript
if (task.status !== "In Review") {
  console.warn("⚠️ Task não está em status 'In Review'")
  console.log(`   Status atual: ${task.status}`)
  console.log("   Recomendação: Executar /spec-execute primeiro")
}
```

#### 2.2 Validação Automática de ACs (OBRIGATÓRIO)

**CRÍTICO**: Verificar que TODOS os ACs estão marcados como concluídos:

```javascript
// Contar ACs marcados vs pendentes
const uncheckedACs = task.acceptance_criteria.filter(ac => ac.startsWith("[ ]"))
const checkedACs = task.acceptance_criteria.filter(ac => ac.startsWith("[x]"))

const totalACs = task.acceptance_criteria.length
const completionRate = ((checkedACs.length / totalACs) * 100).toFixed(0)

console.log(`\n📊 Progresso dos Acceptance Criteria: ${checkedACs.length}/${totalACs} (${completionRate}%)`)
console.log(`   ✅ Concluídos: ${checkedACs.length}`)
console.log(`   ⏳ Pendentes: ${uncheckedACs.length}`)

// SE houver ACs pendentes, BLOQUEAR revisão
if (uncheckedACs.length > 0) {
  console.log("\n❌ BLOCKING ERROR: Acceptance Criteria INCOMPLETOS")
  console.log("\nACs pendentes:")
  uncheckedACs.forEach((ac, index) => {
    const acNumber = task.acceptance_criteria.indexOf(ac) + 1
    console.log(`   ${acNumber}. ${ac}`)
  })

  console.log("\n🔧 Como marcar ACs como concluídos:")
  console.log(`   backlog_task_edit("${task.id}", {`)
  console.log(`     check_acceptance_criteria: [1, 3, 5]`)
  console.log(`   })`)
  console.log("\n💡 Dica: Use o número do AC (1-indexed) para marcá-lo como [x]")

  // RETORNAR com status REFUSED
  return {
    status: "REFUSED",
    reason: `Acceptance Criteria incompletos (${checkedACs.length}/${totalACs})`,
    completion_rate: completionRate,
    unchecked_acs: uncheckedACs,
    recommendation: "Marcar todos os ACs como [x] antes de revisar"
  }
}

// SE todos os ACs estão completos, continuar
console.log("\n✅ VALIDATION PASSED: Todos os ACs estão marcados como [x]")
console.log("   Continuando com revisão técnica...")
```

**Exemplo de uso prático:**

```javascript
// Durante /spec-execute, implementar e marcar ACs um por um
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1]  // Marca AC #1 como [x]
})

// Verificar progresso antes de chamar /spec-review
const task = backlog_task_get("task-10")
const done = task.acceptance_criteria.filter(ac => ac.startsWith("[x]")).length
console.log(`Progresso: ${done}/${task.acceptance_criteria.length} ACs`)

// SE progresso = 100%, chamar /spec-review
if (done === task.acceptance_criteria.length) {
  console.log("✅ Todos os ACs completos! Pronto para /spec-review")
}
```

#### 2.3 Verificação de Código

**Para cada AC marcado como [x], verificar implementação no código:**

```javascript
// Ler código relevante conforme spec
// Validar que cada AC está realmente implementado, não apenas marcado

// Exemplos de verificações:
// - AC "Endpoint /auth/login retorna JWT" → Verificar arquivo de rotas/controllers
// - AC "Testes com cobertura > 80%" → Executar coverage report
// - AC "Documentação atualizada" → Verificar README/docs
```

#### 2.4 Alinhamento Arquitetural

**Verificar conformidade com Constituição:**

- ✅ Padrões de nomenclatura seguidos?
- ✅ Estrutura de arquivos/diretórios correta?
- ✅ Dependências declaradas apropriadamente?
- ✅ Sem código duplicado?
- ✅ Sem TODOs/FIXMEs críticos?
- ✅ Sem logs de debug/console.log remanescentes?

**Verificar conformidade com Spec:**

- ✅ Arquitetura proposta implementada?
- ✅ APIs/endpoints conforme especificado?
- ✅ Modelos de dados corretos?
- ✅ Casos de borda tratados?

#### 2.5 Qualidade de Código

**Checklist:**

- ✅ Testes automatizados presentes?
- ✅ Cobertura de testes adequada?
- ✅ Documentação inline onde necessário?
- ✅ Tratamento de erros robusto?
- ✅ Performance aceitável?
- ✅ Segurança (sem vulnerabilidades OWASP Top 10)?

### 3. Relatório de Conformidade

**Gerar relatório estruturado:**

```markdown
🔍 **Relatório de Revisão: Task {{task-id}}**

**Task**: {{task.title}}
**Prioridade**: {{task.priority}}
**Milestone**: {{task.milestone}}
**Labels**: {{task.labels.join(", ")}}

---

## ✅ Acceptance Criteria ({{checkedACs.length}}/{{task.acceptance_criteria.length}})

{{Para cada AC:}}
- [✅] {{AC texto}} - ✓ Verificado em `caminho/arquivo:linha`
  {{ou}}
- [❌] {{AC texto}} - ✗ Não implementado corretamente: {{explicação}}

---

## 📋 Conformidade com Constituição

**Padrões de Código:**
- [✅] Nomenclatura: Seguindo convenções
- [✅] Estrutura: Arquivos nos locais corretos
- [⚠️] Qualidade: {{observação se houver}}

**Arquitetura:**
- [✅] Alinhada com Spec: {{confirmação}}
- [⚠️] Desvio detectado: {{se houver}}

**Testes:**
- [✅] Unitários: {{N testes}} adicionados
- [✅] Cobertura: {{X%}} (meta: >80%)
- [❌] Faltam testes para: {{se aplicável}}

**Documentação:**
- [✅] README atualizado
- [✅] Comentários inline adequados
- [⚠️] Falta documentar: {{se aplicável}}

---

## 🔍 Pontos de Atenção

{{Se houver problemas encontrados:}}
1. **{{Categoria}}** ({{arquivo:linha}}):
   - Problema: {{descrição}}
   - Impacto: {{severidade}}
   - Sugestão: {{como corrigir}}

---

## 🎯 Veredito Final

{{Se TODOS ACs concluídos E sem problemas críticos:}}
### 🟢 **APPROVED**

Parabéns! A implementação está em conformidade com:
- ✅ Todos os Acceptance Criteria atendidos
- ✅ Padrões da Constituição respeitados
- ✅ Qualidade de código adequada

**Sugestões menores (opcional):**
- {{melhorias não-bloqueantes}}

**Próximo passo:**
Execute `/spec-retro {{task-id}}` para finalizar a task.

{{Se houver problemas:}}
### 🔴 **REFUSED**

**Motivo do bloqueio:**
{{Razão principal - ex: "3 ACs não concluídos", "Falta cobertura de testes"}}

**Ações necessárias antes de aprovar:**
1. {{Ação corretiva 1}}
2. {{Ação corretiva 2}}

**Manter task em status**: In Review (ou voltar para In Progress)

Após correções, execute `/spec-review {{task-id}}` novamente.
```

### 4. Atualizar Task (Se necessário)

**Se REFUSED, adicionar nota:**

```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 🔴 Review REFUSED (${timestamp})\n` +
         `Motivo: ${razão}\n` +
         `Ações necessárias:\n${açõesLista}`
})
```

**Se APPROVED, adicionar nota:**

```javascript
backlog_task_update(task.id, {
  notes: task.notes + `\n\n## 🟢 Review APPROVED (${timestamp})\n` +
         `Todos os ACs validados\n` +
         `Conformidade verificada\n` +
         `Pronta para /spec-retro`
})
```

### 5. Próximos Passos

**Se REFUSED:**
- Listar correções necessárias detalhadamente
- Manter task em status "In Review" ou voltar para "In Progress"
- Solicitar que desenvolvedor corrija e execute `/spec-review` novamente

**Se APPROVED:**
- Sugerir execução de `/spec-retro {{task-id}}` para encerrar formalmente
- Task pode prosseguir para status "Done"

## Notas Importantes

- **Validação Automática de ACs**: O comando agora verifica automaticamente se TODOS os ACs estão marcados como [x] antes de prosseguir
- **Bloqueio Obrigatório**: Se houver ACs pendentes ([ ]), a revisão é automaticamente REFUSED
- **CLI para Marcar ACs**: Orientar uso de `backlog task edit --check-ac` para marcar ACs
- **Critério Rigoroso**: Seja crítico e detalhista - melhor reprovar agora do que ter bugs em produção
- **Apontar Código Específico**: Sempre referenciar arquivos e linhas exatas (ex: `src/auth.ts:42`)
- **Sem Aprovação Automática**: NUNCA aprovar se houver falhas óbvias, mesmo que pequenas
- **Rastreabilidade**: Adicionar notas na task para histórico completo de reviews
