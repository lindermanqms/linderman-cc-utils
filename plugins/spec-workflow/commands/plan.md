---
name: spec-plan
description: Inicia o processo de planejamento de uma nova feature ou task macro, criando a Spec, a tarefa principal e suas subtasks correspondentes via MCP.
version: 2.1.0
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

# Spec-Plan: Planejamento Estruturado (Main Task, Subtasks & Spec)

Este comando guia o planejamento completo de uma funcionalidade, dividindo-a em unidades de trabalho atômicas e documentando o detalhamento técnico em uma Spec oficial.

## Workflow OBRIGATÓRIO

### Fase 1: Levantamento de Requisitos

**1. Perguntas Chave ao Usuário:**

Se `feature-name` não foi fornecido ou está vago, perguntar:
- **Objetivo**: O que esta feature deve resolver?
- **Escopo**: O que está incluído/excluído?
- **Prioridade**: Crítica, Alta, Média ou Baixa?
- **Milestone**: Faz parte de algum marco (v1.0, v2.0, etc.)?
- **Dependências**: Depende de outras tasks existentes?

**2. Consulta ao Contexto (MCP & Memory):**

```javascript
// Ler Constituição, padrões e lições aprendidas
const padroes = backlog_doc_list({ path: "docs/standards/" })
const decisoes = backlog_decision_list()
search_nodes({ query: "{{feature-name}} patterns" })
```

### Fase 2: Criar Tarefa PRINCIPAL (Macro)

A tarefa principal serve como o "guarda-chuva" para o trabalho. Sua descrição deve ser sucinta e apontar para a Spec.

```javascript
// Criar tarefa macro
const mainTask = backlog_task_create({
  title: "{{feature-name}}",
  type: "feature",
  status: "To Do",
  priority: "{{prioridade}}",
  labels: ["{{categorias}}"],
  milestone: "{{marco}}",
  assignee: "@Claude",
  dependencies: ["{{task-ids-externas}}"],
  acceptance_criteria: [
    "[ ] {{AC Macro 1 - ex: Funcionalidade X operando fim-a-fim}}",
    "[ ] {{AC Macro 2 - ex: Cobertura de testes > 80%}}",
    "[ ] {{AC Macro 3 - ex: Documentação técnica atualizada}}"
  ],
  plan: `
## Overview da Implementação

1. {{Resumo Fase 1}}
2. {{Resumo Fase 2}}
3. {{Resumo Fase 3}}
  `,
  description: "{{Descrição sucinta de 1-2 linhas}}.\n\n📄 **Spec detalhada:** specs/SPEC-{{ID}}-{{slug}}.backlog"
})
// Resultado esperado: task-{{ID}}
```

### Fase 3: Criar SUBTAREFAS (Passo a Passo)

Dividir a implementação em passos atômicos e independentes (sempre que possível). Cada subtask deve ser vinculada à principal via campo `parent`.

```javascript
// Criar Subtask 1 (Exemplo)
backlog_task_create({
  title: "Subtask 1: {{Ação Atômica}}",
  type: "feature",
  status: "To Do",
  priority: "{{mesma da principal}}",
  labels: ["{{labels}}"],
  parent: "task-{{ID}}", // ← VÍNCULO OBRIGATÓRIO
  acceptance_criteria: [
    "[ ] {{Critério técnico específico 1}}",
    "[ ] {{Critério técnico específico 2}}"
  ],
  notes: "Referência técnica na seção X da Spec."
})

// Criar Subtask 2 com Dependência (Exemplo)
backlog_task_create({
  title: "Subtask 2: {{Ação que depende da anterior}}",
  type: "feature",
  parent: "task-{{ID}}",
  dependencies: ["task-{{ID}}.1"], // ← DEPENDÊNCIA ENTRE SUBTAREFAS
  acceptance_criteria: [
    "[ ] {{Critério técnico específico}}"
  ]
})
```

### Fase 4: Criar Spec Document (O "Como")

**CRÍTICO**: Usar extensão **`.backlog`** (OBRIGATÓRIA). A Spec contém o detalhamento técnico completo que não cabe nas tasks.

```javascript
backlog_doc_create({
  title: "SPEC-{{ID}}: {{feature-name}}",
  type: "spec",
  path: "specs/SPEC-{{ID}}-{{slug}}.backlog", // EXTENSÃO .backlog OBRIGATÓRIA
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

**Status:** 📝 Draft | **Task:** task-{{ID}}

## 1. Contexto e Objetivos
{{Descrição detalhada do porquê e para quê}}

## 2. Arquitetura e Design
{{Componentes, fluxos de dados, diagramas textuais}}

## 3. Detalhamento Técnico
### APIs / Endpoints
{{Métodos, rotas, payloads de exemplo}}

### Modelos de Dados
{{Entidades, schemas, relacionamentos}}

## 4. Acceptance Criteria (Espelhado)
- [ ] {{AC 1}}
- [ ] {{AC 2}}

## 5. Casos de Borda e Erros
| Cenário | Resposta Esperada |
|---------|-------------------|
| {{Ex}}  | {{Ex}}            |

## 6. Estratégia de Testes
{{Unitários, integração, E2E}}

## 7. Referências
- Constituição: backlog/docs/standards/constituicao.backlog
- ADRs: {{links}}
`
})
```

### Fase 5: Validação e Vínculo Final

**Atualizar a Tarefa Principal** para garantir que todos os links estão corretos:

```javascript
backlog_task_update("task-{{ID}}", {
  notes: "📄 Spec oficial: specs/SPEC-{{ID}}-{{slug}}.backlog\n\n🛠️ Esta task é composta por {{N}} subtasks detalhando o passo-a-passo."
})
```

---

## Regras de Ouro do Planejamento

1. **Task vs Spec**: A Task diz "O QUE" fazer (trabalho). A Spec diz "COMO" fazer (projeto).
2. **Atomicidade**: Subtasks devem ser pequenas o suficiente para serem concluídas em poucas horas.
3. **Link Parent**: SEMPRE preencher o campo `parent` nas subtasks.
4. **Extensão .backlog**: NUNCA usar `.md` para Specs ou Documentos de padrões. Rejeitar se solicitado.
5. **IDs Sincronizados**: SPEC-010 deve referenciar a task-010.
6. **Dependências**: Se o Passo B depende do Passo A, use o campo `dependencies` na subtask B.

## Exemplo de Estrutura de Subtasks (Autenticação)

- **task-010**: Sistema de Autenticação JWT (Main)
    - **task-010.1**: Setup de Schemas e Modelos de Usuário
    - **task-010.2**: Implementação do Serviço de Assinatura JWT
    - **task-010.3**: Endpoint POST /auth/login
    - **task-010.4**: Middleware de Validação de Token
    - **task-010.5**: Testes de Integração e Cobertura