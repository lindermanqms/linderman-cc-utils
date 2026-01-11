# Changelog - Gemini Orchestrator Plugin

## [1.0.0] - 2026-01-11

### Added
- **Agent**: `gemini-orchestrator` - Sistema completo de orquestração para Gemini models
- **Skill**: `gemini-delegate` - Skill para facilitar invocação do orchestrator
- **Documentação**: README.md completo com exemplos e troubleshooting
- **Integração**: Basic Memory MCP para auto-fetch e auto-save de conhecimento
- **Workflows**: Delegação simples, orquestração complexa, error resolution

### Features

#### Delegation Strategy
- `gemini-3-pro-preview`: Planning, architecture design, problem analysis
- `gemini-3-flash-preview`: Implementation, coding, bug fixes
- Auto-selection baseado no tipo de task

#### Context Gathering
- Coleta automática de CLAUDE.md, specs, documentação
- Integração com Explore agent para análise de codebase
- Inclusão de URLs de referência técnica
- Fetch automático de conhecimento do Basic Memory

#### Memory Integration
- **Auto-fetch**: Busca padrões, decisões e erros antes de delegações
- **Auto-save**: Salva ADRs, patterns e error resolutions automaticamente
- **Prefixação**: Namespace automático por projeto (`{slug}/*`)
- **Relações**: Criação de relações entre entidades

#### Spec-Workflow Integration
- Lê Acceptance Criteria de specs
- Usa ACs como requisitos em delegações
- Atualiza task notes com progresso
- Sugere `/spec-review` após conclusão

### Prompt Templates
- Template para gemini-3-pro-preview (reasoning/planning)
- Template para gemini-3-flash-preview (coding)
- Estrutura de contexto padronizada

### Workflow Patterns
1. Simple Delegation (7 steps)
2. Complex Orchestration (multi-phase)
3. Error Resolution (memory-aware)

### Components
```
Repository root:
└── agents/
    └── gemini-orchestrator.md   # Agent definition (815 lines)

plugins/gemini-orchestrator/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── gemini-delegate/
│       └── SKILL.md
├── README.md
└── CHANGELOG.md
```

### Prerequisites
- `gemini-cli` installed globally: `npm install -g gemini-cli`
- `GEMINI_API_KEY` environment variable configured
- Basic Memory MCP active (for memory integration)

### Trigger Phrases
- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "orchestrate with gemini"
- "gemini-cli"

### Absolute Rules
1. ❌ NEVER use Edit/Write tools for code implementation
2. ❌ NEVER use Bash for coding - only for calling gemini-cli
3. ✅ ALWAYS delegate coding to gemini-3-flash-preview
4. ✅ ALWAYS delegate planning to gemini-3-pro-preview
5. ✅ ALWAYS provide EXPLICIT CONTEXT to Gemini agents
6. ✅ CAN invoke Explore agent for codebase analysis
7. ✅ EXECUTE final tests and validations (as Sonnet)
8. ✅ ALWAYS fetch from memory before delegations
9. ✅ ALWAYS save important insights to memory
10. ✅ ALWAYS use project slug prefix for memory entities

### Responsibility Matrix

| Task | Executor | Notes |
|------|----------|-------|
| Planning/Design | gemini-3-pro | Specify "PLANNING task" |
| Problem analysis | gemini-3-pro | Specify "PROBLEM RESOLUTION" |
| Coding | gemini-3-flash | Can execute Bash/scripts |
| Final tests | Orchestrator (Sonnet) | After delegations |
| Final approval | Orchestrator | Decision maker |

---

**Initial Release**: Complete orchestration system ready for global use across projects.
