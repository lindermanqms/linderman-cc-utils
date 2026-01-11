---
name: spec-plan
description: Inicia o processo de planejamento de uma nova feature ou task macro, criando a Spec e a tarefa correspondente via MCP.
version: 2.0.0
category: workflow
triggers:
  - "/spec-plan"
  - "planejar feature"
  - "criar spec"
  - "novo planejamento"
arguments:
  - name: feature-name
    description: Nome da feature ou task a ser planejada.
    required: false
---

# Spec-Plan: Planejamento de Feature com Spec Document

Este comando guia a criação de uma **Spec completa** utilizando o servidor MCP do Backlog, com TODOS os campos disponíveis (priority, labels, milestones, dependencies, etc.).

## Workflow OBRIGATÓRIO

### Fase 1: Levantamento de Requisitos

**1. Perguntas Chave ao Usuário:**

Se `feature-name` não foi fornecido ou está vago, perguntar:
- **Objetivo**: O que esta feature deve resolver/entregar?
- **Usuários**: Quem vai usar? Qual o impacto?
- **Escopo**: O que está incluído/excluído?
- **Prioridade**: Crítica, Alta, Média ou Baixa?
- **Milestone**: Faz parte de algum marco (v1.0, v2.0, etc.)?
- **Dependências**: Depende de outras tasks existentes?
- **Labels**: Quais categorias (backend, frontend, plugin, etc.)?

**2. Consulta ao MCP:**

```javascript
// Ler Constituição e padrões existentes
const constituicao = backlog_doc_list({ path: "docs/standards/" })
const decisoes = backlog_decision_list()

// Evitar duplicidade
const tasksExistentes = backlog_task_list()
```

**3. Consultar Basic Memory:**

```javascript
// Buscar lições aprendidas e ADRs relacionados
search("termo relacionado à feature")
build_context() // Para carregar notas relevantes
```

### Fase 2: Criar Task Macro via MCP (APRIMORADO)

**IMPORTANTE**: Usar **TODOS** os campos disponíveis no Backlog.md MCP:

```javascript
backlog_task_create({
  title: "{{feature-name}}",
  type: "feature",  // ou "enhancement", "bug", "chore"
  status: "To Do",
  priority: "{{prioridade definida}}",  // low, medium, high, critical
  labels: ["{{categorias}}"],  // Ex: ["backend", "api", "authentication"]
  milestone: "{{marco}}",  // Ex: "v1.0 - MVP" ou null
  assignee: "@Claude",
  dependencies: ["{{task-ids}}"],  // Ex: ["task-5", "task-12"] ou []
  acceptance_criteria: [
    "[ ] {{AC1 - critério verificável}}",
    "[ ] {{AC2 - critério verificável}}",
    "[ ] {{AC3 - critério verificável}}"
  ],
  plan: `
## Plano de Implementação

1. {{Etapa 1 - ex: Análise de requisitos}}
2. {{Etapa 2 - ex: Design da arquitetura}}
3. {{Etapa 3 - ex: Implementação core}}
4. {{Etapa 4 - ex: Testes unitários e integração}}
5. {{Etapa 5 - ex: Revisão e documentação}}
  `,
  notes: `Feature solicitada em {{data}}.
Contexto: {{contexto adicional se relevante}}`
})
```

**Exemplo concreto:**

```javascript
backlog_task_create({
  title: "Sistema de Autenticação JWT",
  type: "feature",
  status: "To Do",
  priority: "high",
  labels: ["backend", "security", "api"],
  milestone: "v1.0 - MVP",
  assignee: "@Claude",
  dependencies: [],
  acceptance_criteria: [
    "[ ] Endpoint /auth/login retorna JWT válido",
    "[ ] Refresh token implementado e funcional",
    "[ ] Rate limiting configurado (max 5 tentativas/min)",
    "[ ] Testes unitários com cobertura > 80%"
  ],
  plan: `
## Plano de Implementação

1. Implementar endpoint /auth/login com validação de credenciais
2. Configurar geração de JWT com secret e expiração
3. Adicionar middleware de autenticação para rotas protegidas
4. Implementar refresh token logic com Redis
5. Configurar rate limiting com express-rate-limit
6. Escrever testes unitários e de integração
7. Documentar API e atualizar README
  `,
  notes: "Feature crítica para lançamento MVP. Requer integração com Redis."
})
```

**Capturar o ID retornado:** `task-{{ID}}`

### Fase 3: Criar Spec Document via MCP (APRIMORADO)

**CRÍTICO**: Usar extensão **`.backlog`** (OBRIGATÓRIA, não aceitar `.md`):

```javascript
backlog_doc_create({
  title: "SPEC-{{ID}}: {{feature-name}}",
  type: "spec",
  path: "specs/SPEC-{{ID}}-{{slug}}.backlog",  // EXTENSÃO .backlog OBRIGATÓRIA
  labels: ["specification"],
  content: `---
spec_id: SPEC-{{ID}}
feature: {{feature-name}}
related_task: task-{{ID}}
status: draft
version: 1.0
author: Claude
created_date: {{timestamp}}
---

# SPEC-{{ID}}: {{feature-name}}

**Status:** 📝 Draft
**Task Relacionada:** task-{{ID}}
**Milestone:** {{milestone}}
**Prioridade:** {{priority}}

## 1. Contexto e Motivação

### Problema
{{Descrição do problema que esta feature resolve}}

### Objetivos
{{O que queremos alcançar com esta implementação}}

### Stakeholders
{{Quem se beneficia ou é impactado}}

## 2. Proposta de Solução

### Visão Geral
{{Descrição high-level da solução}}

### Arquitetura
{{Diagramas, fluxo de dados, componentes envolvidos}}

### Stack Tecnológica
{{Tecnologias, bibliotecas, frameworks a serem usados}}

## 3. Requisitos Funcionais

1. {{RF1 - requisito funcional detalhado}}
2. {{RF2 - requisito funcional detalhado}}

## 4. Requisitos Não-Funcionais

1. **Performance**: {{critérios de desempenho}}
2. **Segurança**: {{requisitos de segurança}}
3. **Escalabilidade**: {{requisitos de escala}}

## 5. Critérios de Aceite (AC) - Espelhado da Task

{{Copiar os ACs da task aqui para referência}}

- [ ] {{AC1}}
- [ ] {{AC2}}
- [ ] {{AC3}}

## 6. Detalhamento Técnico

### APIs/Endpoints
{{Endpoints, métodos, payloads}}

### Modelos de Dados
{{Schemas, entidades, relacionamentos}}

### Fluxos de Execução
{{Sequências, state machines, algoritmos}}

## 7. Casos de Borda e Tratamento de Erros

| Cenário | Comportamento Esperado |
|---------|------------------------|
| {{Cenário 1}} | {{Resposta}} |
| {{Cenário 2}} | {{Resposta}} |

## 8. Estratégia de Testes

### Testes Unitários
{{O que testar isoladamente}}

### Testes de Integração
{{O que testar em conjunto}}

### Testes E2E (se aplicável)
{{Fluxos completos a validar}}

## 9. Dependências e Riscos

### Dependências
{{Tasks dependentes: task-X, task-Y}}

### Riscos Identificados
1. {{Risco 1 - mitigação}}
2. {{Risco 2 - mitigação}}

## 10. Plano de Rollout

### Fase 1: {{nome fase}}
{{Descrição}}

### Fase 2: {{nome fase}}
{{Descrição}}

## 11. Referências

- Constituição: backlog/docs/doc-001...
- ADRs relacionadas: {{lista}}
- Documentação externa: {{links}}
  `
})
```

**Validação de extensão:**
```javascript
// REJEITAR se usuário tentar .md:
if (path.endsWith('.md')) {
  throw new Error('❌ Extensão .md não permitida para specs! Use .backlog obrigatoriamente.')
}
```

### Fase 4: Vincular Spec à Task

**Atualizar task com link para spec:**

```javascript
backlog_task_update("task-{{ID}}", {
  description: `Spec detalhada: specs/SPEC-{{ID}}-{{slug}}.backlog

{{Descrição resumida da feature}}`
})
```

**Ou adicionar em notes:**

```javascript
backlog_task_update("task-{{ID}}", {
  notes: task.notes + `\n\n📄 Spec criada: specs/SPEC-{{ID}}-{{slug}}.backlog`
})
```

### Fase 5: Registrar Decisões no Basic Memory (Se aplicável)

**Se houver decisões arquiteturais importantes:**

```javascript
write_note({
  title: "[ADR] - {{título da decisão}}",
  content: `---
type: ADR
tags: [architecture, {{feature-name}}]
project: linderman-cc-utils
---
# ADR: {{título da decisão}}

## Contexto
{{contexto da decisão}}

## Decisão
{{o que foi decidido}}

## Alternativas
{{outras opções consideradas}}

## Consequências
{{impactos esperados}}

## Relação
- Task: task-{{ID}}
`
})
```

### Saída Esperada

```markdown
✅ Feature Planejada com Sucesso!

📋 **Task Criada**: task-{{ID}}
   - Título: {{feature-name}}
   - Tipo: feature
   - Prioridade: {{priority}}
   - Labels: {{labels}}
   - Milestone: {{milestone}}
   - Dependências: {{dependencies ou "Nenhuma"}}
   - Status: To Do

📄 **Spec Criada**: specs/SPEC-{{ID}}-{{slug}}.backlog
   - Versão: 1.0
   - Status: Draft
   - Vinculada à task-{{ID}}

🏗️ **Plano de Implementação**: {{X etapas definidas}}

✅ **Acceptance Criteria**: {{N critérios}} definidos

🧠 **Memory MCP**: {{Se aplicável: "ADR registrada"}}

🎯 **Próximos Passos:**
   1. Revise a Spec: Ler specs/SPEC-{{ID}}-{{slug}}.backlog
   2. Ajuste se necessário (via backlog_doc_update)
   3. Quando pronto: /spec-execute task-{{ID}}
   4. Visualize no Kanban: backlog board
```

## Template Rápido do Spec (Para Referência)

```markdown
---
spec_id: SPEC-{{ID}}
feature: {{nome}}
related_task: task-{{ID}}
status: draft
version: 1.0
---

# SPEC-{{ID}}: {{Nome}}

## 1. Contexto
## 2. Solução
## 3. Requisitos Funcionais
## 4. Requisitos Não-Funcionais
## 5. Acceptance Criteria
## 6. Detalhamento Técnico
## 7. Casos de Borda
## 8. Testes
## 9. Dependências/Riscos
## 10. Rollout
## 11. Referências
```

## Regras de Ouro

1. **MCP-Only**: PROIBIDO editar arquivos Markdown/Backlog diretamente. Use sempre ferramentas MCP.
2. **Extensão .backlog Obrigatória**: Specs DEVEM usar `.backlog`, não `.md`. Rejeitar tentativas de usar `.md`.
3. **Todos os Campos**: Usar TODOS os campos disponíveis no MCP (priority, labels, milestones, dependencies, assignee, plan, notes).
4. **ACs são Contratos**: Seja exaustivo e verificável nos Critérios de Aceite.
5. **Consultar Memória**: SEMPRE consultar Memory MCP e Constituição antes de criar spec.
6. **Dependências Explícitas**: Se a feature depende de outras tasks, declarar via campo `dependencies`.
7. **Plano Estruturado**: Campo `plan` deve ter etapas numeradas e claras.

## Notas Importantes

- **Idempotência**: Se já existe spec para a feature, avisar usuário antes de duplicar
- **Validação de Nomes**: Slug deve ser kebab-case (ex: `sistema-autenticacao`)
- **IDs Sequenciais**: SPEC-ID e task-ID devem corresponder (SPEC-001 ↔ task-001)
- **Versionamento**: Specs podem evoluir - use campo `version` se houver mudanças significativas
- **Status da Spec**: Draft → In Review → Approved → Implemented
