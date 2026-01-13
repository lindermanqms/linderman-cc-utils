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

A tarefa principal serve como o "guarda-chuva" para o trabalho. O campo `plan` contém a Spec (estratégia de implementação).

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

## Detalhes Técnicos

### Arquitetura
{{Descrição da arquitetura proposta}}

### APIs / Componentes
{{Lista de APIs ou componentes a serem criados}}

### Passos de Implementação
1. {{Passo 1 com detalhes}}
2. {{Passo 2 com detalhes}}
3. {{Passo 3 com detalhes}}
`,
  description: "{{Descrição sucinta de 1-2 linhas}}.\n\n📋 **Spec completa**: Ver campo 'plan' acima."
})
// Resultado esperado: task-{{ID}}
```

### 📋 Fase 2.5: Criar Plano de Implementação (Plan) - OBRIGATÓRIO

**CRÍTICO**: O campo `plan` contém a estratégia de implementação DENTRO da task. É diferente da Spec (que está em arquivo separado).

**O que é um Plan:**
- **Spec** (`.backlog`): Documento separado com requisitos, arquitetura e detalhes técnicos
- **Plan** (campo da task): Estratégia de implementação passo a passo, EMBUTIDA na task

**Estrutura de um Plan BEM FEITO:**

```javascript
// Criar ou ATUALIZAR a task COM plan detalhado
backlog_task_update("task-{{ID}}", {
  plan: `
## Estratégia de Implementação

### 🎯 Abordagem Arquitetural
${descrição da arquitetura proposta - ex: "JWT para autenticação stateless"}

### 📦 Passo 1: Configuração e Setup
- Instalar dependências: ${lista de pacotes}
- Configurar environment variables
- Setup inicial de banco de dados

### 🔧 Passo 2: Camada de Dados
- Criar models: ${User, Session, etc.}
- Criar migrations
- Configurar relacionamentos

### 💼 Passo 3: Camada de Negócios (Services)
- Implementar ${ServiceName}.login()
- Implementar ${ServiceName}.verify()
- Implementar ${ServiceName}.refresh()

### 🌐 Passo 4: Camada de API
- Criar controllers
- Configurar rotas: POST /auth/login, POST /auth/refresh
- Adicionar middleware de autenticação

### 🧪 Passo 5: Testes
- Testes unitários (cobertura > 80%)
- Testes de integração
- Testes E2E

### 📚 Passo 6: Documentação
- Atualizar README com novos endpoints
- Documentar estratégia de autenticação
- Adicionar exemplos de uso

### ⚠️ Riscos e Mitigações
- **Risco**: JWT secret exposto
  - **Mitigação**: Usar environment variables, nunca hardcode
- **Risco**: Refresh token reuse
  - **Mitigação**: Implementar token rotation
`
})
```

**Tipos de Plans por Tipo de Task:**

**Task de Backend:**
```javascript
plan: `
## Implementação de API REST

### Passo 1: Database
- Criar tabela com migrations
- Model com validations

### Passo 2: Service Layer
- Business logic
- Error handling

### Passo 3: Controller & Routes
- REST endpoints
- Input validation

### Passo 4: Tests
- Unit tests for services
- Integration tests for routes
`
```

**Task de Frontend:**
```javascript
plan: `
## Implementação de Componente UI

### Passo 1: Setup
- Criar diretório component/
- Instalar dependencies (se necessário)

### Passo 2: Component Structure
- Component.tsx
- useComponent.ts (hook customizado)
- Component.module.css

### Passo 3: State Management
- useState para estado local
- useContext para estado global

### Passo 4: Styling
- Design system compliance
- Responsive (mobile/desktop)

### Passo 5: Tests
- Unit tests with React Testing Library
- Visual regression tests
`
```

**Task de Bug Fix:**
```javascript
plan: `
## Estratégia de Fix

### Análise
- **Sintoma**: ${descrição do bug}
- **Causa Raiz**: ${por que acontece}
- **Impacto**: ${quem afeta}

### Passo 1: Reproduzir
- Criar teste que falha
- Verificar condições exatas

### Passo 2: Investigar
- Ler código relacionado
- Entender fluxo de execução

### Passo 3: Implementar Fix
- Aplicar correção
- Adicionar error handling

### Passo 4: Testar
- Executar teste criado
- Verificar não regressão
- Testar edge cases

### Passo 5: Prevenir
- Adicionar testes para evitar regressão
- Documentar decision (comentário ou ADR)
`
```

### 🔗 Fase 2.6: Identificar e Adicionar Dependencies - OBRIGATÓRIO

**CRÍTICO**: Dependencies impedem que tasks sejam executadas antes que suas dependências sejam concluídas.

**Como Identificar Dependencies:**

```javascript
// 1. Buscar tasks relacionadas ao mesmo domínio
const relatedTasks = backlog_task_list({
  labels: ["{{mesmo label da task atual}}"]
})

// 2. Identificar dependencies por palavras-chave
const keywords = [
  "depende de",
  "após",
  "depois de",
  "requer",
  "pré-requisito"
]

// 3. Analisar se a task menciona outras tasks
const mentionsOtherTasks = task.description?.match(/task-\d+/g) ||
                          task.notes?.match(/task-\d+/g)

// 4. Dependencies automáticas por milestone
const milestoneTasks = backlog_task_list({
  milestone: "{{mesmo milestone}}"
})
// Tasks no mesmo milestone podem ter dependencies implícitas
```

**Adicionar Dependencies à Task:**

```javascript
// DURANTE criação da task
const mainTask = backlog_task_create({
  title: "{{feature-name}}",
  // ... outros campos ...

  // Adicionar dependencies identificadas
  dependencies: [
    "task-5",   // Database schema precisa existir primeiro
    "task-12"   // AuthService precisa estar implementado
  ]
})

// OU APÓS criação (descobriu nova dependency)
backlog_task_edit("task-{{ID}}", {
  add_dependencies: ["task-20", "task-25"]
})

// Remover dependencies se necessário
backlog_task_edit("task-{{ID}}", {
  remove_dependencies: ["task-5"]
})
```

**Exemplo de Dependencies em Sequência:**

```javascript
// Feature: Sistema de Autenticação Completo

// Task 1: Database (SEM dependencies)
backlog_task_create({
  id: "task-10",
  title: "Database Schema: Users e Sessions",
  dependencies: []  // Primeira task, sem dependencies
})

// Task 2: Models (DEPENDE de task-10)
backlog_task_create({
  id: "task-11",
  title: "Models: User e Session",
  dependencies: ["task-10"]  // Precisa do schema primeiro
})

// Task 3: Services (DEPENDE de task-11)
backlog_task_create({
  id: "task-12",
  title: "AuthService: login, verify, refresh",
  dependencies: ["task-11"]  // Precisa dos models primeiro
})

// Task 4: Middleware (DEPENDE de task-12)
backlog_task_create({
  id: "task-13",
  title: "Middleware de Autenticação",
  dependencies: ["task-12"]  // Precisa do AuthService primeiro
})

// Task 5 e 6: Frontend (DEPENDEM de task-13)
backlog_task_create({
  id: "task-14",
  title: "Frontend AuthContext",
  dependencies: ["task-13"]
})

backlog_task_create({
  id: "task-15",
  title: "Login Page UI",
  dependencies: ["task-13", "task-14"]  // Precisa do middleware E do context
})
```

**Validação de Dependencies (OBRIGATÓRIO):**

```javascript
// Após adicionar dependencies, validar que não há ciclos
function validateNoCycle(taskId, visited = new Set()) {
  if (visited.has(taskId)) {
    throw new Error(`Ciclo detectado: ${taskId} depende de si mesma`)
  }

  const task = backlog_task_get(taskId)
  if (!task.dependencies || task.dependencies.length === 0) {
    return true  // Sem dependencies = sem ciclo
  }

  visited.add(taskId)

  for (const depId of task.dependencies) {
    validateNoCycle(depId, new Set(visited))
  }

  return true
}

// Usar durante criação
try {
  validateNoCycle("task-15")
  console.log("✅ Dependencies validadas (sem ciclos)")
} catch (error) {
  console.error(`❌ ${error.message}`)
  // Revisar dependencies
}
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

### 📝 NOTA IMPORTANTE: Specs e Documentos

**⚠️ DISTINÇÃO CRÍTICA:**

**Specs** = São os **PLANOS** das tasks (campo `plan` das tasks)
- Criados na **Fase 2.5** (campo `plan` da task)
- Contêm estratégia de implementação
- **NÃO são arquivos .backlog separados**

**Documentos** = Artefatos PERMANENTES do projeto
- Criados com `backlog_doc_create({ path: "docs/standards/..." })`
- Exemplo: constituicao.backlog, padroes-codigo.backlog
- São constituição, guias, padrões estáticos

### Fase 4: Validação e Vínculo Final

**Atualizar a Tarefa Principal** para garantir que a Spec (plan) está completa:

```javascript
backlog_task_update("task-{{ID}}", {
  notes: "🛠️ Esta task é composta por {{N}} subtasks detalhando o passo-a-passo.\n\n📋 **Spec completa**: Ver campo 'plan' acima para a estratégia de implementação detalhada."
})
```

---

## Regras de Ouro do Planejamento

1. **Task vs Plan (Spec)**: A Task diz "O QUE" fazer (trabalho). O Plan (campo `plan`) diz "COMO" fazer (estratégia de implementação).
2. **Atomicidade**: Subtasks devem ser pequenas o suficiente para serem concluídas em poucas horas.
3. **Link Parent**: SEMPRE preencher o campo `parent` nas subtasks.
4. **Documentos vs Specs**: Documentos são artefatos permanentes (`.backlog` em `docs/standards/`). Specs são Plans das tasks (campo `plan`).
5. **Specs em Plans**: Specs NUNCA são arquivos separados. Sempre usar o campo `plan` da task.
6. **Dependências**: Se o Passo B depende do Passo A, use o campo `dependencies` na subtask B.

## Exemplo de Estrutura de Subtasks (Autenticação)

- **task-010**: Sistema de Autenticação JWT (Main)
    - **task-010.1**: Setup de Schemas e Modelos de Usuário
    - **task-010.2**: Implementação do Serviço de Assinatura JWT
    - **task-010.3**: Endpoint POST /auth/login
    - **task-010.4**: Middleware de Validação de Token
    - **task-010.5**: Testes de Integração e Cobertura