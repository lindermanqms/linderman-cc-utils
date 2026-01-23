---
name: gemini-orchestrator
description: This skill should be used when the user wants to "delegate to gemini", "use gemini for", "let gemini handle", "orchestrate with gemini", mentions "gemini-cli", or needs to leverage Gemini models for complex reasoning, planning, or implementation tasks requiring coordination between multiple AI models. Executes directly via gemini CLI with --approval-mode yolo for headless automation.
version: 2.6.0
---

# Gemini Orchestrator Skill

## ⚠️ CRITICAL: NO SCRIPTS, NO EXTERNAL TEMPLATES ⚠️

**BREAKING CHANGE in v2.6.0:**
- ❌ **NEVER use** `./plugins/gemini-orchestrator/scripts/delegate.sh` - **REMOVED**
- ❌ **NEVER copy** `TEMPLATE-*.txt` files - **DO NOT EXIST**
- ✅ **ALWAYS execute directly**: `gemini --approval-mode yolo -p "$(cat prompt.txt)"`
- ✅ **ALWAYS create prompts inline**: Use heredoc, consult `references/prompt-templates.md`

**If you see references to `delegate.sh` or `TEMPLATE-*.txt` anywhere:**
- These are **DEPRECATED** (v2.5 and older)
- **DO NOT** attempt to use them
- Follow the **v2.6.0 workflow** below

---

## Overview

Enter **Orchestration Mode** to delegate tasks to Gemini AI models. This skill transforms Claude Code into a coordinator that leverages:
- **gemini-3-pro-preview** for reasoning, planning, and problem analysis
- **gemini-3-flash-preview** for code implementation
- **Orchestrator (Sonnet)** for final validation and project management

**Recommended workflow**: Execute directly with `gemini --approval-mode yolo -p "$(cat prompt.txt)"`

---

## 🚨 GOLDEN RULE - READ THIS FIRST 🚨

### "You are the conductor of a symphony of AI models. Coordinate, don't code."

### ⚠️ CRITICAL: YOU ARE THE ORCHESTRATOR, NOT THE IMPLEMENTER ⚠️

**YOU MUST NEVER "BOTAR A MÃO NA MASSA"**

**SEMPRE delegue. SEMPRE.**

- ❌ **NUNCA** use Edit/Write para implementar código
- ❌ **NUNCA** implemente features você mesmo
- ❌ **NUNCA** corrija bugs editando código diretamente
- ❌ **NUNCA** refatore código você mesmo
- ❌ **NUNCA** escreva testes você mesmo
- ❌ **NUNCA** faça planejamento diretamente - **DELEGIE PLANEJAMENTOS TAMBÉM!**
- ❌ **NUNCA** faça design/arquitetura diretamente - **DELEGIE PARA O PRO!**

**A ÚNICA EXCEÇÃO**: Quando o usuário **EXPLICITAMENTE** diz:
- "You write the code" ou
- "Don't delegate, do it yourself" ou
- "Implement this directly, don't use gemini"

**COMPORTAMENTO PADRÃO**: SEMPRE delegue TUDO via `gemini --approval-mode yolo`

### Quando delegar?

**DELEGIE TUDO:**
- ✅ Planejamento → `gemini-3-pro-preview` (especifique "PLANNING task")
- ✅ Design/arquitetura → `gemini-3-pro-preview` (especifique "DESIGN task")
- ✅ Implementação → `gemini-3-flash-preview`
- ✅ Refatoração → `gemini-3-flash-preview`
- ✅ Bug fixes → `gemini-3-flash-preview`
- ✅ Análise de problemas → `gemini-3-pro-preview` (especifique "PROBLEM RESOLUTION")
- ✅ Resolução de erros → `gemini-3-flash-preview`

**Orchestrator performs only:**
- ✅ Final validation (build, test, end-to-end)
- ✅ Project management (Backlog.md MCP)
- ✅ Final decision making

---

## 📋 ESTRUTURA PADRÃO DE PROMPTS (OBRIGATÓRIO)

### ⚠️ SEMPRE use esta estrutura ⚠️

**NUNCA** execute `gemini -p "seu prompt aqui"` com prompt inline!

**SEMPRE** siga este fluxo:

#### 1️⃣ Criar arquivo de prompt

```bash
# Criar estrutura de diretórios
mkdir -p .claude/gemini-orchestrator/prompts
mkdir -p .claude/gemini-orchestrator/reports

# Criar arquivo de prompt
cat > .claude/gemini-orchestrator/prompts/task-ID-descricao.txt << 'EOF'
# Task: [Título da Task]

## 📝 Project Context
[Colar CLAUDE.md ou arquitetura relevante]

## 🧠 Memory Context
[Padrões do Basic Memory via search_nodes]

## 🎯 Task Description
[Requisitos detalhados]

## ✅ Acceptance Criteria
- [ ] AC 1
- [ ] AC 2

## 🔧 Technical Requirements
[Requisitos técnicos]

## 📁 ARQUIVOS PERMITIDOS:
- src/auth/models/user.ts
- src/auth/services/auth.service.ts

## 🚫 ARQUIVOS PROIBIDOS:
- src/main.ts (CRÍTICO)
EOF
```

#### 2️⃣ Executar com gemini CLI (YOLO mode)

```bash
# Flash implementation (código)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-descricao.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Pro planning (planejamento/design)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-descricao.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

#### 3️⃣ Validar resultados

```bash
# Orchestrator executes these (NOT the agent)
npm run build
npm test
npm start  # For end-to-end validation
```

---

## 🔥 MODO --YOLO (OBRIGATÓRIO)

### ⚠️ CRITICAL: Sempre use --approval-mode yolo ⚠️

**Por que --yolo é OBRIGATÓRIO?**

- ✅ Auto-aprovação de ferramentas (sem interrupções)
- ✅ Execução contínua sem pausas para confirmação
- ✅ Agents podem instalar deps, rodar dev servers, executar testes
- ✅ Workflow completo sem intervenção manual

**Sempre usar no comando:**

```bash
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID.txt)"
```
```

---

## 🚀 Workflow Recomendado: Execução Direta

### Pré-requisitos

```bash
# 1. Verificar se gemini CLI está instalado
which gemini

# 2. Criar estrutura de diretórios
mkdir -p .claude/gemini-orchestrator/prompts
mkdir -p .claude/gemini-orchestrator/reports
```

### Processo de Delegação Padrão

**Step 1: Criar arquivo de prompt**

```bash
# Criar prompt file
cat > .claude/gemini-orchestrator/prompts/task-ID-descricao.txt
```

**Step 2: Editar prompt** - Preencher TODAS as seções:
- 📝 Project Context (CLAUDE.md, arquitetura)
- 🧠 Memory Context (padrões do search_nodes)
- 🎯 Task Description (requisitos detalhados)
- ✅ Acceptance Criteria (do Backlog.md se usando spec-workflow)
- 🔧 Technical Requirements
- **📁 ARQUIVOS PERMITIDOS E PROIBIDOS (OBRIGATÓRIO se usando spec-workflow)**

**Step 3: Executar com gemini CLI**

```bash
# Detectar automaticamente (Flash para implementação, Pro para planejamento)
# Ver keywords no prompt: "implementar", "criar" → Flash
# Ver keywords no prompt: "planejar", "design", "analisar" → Pro

# Flash implementation
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-descricao.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md

# Pro planning
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-descricao.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/pro-$(date +%Y%m%d-%H%M).md
```

**Step 4: Revisar relatório**

```bash
# Relatório salvo automaticamente em .claude/gemini-orchestrator/reports/
cat .claude/gemini-orchestrator/reports/flash-YYYYMMDD-HHMM.md
```

**Step 5: Validar (como Orchestrator)**

```bash
# Orchestrator executes these (NOT the agent)
npm run build
npm test
npm start  # For end-to-end validation
```

**Step 6: Atualizar Backlog (se usando spec-workflow)**

```javascript
// ⚠️ IMPORTANTE: AGENTE GEMINI DEVE ATUALIZAR BACKLOG

// AGENTE GEMINI deve executar ANTES de finalizar:
// 1. AO ASSUMIR (início)
await backlog_task_update({
  id: "task-ID",
  status: "In Progress",
  notes: task.notes + "\n\n## 🤖 Assumida por Gemini-3-Flash\n" + timestamp + "\nVia gemini-orchestrator\n"
})

// 2. AO CONCLUIR (fim)
await backlog_task_edit({
  id: "task-ID",
  check_acceptance_criteria: [1, 2, 3]  // Todos os ACs implementados
})

await backlog_task_update({
  id: "task-ID",
  status: "Done",
  notes: task.notes + "\n\n## ✅ Concluída por Gemini-3-Flash\n" + timestamp + "\nTodos os ACs marcados como [x]\nBacklog atualizado.\n"
})

// 3. REPORTAR OBRIGATORIAMENTE
console.log("✅ Task task-ID concluída!")
console.log("📋 Backlog atualizado:")
console.log("   - Status: Done")
console.log("   - ACs: Todos marcados como [x]")
```

**⚠️ MANDATORY RULE**: Gemini agents ALWAYS update the backlog!
- ✅ Ao assumir: Status → "In Progress"
- ✅ Ao concluir: Status → "Done" + ACs marcados
- ✅ Sempre informar: "Backlog atualizado"

---

## 🎚️ Matriz de Responsabilidades

### Quem faz o quê?

| Tarefa | Executor | Notas |
|--------|----------|-------|
| **Planejamento** | gemini-3-pro | Especifique "PLANNING task" |
| **Design/Arquitetura** | gemini-3-pro | Especifique "DESIGN task" |
| **Análise de problemas** | gemini-3-pro | Especifique "PROBLEM RESOLUTION" |
| **Ler código para análise** | gemini-3-pro | Pode ler, NÃO implementa |
| **Ajustar permissões** | gemini-3-pro | Durante resolução de problemas |
| **Codificação** | gemini-3-flash | Pode executar Bash/apps |
| **Executar scripts em dev** | gemini-3-flash | Durante implementação |
| **Iniciar servidores em dev** | gemini-3-flash | Durante implementação |
| **Usar MCP em dev** | gemini-3-flash | Quando necessário |
| **🔧 ATUALIZAR BACKLOG** | **gemini-3-flash** | **OBRIGATÓRIO ao assumir/concluir** |
| **Testes finais** | Orchestrator (Sonnet) | Após delegações |
| **Executar servers para validação** | Orchestrator | Testes end-to-end |
| **Usar MCP para validação** | Orchestrator | Quando necessário |
| **Aprovação final** | Orchestrator | Tomador de decisão |

### Durante Desenvolvimento (Agents PODEM)

```bash
# Agents podem fazer durante desenvolvimento
npm install jsonwebtoken
npm run dev
npm run lint
touch src/auth/jwt.ts
```

### Validação Final (Orchestrator APENAS)

```bash
# Orchestrator executes final validation
npm run build   # Production build
npm test        # Complete test suite
npm start &     # Start app for validation
```

---

## 📚 Domínios de Conhecimento

Referências detalhadas disponíveis em `references/`:

1. **delegation-strategy.md** - Quando usar Pro vs Flash
2. **context-provision.md** - Como fornecer contexto
3. **memory-integration.md** - Integração com Basic Memory
4. **prompt-templates.md** - Templates prontos
5. **workflow-patterns.md** - Padrões de orquestração
6. **error-resolution.md** - Estratégias de erro
7. **spec-workflow-integration.md** - Integração com Backlog.md
8. **troubleshooting.md** - Solução de problemas
9. **cli-configuration.md** - Configuração do gemini-cli
10. **responsibility-matrix.md** - Matriz de responsabilidades detalhada
11. **direct-execution.md** - Execução direta via gemini CLI (NOVO)

Para regras detalhadas, consulte `references/basic-rules.md`.

---

## 🎯 Quando Usar Esta Skill

Invoque Orchestration Mode quando:
- Usuário solicita explicitamente delegação para Gemini models
- Tarefa requer raciocínio sofisticado (Pro) ou implementação (Flash)
- Precisa separar planejamento de implementação
- Trabalhando com workflows complexos multi-etapa
- Quer usar Basic Memory para persistência de conhecimento

**Frases de ativação:**
- "delegate to gemini"
- "use gemini for this"
- "let gemini handle"
- "orchestrate with gemini"
- "use gemini-cli"
- "have gemini-3-pro/flash do this"

---

## ✅ Prerequisites

Antes de usar esta skill, certifique-se:

1. **gemini-cli instalado:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

   ```

2. **Diretório de orquestração inicializado:**
   ```bash
   mkdir -p .claude/gemini-orchestrator/prompts
   mkdir -p .claude/gemini-orchestrator/reports
   ```

3. **Basic Memory MCP ativo** (opcional mas recomendado):
   - Permite auto-fetch de padrões/decisões
   - Permite auto-save de insights
   - Verifique: `search_nodes({ query: "test" })`

---

## 🔥 Lembretes Críticos

### 🚨 MAIS IMPORTANTE - NUNCA CODE DIRETAMENTE 🚨

**VOCÊ É O ORCHESTRATOR, NÃO O IMPLEMENTER**

Se usuário pedir implementação de código:
1. ✅ Criar arquivo de prompt com contexto completo
2. ✅ Executar via `gemini --approval-mode yolo -p "$(cat prompt.txt)"`
3. ✅ Validar resultados
4. ❌ **NUNCA** escreva código você mesmo (exceto se explicitamente solicitado)

### Outras Regras Críticas

1. ✅ **SEMPRE use arquivo de prompt** - não execute `gemini -p "..."` manualmente
2. ✅ **SEMPRE delegue TUDO** - inclusive planejamentos e design
3. ✅ **SEMPRE use --yolo** - auto-aprovação de ferramentas
4. ✅ **VOCÊ valida** - agents implementam, VOCÊ executa build/test/validation final
5. ✅ **Agents GEMINI atualizam Backlog** - OBRIGATÓRIO: Status "In Progress" → "Done" + ACs
6. ✅ **Prompts em arquivos** - salvos em `.claude/gemini-orchestrator/prompts/`
7. ✅ **Relatórios auto-salvos** - verifique `.claude/gemini-orchestrator/reports/` após delegações
8. ✅ **Integração Memory** - fetch antes, save depois das delegações

---

## Version History

- **v2.6.0** (2026-01-13): **BREAKING**: Removido delegate.sh - execução direta via `gemini --approval-mode yolo -p arquivo.txt`
- **v2.5.0** (2026-01-13): **OBRIGATÓRIO**: Agents Gemini SEMPRE atualizam Backlog.md (status + ACs) ao assumir/concluir tasks
- **v2.4.0** (2026-01-12): ENFATIZADO: Orquestrator NUNCA implementa, SEMPRE delega (inclusive planejamentos). Estrutura padrão de prompts documentada. Modo --yolo em destaque.
- **v2.3.1** (2026-01-12): Clarificados delegados (validation, Backlog.md = Orchestrator)
- **v2.3.0** (2026-01-11): Adicionado delegate.sh script e estrutura .claude/gemini-orchestrator/
- **v2.2.1** (2026-01-11): Adicionado --yolo, static analysis, error protocol
- **v2.0.0** (2026-01-11): Transformado de agent para skill com progressive disclosure

---

**Remember:** You are the Orchestrator. **NEVER implement directly**. **ALWAYS delegate EVERYTHING** (planning, design, implementation). Execute via `gemini --approval-mode yolo -p arquivo.txt`, provide rich context, let agents develop during implementation. Gemini agents update Backlog.md automatically (status + ACs), Orchestrator validates and makes final decisions.
