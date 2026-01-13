# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code plugin marketplace** that hosts custom plugins for Claude Code. The marketplace enables distribution of specialized skills and tools to enhance Claude Code's capabilities.

Currently contains:
- **pje-extensions**: Plugin providing skills for developing Chrome extensions for PJe (Processo Judicial Eletrônico - Brazilian court system, specifically TRF5)
- **reverse-engineering-utils**: General purpose tools for web reverse engineering and HAR analysis
- **spec-workflow**: Workflow Spec-Driven Development com integração Backlog.md e Basic Memory
- **gemini-orchestrator**: Sistema de orquestração para delegar tarefas complexas aos modelos Gemini (Pro para planejamento, Flash para implementação) com coleta automática de contexto e integração com memória

## Architecture

### Marketplace Structure

```
linderman-cc-utils/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
└── plugins/
    └── {plugin-name}/
        ├── .claude-plugin/
        │   └── plugin.json        # Plugin manifest
        └── skills/
            └── {skill-name}/
                ├── SKILL.md       # Skill definition and metadata
                └── references/    # Progressive disclosure documentation
```

### Plugin System

**Marketplace manifest** (`.claude-plugin/marketplace.json`):
- Defines marketplace owner and registered plugins
- Each plugin entry specifies name, source path, and description

**Plugin manifest** (`plugins/{name}/.claude-plugin/plugin.json`):
- Contains plugin metadata (name, description, version, author)
- Points to skills directory location

### Skills Architecture

Skills use **progressive disclosure** pattern for documentation:

1. **SKILL.md**: Lightweight skill definition (~600 words)
   - Frontmatter with name, description, version, trigger phrases
   - Overview and usage guidance
   - Points to reference documentation

2. **references/**: Detailed domain-specific documentation
   - Only loaded when specific information is needed
   - Each file focuses on a single topic
   - Enables unlimited documentation without context bloat

**Example**: The `pje-reverse-engineering` skill:
- SKILL.md loads initially with overview
- When user asks about "PJe API endpoints", reads `references/api-endpoints.md`
- When user asks about "PJe authentication", reads `references/authentication.md`

## Working with Plugins

### Adding a New Plugin

1. Create directory structure:
   ```bash
   mkdir -p plugins/{plugin-name}/.claude-plugin
   mkdir -p plugins/{plugin-name}/skills
   ```

2. Create plugin manifest at `plugins/{plugin-name}/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "plugin-name",
     "description": "Plugin description",
     "version": "0.1.0",
     "author": {
       "name": "Author Name",
       "email": "email@example.com"
     },
     "skills": "./skills/"
   }
   ```

3. Register plugin in `.claude-plugin/marketplace.json`:
   ```json
   {
     "plugins": [
       {
         "name": "plugin-name",
         "source": "./plugins/plugin-name",
         "description": "Plugin description"
       }
     ]
   }
   ```

### Creating a Skill

1. Create skill directory: `plugins/{plugin-name}/skills/{skill-name}/`

2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Trigger phrases and when to use this skill
   version: 0.1.0
   ---
   ```

3. Add skill documentation following progressive disclosure:
   - Keep SKILL.md focused on overview and usage
   - Place detailed documentation in `references/` subdirectory
   - Create topic-focused reference files (api-endpoints.md, authentication.md, etc.)

### Skill Trigger Patterns

The `description` field in SKILL.md frontmatter should specify:
- Exact phrases that trigger the skill
- Conceptual questions the skill handles
- Domain knowledge the skill provides

**Example from pje-reverse-engineering**:
```
description: This skill should be used when the user asks about "PJe internal structure", "PJe endpoints", "PJe API", "how PJe works internally", "reverse engineering PJe", or needs to consult technical knowledge about the Brazilian court system PJe (TRF5).
```

## PJe Extensions Plugin

Focused on developing Chrome extensions for the PJe (Processo Judicial Eletrônico) system used by TRF5 (Tribunal Regional Federal da 5ª Região).

### Current Skills

**pje-reverse-engineering**: Knowledge base for PJe's internal architecture
- API endpoint structures and authentication
- Frontend architecture and JavaScript patterns
- Data models and entity relationships
- DOM structure and selectors for extension development

### Reference Documentation Pattern

The skill uses `references/` directory for modular documentation:
- `api-endpoints.md`: REST API catalog, parameters, examples
- `authentication.md`: Auth mechanisms, session management
- `data-models.md`: Entity structures, relationships, validation
- `frontend-architecture.md`: Framework analysis, state management
- `dom-structure.md`: Selectors, form structures, dynamic content
- `network-patterns.md`: AJAX patterns, error handling
- `extension-integration.md`: Best practices for Chrome extensions

As knowledge is gathered through reverse engineering, add focused reference files following this structure.

## Development Workflow

### Modifying Skills

1. Update SKILL.md if changing overview, triggers, or usage patterns
2. Add/update reference files in `references/` for specific documentation
3. Keep reference files focused on single topics for modularity

### Testing Skills

Skills are loaded by Claude Code when:
- The marketplace is active in user's environment
- Trigger phrases from skill descriptions are matched
- User explicitly invokes the skill

### Version Management

When updating:
- Increment skill version in SKILL.md frontmatter
- Increment plugin version in plugin.json if adding/removing skills
- No need to increment marketplace.json version (it's a registry)

## Key Principles

1. **Progressive Disclosure**: Keep initial context lean, load details on-demand
2. **Modular Documentation**: One reference file per topic
3. **Trigger Clarity**: Explicitly define when skills should activate
4. **Domain Focus**: Each skill serves a specific domain or use case

---

## Spec-Workflow Plugin (v2.0)

Este projeto utiliza o plugin **spec-workflow** para gerenciamento de projeto via **Spec-Driven Development** integrado 100% ao **Backlog.md MCP**.

### Filosofia Spec-Driven Development

**Princípios Fundamentais:**
1. **Plan-First**: Toda feature DEVE ter um Plan (Spec) antes de implementação
2. **AC Obrigatório**: Toda task DEVE ter Acceptance Criteria verificáveis
3. **MCP-Only**: NUNCA editar arquivos `.backlog` manualmente
4. **Specs são Plans**: Specs são o campo `plan` das tasks (NÃO são arquivos `.backlog` separados)
5. **Documentos são .backlog**: Documentos permanentes (constituição, padrões) usam extensão `.backlog`
6. **Revisão Obrigatória**: Código DEVE passar por `/spec-review` antes de `/spec-retro`
7. **Memória Ativa**: Aprendizados críticos DEVEM ser salvos no Basic Memory

**⚠️ DISTINÇÃO CRÍTICA:**
- **Specs (Plans)** = Campo `plan` das tasks (estratégia de implementação)
- **Documentos** = Artefatos permanentes em `docs/standards/*.backlog` (constituição, padrões)

### Integração com Backlog.md MCP

O plugin utiliza o servidor MCP **Backlog.md** (https://github.com/MrLesk/Backlog.md) para gerenciar:

**Tasks Completas** com TODOS os campos MCP:
```javascript
backlog_task_create({
  title, type, status,
  priority,      // critical, high, medium, low
  labels,        // ["backend", "security", "api"]
  milestone,     // "v1.0 - MVP"
  assignee,      // "@Claude"
  dependencies,  // ["task-5", "task-12"]
  acceptance_criteria,  // ["[ ] AC1", "[ ] AC2"]
  plan,          // Plano de implementação estruturado
  notes          // Observações incrementais
})
```

**Specs (Plans das Tasks):**
- **Localização**: Campo `plan` das tasks (NÃO são arquivos separados)
- **Formato**: Markdown com estratégia de implementação
- **Conteúdo**: Requisitos, arquitetura, passos de implementação, riscos

**Documentos de Padrões** (Constituição):
- Localização: `backlog/docs/standards/*.backlog`
- CRUD via MCP: `backlog_doc_create`, `backlog_doc_update`, etc.
- Extensão: `.backlog` (OBRIGATÓRIA)

**ADRs** (Architecture Decision Records):
- Criação: `backlog_decision_create({ title, context, decision, consequences, alternatives, status })`
- Listagem: `backlog_decision_list()`

### Comandos Disponíveis

#### Ciclo de Vida
- `/spec-init` - Inicializar ambiente (CLI validation, migration, config)
- `/spec-plan` - Criar task + spec com TODOS os campos MCP
- `/spec-execute` - Executar task (dependency check, subtasks, incremental notes)
- `/spec-review` - Revisar (automatic AC validation, blocking logic)
- `/spec-retro` - Finalizar (4-item checklist, milestone progress, Basic Memory)

#### Gerenciamento
- `/spec-replan` - Reestruturar backlog (dependency/milestone impact analysis)
- `/spec-align` - CRUD completo de documentos de padrões
- `/spec-memorize` - Salvar aprendizados no Basic Memory

#### Visualização
- `/spec-board` - Kanban interativo com estatísticas
- `/spec-search` - Busca fuzzy em tasks/docs/ADRs (plans são campo `plan` das tasks)

### Estrutura de Arquivos

```
linderman-cc-utils/
├── Backlog.md                    # Inicializado via backlog init
├── backlog/
│   ├── config.yml                # Statuses, labels, milestones
│   ├── task-001 - Feature X.md
│   ├── task-002 - Bug Y.md
│   └── docs/
│       └── standards/
│           ├── constituicao.backlog    # ← Documento permanente
│           ├── padroes-codigo.backlog  # ← Documento permanente
│           ├── padroes-testes.backlog  # ← Documento permanente
│           └── workflow-desenvolvimento.backlog  # ← Documento permanente
└── plugins/
    └── spec-workflow/
        └── commands/                   # v2.0 - Redesign completo
```

### Regras Inegociáveis

Quando trabalhando neste projeto:

1. **NUNCA** editar arquivos `.backlog` manualmente - usar sempre MCP tools
2. **Specs são Plans**: Specs são o campo `plan` das tasks (NUNCA são arquivos `.backlog` separados)
3. **Documentos são .backlog**: Apenas documentos permanentes (constituição, padrões) usam `.backlog`
4. **OBRIGATÓRIO** validar CLI `backlog` está instalado antes de usar comandos
5. **PROIBIDO** aprovar task sem TODOS os ACs marcados como `[x]`
6. **OBRIGATÓRIO** passar por `/spec-review` antes de `/spec-retro`
7. **PROIBIDO** deletar tasks - arquivar via `backlog_task_archive`

### Ferramentas MCP Disponíveis

**Tasks:**
- `backlog_task_create()` - Criar task com todos os campos
- `backlog_task_get(id)` - Ler task
- `backlog_task_list({ status, priority, milestone })` - Listar filtrado
- `backlog_task_update(id, { ... })` - Atualizar
- `backlog_task_archive(id)` - Arquivar (não deletar!)

**Documentos:**
- `backlog_doc_create({ title, type, path, labels, content })` - path DEVE terminar em `.backlog`
- `backlog_doc_get(id)` - Ler documento
- `backlog_doc_list({ path, type })` - Listar documentos
- `backlog_doc_update(id, { content, notes })` - Atualizar

**Decisões:**
- `backlog_decision_create({ title, context, decision, consequences, alternatives, status })` - Criar ADR
- `backlog_decision_list()` - Listar ADRs
- `backlog_decision_get(id)` - Obter ADR específica

### CLI do Backlog

**Instalação:**
```bash
npm install -g backlog-md
```

**Comandos úteis:**
```bash
backlog board                # Kanban interativo
backlog browser              # Interface web
backlog search "termo"       # Busca fuzzy
backlog task view task-10    # Ver detalhes da task
```

### Workflow Típico

```bash
# 1. Inicialização (uma vez)
/spec-init

# 2. Planejar feature
/spec-plan "Sistema de Autenticação"
# → task-10 criada
# → SPEC-010-sistema-autenticacao.backlog criada

# 3. Executar
/spec-execute task-10
# → Dependências verificadas
# → Status: To Do → In Progress → In Review
# → ACs marcados progressivamente

# 4. Revisar
/spec-review task-10
# → Validação automática de ACs
# → APPROVED ou REFUSED

# 5. Finalizar
/spec-retro task-10
# → Checklist de 4 itens validado
# → Status: Done
# → Milestone progress: 7/10 (70%)
# → Basic Memory consolidado

# 6. Visualizar
/spec-board --milestone "v1.0 - MVP"
/spec-search "autenticação"
```

### Recursos Adicionais

- **Documentação Completa**: `/spec-help`
- **MCP Server**: https://github.com/MrLesk/Backlog.md
- **Basic Memory**: Notas em Markdown para lições aprendidas, ADRs, padrões
- **Constituição**: `backlog/docs/standards/constituicao.backlog`

### Novidades na v2.0

- ✅ Integração 100% com Backlog.md MCP
- ✅ Uso de TODOS os campos MCP (priority, labels, milestones, dependencies)
- ✅ Extensão `.backlog` obrigatória para specs e docs
- ✅ Validação automática de ACs em `/spec-review`
- ✅ Gerenciamento de dependências em `/spec-execute`
- ✅ Análise de impacto em milestones/dependências em `/spec-replan`
- ✅ CRUD completo de documentos em `/spec-align`
- ✅ Novos comandos: `/spec-board` e `/spec-search`
- ✅ Migração automática em `/spec-init`
- ✅ Progresso de milestones em `/spec-retro`

---

## Gemini Orchestrator Plugin (v2.0)

Skill de orquestração para delegar tarefas complexas aos modelos Gemini através do `gemini-cli`, com coleta automática de contexto e integração com Basic Memory.

### Filosofia Core

**Princípio Fundamental:**
> **"You are the conductor of a symphony of AI models. Coordinate, don't code."**

Quando ativa, esta skill transforma Claude Code em um orquestrador que **NUNCA** escreve código diretamente, delegando sempre para o modelo Gemini apropriado.

### Arquitetura

**Componente:**
- **Skill**: `gemini-orchestrator` - Skill com progressive disclosure (SKILL.md + references/)

**Delegation Strategy:**
- `gemini-3-pro-preview`: Planning, architecture design, problem analysis (SPECIFY "PLANNING task")
- `gemini-3-flash-preview`: Implementation, coding, bug fixes
- **Claude Code (Orchestrator)**: Final validation, tests, approval

### Trigger Phrases

A skill é automaticamente ativada quando detecta:
- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "orchestrate with gemini"
- "gemini-cli"

### Workflow Patterns

**1. Simple Delegation (Tarefa Única)**
```
User: "Delegate to gemini: implement JWT authentication"

Orchestrator:
├─ EXTRACT PROJECT SLUG (basename $(git rev-parse --show-toplevel))
├─ FETCH FROM MEMORY (patterns, decisions, errors)
├─ COLLECT CONTEXT (CLAUDE.md, specs, existing code)
├─ DETERMINE MODEL (Flash para implementação)
├─ EXECUTE DELEGATION (gemini-cli)
├─ SAVE TO MEMORY (patterns descobertos)
├─ VALIDATE (testes como Sonnet)
└─ REPORT RESULTS
```

**2. Complex Orchestration (Multi-Step)**
```
User: "Let gemini design and implement the API layer"

Orchestrator:
├─ EXTRACT PROJECT SLUG
├─ FETCH MEMORY CONTEXT
├─ COLLECT INITIAL CONTEXT (Explore agent)
├─ CREATE ORCHESTRATION PLAN (TodoWrite)
│
├─ PHASE 1: DESIGN (gemini-3-pro-preview)
│   ├─ Fetch domain knowledge from memory
│   ├─ Delegate architecture design
│   ├─ Process design JSON
│   └─ Save ADR to memory
│
├─ PHASE 2: IMPLEMENTATION (gemini-3-flash-preview)
│   ├─ Pass design from Phase 1
│   ├─ Fetch implementation patterns from memory
│   ├─ Delegate coding
│   └─ Save code patterns to memory
│
├─ FINAL TESTS (Sonnet)
└─ SYNTHESIZE RESULTS
```

**3. Error Resolution**
```
User: "Use gemini to fix this error"

Orchestrator:
├─ CHECK MEMORY FOR SIMILAR ERRORS
│   └─ If found: Apply known solution
├─ DELEGATE DIAGNOSIS (gemini-3-pro)
│   └─ Pro analyzes and proposes solution
├─ DELEGATE FIX (gemini-3-flash)
│   └─ Flash implements the fix
├─ SAVE ERROR RESOLUTION TO MEMORY
└─ VALIDATE FIX (Sonnet)
```

### Integração com Basic Memory

**Auto-Fetch (Antes de TODA delegação):**

1. **Conhecimento global:** `search_nodes({ query: "{slug} conventions patterns" })`
2. **Conhecimento de task/spec:** `open_nodes({ names: ["{slug}/task-10", "{slug}/spec-010"] })`
3. **Padrões do domínio:** `search_nodes({ query: "{slug} {domain} patterns" })`

**Auto-Save (Após delegações importantes):**

1. **ADRs** - Architecture Decision Records
   - Quando: Após delegação ao Pro que resulta em decisão arquitetural
   - Entidade: `{slug}/spec-{id}/decision-{slug}`
   - Conteúdo: Contexto, decisão, alternativas, consequências

2. **Patterns** - Padrões Descobertos
   - Quando: Delegação identifica padrão de código ou solução recorrente
   - Entidade: `{slug}/global/pattern-{slug}`
   - Conteúdo: Descrição, uso, exemplos, quando aplicar

3. **Errors** - Erros Resolvidos
   - Quando: Após workflow de Error Resolution
   - Entidade: `{slug}/task-{id}/error-{slug}` ou `{slug}/global/error-{slug}`
   - Conteúdo: Sintoma, causa raiz, solução, prevenção

**Prefixação Automática:**

Todas as entidades usam o **slug do projeto** como prefixo para prevenir colisões:
```
projeto: linderman-cc-utils

Entidades criadas:
├─ linderman-cc-utils/global/pattern-jwt-auth
├─ linderman-cc-utils/spec-010/decision-api-design
├─ linderman-cc-utils/task-05/error-port-conflict
└─ linderman-cc-utils/agents/gemini-orchestrator
```

### Regras Absolutas

Quando trabalhando com o orchestrator:

1. ❌ **NUNCA** usar Edit/Write tools para implementação de código
2. ❌ **NUNCA** usar Bash para codificação - apenas para invocar gemini-cli
3. ✅ **SEMPRE** delegar codificação para gemini-3-flash-preview
4. ✅ **SEMPRE** delegar planejamento para gemini-3-pro-preview (especificar "PLANNING task")
5. ✅ **SEMPRE** fornecer contexto EXPLÍCITO aos agentes Gemini
6. ✅ **PODE** invocar Explore agent (via Task tool) para análise de codebase
7. ✅ **EXECUTAR** testes finais e validações (como Sonnet)
8. ✅ **SEMPRE** buscar do memory antes de delegações
9. ✅ **SEMPRE** salvar insights importantes no memory
10. ✅ **SEMPRE** usar prefixo de projeto slug nas entidades do memory

### Integração com Spec-Workflow

Quando usado com spec-workflow:

**ANTES da execução:**
- Verifica SPEC no Backlog.md
- Lê Acceptance Criteria
- Usa ACs como requisitos nas delegações

**DURANTE execução:**
- Cria subtasks via TodoWrite
- Atualiza `notes` da task com progresso
- Marca ACs como implementados

**APÓS conclusão:**
- Sugere `/spec-review`
- Valida TODOS os ACs implementados
- Aguarda aprovação

### Pré-requisitos

1. **Instalar gemini-cli:**
```bash
npm install -g gemini-cli
```

2. **Configurar API key:**
```bash
export GEMINI_API_KEY="sua-chave-aqui"
```

3. **Basic Memory MCP ativo** (para integração com memória)

### Prompt Templates

**Para gemini-3-pro-preview (Reasoning):**
```bash
gemini -p "
IMPORTANT: This is a PLANNING task (NOT implementation).

TASK: [objetivo específico]

MEMORY CONTEXT:
[conhecimento prévio do projeto]

PROJECT CONTEXT:
- Standards: [CLAUDE.md]
- Architecture: [padrões do Explore]

ANALYSIS REQUIRED:
1. [aspecto 1]
2. [aspecto 2]

OUTPUT FORMAT:
- Structured reasoning
- Trade-off analysis
- Recommendation with rationale
" --model gemini-3-pro-preview
```

**Para gemini-3-flash-preview (Coding):**
```bash
gemini -p "
You are Gemini-3-Flash, expert developer.

TASK: [tarefa de codificação]

MEMORY CONTEXT:
[padrões e soluções prévias]

PROJECT CONTEXT:
- Standards: [CLAUDE.md]
- Existing code: [arquivos relevantes]

ACCEPTANCE CRITERIA:
- [ ] AC 1
- [ ] AC 2

OUTPUT:
- Complete, functional code
- Error handling
- Best practices
" --model gemini-3-flash-preview
```

### Matriz de Responsabilidades

| Tarefa | Executor | Notas |
|--------|----------|-------|
| Planejamento/Design | gemini-3-pro | Especificar "PLANNING task" |
| Análise de problemas | gemini-3-pro | Especificar "PROBLEM RESOLUTION" |
| Ler código para análise | gemini-3-pro | Pode ler, NÃO implementa |
| Ajustar permissões | gemini-3-pro | Durante resolução de problemas |
| Codificação | gemini-3-flash | Pode executar Bash/apps |
| Executar scripts em dev | gemini-3-flash | Durante implementação |
| Iniciar servidores em dev | gemini-3-flash | Durante implementação |
| Usar MCP em dev | gemini-3-flash | Quando necessário |
| Testes finais | Orchestrator (Sonnet) | Após delegações |
| Executar servers para validação | Orchestrator | Testes end-to-end |
| Usar MCP para validação | Orchestrator | Quando necessário |
| Aprovação final | Orchestrator | Tomador de decisão |

### Exemplo Completo

```
User: "Delegate to gemini: implement JWT authentication for the PJe extension"

=== ORCHESTRATION STARTED ===

[1/7] Extracting project slug...
      → linderman-cc-utils

[2/7] Fetching from memory...
      → Found: pattern-chrome-extension-auth
      → Found: decision-storage-strategy

[3/7] Collecting context...
      ✓ Read CLAUDE.md
      ✓ Read spec-010-auth.backlog
      ✓ Explored existing auth patterns
      ✓ Identified reference: https://jwt.io/introduction

[4/7] Delegating to gemini-3-flash-preview...
      ⏳ Delegation in progress...
      ✓ Completed in 12.4s

[5/7] Saving to memory...
      ✓ Saved pattern: jwt-chrome-extension-storage
      ✓ Created relation: task-10 → pattern-jwt-storage

[6/7] Validating implementation...
      $ npm test
      ✓ All tests passed

[7/7] Reporting results...

=== ORCHESTRATION COMPLETE ===

Task: Implement JWT authentication
Total Time: 18.7s
Delegations: 1 (Flash)
Memory Operations: 2 fetch, 1 save

RESULTS:
✓ JWT service implemented
✓ Token storage in chrome.storage.local
✓ All 5 Acceptance Criteria validated
```

### Documentação Adicional

- **README completo**: `plugins/gemini-orchestrator/README.md` (overview conciso)
- **Skill principal**: `plugins/gemini-orchestrator/skills/gemini-orchestrator/SKILL.md`
- **Referências detalhadas**: `plugins/gemini-orchestrator/skills/gemini-orchestrator/references/*.md`
  - `delegation-strategy.md` - Quando usar cada modelo
  - `context-provision.md` - Como fornecer contexto
  - `memory-integration.md` - Integração com Basic Memory
  - `prompt-templates.md` - Templates prontos
  - `workflow-patterns.md` - Padrões de orquestração
  - `error-resolution.md` - Estratégias de resolução
  - `spec-workflow-integration.md` - Integração com Backlog.md
  - `troubleshooting.md` - Solução de problemas
  - `responsibility-matrix.md` - Matriz de responsabilidades
- **Changelog**: `plugins/gemini-orchestrator/CHANGELOG.md` (inclui v2.0.0 breaking changes)

---

