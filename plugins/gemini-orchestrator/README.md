# Gemini Orchestrator Plugin

Plugin de orquestração para delegar tarefas complexas aos modelos Gemini através do `gemini-cli`, com coleta automática de contexto e integração com Basic Memory.

## Visão Geral

Este plugin fornece um sistema completo de orquestração que:

- **Nunca codifica diretamente** - sempre delega para o modelo Gemini apropriado
- **Coleta contexto automaticamente** - documentação, arquivos, URLs, memória
- **Seleciona o modelo correto**:
  - `gemini-3-pro-preview`: Planejamento, design, análise de problemas
  - `gemini-3-flash-preview`: Implementação, codificação, correção de bugs
- **Integra com Basic Memory MCP** - busca e salva padrões, decisões, erros automaticamente
- **Valida resultados** - executa testes e verificações como Sonnet
- **Reporta progresso** - mantém o usuário informado durante toda a orquestração

## Componentes

### 1. Agent: `gemini-orchestrator`

Agent especializado que coordena delegações aos modelos Gemini.

**Localização**: `/agents/gemini-orchestrator.md` (na raiz do repositório)

**Triggers automáticos:**
- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "orchestrate with gemini"
- "gemini-cli"

**Ferramentas disponíveis:**
- Bash (para invocar gemini-cli)
- Read (para coletar contexto)
- TodoWrite (para planejamento de orquestração)
- AskUserQuestion (para clarificações)
- Task (para invocar Explore agent)
- Basic Memory MCP (para persistência de conhecimento)

### 2. Skill: `gemini-delegate`

Skill opcional que facilita a invocação do agente orquestrador.

**Uso:**
```
User: "Delegate to gemini: implement authentication system"
→ Skill invoca o gemini-orchestrator agent
→ Agent coordena todo o workflow
```

## Instalação

### Pré-requisitos

1. **Instalar gemini-cli globalmente:**
```bash
npm install -g gemini-cli
```

2. **Configurar API key do Gemini:**
```bash
export GEMINI_API_KEY="sua-chave-aqui"
```

### Ativar Plugin

O plugin já está registrado no marketplace `linderman-cc-utils`. Basta usar os triggers ou skill para ativá-lo.

## Uso

### Invocação Automática

O agent é automaticamente invocado quando você usa as frases de trigger:

```bash
# Exemplo 1: Delegação simples
User: "Delegate to gemini: create a REST API for user management"

# Exemplo 2: Delegação com modelo específico
User: "Let gemini-3-pro handle the system design first"

# Exemplo 3: Orquestração complexa
User: "Use gemini to design and implement the authentication module"
```

### Invocação via Skill

```bash
# Invocar via skill system
User: "Use the gemini-delegate skill to implement feature X"
```

## Workflow Patterns

### 1. Delegação Simples (Tarefa Única)

```
User: "Delegate to gemini: implement JWT authentication"

Orchestrator:
├─ EXTRACT PROJECT SLUG
├─ FETCH FROM MEMORY (patterns, decisions)
├─ COLLECT CONTEXT (CLAUDE.md, specs, existing code)
├─ DETERMINE MODEL (Flash para implementação)
├─ EXECUTE DELEGATION (gemini-cli)
├─ SAVE TO MEMORY (patterns descobertos)
├─ VALIDATE (testes como Sonnet)
└─ REPORT RESULTS
```

### 2. Orquestração Complexa (Multi-Step)

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

### 3. Error Resolution

```
User: "Use gemini to fix this error: Port 3000 already in use"

Orchestrator:
├─ CHECK MEMORY FOR SIMILAR ERRORS
│   └─ If found: Apply known solution
│
├─ DELEGATE DIAGNOSIS (gemini-3-pro)
│   └─ Pro analyzes and proposes solution
│
├─ DELEGATE FIX (gemini-3-flash)
│   └─ Flash implements the fix
│
├─ SAVE ERROR RESOLUTION TO MEMORY
└─ VALIDATE FIX (Sonnet)
```

## Integração com Basic Memory

### Auto-Fetch (Antes de Delegações)

O orchestrator **automaticamente** busca conhecimento antes de cada delegação:

1. **Conhecimento global do projeto:**
   ```javascript
   search_nodes({ query: "{slug} conventions patterns" })
   ```

2. **Conhecimento de task/spec ativa:**
   ```javascript
   open_nodes({ names: ["{slug}/task-10", "{slug}/spec-010"] })
   ```

3. **Padrões do domínio:**
   ```javascript
   search_nodes({ query: "{slug} {domain} patterns" })
   ```

### Auto-Save (Após Delegações)

O orchestrator **automaticamente** salva insights importantes:

**1. ADRs (Architecture Decision Records):**
- Quando: Após delegação ao Pro que resulta em decisão arquitetural
- Entidade: `{slug}/spec-{id}/decision-{slug}`
- Conteúdo: Contexto, decisão, alternativas, consequências

**2. Patterns Descobertos:**
- Quando: Delegação identifica padrão de código ou solução recorrente
- Entidade: `{slug}/global/pattern-{slug}`
- Conteúdo: Descrição, uso, exemplos, quando aplicar

**3. Erros Resolvidos:**
- Quando: Após workflow de Error Resolution
- Entidade: `{slug}/task-{id}/error-{slug}` ou `{slug}/global/error-{slug}`
- Conteúdo: Sintoma, causa raiz, solução, prevenção

### Prefixação Automática

Todas as entidades usam o **slug do projeto** como prefixo:

```
projeto: linderman-cc-utils

Entidades criadas:
├─ linderman-cc-utils/global/pattern-jwt-auth
├─ linderman-cc-utils/spec-010/decision-api-design
├─ linderman-cc-utils/task-05/error-port-conflict
└─ linderman-cc-utils/agents/gemini-orchestrator
```

Isso previne colisões entre projetos diferentes.

## Integração com Spec-Workflow

Quando usado com o plugin `spec-workflow`:

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

## Exemplo Completo

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
      Prompt includes:
      - Memory patterns
      - Project standards (CLAUDE.md)
      - Acceptance Criteria from spec
      - JWT reference documentation

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
✓ JWT service implemented (src/services/auth.ts)
✓ Token storage in chrome.storage.local
✓ Refresh token rotation implemented
✓ All 5 Acceptance Criteria validated

NEXT STEPS:
- Run /spec-review task-10 to validate
```

## Matriz de Responsabilidades

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
| Testes finais | Orchestrator | Após delegações |
| Executar servers para validação | Orchestrator | Testes end-to-end |
| Usar MCP para validação | Orchestrator | Quando necessário |
| Aprovação final | Orchestrator | Tomador de decisão |

## Estrutura de Arquivos

```
Repository root:
└── agents/
    └── gemini-orchestrator.md   # Agent definition (815 linhas)

plugins/gemini-orchestrator/
├── .claude-plugin/
│   └── plugin.json              # Manifest do plugin
├── skills/
│   └── gemini-delegate/
│       └── SKILL.md             # Skill para invocação
├── README.md                    # Esta documentação
└── CHANGELOG.md
```

## Prompts Templates

### Para gemini-3-pro-preview (Reasoning)

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

### Para gemini-3-flash-preview (Coding)

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

## Troubleshooting

### gemini-cli não encontrado

```bash
# Instalar globalmente
npm install -g gemini-cli

# Verificar instalação
gemini --version
```

### API key não configurada

```bash
# Adicionar ao .bashrc/.zshrc
export GEMINI_API_KEY="sua-chave-aqui"

# Recarregar shell
source ~/.bashrc
```

### Memory não está salvando

Verificar se o Basic Memory MCP está ativo:
```javascript
// Testar criação de entidade
mcp__memory__create_entities({
  entities: [{
    name: "test-entity",
    entityType: "test",
    observations: ["Test observation"]
  }]
})
```

## Contribuindo

Para adicionar novos padrões de orquestração:

1. Editar `agents/gemini-orchestrator.md`
2. Adicionar novo workflow pattern
3. Documentar template de prompt
4. Atualizar exemplos neste README

## Licença

Este plugin faz parte do marketplace `linderman-cc-utils`.

---

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**
