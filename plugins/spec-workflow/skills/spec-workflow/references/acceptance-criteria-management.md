# Gerenciamento de Acceptance Criteria (ACs)

Guia completo para gerenciar Acceptance Criteria usando o servidor MCP Backlog.md.

## 📋 Visão Geral

**Acceptance Criteria (ACs)** são critérios verificáveis que definem quando uma task está completa. No Backlog.md, ACs são gerenciados individualmente com ferramentas MCP especializadas.

## 🔧 Ferramentas MCP Disponíveis

### 1. Marcar AC como Concluído

**Marcar um AC específico como `[x]`:**
```javascript
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1]  // Marca AC #1 como [x]
})
```

**Marcar múltiplos ACs:**
```javascript
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1, 3, 5]  // Marca ACs #1, #3 e #5 como [x]
})
```

### 2. Desmarcar AC

**Desmarcar um AC (reabri-lo):**
```javascript
backlog_task_edit("task-10", {
  uncheck_acceptance_criteria: [2]  // Marca AC #2 como [ ]
})
```

**Desmarcar múltiplos:**
```javascript
backlog_task_edit("task-10", {
  uncheck_acceptance_criteria: [1, 3]
})
```

### 3. Adicionar Novo AC

**Adicionar AC durante implementação:**
```javascript
backlog_task_edit("task-10", {
  add_acceptance_criteria: [
    "[ ] Novo requisito descoberto durante implementação"
  ]
})
```

**Adicionar múltiplos ACs:**
```javascript
backlog_task_edit("task-10", {
  add_acceptance_criteria: [
    "[ ] Cobertura de testes > 80%",
    "[ ] Documentação atualizada"
  ]
})
```

### 4. Remover AC

**Remover AC inválido ou duplicado:**
```javascript
backlog_task_edit("task-10", {
  remove_acceptance_criteria: [5]  // Remove AC #5
})
```

**Remover múltiplos ACs:**
```javascript
backlog_task_edit("task-10", {
  remove_acceptance_criteria: [2, 4]  // Remove ACs #2 e #4
})
```

## 📊 Verificar Progresso de ACs

**Contar ACs concluídos vs pendentes:**
```javascript
const task = backlog_task_get("task-10")

const total = task.acceptance_criteria.length
const checked = task.acceptance_criteria.filter(ac => ac.startsWith("[x]")).length
const unchecked = task.acceptance_criteria.filter(ac => ac.startsWith("[ ]")).length
const percentage = ((checked / total) * 100).toFixed(0)

console.log(`Progresso: ${checked}/${total} (${percentage}%)`)
console.log(`Concluídos: ${checked}`)
console.log(`Pendentes: ${unchecked}`)
```

## 🎯 Workflow Recomendado

### Durante Implementação (`/spec-execute`)

```javascript
// 1. Ler task
const task = backlog_task_get("task-10")

// 2. Implementar primeiro AC
// ... código ...

// 3. Marcar AC como concluído
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1]
})

// 4. Verificar progresso
const updated = backlog_task_get("task-10")
const done = updated.acceptance_criteria.filter(ac => ac.startsWith("[x]")).length
console.log(`Progresso: ${done}/${updated.acceptance_criteria.length}`)

// 5. Repetir para cada AC
```

### Durante Revisão (`/spec-review`)

```javascript
// 1. Validar que TODOS os ACs estão marcados
const task = backlog_task_get("task-10")
const unchecked = task.acceptance_criteria.filter(ac => ac.startsWith("[ ]"))

if (unchecked.length > 0) {
  console.log("❌ ACs pendentes:")
  unchecked.forEach((ac, i) => {
    const acNumber = task.acceptance_criteria.indexOf(ac) + 1
    console.log(`   ${acNumber}. ${ac}`)
  })

  return {
    status: "REFUSED",
    reason: "Acceptance Criteria incompletos"
  }
}

console.log("✅ Todos os ACs concluídos!")
```

## ⚠️ Boas Práticas

### ✅ SEMPRE marcar ACs individualmente

```javascript
// ✅ CORRETO
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1]
})

// ❌ ERRADO - Não edite o campo completo
backlog_task_update("task-10", {
  acceptance_criteria: [
    "[x] AC 1",
    "[x] AC 2",  // Perde outros ACs que possam existir
    "[ ] AC 3"
  ]
})
```

### ✅ ACs devem ser verificáveis

```javascript
// ✅ BOM - Verificável
"[ ] Endpoint POST /auth/login retorna status 200 e token JWT"
"[ ] Testes unitários cobrem > 80% do código"

// ❌ RUIM - Subjetivo
"[ ] Código está limpo"
"[ ] Implementação está ok"

// ✅ BOM - Específico e mensurável
"[ ] Tempo de resposta < 200ms para 95% das requisições"
"[ ] Consumo de memória < 512MB"
```

### ✅ Marcar ACs progressivamente

```javascript
// ✅ Marcar um por um durante implementação
backlog_task_edit("task-10", { check_acceptance_criteria: [1] })
// ... implementar AC 2 ...
backlog_task_edit("task-10", { check_acceptance_criteria: [2] })
// ... implementar AC 3 ...
backlog_task_edit("task-10", { check_acceptance_criteria: [3] })

// ❌ Não marcar todos no final sem validação
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1, 2, 3, 4, 5]
})
```

## 🐛 Solução de Problemas

### AC não está sendo marcado

**Problema:** `check_acceptance_criteria` não funciona.

**Soluções:**
1. Verificar se está usando `backlog_task_edit` (não `backlog_task_update`)
2. Verificar se o índice do AC está correto (1-indexed, não 0-indexed)
3. Verificar se a task existe

```javascript
// Verificar ACs antes de marcar
const task = backlog_task_get("task-10")
console.log("ACs atuais:")
task.acceptance_criteria.forEach((ac, i) => {
  console.log(`${i + 1}. ${ac}`)
})

// Depois marcar
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1]
})
```

### Erro: "AC index out of bounds"

**Problema:** Tentando marcar AC que não existe.

**Solução:** Verificar quantidade de ACs antes de marcar.

```javascript
const task = backlog_task_get("task-10")
const totalACs = task.acceptance_criteria.length

// Só marcar até o limite
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1, 2, totalACs]  // ✅ Correto
  // check_acceptance_criteria: [1, 2, 99]    // ❌ Errado
})
```

### ACs foram perdidos

**Problema:** Ao editar task, ACs foram sobrescritos.

**Causa:** Usou `backlog_task_update` com campo `acceptance_criteria` completo.

**Solução:** Use SEMPRE `backlog_task_edit` com operações granulares.

```javascript
// ❌ ERRADO - Perde ACs existentes
backlog_task_update("task-10", {
  acceptance_criteria: ["[ ] Novo AC"]
})

// ✅ CORRETO - Adiciona sem perder ACs existentes
backlog_task_edit("task-10", {
  add_acceptance_criteria: ["[ ] Novo AC"]
})
```

## 📚 Referências

- **Backlog.md MCP**: https://github.com/MrLesk/Backlog.md
- **Comando `/spec-execute`**: Execução de tasks com marcação de ACs
- **Comando `/spec-review`**: Valida automática de ACs
- **CLI Command**: `backlog task edit <id> --check-ac <texto>`
