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

## Recursos Adicionais

- **CHANGELOG.md**: Histórico de versões
- **Plugin Manifest**: `plugins/gemini-orchestrator/.claude-plugin/plugin.json`
- **Marketplace**: `.claude-plugin/marketplace.json`

## Versão

**v2.0.0** (2026-01-11) - Transformado de agent para skill com progressive disclosure

---

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**
