# Separação de Responsabilidades: Agents vs Orchestrator

Guia rápido sobre quem faz o quê no Gemini Orchestrator.

## Visão Geral

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION WORKFLOW                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ORCHESTRATOR (Sonnet)                                   │
│     ├─ Lê task do Backlog.md                                │
│     ├─ Busca contexto do Memory                             │
│     ├─ Prepara prompt                                       │
│     └─ Delega para Agent adequado                           │
│                                                              │
│  2. AGENT (Pro ou Flash)                    ┌──────────┐   │
│     ├─ Analisa/Implementa                   │ DURANTE  │   │
│     ├─ Roda comandos DURANTE desenvolvimento│   DEV    │   │
│     ├─ Pode iniciar dev servers             └──────────┘   │
│     ├─ Checagem estática (lint/typecheck)                   │
│     └─ Retorna relatório                                    │
│                                                              │
│  3. ORCHESTRATOR (Sonnet)                   ┌──────────┐   │
│     ├─ Validação final                      │ VALIDAÇÃO│   │
│     ├─ Build final (npm run build)          │  FINAL   │   │
│     ├─ Testes finais (npm test)             └──────────┘   │
│     ├─ Rodar servers para validação                         │
│     ├─ Atualiza Backlog.md                                  │
│     ├─ Salva insights no Memory                             │
│     └─ Reporta ao usuário                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Matriz de Responsabilidades

### Durante Desenvolvimento (Agents)

| Operação | Pro | Flash | Orchestrator |
|----------|-----|-------|--------------|
| Ler código | ✅ | ✅ | ✅ |
| Escrever código | ❌ | ✅ | ❌ (em modo orquestração) |
| npm install | ❌ | ✅ | ✅ |
| Rodar dev server | ❌ | ✅ | ✅ |
| Criar arquivos | ❌ | ✅ | ❌ (em modo orquestração) |
| Ajustar permissões | ✅ | ✅ | ✅ |
| Lint/typecheck | ❌ | ✅ | ✅ |

### Validação Final (Orchestrator APENAS)

| Operação | Pro | Flash | Orchestrator |
|----------|-----|-------|--------------|
| npm run build | ❌ | ❌ | ✅ |
| npm test (final) | ❌ | ❌ | ✅ |
| cargo build --release | ❌ | ❌ | ✅ |
| Start app for validation | ❌ | ❌ | ✅ |
| End-to-end tests | ❌ | ❌ | ✅ |

### Project Management (Orchestrator APENAS)

| Operação | Pro | Flash | Orchestrator |
|----------|-----|-------|--------------|
| backlog_task_get() | ❌ | ❌ | ✅ |
| backlog_task_update() | ❌ | ❌ | ✅ |
| backlog_task_list() | ❌ | ❌ | ✅ |
| Marcar ACs | ❌ | ❌ | ✅ |
| Atualizar status | ❌ | ❌ | ✅ |

### Operações Destrutivas (Orchestrator APENAS)

| Operação | Pro | Flash | Orchestrator |
|----------|-----|-------|--------------|
| Deletar arquivos | ❌ | ❌ | ✅ |
| npm uninstall | ❌ | ❌ | ✅ |
| rm -rf | ❌ | ❌ | ✅ |
| git reset --hard | ❌ | ❌ | ✅ |

## Por Que Essa Separação?

### 1. Validação Final (Orchestrator)

**Razão**: Requer contexto completo da orquestração

**Exemplo**:
```bash
# ❌ ERRADO - Agent faz validação final
gemini -p "Implement auth AND run npm test to validate" --yolo

# ✅ CORRETO - Agent implementa, Orchestrator valida
gemini -p "Implement auth (static analysis only)" --yolo
# Depois, Orchestrator roda:
npm test
```

**Por quê?**
- Orchestrator sabe se outras delegações falharam
- Orchestrator pode tomar decisões informadas sobre próximos passos
- Orchestrator reporta resultado consolidado ao usuário

### 2. Backlog.md MCP (Orchestrator)

**Razão**: Requer entendimento do workflow e estado do projeto

**Exemplo**:
```javascript
// ❌ ERRADO - Agent usa Backlog.md
gemini -p "Implement auth and update task-10 in Backlog" --yolo

// ✅ CORRETO - Orchestrator usa Backlog.md
// 1. Orchestrator lê task
const task = await backlog_task_get({ id: "task-10" })

// 2. Orchestrator prepara prompt com ACs
const prompt = `Implement auth with ACs: ${task.acceptance_criteria}`

// 3. Agent implementa (sem tocar Backlog)
gemini -p prompt --yolo

// 4. Orchestrator atualiza Backlog
await backlog_task_update({
  id: "task-10",
  notes: "Implementation completed by Gemini Flash"
})
```

**Por quê?**
- Orchestrator entende o contexto completo da task
- Orchestrator pode correlacionar múltiplas delegações com uma task
- Orchestrator decide quando marcar ACs como completos

### 3. Durante Desenvolvimento vs Validação Final

**Durante Desenvolvimento** (Agents PODEM):
```bash
# Instalar dependências
npm install jsonwebtoken

# Rodar dev server para testar
npm run dev

# Criar arquivos
touch src/auth/jwt.ts

# Rodar linter
npm run lint
```

**Validação Final** (Orchestrator APENAS):
```bash
# Build de produção
npm run build

# Testes completos
npm test

# Iniciar app para validação end-to-end
npm start &
curl http://localhost:3000/health
```

**Por quê?**
- Agents precisam de ferramentas para desenvolvimento
- Mas validação final requer decisão informada do Orchestrator
- Orchestrator pode abortar, repetir, ou prosseguir baseado em resultados

## Fluxo Completo: Exemplo Real

### Tarefa: Implementar JWT Authentication

**Passo 1: Orchestrator prepara**
```javascript
// Ler task do Backlog
const task = await backlog_task_get({ id: "task-10" })

// Buscar contexto do Memory
const patterns = await search_nodes({ query: "linderman-cc-utils auth patterns" })

// Preparar prompt
const prompt = `
Implement JWT authentication

ACs from Backlog:
${task.acceptance_criteria.join('\n')}

Patterns from Memory:
${patterns}
`
```

**Passo 2: Agent implementa**
```bash
# Agent executa (com --yolo)
# Durante desenvolvimento, pode:
npm install jsonwebtoken  # ✅ Instalar deps
npm run dev               # ✅ Testar localmente
npm run lint              # ✅ Lint

# Mas NÃO faz:
npm run build             # ❌ Build final
npm test                  # ❌ Testes finais
# (Retorna relatório)
```

**Passo 3: Orchestrator valida**
```bash
# Orchestrator executa validação final
npm run build   # ✅ Build de produção
npm test        # ✅ Testes completos

# Valida endpoints
npm start &
sleep 5
curl http://localhost:3000/auth/login -d '{"user":"test","pass":"test"}'

# Atualiza Backlog
backlog_task_update task-10 --notes "Implementation complete, all tests passing"

# Marca ACs
# [x] AC 1: JWT tokens stored securely
# [x] AC 2: Refresh token rotation
```

## Troubleshooting

### Erro: "Agent tentou usar Backlog.md"

**Sintoma**: Agent executou `backlog_task_update` ou similar

**Solução**: Remover instruções de Backlog.md do prompt. Exemplo:

```diff
- Implement auth and update task-10 with progress
+ Implement auth (Orchestrator will update Backlog.md)
```

### Erro: "Agent rodou npm test final"

**Sintoma**: Agent executou testes finais no prompt

**Solução**: Clarificar que testes finais são do Orchestrator:

```diff
- Implement auth and run npm test
+ Implement auth (run static analysis only, Orchestrator will run final tests)
```

### Erro: "Agent fez build de produção"

**Sintoma**: Agent executou `npm run build` ou `cargo build --release`

**Solução**: Especificar que build final é do Orchestrator:

```diff
- Implement auth and build for production
+ Implement auth (Orchestrator will do final build)
```

## Regras de Ouro

1. **Agents fazem desenvolvimento** - criar, editar, rodar dev tools
2. **Orchestrator faz validação** - build final, testes finais, servers para validação
3. **Orchestrator gerencia projeto** - TODAS as operações do Backlog.md
4. **Orchestrator decide** - próximos passos, marcar completo, reportar ao usuário

## Benefícios

✅ **Separação clara** de preocupações
✅ **Validação controlada** pelo Orchestrator
✅ **Context awareness** - Orchestrator tem visão completa
✅ **Agents focados** - só desenvolvimento, sem distrações
✅ **Decisões informadas** - Orchestrator correlaciona tudo

---

**Resumo em uma frase**: Agents desenvolvem, Orchestrator valida e gerencia.
