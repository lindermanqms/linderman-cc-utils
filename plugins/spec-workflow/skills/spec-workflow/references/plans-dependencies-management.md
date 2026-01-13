# Gerenciamento de Plans e Dependencies

Guia completo para usar Plans e Dependencies no servidor MCP Backlog.md.

## 📋 Visão Geral

**Plans** e **Dependencies** são dois campos poderosos do Backlog.md MCP que permitem:

- **Plans**: Documentar a estratégia de implementação DENTRO da task
- **Dependencies**: Gerenciar dependências entre tasks com validação automática

## 🔧 Plan (Spec da Task)

### O que é um Plan?

Um **Plan** é um campo de texto que contém a abordagem detalhada de como implementar uma task. **O Plan É a Spec da task:**

- **Spec (Plan)**: Campo `plan` da task com estratégia de implementação
- **Documentos**: Artefatos permanentes (`.backlog`) em `docs/standards/` (constituição, padrões)

**⚠️ DISTINÇÃO CRÍTICA:**
- **Specs** são Plans (campos `plan` das tasks) - **NÃO são arquivos separados**
- **Documentos** são artefatos permanentes do projeto - constituicao.backlog, padroes-codigo.backlog, etc.

### Criar Plan durante Criação da Task

```javascript
const task = backlog_task_create({
  title: "Sistema de Autenticação JWT",
  type: "feature",
  status: "To Do",
  priority: "high",
  labels: ["backend", "security"],
  acceptance_criteria: [
    "[ ] Endpoint POST /auth/login retorna JWT",
    "[ ] Middleware de autenticação funcionando",
    "[ ] Testes com cobertura > 80%"
  ],

  // Plan com estratégia de implementação
  plan: `
## Estratégia de Implementação

### Arquitetura Proposta
- Usar JWT (JSON Web Tokens) para autenticação stateless
- Armazenar secrets em environment variables
- Implementar refresh token rotation

### Passo 1: Configuração de Ambiente
- Instalar: jsonwebtoken, bcrypt
- Criar .env com JWT_SECRET, JWT_EXPIRES_IN
- Configurar variáveis de ambiente

### Passo 2: Models e Schemas
- Criar User model (id, email, password_hash)
- Criar Session model (user_id, token, expires_at)
- Adicionar validações (email único, password forte)

### Passo 3: Services
- Implementar AuthService.login(email, password)
- Implementar AuthService.verifyToken(token)
- Implementar AuthService.refreshToken(refresh_token)

### Passo 4: Middleware
- Criar authMiddleware(req, res, next)
- Validar token JWT no header Authorization
- Anexar user ao req对象

### Passo 5: Routes
- POST /auth/login - Login e retorna access + refresh token
- POST /auth/refresh - Renova access token
- POST /auth/logout - Invalida refresh token

### Passo 6: Testes
- Testar login com credenciais válidas
- Testar login com credenciais inválidas
- Testar expiração de token
- Testar refresh token rotation
- Verificar cobertura > 80%

### Riscos e Mitigações
- **Risco**: JWT secret exposto - **Mitigação**: Usar environment variables
- **Risco**: Token nunca expira - **Mitigação**: Configurar expires_in curto (15min)
- **Risco**: Refresh token reuse - **Mitigação**: Implementar rotation
`
})
```

### Atualizar Plan Existente

```javascript
// Durante /spec-execute, descobriu novo requisito
backlog_task_edit(task.id, {
  plan: task.plan + `

### Passo 7: Documentação (DESCOBERTO DURANTE EXECUÇÃO)
- Atualizar README com novos endpoints
- Documentar estrutura de JWT (header.payload.signature)
- Adicionar exemplos de uso em insomnia/postman
`
})
```

### Estrutura Recomendada de Plan

Um bom plan DEVE conter:

1. **Arquitetura Proposta** - Visão geral da solução
2. **Passos Numerados** - Sequência clara de implementação
3. **Dependências Externas** - Bibliotecas, APIs, serviços
4. **Arquivos/Criar** - Lista de arquivos a serem criados
5. **Testes** - Estratégia de testes
6. **Riscos** - Possíveis problemas e como mitigar

### Exemplos de Plans por Tipo de Task

#### Task de Backend (API)

```markdown
## Estratégia de Implementação

### API Design
- POST /api/resource - Criar
- GET /api/resource/:id - Ler
- PUT /api/resource/:id - Atualizar
- DELETE /api/resource/:id - Deletar

### Passo 1: Database Schema
- Criar tabela com migrations
- Adicionar índices para performance
- Configurar relacionamentos

### Passo 2: Models
- Implementar Model com ORM
- Adicionar validações
- Criar métodos helpers (find, create, update)

### Passo 3: Controllers
- Implementar métodos CRUD
- Adicionar error handling
- Validar input com middleware

### Passo 4: Routes
- Registrar rotas no express/fastify
- Adicionar middleware de autenticação
- Configurar rate limiting

### Passo 5: Testes
- Unitários para models
- Integração para controllers
- E2E para rotas
```

#### Task de Frontend (UI)

```markdown
## Estratégia de Implementação

### Component Design
- Component: UserProfileCard
- Props: userId, onEdit, onDelete
- State: user, loading, error

### Passo 1: Setup
- Criar diretório components/UserProfileCard/
- Instalar dependências (se necessário)

### Passo 2: Component Structure
- UserProfileCard.tsx - Componente principal
- useUserProfile.ts - Hook customizado
- UserProfileCard.test.tsx - Testes

### Passo 3: State Management
- Usar useUserProfile hook para fetch data
- Implementar loading state
- Implementar error state

### Passo 4: Styling
- Criar UserProfileCard.module.css
- Seguir design system
- Responsivo (mobile/desktop)

### Passo 5: Integration
- Adicionar rota no router
- Conectar com API endpoints
- Testar navegação
```

#### Task de Bug Fix

```markdown
## Estratégia de Fix

### Análise do Problema
- **Sintoma": Descrição do bug
- **Causa Raiz": Por que acontece
- **Impacto": Quem afeta

### Passo 1: Reproduzir Bug
- Criar caso de teste que falha
- Verificar condições exatas
- Documentar passos para reproduzir

### Passo 2: Investigar Código
- Ler código relacionado
- Identificar onde ocorre o bug
- Entender fluxo de execução

### Passo 3: Implementar Fix
- Aplicar correção
- Adicionar tratamento de erros (se necessário)
- Refatorar código confuso (se necessário)

### Passo 4: Testar
- Executar caso de teste criado
- Verificar que não regressou
- Testar edge cases

### Passo 5: Prevenção
- Adicionar testes para evitar regressão
- Documentar decision no código (comentário)
- Criar ADR se mudança arquitetural
```

## 🔗 Dependencies (Dependências entre Tasks)

### O que são Dependencies?

**Dependencies** permitem expressar que uma task SÓ pode ser executada após outras tasks terem sido concluídas.

### Criar Task com Dependencies

```javascript
const task = backlog_task_create({
  title: "Implementar Dashboard UI",
  // ... outros campos ...

  // Esta task depende das tasks task-5 e task-12
  dependencies: ["task-5", "task-12"]
})
```

### Adicionar Dependencies a Task Existente

```javascript
// Descobriu que task-15 depende de task-20
backlog_task_edit("task-15", {
  add_dependencies: ["task-20"]
})

// Adicionar múltiplas dependências
backlog_task_edit("task-15", {
  add_dependencies: ["task-20", "task-25", "task-30"]
})
```

### Remover Dependencies

```javascript
// Task não depende mais de task-5
backlog_task_edit("task-15", {
  remove_dependencies: ["task-5"]
})

// Remover múltiplas
backlog_task_edit("task-15", {
  remove_dependencies: ["task-5", "task-12"]
})
```

### Validar Dependencies (OBRIGATÓRIO em /spec-execute)

```javascript
// FASE 2 de /spec-execute: Validar Dependências

if (task.dependencies && task.dependencies.length > 0) {
  console.log(`\n🔗 Validando ${task.dependencies.length} dependência(s)...`)

  const blockers = []

  for (const depId of task.dependencies) {
    const depTask = backlog_task_get(depId)

    if (depTask.status !== "Done") {
      blockers.push({
        id: depId,
        title: depTask.title,
        status: depTask.status
      })
    }
  }

  if (blockers.length > 0) {
    console.error("\n❌ BLOCKED: Dependências pendentes!")
    blockers.forEach(b => {
      console.error(`   - ${b.id}: ${b.title} (${b.status})`)
    })

    console.error("\n🔧 Ações necessárias:")
    console.error("   1. Executar tasks dependentes primeiro:")
    blockers.forEach(b => {
      console.error(`      /spec-execute ${b.id}`)
    })
    console.error("\n   2. Ou remover dependência se desnecessária:")
    console.error(`      backlog_task_edit("${task.id}", {`)
    console.error(`        remove_dependencies: ["${blockers[0].id}"]`)
    console.error(`      })`)

    throw new Error(`Task ${task.id} BLOQUEADA por dependências pendentes`)
  }

  console.log("✅ Todas as dependências estão concluídas!")
}
```

### Tipos de Dependencies

#### 1. Hard Dependency (Obrigatória)

```javascript
// Task NUNCA pode ser executada sem a dependência
dependencies: ["task-5"]  // task-5 DEVE estar Done
```

**Exemplo:** Task "Implementar Middleware" depende de "Criar Model"

#### 2. Soft Dependency (Recomendada)

```javascript
// Task pode ser executada isolada, mas é melhor após a dependência
// Anotar no notes ao invés de dependencies
notes: `
Recomendado executar após task-10 para melhor contexto,
mas não é obrigatório.
`
```

**Exemplo:** Task "Documentar API" pode ser feita antes ou depois de testes

#### 3. Transitive Dependency (Automática)

```javascript
// task-30 depende de task-20
// task-20 depende de task-10
// Logo: task-30 transitivamente depende de task-10

dependencies: ["task-20"]  // Não precisa listar task-10 explicitamente
```

### Visualizar Dependencies

```bash
# Via CLI backlog
backlog task view task-15  # Mostra dependencies

# Listar todas as tasks que dependem de task-10
backlog search --dep task-10

# Via MCP
const dependents = backlog_task_list({ dependencies: "task-10" })
```

## 🎯 Workflow Completo com Plans e Dependencies

### Exemplo 1: Feature Complexa com Múltiplas Tasks

**Cenário:** Implementar sistema de autenticação completo

```javascript
// 1. Criar task principal (container)
const mainTask = backlog_task_create({
  title: "Sistema de Autenticação",
  type: "feature",
  status: "To Do",
  plan: `
## Visão Geral
Implementar autenticação JWT completo com refresh tokens.

### Arquitetura
- Backend: JWT + Refresh Tokens
- Frontend: Context API + Interceptors
- Database: Sessions table

### Subtarefas
1. task-10: Models e Database Schema
2. task-11: AuthService (login, verify, refresh)
3. task-12: Middleware de Autenticação
4. task-13: API Routes (/auth/login, /auth/refresh)
5. task-14: Frontend AuthContext
6. task-15: Login Page UI

### Ordem de Execução
task-10 → task-11 → task-12 → task-13 → (task-14, task-15 em paralelo)
`
})

// 2. Criar subtarefas COM dependencies
backlog_task_create({
  id: "task-10",
  title: "Models e Database Schema",
  parent: mainTask.id,
  status: "To Do",
  dependencies: [],  // Sem dependências (primeira task)
  plan: `
## Implementação

### Passo 1: Criar migration
- Criar table users (id, email, password_hash)
- Criar table sessions (user_id, token, expires_at)
- Adicionar índices (email, user_id)

### Passo 2: Criar models
- User model com validations
- Session model com associations

### Passo 3: Testes
- Testar unique constraint em email
- Testar relationship users-sessions
`
})

backlog_task_create({
  id: "task-11",
  title: "AuthService",
  parent: mainTask.id,
  status: "To Do",
  dependencies: ["task-10"],  // Depende de models
  plan: `
## Implementação

### Passo 1: Instalar dependências
- jsonwebtoken
- bcrypt

### Passo 2: Implementar AuthService.login
- Hash password com bcrypt
- Gerar JWT access token
- Gerar refresh token

### Passo 3: Implementar AuthService.verify
- Validar JWT signature
- Verificar expiração

### Passo 4: Implementar AuthService.refresh
- Validar refresh token
- Gerar novo access token
- Rotacionar refresh token
`
})

backlog_task_create({
  id: "task-12",
  title: "Middleware de Autenticação",
  parent: mainTask.id,
  status: "To Do",
  dependencies: ["task-11"],  // Depende de AuthService
  plan: `
## Implementação

### Passo 1: Criar authMiddleware
- Extrair token do header Authorization
- Chamar AuthService.verify
- Anexar user ao req

### Passo 2: Error handling
- Retornar 401 se token inválido
- Retornar 403 se sem permissão

### Passo 3: Testes
- Testar rota protegida sem token
- Testar rota protegida com token válido
- Testar rota protegida com token expirado
`
})

// ... task-13, task-14, task-15 ...
```

**Fluxo de Execução:**

```bash
# Executar task-10 (sem dependências)
/spec-execute task-10
✅ Task concluída

# Executar task-11 (depende de task-10)
/spec-execute task-11
🔗 Validando 1 dependência(s)...
✅ Todas as dependências estão concluídas!
✅ Task concluída

# Tentar executar task-12 ANTES de task-11
/spec-execute task-12
🔗 Validando 1 dependência(s)...
❌ BLOCKED: Dependências pendentes!
   - task-11: AuthService (To Do)

🔧 Ações necessárias:
   1. Executar tasks dependentes primeiro:
      /spec-execute task-11

Error: Task task-12 BLOQUEADA por dependências pendentes
```

## 🐛 Solução de Problemas

### Plan não está sendo seguido

**Problema:** Task tem plan mas implementação ignora.

**Solução:**
```javascript
// Em /spec-execute, FORÇAR leitura do plan
if (!task.plan) {
  console.warn("⚠️ Task não tem plan!")
  console.warn("   Recomendado criar plan ANTES de implementar:")
  console.warn(`   backlog_task_edit("${task.id}", {`)
  console.warn(`     plan: \`Estratégia de implementação...\``)
  console.warn(`   })`)

  // Opcional: Bloquear execução sem plan
  // throw new Error("Plan OBRIGATÓRIO para esta task")
}

// Mostrar plan e pedir confirmação
console.log("\n📋 Plan de Implementação:")
console.log(task.plan)
console.log("\n✅ Seguir este plan durante implementação? (s/n)")
```

### Dependencies causam deadlock

**Problema:** task-10 depende de task-11, mas task-11 depende de task-10 (ciclo).

**Solução:**
```javascript
// Detectar ciclo de dependencies
function detectCycle(taskId, visited = new Set()) {
  if (visited.has(taskId)) {
    throw new Error(`Ciclo detectado: ${taskId}`)
  }

  const task = backlog_task_get(taskId)
  visited.add(taskId)

  for (const depId of task.dependencies || []) {
    detectCycle(depId, new Set(visited))
  }
}

// Chamar antes de adicionar dependency
detectCycle("task-10")
```

### Muitas dependencies (dependency hell)

**Problema:** Task depende de 10+ outras tasks.

**Solução:**
```javascript
// Reagrupar em milestones
// Ao invés de:
dependencies: ["task-1", "task-2", "task-3", "task-4", "task-5", ...]

// Criar milestone e depender apenas dele
milestone: "v1.0 - Auth Complete"

// Ou criar "wrapper task"
const wrapperTask = backlog_task_create({
  title: "Auth Prerequisites",
  acceptance_criteria: [
    "[ ] task-1 Done",
    "[ ] task-2 Done",
    // ...
  ]
})

dependencies: [wrapperTask.id]
```

### Plan muito longo (dificulta leitura)

**Problema:** Plan com 500+ linhas, difícil de seguir.

**Solução:**
```javascript
// Usar subtasks com plans menores
// Ao invés de 1 task com plan gigante:

// Criar 5 subtarefas, cada uma com plan focado
const subtasks = [
  { title: "Setup e Configuração", plan: "Plan curto (50 linhas)" },
  { title: "Models e Database", plan: "Plan curto (50 linhas)" },
  { title: "Services", plan: "Plan curto (100 linhas)" },
  { title: "API Routes", plan: "Plan curto (100 linhas)" },
  { title: "Testes", plan: "Plan curto (50 linhas)" }
]
```

## 📚 Referências

- **Backlog.md MCP**: https://github.com/MrLesk/Backlog.md
- **Comando `/spec-plan`**: Criação de tasks com plans
- **Comando `/spec-execute`**: Validação de dependencies e execução de plans
- **CLI Command**:
  - `backlog task edit <id> --plan "texto"`
  - `backlog task edit <id> --dep <task-id>`
