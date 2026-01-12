# .claude/gemini-orchestrator

Diretório de trabalho para delegações do Gemini Orchestrator.

## Estrutura

```
.claude/gemini-orchestrator/
├── prompts/               # Arquivos de prompt (.txt)
│   ├── TEMPLATE-pro-planning.txt
│   ├── TEMPLATE-flash-implementation.txt
│   ├── task-9.1-part2-update-hooks.txt
│   └── ...
└── reports/               # Relatórios gerados (.md, .log)
    ├── flash-2026-01-11-15-30.md
    ├── flash-2026-01-11-15-30-full.log
    ├── pro-2026-01-11-14-20.md
    └── ...
```

## Workflow

### 1. Criar Prompt

Copie um template e preencha com contexto:

```bash
# Para planejamento/design
cp .claude/gemini-orchestrator/prompts/TEMPLATE-pro-planning.txt \
   .claude/gemini-orchestrator/prompts/task-10-design-api.txt

# Para implementação
cp .claude/gemini-orchestrator/prompts/TEMPLATE-flash-implementation.txt \
   .claude/gemini-orchestrator/prompts/task-10-implement-api.txt
```

### 2. Editar Prompt

Preencha as seções:
- **Project Context**: CLAUDE.md, arquitetura existente
- **Memory Context**: Padrões, decisões, conhecimento do domínio
- **Task Description**: Detalhes da tarefa
- **Requirements**: Requisitos e Acceptance Criteria

### 3. Executar Delegação

Use o script helper:

```bash
# Auto-detecta modelo (Pro ou Flash)
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .claude/gemini-orchestrator/prompts/task-10-design-api.txt

# Especificar modelo explicitamente
./plugins/gemini-orchestrator/scripts/delegate.sh -m pro \
  .claude/gemini-orchestrator/prompts/task-10-design-api.txt

# Especificar arquivo de saída
./plugins/gemini-orchestrator/scripts/delegate.sh \
  -o .claude/gemini-orchestrator/reports/task-10-design.md \
  .claude/gemini-orchestrator/prompts/task-10-design-api.txt

# Salvar prompt na pasta de orquestração
./plugins/gemini-orchestrator/scripts/delegate.sh -s \
  /tmp/my-prompt.txt
```

### 4. Revisar Relatório

Os relatórios são salvos automaticamente em `reports/`:

```bash
# Ver relatório estruturado
cat .claude/gemini-orchestrator/reports/flash-2026-01-11-15-30.md

# Ver output completo (debugging)
cat .claude/gemini-orchestrator/reports/flash-2026-01-11-15-30-full.log
```

## Scripts Disponíveis

### `delegate.sh`

Script principal de delegação.

**Uso**:
```bash
./plugins/gemini-orchestrator/scripts/delegate.sh [OPTIONS] <prompt-file>
```

**Opções**:
- `-m, --model <model>` - Modelo (pro|flash) [default: auto-detect]
- `-o, --output <file>` - Arquivo de saída [default: auto-generated]
- `-f, --format <fmt>` - Formato (plain|markdown|json) [default: markdown]
- `-s, --save-prompt` - Salvar prompt em prompts/
- `-h, --help` - Ajuda

**Exemplos**:
```bash
# Delegação simples
./plugins/gemini-orchestrator/scripts/delegate.sh prompts/implement-auth.txt

# Escolher modelo
./plugins/gemini-orchestrator/scripts/delegate.sh -m flash prompts/fix-bug.txt

# Salvar em arquivo específico
./plugins/gemini-orchestrator/scripts/delegate.sh \
  -o reports/auth-implementation.md \
  prompts/implement-auth.txt
```

### `extract-report.sh`

Extrai relatório estruturado do output do gemini-cli.

**Uso**:
```bash
gemini -p "..." | ./plugins/gemini-orchestrator/scripts/extract-report.sh
```

Chamado automaticamente pelo `delegate.sh`.

## Auto-Detecção de Modelo

O script `delegate.sh` detecta automaticamente o modelo baseado em keywords:

**gemini-3-pro-preview** (Planning/Analysis):
- Keywords: `PLANNING task`, `PROBLEM RESOLUTION`, `analyze`, `design`, `architecture`, `trade-off`

**gemini-3-flash-preview** (Implementation):
- Todos os outros casos

Para forçar um modelo específico, use `-m pro` ou `-m flash`.

## Estrutura de Relatórios

### Pro (Planning/Analysis)

```markdown
=== ORCHESTRATOR REPORT ===

## Analysis
[Análise detalhada...]

## Decisions
[Decisões tomadas...]

## Trade-offs
[Análise de trade-offs...]

## Alternatives Considered
[Alternativas avaliadas...]

## Risks & Mitigations
[Riscos e mitigações...]

## Recommendations
[Recomendações...]

## Next Steps
[Próximos passos...]
```

### Flash (Implementation)

```markdown
=== ORCHESTRATOR REPORT ===

## Implementation Summary
[Resumo...]

## Files Modified
[Lista de arquivos...]

## Changes Made
[Descrição das mudanças...]

## Static Analysis Results
[Resultados de lint/typecheck...]

## Testing Performed
[Testes executados...]

## Results
[ACs atendidos, testes passando...]

## Issues Found
[Problemas encontrados...]
```

## Convenções de Nomenclatura

### Arquivos de Prompt

Formato: `{task-id}-{slug}.txt`

Exemplos:
- `task-9.1-update-hooks.txt`
- `task-10-design-api.txt`
- `task-10-implement-api.txt`

### Arquivos de Relatório

Gerados automaticamente: `{model}-{timestamp}.md`

Exemplos:
- `pro-2026-01-11-14-20.md`
- `flash-2026-01-11-15-30.md`

Ou custom via `-o`:
- `task-10-design.md`
- `task-10-implementation.md`

## Integração com Workflow

### Com Spec-Workflow

```bash
# 1. Ler spec e ACs
backlog task view task-10

# 2. Criar prompt baseado na spec
cp .claude/gemini-orchestrator/prompts/TEMPLATE-flash-implementation.txt \
   .claude/gemini-orchestrator/prompts/task-10-impl.txt

# 3. Editar prompt (colar ACs da spec)
vim .claude/gemini-orchestrator/prompts/task-10-impl.txt

# 4. Executar delegação
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .claude/gemini-orchestrator/prompts/task-10-impl.txt

# 5. Revisar relatório
cat .claude/gemini-orchestrator/reports/flash-*.md

# 6. Atualizar task com progresso
backlog task update task-10 --notes "Implementação via Gemini Flash concluída"
```

### Com Basic Memory

O Orchestrator (Sonnet) deve:

1. **Antes da delegação**: Buscar contexto do memory
   ```javascript
   search_nodes({ query: "{slug} {domain} patterns" })
   open_nodes({ names: ["{slug}/task-10"] })
   ```

2. **Preencher seção Memory Context** no prompt

3. **Após delegação bem-sucedida**: Salvar insights
   ```javascript
   create_entities([{
     name: "{slug}/task-10/pattern-jwt-auth",
     entityType: "pattern",
     observations: ["Padrão JWT implementado com refresh tokens"]
   }])
   ```

## Troubleshooting

### Erro: "command not found: gemini"

**Solução**:
```bash
npm install -g gemini-cli
```

### Erro: "GEMINI_API_KEY not set"

**Solução**:
```bash
export GEMINI_API_KEY="sua-chave-aqui"
# Adicionar ao ~/.bashrc ou ~/.zshrc
```

### Erro: "No orchestrator report found"

**Causa**: Agent não incluiu marcador `=== ORCHESTRATOR REPORT ===`

**Solução**: Verificar se prompt inclui linha:
```
CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT...
```

### Erro de parsing no prompt

**Causa**: Caracteres especiais ou múltiplas linhas quebrando Bash

**Solução**: Use `delegate.sh` que lê de arquivo, evitando problemas de parsing.

## Boas Práticas

1. **Sempre use templates**: Garante formato consistente
2. **Preencha todo o contexto**: Memory, CLAUDE.md, arquitetura
3. **Use nomes descritivos**: `task-10-design-api.txt` melhor que `prompt1.txt`
4. **Revise relatórios**: Sempre leia o report antes de validar
5. **Salve prompts importantes**: Use `-s` para historiar delegações complexas
6. **Versionamento**: Prompts e reports importantes podem ser commitados (opcional)

## Arquivos Ignorados

A pasta `.claude/gemini-orchestrator/` está em `.gitignore` por padrão.

Para versionar prompts/reports importantes:
```bash
# Forçar commit de prompt específico
git add -f .claude/gemini-orchestrator/prompts/critical-task.txt

# Forçar commit de relatório
git add -f .claude/gemini-orchestrator/reports/task-10-design.md
```

---

**Dúvidas?** Consulte:
- `plugins/gemini-orchestrator/README.md`
- `plugins/gemini-orchestrator/CHANGELOG.md`
- `plugins/gemini-orchestrator/skills/gemini-orchestrator/SKILL.md`
