# Gemini Orchestrator Plugin

Skill de orquestração para delegar tarefas complexas aos modelos Gemini através do `gemini-cli`, com coleta automática de contexto e integração com Basic Memory.

## O que é

O **Gemini Orchestrator** transforma Claude Code em um coordenador que delega tarefas para os modelos Gemini apropriados:

- **gemini-3-pro-preview**: Planejamento, design, análise de problemas
- **gemini-3-flash-preview**: Implementação, codificação, correção de bugs
- **Claude Code (Orchestrator)**: Validação final, testes, aprovação

### Princípio Core

> **"You are the conductor of a symphony of AI models. Coordinate, don't code."**

Quando ativo, Claude Code:
- **NUNCA** escreve código diretamente - delega para o modelo Gemini apropriado
- **SEMPRE** fornece contexto completo - documentação, arquivos, URLs, memória
- **EXECUTA** validação final - roda testes e verifica resultados como Sonnet
- **INTEGRA** com Basic Memory - busca conhecimento antes, salva insights depois

## Instalação

### Pré-requisitos

1. **Instalar gemini-cli:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

2. **Configurar API key do Gemini:**
   ```bash
   export GEMINI_API_KEY="sua-chave-aqui"
   # Adicionar ao ~/.bashrc ou ~/.zshrc para persistência
   ```

3. **Basic Memory MCP** (opcional, recomendado):
   - Habilita busca automática de padrões/decisões antes de delegações
   - Habilita salvamento automático de insights após delegações
   - Requer servidor Basic Memory MCP configurado

### Ativar Plugin

Este plugin já está registrado no marketplace `linderman-cc-utils`. Basta usar os triggers de ativação.

## Como Usar

### Invocação Automática

A skill é automaticamente ativada quando você usa estas frases:

- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "orchestrate with gemini"
- "gemini-cli"

### Exemplos Rápidos

**⚠️ IMPORTANT - v2.6.0 Breaking Changes:**
- ❌ **DO NOT use** `delegate.sh` script (removed)
- ❌ **DO NOT copy** `TEMPLATE-*.txt` files (do not exist)
- ✅ **ALWAYS** create prompts inline and execute directly via `gemini-cli`

**Exemplo rápido:**
```bash
# 1. Create prompt file inline
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
[See references/prompt-templates.md for complete templates]
EOF

# 2. Execute directly via gemini-cli
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md
```

**Orquestração complexa:**
```
User: "Let gemini design and implement the API layer"

Orchestrator:
├─ FASE 1: gemini-3-pro (design)
├─ FASE 2: gemini-3-flash (implementação)
├─ FASE 3: Validação (Sonnet)
└─ Reporta resultados consolidados
```

**Resolução de erros:**
```
User: "Use gemini to fix this error"

Orchestrator:
├─ Verifica memory por erros similares
├─ Se encontrado: aplica solução conhecida
├─ Se não: gemini-3-pro (diagnóstico) → gemini-3-flash (fix)
└─ Salva resolução no memory
```

## Documentação Completa

A skill usa **progressive disclosure** - conteúdo detalhado é carregado sob demanda.

### Arquivos da Skill

- **SKILL.md**: Visão geral e instruções essenciais
- **references/**: Documentação técnica detalhada
- **examples/**: Exemplos completos de workflows

### Guias de Referência

1. **[`prompt-templates.md`](skills/gemini-orchestrator/references/prompt-templates.md)**
   Templates completos para criar prompts inline (Flash e Pro)

2. **[`delegation-strategy.md`](skills/gemini-orchestrator/references/delegation-strategy.md)**
   Quando usar cada modelo Gemini (Pro vs Flash vs Explore)

3. **[`workflow-patterns.md`](skills/gemini-orchestrator/references/workflow-patterns.md)**
   Padrões de orquestração: Simple, Complex, Error Resolution

4. **[`memory-integration.md`](skills/gemini-orchestrator/references/memory-integration.md)**
   Integração com Basic Memory: auto-fetch e auto-save

5. **[`spec-workflow-integration.md`](skills/gemini-orchestrator/references/spec-workflow-integration.md)**
   Integração com plugin spec-workflow (Backlog.md)

6. **[`responsibility-matrix.md`](skills/gemini-orchestrator/references/responsibility-matrix.md)**
   Matriz de responsabilidades: Quem faz o quê

7. **[`troubleshooting.md`](skills/gemini-orchestrator/references/troubleshooting.md)**
   Solução de problemas: gemini-cli, API key, Memory

## Recursos Adicionais

- **CHANGELOG.md**: Histórico de versões
- **examples/**: Exemplos completos de workflows
  - `simple-delegation.md` - Workflow de task única
  - `complex-orchestration.md` - Workflow multi-fase (Pro→Flash)

## Versão

**v2.6.0** (2026-01-17) - **BREAKING CHANGE**
- 🔥 **REMOVIDO**: Scripts `delegate.sh` e `extract-report.sh`
  - **Motivo**: Path discovery impossível - agents não conseguiam encontrar scripts no cache do plugin
  - **Solução**: Execução direta via `gemini --approval-mode yolo -p "$(cat arquivo.txt)"`
- 🔥 **REMOVIDO**: Diretório `templates/` externo
  - **Motivo**: Templates externos não eram encontráveis pelo agente
  - **Solução**: Templates inline em `references/prompt-templates.md` + criação via heredoc
- ✅ **NOVO**: Instruções completas de criação inline de prompts
- ✅ **MELHORADO**: Documentação atualizada sem dependências de arquivos externos
- ✅ **CORRIGIDO**: Violações de segunda pessoa no SKILL.md (forma imperativa)

**Migração de v2.5 para v2.6:**
```bash
# ANTES (v2.5)
cp templates/TEMPLATE-flash.txt prompts/task-10.txt
./plugins/gemini-orchestrator/scripts/delegate.sh prompts/task-10.txt

# AGORA (v2.6)
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
[conteúdo do template - veja references/prompt-templates.md]
EOF
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md
```

---

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**
