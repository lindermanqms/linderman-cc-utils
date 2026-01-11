# Workflow Simplificado com delegate.sh

Guia rápido para usar o script `delegate.sh` que simplifica delegações.

## Overview

O script `delegate.sh` resolve problemas de parsing, salva relatórios automaticamente e oferece workflow padronizado para delegações.

## Setup Inicial

### 1. Estrutura de Diretórios

O projeto já deve ter:
```
.gemini-orchestration/
├── prompts/               # Arquivos de prompt
│   ├── TEMPLATE-pro-planning.txt
│   └── TEMPLATE-flash-implementation.txt
└── reports/               # Relatórios gerados
```

### 2. Scripts Disponíveis

- `plugins/gemini-orchestrator/scripts/delegate.sh` - Script principal
- `plugins/gemini-orchestrator/scripts/extract-report.sh` - Extrator de relatórios

### 3. Verificar Instalação

```bash
# Verificar gemini-cli
gemini --version

# Verificar API key
echo $GEMINI_API_KEY

# Testar script
./plugins/gemini-orchestrator/scripts/delegate.sh -h
```

## Workflow Básico

### Passo 1: Criar Prompt

```bash
# Para planejamento (Pro)
cp .gemini-orchestration/prompts/TEMPLATE-pro-planning.txt \
   .gemini-orchestration/prompts/task-10-design.txt

# Para implementação (Flash)
cp .gemini-orchestration/prompts/TEMPLATE-flash-implementation.txt \
   .gemini-orchestration/prompts/task-10-implement.txt
```

### Passo 2: Editar Prompt

Preencha as seções do template:

```txt
# IMPLEMENTATION TASK - Implement JWT Authentication

You are Gemini-3-Flash, expert TypeScript developer.

## PROJECT CONTEXT

**Project Slug**: linderman-cc-utils

**Standards (CLAUDE.md)**:
[Colar padrões relevantes]

**Existing Code**:
[Colar arquivos relevantes]

## MEMORY CONTEXT

**Patterns**:
- pattern-chrome-extension-auth: ...
- pattern-jwt-storage: ...

## TASK DESCRIPTION

Implement JWT authentication with refresh tokens for the PJe extension.

### Acceptance Criteria

- [ ] JWT tokens stored securely in chrome.storage.local
- [ ] Refresh token rotation implemented
- [ ] Token expiration handled gracefully
...
```

### Passo 3: Executar Delegação

```bash
# Auto-detecta modelo
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .gemini-orchestration/prompts/task-10-implement.txt

# Ou especificar modelo
./plugins/gemini-orchestrator/scripts/delegate.sh -m flash \
  .gemini-orchestration/prompts/task-10-implement.txt
```

Output:
```
ℹ Auto-detected model: gemini-3-flash-preview
ℹ Output will be saved to: .gemini-orchestration/reports/flash-2026-01-11-15-30.md
ℹ Executing delegation with gemini-3-flash-preview...
✓ Delegation completed successfully
✓ Report extracted to: .gemini-orchestration/reports/flash-2026-01-11-15-30.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REPORT PREVIEW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
=== ORCHESTRATOR REPORT ===

## Implementation Summary
...
```

### Passo 4: Revisar Relatório

```bash
# Ver relatório estruturado
cat .gemini-orchestration/reports/flash-2026-01-11-15-30.md

# Ver output completo (se necessário debugging)
cat .gemini-orchestration/reports/flash-2026-01-11-15-30-full.log
```

## Exemplos Práticos

### Exemplo 1: Simple Delegation (Flash)

```bash
# 1. Criar prompt
cat > .gemini-orchestration/prompts/fix-auth-bug.txt << 'EOF'
# IMPLEMENTATION TASK - Fix Authentication Bug

You are Gemini-3-Flash, expert TypeScript developer.

## TASK DESCRIPTION
Fix bug where JWT tokens expire silently without user notification.

## FILES TO MODIFY
- src/auth/tokenManager.ts

## ACCEPTANCE CRITERIA
- [ ] User notified before token expiration
- [ ] Graceful logout on expired token
- [ ] Tests updated

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT...
EOF

# 2. Executar
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .gemini-orchestration/prompts/fix-auth-bug.txt

# 3. Revisar
cat .gemini-orchestration/reports/flash-*.md | tail -n 50
```

### Exemplo 2: Complex Orchestration (Pro → Flash)

```bash
# FASE 1: Design (Pro)
cat > .gemini-orchestration/prompts/task-10-design.txt << 'EOF'
# PLANNING TASK - Design API Authentication System

IMPORTANT: This is a PLANNING task (NOT implementation).

## TASK DESCRIPTION
Design a scalable authentication system for the API...

## ANALYSIS REQUIRED
1. Token strategy (JWT vs session)
2. Refresh token rotation
3. Security considerations

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT...
EOF

./plugins/gemini-orchestrator/scripts/delegate.sh -m pro \
  .gemini-orchestration/prompts/task-10-design.txt

# FASE 2: Implementation (Flash)
# Copiar output do Pro para o prompt do Flash
cat .gemini-orchestration/reports/pro-*.md > design-output.txt

cat > .gemini-orchestration/prompts/task-10-implement.txt << 'EOF'
# IMPLEMENTATION TASK - Implement Authentication System

## DESIGN CONTEXT (from Pro)
[Colar conteúdo de design-output.txt]

## TASK DESCRIPTION
Implement the authentication system as designed by Pro...
EOF

./plugins/gemini-orchestrator/scripts/delegate.sh -m flash \
  .gemini-orchestration/prompts/task-10-implement.txt
```

### Exemplo 3: Com Spec-Workflow

```bash
# 1. Ler spec
backlog task view task-10

# 2. Criar prompt baseado na spec
cp .gemini-orchestration/prompts/TEMPLATE-flash-implementation.txt \
   .gemini-orchestration/prompts/task-10.txt

# 3. Editar (colar ACs da spec)
vim .gemini-orchestration/prompts/task-10.txt

# 4. Executar delegação
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .gemini-orchestration/prompts/task-10.txt

# 5. Atualizar task
backlog task update task-10 \
  --notes "Implementação via Gemini Flash concluída. Ver: .gemini-orchestration/reports/flash-*.md"
```

## Opções Avançadas

### Auto-Salvar Prompt

```bash
# Prompt temporário que você quer salvar
./plugins/gemini-orchestrator/scripts/delegate.sh -s /tmp/my-prompt.txt
```

Resultado:
```
✓ Prompt saved to: .gemini-orchestration/prompts/my-prompt.txt
```

### Output Customizado

```bash
# Nomear relatório
./plugins/gemini-orchestrator/scripts/delegate.sh \
  -o .gemini-orchestration/reports/task-10-final.md \
  .gemini-orchestration/prompts/task-10.txt
```

### Formato JSON

```bash
# Útil para parsing programático
./plugins/gemini-orchestrator/scripts/delegate.sh \
  -f json \
  .gemini-orchestration/prompts/task-10.txt
```

## Integração com Memory

O Orchestrator (Sonnet) deve preencher seção **Memory Context** do prompt:

```bash
# No Claude Code, antes de criar prompt:
# 1. Buscar contexto
search_nodes({ query: "linderman-cc-utils jwt patterns" })
open_nodes({ names: ["linderman-cc-utils/task-10"] })

# 2. Copiar resultados para prompt
# 3. Executar delegação
# 4. Salvar insights após sucesso
create_entities([{
  name: "linderman-cc-utils/task-10/pattern-jwt-refresh",
  entityType: "pattern",
  observations: ["JWT refresh token rotation implementado..."]
}])
```

## Auto-Detecção de Modelo

O script detecta automaticamente baseado em keywords:

**Pro (Planning/Analysis)**:
- `PLANNING task`
- `PROBLEM RESOLUTION`
- `analyze`, `design`, `architecture`, `trade-off`

**Flash (Implementation)**:
- Todos os outros casos

Para forçar: `-m pro` ou `-m flash`

## Tratamento de Erros

### Erro na Delegação

Se `gemini` falhar:
```
✗ Delegation failed
✗ Error output saved to: .gemini-orchestration/reports/flash-*-error.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ERROR OUTPUT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Últimas 30 linhas do erro]
```

### Sem Relatório Estruturado

Se agent não incluir `=== ORCHESTRATOR REPORT ===`:
```
⚠ No orchestrator report found in output
ℹ Saving raw output instead
```

## Vantagens vs Execução Manual

| Aspecto | Manual (`gemini -p "..."`) | Com `delegate.sh` |
|---------|---------------------------|-------------------|
| Parsing de prompt | ❌ Quebra com multiline | ✅ Funciona perfeitamente |
| Salvamento de output | ❌ Manual (redirecionamento) | ✅ Automático |
| Extração de report | ❌ Manual | ✅ Automática |
| Nomenclatura | ❌ Inconsistente | ✅ Padronizada |
| Histórico | ❌ Difícil rastrear | ✅ Organizado em reports/ |
| Reutilização | ❌ Perda de prompts | ✅ Prompts salvos |
| Debugging | ❌ Output perdido | ✅ Full log salvo |

## Troubleshooting

### Erro: "command not found: delegate.sh"

**Solução**: Usar caminho completo
```bash
./plugins/gemini-orchestrator/scripts/delegate.sh ...
```

Ou adicionar ao PATH:
```bash
export PATH="$PATH:$PWD/plugins/gemini-orchestrator/scripts"
delegate.sh ...
```

### Erro: "gemini-cli not found"

**Solução**:
```bash
npm install -g gemini-cli
```

### Erro: "GEMINI_API_KEY not set"

**Solução**:
```bash
export GEMINI_API_KEY="sua-chave-aqui"

# Persistir
echo 'export GEMINI_API_KEY="sua-chave"' >> ~/.bashrc
source ~/.bashrc
```

### Prompt muito longo

Se prompt > 10KB, considere:
1. Referenciar arquivos em vez de colar conteúdo completo
2. Usar links para documentação externa
3. Dividir em múltiplas delegações (Pro design → Flash impl)

## Boas Práticas

1. ✅ **Use templates**: Garante formato consistente
2. ✅ **Nomes descritivos**: `task-10-implement.txt` > `prompt1.txt`
3. ✅ **Preencha contexto completo**: Memory, CLAUDE.md, arquitetura
4. ✅ **Revise reports**: Sempre leia antes de validar
5. ✅ **Salve prompts importantes**: Use `-s` para historiar
6. ✅ **Versione quando crítico**: Commit prompts/reports importantes com `-f`

## Próximos Passos

Após dominar `delegate.sh`, consulte:
- `workflow-patterns.md` - Padrões de orquestração complexa
- `memory-integration.md` - Integração profunda com Basic Memory
- `spec-workflow-integration.md` - Workflow completo com Backlog.md
