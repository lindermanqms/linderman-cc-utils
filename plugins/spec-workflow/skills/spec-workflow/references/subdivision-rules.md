# Regras de Subdivisão de Tasks

Guia completo para subdivisão obrigatória de tasks no spec-workflow.

## 🚨 REGRA DE OURO

**TODA task com Score > 5 DEVE ser subdividida.**

**Score = ACs + Arquivos + (Horas × 0.25) + (Deps × 0.5)**

## 📊 Fórmula de Complexidade

```javascript
const complexityScore = {
  acs: acceptance_criteria.length,           // 1 ponto por AC
  files: estimatedFiles || 0,                // 1 ponto por arquivo
  hours: estimatedHours || 0,                // 0.25 pontos por hora
  dependencies: dependencies?.length || 0    // 0.5 pontos por dependência
}

const totalScore = complexityScore.acs +
                   complexityScore.files +
                   (complexityScore.hours * 0.25) +
                   (complexityScore.dependencies * 0.5)

// REGRA: Score > 5 = DEVE subdividir
if (totalScore > 5) {
  // OBRIGATÓRIO subdividir
}
```

## 🎯 Tabela de Complexidade

| Score | Classificação | Ação | Exemplo |
|-------|---------------|------|---------|
| **0-3** | Simples | Implementar direta | "Criar botão de login" |
| **3-5** | Média | Avaliar caso a caso | "CRUD de usuários" |
| **5-8** | Complexa | **SUBDIVIDIR** | "Sistema de autenticação" |
| **8+** | Muito Complexa | **OBRIGATÓRIO subdividir** | "Módulo completo de pagamentos" |

## 📐 Exemplos Práticos

### ✅ Task Simples (Score 3.25)

**Task:** "Criar botão de login na UI"

```javascript
{
  acceptance_criteria: [
    "[ ] Botão exibe 'Login'",
    "[ ] Ao clicar, abre modal de login"
  ],
  estimatedFiles: 1,      // LoginForm.tsx
  estimatedHours: 2,
  dependencies: []
}

// Score: 2 + 1 + (2 × 0.25) + 0 = 3.25
// Ação: ✅ Implementar direta (sem subdivisão)
```

### ⚠️ Task Média (Score 6)

**Task:** "Implementar CRUD de usuários"

```javascript
{
  acceptance_criteria: [
    "[ ] POST /api/users - Criar usuário",
    "[ ] GET /api/users/:id - Ler usuário",
    "[ ] PUT /api/users/:id - Atualizar usuário",
    "[ ] DELETE /api/users/:id - Deletar usuário"
  ],
  estimatedFiles: 3,      // UserModel, UserService, UserController
  estimatedHours: 6,
  dependencies: []
}

// Score: 4 + 3 + (6 × 0.25) + 0 = 8.5
// Ação: ⚠️ DEVE subdividir em 2-3 subtarefas
```

**Subdivisão recomendada:**
1. Subtask 1: UserModel e Database (Score ~2)
2. Subtask 2: UserService (CRUD methods) (Score ~3)
3. Subtask 3: UserController e Routes (Score ~2)

### 🚨 Task Complexa (Score 21)

**Task:** "Sistema completo de autenticação"

```javascript
{
  acceptance_criteria: [
    "[ ] Models: User e Session criados",
    "[ ] AuthService com login/verify/refresh",
    "[ ] Middleware de autenticação",
    "[ ] API Routes /auth/login, /auth/refresh, /auth/logout",
    "[ ] Frontend AuthContext",
    "[ ] Página de Login UI",
    "[ ] Página de Registro UI",
    "[ ] Testes unitários (cobertura > 80%)",
    "[ ] Testes de integração",
    "[ ] Documentação atualizada",
    "[ ] Rate limiting implementado",
    "[ ] Refresh token rotation"
  ],
  estimatedFiles: 8,      // Models, Services, Middleware, Routes, Context, UI components, Tests
  estimatedHours: 24,
  dependencies: ["task-5", "task-8"]
}

// Score: 12 + 8 + (24 × 0.25) + (2 × 0.5) = 12 + 8 + 6 + 1 = 27
// Ação: 🚨 OBRIGATÓRIO subdividir em 6+ subtarefas
```

**Subdivisão recomendada:**
1. Subtask 1: Database Schema e Models (Score ~4)
2. Subtask 2: AuthService - Login/Verify/Refresh (Score ~5)
3. Subtask 3: Middleware de Autenticação (Score ~3)
4. Subtask 4: API Routes (Score ~4)
5. Subtask 5: Frontend AuthContext (Score ~3)
6. Subtask 6: Login/Registration Pages (Score ~4)
7. Subtask 7: Testes Unitários (Score ~3)
8. Subtask 8: Testes Integração e Documentação (Score ~3)

## 🔄 Workflow de Subdivisão

### 1. No `/spec-plan` (Criação)

**ANTES de criar a task principal:**

```javascript
// Calcular score de complexidade
const totalScore = calculateComplexityScore(taskSpec)

// SE score > 5: SUBDIVIDIR OBRIGATORIAMENTE
if (totalScore > 5) {
  console.log(`⚠️ ATENÇÃO: Task tem complexidade ${totalScore.toFixed(1)}`)
  console.log(`   ACs: ${complexityScore.acs}`)
  console.log(`   Arquivos: ${complexityScore.files}`)
  console.log(`   Estimativa: ${complexityScore.hours}h`)
  console.log(`   Dependências: ${complexityScore.dependencies}`)

  console.log("\n🚨 REGRA: Task com score > 5 DEVE ser subdividida!")

  // Estratégias de subdivisão
  if (complexityScore.acs >= 4) {
    // Estratégia 1: Dividir por ACs (2 ACs por subtask)
    const acGroups = chunkArray(acceptance_criteria, 2)

    acGroups.forEach((group, index) => {
      backlog_task_create({
        title: `Subtask ${index + 1}: ${featureName} (${group.length} ACs)`,
        parent: mainTask.id,
        type: "subtask",
        acceptance_criteria: group,
        // ... outros campos
      })
    })

  } else if (complexityScore.files >= 3) {
    // Estratégia 2: Dividir por arquivos
    estimatedFiles.forEach((file, index) => {
      backlog_task_create({
        title: `Subtask ${index + 1}: Implementar ${file}`,
        parent: mainTask.id,
        type: "subtask",
        acceptance_criteria: [
          `[ ] ${file} implementado`,
          `[ ] Testes de ${file} passando`,
          `[ ] Code review aprovado`
        ],
        // ... outros campos
      })
    })

  } else {
    // Estratégia 3: Dividir por responsabilidades
    throw new Error("Task muito complexa. Subdividir manualmente em responsabilidades.")
  }
}
```

### 2. No `/spec-execute` (Validação)

**No início da execução:**

```javascript
const task = backlog_task_get("{{task-id}}")

// Calcular complexidade
const totalScore = calculateComplexityScore(task)

// Verificar se foi subdividida
const hasSubtasks = task.notes?.includes("subtask") ||
                   task.notes?.includes("subtarefa") ||
                   task.type === "subtask"

// SE não subdividida E score > 5: REJEITAR
if (!hasSubtasks && totalScore > 5) {
  console.error(`❌ ERRO: Task monolítica detectada!`)
  console.error(`   Task: ${task.id}`)
  console.error(`   Score: ${totalScore.toFixed(1)} (> 5 = monolítica)`)
  console.error(`   ACs: ${complexityScore.acs}`)
  console.error(`   Arquivos: ${complexityScore.files}`)
  console.error(`   Estimativa: ${complexityScore.hours}h`)

  console.error("\n🚨 AÇÃO OBRIGATÓRIA:")
  console.error("   1. Volte ao /spec-plan")
  console.error("   2. Subdivida esta task em subtarefas")
  console.error("   3. Execute cada subtask individualmente")

  throw new Error(`Task ${task.id} é monolítica! Subdivisão OBRIGATÓRIA.`)
}

// SE OK, prosseguir
console.log("✅ Task aprovada. Prosseguindo com execução...")
```

## 📦 Estratégias de Subdivisão

### Estratégia 1: Por ACs (Acceptance Criteria)

**Quando usar:** Tasks com muitos ACs (4+)

**Como fazer:**
```javascript
// Agrupar ACs em grupos de 2-3
const acGroups = [
  [
    "[ ] Model User criado",
    "[ ] Model Session criado"
  ],
  [
    "[ ] AuthService.login implementado",
    "[ ] AuthService.verify implementado"
  ],
  [
    "[ ] API Routes /auth/* criadas",
    "[ ] Testes de integração passando"
  ]
]

acGroups.forEach((group, index) => {
  backlog_task_create({
    title: `Subtask ${index + 1}: Implementar ${featureName} (ACs ${index * 2 + 1}-${index * 2 + group.length})`,
    parent: mainTask.id,
    type: "subtask",
    acceptance_criteria: group
  })
})
```

### Estratégia 2: Por Arquivos

**Quando usar:** Tasks que afetam muitos arquivos (3+)

**Como fazer:**
```javascript
const files = [
  "UserModel.ts",
  "UserService.ts",
  "AuthController.ts",
  "auth.routes.ts"
]

files.forEach((file, index) => {
  backlog_task_create({
    title: `Subtask ${index + 1}: Implementar ${file}`,
    parent: mainTask.id,
    type: "subtask",
    acceptance_criteria: [
      `[ ] ${file} criado`,
      `[ ] Lógica de ${file} implementada`,
      `[ ] Testes de ${file} passando`
    ],
    plan: `
## Implementação de ${file}

### Passo 1: Criar arquivo
- Criar ${file} no diretório apropriado

### Passo 2: Implementar lógica
- Seguir arquitetura do projeto
- Adicionar validações

### Passo 3: Testar
- Criar testes unitários
- Verificar覆盖率 > 80%
`
  })
})
```

### Estratégia 3: Por Responsabilidades

**Quando usar:** Tasks com múltiplas responsabilidades distintas

**Como fazer:**
```javascript
const responsibilities = [
  {
    title: "Database Layer",
    acs: ["[ ] Models criados", "[ ] Migrations rodadas"]
  },
  {
    title: "Business Logic Layer",
    acs: ["[ ] Services implementados", "[ ] Validações adicionadas"]
  },
  {
    title: "API Layer",
    acs: ["[ ] Controllers criados", "[ ] Routes configuradas"]
  },
  {
    title: "Frontend Integration",
    acs: ["[ ] Client criado", "[ ] UI components criados"]
  }
]

responsibilities.forEach((resp, index) => {
  backlog_task_create({
    title: `Subtask ${index + 1}: ${resp.title}`,
    parent: mainTask.id,
    type: "subtask",
    acceptance_criteria: resp.acs
  })
})
```

### Estratégia 4: Por Fluxo de Usuário

**Quando usar:** Features com fluxos de usuário complexos

**Como fazer:**
```javascript
const userFlows = [
  {
    flow: "Cadastro",
    steps: ["Formulário", "Validação", "Criação de conta", "Email de confirmação"]
  },
  {
    flow: "Login",
    steps: ["Formulário", "Autenticação", "Geração de token", "Redirecionamento"]
  },
  {
    flow: "Recuperação de Senha",
    steps: ["Solicitação", "Email de reset", "Nova senha", "Confirmação"]
  }
]

userFlows.forEach((flow, index) => {
  backlog_task_create({
    title: `Subtask ${index + 1}: Implementar fluxo de ${flow.flow}`,
    parent: mainTask.id,
    type: "subtask",
    acceptance_criteria: flow.steps.map(step => `[ ] ${step}`),
    dependencies: index > 0 ? [`subtask-${index}`] : []
  })
})
```

## 🎯 Boas Práticas

### ✅ SEMPRE subdividir tasks com score > 5

```javascript
// ✅ CORRETO
if (totalScore > 5) {
  subdivide(task)
}

// ❌ ERRADO - Ignorar regra
if (totalScore > 5) {
  console.log("Task é grande, mas vou implementar mesmo assim")
  // Implementação monolítica
}
```

### ✅ Criar subtarefas com contexto completo

```javascript
// ✅ CORRETO - Subtask tem plan próprio
backlog_task_create({
  title: "Subtask 1: Implementar UserService",
  parent: mainTask.id,
  type: "subtask",
  acceptance_criteria: [
    "[ ] UserService.login implementado",
    "[ ] UserService.verify implementado"
  ],
  plan: `
## Implementação de UserService

### Passo 1: Setup
- Instalar jsonwebtoken, bcrypt

### Passo 2: Implementar métodos
- login(email, password)
- verifyToken(token)
- refreshToken(token)

### Passo 3: Testes
- Testar login com credenciais válidas/inválidas
- Testar expiração de token
`,
  dependencies: ["subtask-0"]  // Depende de Database
})

// ❌ ERRADO - Subtask sem contexto
backlog_task_create({
  title: "Subtask 1: UserService",
  parent: mainTask.id,
  type: "subtask",
  acceptance_criteria: [
    "[ ] Implementar"
  ]
  // Sem plan, sem dependencies
})
```

### ✅ Manter subtarefas atômicas e independentes

```javascript
// ✅ CORRETO - Subtarefas independentes
const subtasks = [
  { title: "Model User", dependencies: [] },
  { title: "Model Session", dependencies: [] },
  { title: "UserService", dependencies: ["subtask-0", "subtask-1"] },
  { title: "AuthController", dependencies: ["subtask-2"] }
]

// ❌ ERRADO - Subtarefas acopladas
const subtasks = [
  { title: "Começar autenticação" },
  { title: "Continuar de onde parou (depende de contexto anterior)" }
]
```

### ✅ Score mínimo de 2 por subtask

```javascript
// ✅ CORRETO - Subtask com score adequado
{
  acceptance_criteria: ["[ ] AC 1", "[ ] AC 2"],
  estimatedFiles: 1,
  estimatedHours: 2
}
// Score: 2 + 1 + 0.5 = 3.5 ✅

// ❌ ERRADO - Subtask tiny (score < 2)
{
  acceptance_criteria: ["[ ] Adicionar linha no config"],
  estimatedFiles: 0,
  estimatedHours: 0.1
}
// Score: 1 + 0 + 0.025 = 1.025 ❌ (muito pequena)
```

## 🚫 Anti-Patterns

### ❌ Criar tasks dummy para contornar regra

```javascript
// ❌ ERRADO
const dummySubtasks = [
  { title: "Parte 1", acs: ["[ ] Implementar parte 1"] },
  { title: "Parte 2", acs: ["[ ] Implementar parte 2"] },
  { title: "Parte 3", acs: ["[ ] Implementar parte 3"] }
]
// Subtarefas genéricas não ajudam
```

**Solução:** Subtarefas devem ter ACs específicos e verificáveis.

### ❌ Subdivisão excessiva (micro-tasks)

```javascript
// ❌ ERRADO - Cada AC vira uma subtask
const acs = ["[ ] AC 1", "[ ] AC 2", "[ ] AC 3", "[ ] AC 4", "[ ] AC 5"]

acs.forEach((ac, index) => {
  backlog_task_create({
    title: `Subtask ${index + 1}`,
    acceptance_criteria: [ac]
  })
})
// 5 subtarefas com 1 AC cada = overhead alto
```

**Solução:** Agrupar 2-3 ACs por subtask.

### ❌ Subdivisão tardia (durante execução)

```javascript
// ❌ ERRADO - Começar implementação e depois subdividir
/spec-execute task-10
// Implementando...
// "Hmm, isso está muito grande, vou dividir ao meio"
// Perdeu-se tempo e contexto
```

**Solução:** Subdividir SEMPRE no `/spec-plan`, ANTES de executar.

## 🔧 Validação Automática

### No `/spec-plan`

```javascript
// Validação AUTOMÁTICA no creation
const score = calculateComplexity(taskSpec)

if (score > 5 && !taskSpec.subtasks) {
  throw new Error(`Task monolítica detectada! Score: ${score}. Subdivisão OBRIGATÓRIA.`)
}
```

### No `/spec-execute`

```javascript
// Validação AUTOMÁTICA no execution
const task = backlog_task_get(taskId)
const score = calculateComplexity(task)

if (score > 5 && !isSubtask(task)) {
  throw new Error(`Task ${taskId} é monolítica! Volte ao /spec-plan e subdivida.`)
}
```

## 📚 Referências

- **Backlog.md MCP**: https://github.com/MrLesk/Backlog.md
- **Comando `/spec-plan`**: Criação de tasks com subdivisão automática
- **Comando `/spec-execute`**: Validação de tasks monolíticas
- **CLI Command**: `backlog task create --parent <id>` para criar subtasks
