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

**Delegação simples:**
```
User: "Delegate to gemini: implement JWT authentication"

Orchestrator:
├─ Busca padrões de auth no memory
├─ Coleta contexto (CLAUDE.md, specs)
├─ Delega para gemini-3-flash (implementação)
├─ Salva padrões descobertos no memory
├─ Roda testes
└─ Reporta resultados
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

- **SKILL.md**: Visão geral conciso (600-800 palavras)
- **references/**: Documentação técnica detalhada

### Guias de Referência

1. **[`delegation-strategy.md`](skills/gemini-orchestrator/references/delegation-strategy.md)**
   Quando usar cada modelo Gemini (Pro vs Flash vs Explore)

2. **[`context-provision.md`](skills/gemini-orchestrator/references/context-provision.md)**
   Como fornecer contexto completo aos modelos Gemini

3. **[`memory-integration.md`](skills/gemini-orchestrator/references/memory-integration.md)**
   Integração com Basic Memory: auto-fetch e auto-save

4. **[`prompt-templates.md`](skills/gemini-orchestrator/references/prompt-templates.md)**
   Templates prontos para delegações a gemini-3-pro e gemini-3-flash

5. **[`workflow-patterns.md`](skills/gemini-orchestrator/references/workflow-patterns.md)**
   Padrões de orquestração: Simple, Complex, Error Resolution

6. **[`error-resolution.md`](skills/gemini-orchestrator/references/error-resolution.md)**
   Estratégias para tratar erros durante orquestração

7. **[`spec-workflow-integration.md`](skills/gemini-orchestrator/references/spec-workflow-integration.md)**
   Integração com plugin spec-workflow (Backlog.md)

8. **[`troubleshooting.md`](skills/gemini-orchestrator/references/troubleshooting.md)**
   Solução de problemas: gemini-cli, API key, Memory

9. **[`responsibility-matrix.md`](skills/gemini-orchestrator/references/responsibility-matrix.md)**
   Matriz de responsabilidades: Quem faz o quê

10. **[`cli-configuration.md`](skills/gemini-orchestrator/references/cli-configuration.md)**
    Configuração do gemini-cli: `--yolo`, `--approval-mode`, MCP, ferramentas

11. **[`delegate-script-workflow.md`](skills/gemini-orchestrator/references/delegate-script-workflow.md)**
    Workflow simplificado com script `delegate.sh` para execução de prompts

## Scripts de Apoio

### `delegate.sh`

Script helper para executar delegações de forma padronizada:

```bash
# Auto-detecta modelo e executa
./plugins/gemini-orchestrator/scripts/delegate.sh prompts/implement-auth.txt

# Ver ajuda
./plugins/gemini-orchestrator/scripts/delegate.sh -h
```

**Recursos**:
- ✅ Lê prompts de arquivos (evita problemas de parsing)
- ✅ Auto-detecta modelo (Pro vs Flash) baseado em keywords
- ✅ Salva relatórios automaticamente em `.gemini-orchestration/reports/`
- ✅ Extrai relatórios estruturados
- ✅ Histórico organizado de delegações

Consulte `.gemini-orchestration/README.md` para workflow completo.

## Recursos Adicionais

- **CHANGELOG.md**: Histórico de versões
- **Plugin Manifest**: `plugins/gemini-orchestrator/.claude-plugin/plugin.json`
- **Marketplace**: `.claude-plugin/marketplace.json`

## Versão

**v2.3.0** (2026-01-11)
- 📚 **CLARIFICAÇÃO IMPORTANTE**: Como scripts funcionam
  - Adicionada seção "How Scripts Work" no SKILL.md
  - Scripts NÃO são copiados para o projeto
  - Scripts são executados diretamente de `plugins/gemini-orchestrator/scripts/`
  - Rationale: single source of truth, auto-updates, sem duplicação
- 📁 **NOVA estrutura examples/**
  - `simple-delegation.md` - Workflow de task única
  - `complex-orchestration.md` - Workflow multi-fase (Pro→Flash)
  - Removidos exemplos extensos do SKILL.md (compactado de ~4,200 para ~2,244 palavras)
- 🎯 **description atualizada**: Agora menciona "delegate.sh" e localização dos scripts

**v2.2.4** (2026-01-11)
- 🚨 **REFORÇO CRÍTICO**: GOLDEN RULE enfatizada ao máximo no SKILL.md
  - Orchestrator NUNCA deve escrever código (exceto se usuário pedir explicitamente)
  - Adicionada seção proeminente "🚨 GOLDEN RULE - NEVER BREAK THIS 🚨"
  - RULE #0 adicionada nas Basic Rules
  - Critical Reminders reorganizada para começar com este aviso

**v2.2.3** (2026-01-11)
- 🐛 **BUGFIX CRÍTICO**: Corrigida flag de aprovação automática no delegate.sh
  - Antes: `--yolo` (sintaxe incorreta, causava erro)
  - Depois: `--approval-mode yolo` (sintaxe correta)
  - Script agora funciona corretamente!

**v2.2.2** (2026-01-11)
- ✅ SKILL.md reescrito para reforçar uso do delegate.sh
- ✅ Eliminadas ambiguidades sobre método de delegação
- ✅ Script path e approval mode claramente documentados

**v2.2.1** (2026-01-11)
- ✅ Clarificação: Agents podem rodar comandos durante dev, mas NÃO fazem validação final
- ✅ Backlog.md MCP é exclusivamente responsabilidade do Orchestrator
- ✅ Validação final (build, tests, servers) é do Orchestrator

**v2.2.0** (2026-01-11)
- ✅ Script `delegate.sh` para execução padronizada
- ✅ Templates de prompt (Pro e Flash)
- ✅ Estrutura `.gemini-orchestration/` para organização
- ✅ Auto-detecção de modelo baseada em keywords
- ✅ Salvamento automático de relatórios

**v2.1.1** (2026-01-11)
- ✅ Flag `--yolo` para autonomia completa dos agentes
- ✅ Checagem estática obrigatória antes de relatórios
- ✅ Protocolo de erro (3 tentativas) para resiliência
- ✅ Limitações de operações destrutivas (apenas Orchestrator)

**v2.0.0** (2026-01-11) - Transformado de agent para skill com progressive disclosure

---

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**
