---
name: spec-init
description: Inicializa o ambiente Spec-Driven Development com Backlog MCP, limpando resquícios anteriores e configurando estrutura completa
version: 2.0.0
category: workflow
triggers:
  - "/spec-init"
  - "inicializar spec workflow"
  - "setup spec-driven development"
arguments: []
---

# Spec-Init: Inicialização e Limpeza do Ambiente

Este comando inicializa ou reinicializa o ambiente Spec-Driven Development, integrando totalmente com o Backlog.md MCP. É idempotente e seguro para executar múltiplas vezes.

## Workflow de Inicialização (OBRIGATÓRIO)

### Fase 1: Validação de Pré-requisitos

**CRÍTICO**: Verificar se o CLI do Backlog.md está instalado:

```bash
which backlog
```

**Se NÃO estiver instalado:**
```markdown
❌ CLI do Backlog.md não encontrado!

O plugin spec-workflow requer o CLI do Backlog.md instalado.

**Instale via npm:**
npm install -g backlog-md

**Ou via homebrew (macOS/Linux):**
brew install backlog-md

**Após instalar, execute novamente /spec-init**
```

**Se estiver instalado, continue para Fase 2.**

### Fase 2: Limpeza e Migração de Resquícios

**Detectar arquivos antigos:**

1. **Verificar Backlog.md existente:**
   - Se existe e está vazio/minimalista (< 100 linhas) → Mover para `backlog.old/Backlog.md.bak`
   - Se existe e tem conteúdo substancial → Realizar migração automática (Fase 2.1)

2. **Verificar diretório backlog/ existente:**
   - Se existe → Mover para `backlog.old/` como backup antes de reinicializar

3. **Limpar entradas antigas no Memory MCP:**
   - Buscar entidade "Project Root" ou similar
   - Se existir de execuções anteriores, deletar e recriar

#### Fase 2.1: Migração Automática (Se aplicável)

**Se detectar Backlog.md antigo com tasks/specs:**

```markdown
🔄 Detectado Backlog.md existente com dados!

📦 Iniciando migração automática...
   - Backup criado: backlog.old/Backlog.md.bak
   - Convertendo tasks antigas para novo formato MCP
   - Renomeando specs .md → .backlog
   - Preservando histórico e Acceptance Criteria
```

**Processo de migração:**
1. Fazer backup completo em `backlog.old/`
2. Parsear tasks antigas e extrair metadados
3. Recriar tasks via MCP com campos completos (priority, labels, etc.)
4. Renomear specs de `specs/*.md` para `specs/*.backlog`
5. Vincular specs migradas às tasks correspondentes

### Fase 3: Inicialização do Backlog MCP

**Executar comando CLI:**

```bash
backlog init --defaults "$(basename $(pwd))"
```

Este comando cria:
- `Backlog.md` raiz
- `backlog/` diretório
- `backlog/config.yml` configuração base

### Fase 4: Configuração do backlog/config.yml

**Atualizar o arquivo com configuração completa:**

```yaml
project_name: $(basename $(pwd))
default_assignee: "@Claude"
default_status: To Do
statuses:
  - To Do
  - In Progress
  - In Review
  - Done
  - Blocked
labels:
  - backend
  - frontend
  - plugin
  - skill
  - documentation
  - bugfix
  - enhancement
  - refactoring
milestones:
  - "v1.0 - MVP"
  - "v2.0 - Full Integration"
date_format: yyyy-mm-dd HH:mm:ss
timezonePreference: America/Fortaleza
defaultEditor: code
autoCommit: false
bypassGitHooks: false
zeroPaddedIds: true
```

**Criar via script ou edição:**
```bash
cat > backlog/config.yml <<'EOF'
[conteúdo acima]
EOF
```

### Fase 5: Criar Estrutura de Documentação

**1. Garantir diretórios existem:**
```bash
mkdir -p backlog/specs
mkdir -p backlog/docs/standards
mkdir -p backlog/docs/decisions
```

**2. Criar Constituição do Projeto via CLI:**

```bash
backlog doc create "Constituição do Projeto" --type guide
```

**Conteúdo inicial da Constituição** (escrever em `backlog/docs/doc-001 - Constituição do Projeto.md`):

```markdown
---
id: doc-001
title: Constituição do Projeto
type: guide
labels: [standards, architecture]
creation_date: $(date +"%Y-%m-%d %H:%M:%S")
---

# Constituição do Projeto: $(basename $(pwd))

## Regras Inegociáveis

1. **Spec-First**: Toda feature DEVE ter uma Spec antes de implementação
2. **AC Obrigatório**: Toda task DEVE ter Acceptance Criteria verificáveis
3. **Revisão**: Código DEVE passar por /spec-review antes de /spec-retro
4. **Memória**: Aprendizados críticos DEVEM ser salvos no Basic Memory
5. **Extensão .backlog**: Specs DEVEM usar extensão .backlog (não .md)

## Padrões de Código

(A ser preenchido durante /spec-align)

## Arquitetura

(A ser documentada durante desenvolvimento)

## Stack Tecnológica

(A ser definida conforme necessidade)
```

### Fase 6: Inicializar Basic Memory

**Criar nota raiz do projeto:**

```javascript
write_note({
  title: `[Project] - $(basename $(pwd))`,
  content: `---
type: Project
tags: [plugin-marketplace, spec-workflow]
project: $(basename $(pwd))
---
# Projeto: $(basename $(pwd))

- Marketplace de plugins para Claude Code
- Workflow: Spec-Driven Development com Backlog.md MCP
- Linguagem: Português do Brasil
- Inicializado via /spec-init v2.0.0
`
})
```

**Criar notas de padrões obrigatórias (exemplos):**

```javascript
write_note({
  title: "[Standard] - Uso de MCP",
  content: `---
type: Standard
tags: [mcp, best-practices]
project: $(basename $(pwd))
---
# Uso de ferramentas MCP

- SEMPRE usar ferramentas MCP para gerenciar tasks/specs
- NUNCA editar arquivos .backlog manualmente
`
})
```

### Fase 7: Atualizar CLAUDE.md

**Injetar regras imperativas no CLAUDE.md da raiz do projeto:**

Localizar seção "## Workflow Obrigatório" ou criar no final:

```markdown
## Workflow Obrigatório (Spec-Driven Development)

Este projeto usa Spec-Driven Development via Backlog.md MCP.

**REGRAS IMPERATIVAS:**

1. **NUNCA editar arquivos .backlog manualmente** - Use comandos /spec-* ou CLI backlog
2. **SEMPRE usar comandos /spec-\*** para gerenciar tasks, specs e decisões
3. **SEMPRE consultar Constituição** antes de implementar (backlog/docs/doc-001...)
4. **SEMPRE marcar AC como concluídos** antes de /spec-retro
5. **SEMPRE usar extensão .backlog** para specs (rejeitar .md)

**Comandos disponíveis:**
- /spec-init: Inicializar/reinicializar ambiente
- /spec-plan: Criar nova feature com task + spec
- /spec-execute: Executar task
- /spec-review: Revisar conformidade
- /spec-retro: Finalizar task e consolidar memória
- /spec-replan: Replanejamento estratégico
- /spec-align: Alinhar Constituição
- /spec-memorize: Salvar aprendizados no Basic Memory
- /spec-board: Visualizar Kanban
- /spec-search: Buscar no backlog
- /spec-help: Ajuda completa

**Integração MCP:**
- Backlog MCP: Gerenciamento de tasks, specs, docs, decisões
- Basic Memory: Persistência de ADRs, lições aprendidas, padrões (Markdown)

**Antes de qualquer tarefa:**
1. Consultar Basic Memory: `search("termo relacionado")`
2. Verificar Constituição: Ler `backlog/docs/doc-001...`
3. Listar tasks relacionadas: `backlog task list --labels <label>`
```

**Método de atualização:**
- Ler CLAUDE.md existente
- Localizar seção "## Workflow Obrigatório" ou adicionar no final
- Substituir ou adicionar o conteúdo acima

### Saída Esperada

```markdown
✅ Ambiente Spec-Driven Development Inicializado com Sucesso!

📦 **Backlog MCP**: ✅ Configurado
   - Backlog.md criado/atualizado
   - backlog/config.yml configurado com statuses, labels, milestones
   - Estrutura de diretórios criada:
     ✓ backlog/specs/
     ✓ backlog/docs/standards/
     ✓ backlog/docs/decisions/

🏛️ **Constituição**: ✅ Criada
   - backlog/docs/doc-001 - Constituição do Projeto.md

🧠 **Basic Memory**: ✅ Inicializado
   - Nota "[Project] - $(basename $(pwd))" criada
   - Persistência em Markdown configurada

📝 **CLAUDE.md**: ✅ Atualizado
   - Regras imperativas injetadas
   - Comandos /spec-* documentados

🔄 **Migração**: $(se aplicável: "✅ Concluída - Backup em backlog.old/")

🎯 **Próximos Passos:**
   1. Explore o backlog: `backlog board`
   2. Crie sua primeira feature: `/spec-plan "Nome da Feature"`
   3. Consulte a ajuda: `/spec-help`
   4. Visualize a Constituição: Ler backlog/docs/doc-001...

📚 **Recursos:**
   - CLI Backlog: https://github.com/MrLesk/Backlog.md
   - Documentação spec-workflow: /spec-help
```

## Notas Importantes

- **Limpeza Automática**: O comando detecta e limpa inicializações parciais anteriores, movendo para `backlog.old/`
- **Validação Obrigatória**: Verifica se o CLI `backlog` está instalado antes de prosseguir. Se não estiver, instrui instalação.
- **Idempotência**: Pode ser executado múltiplas vezes sem duplicar dados. Detecta estado existente e ajusta.
- **Migração Automática**: Preserva dados de Backlog.md antigo, convertendo para novo formato MCP com todos os campos.
- **Backup Seguro**: Todos os arquivos antigos são movidos para `backlog.old/` antes de qualquer modificação.
- **Extensão .backlog**: Durante migração, specs antigas `.md` são renomeadas para `.backlog` automaticamente.
- **CLI Obrigatório**: O comando depende do CLI `backlog` do sistema. Não usa apenas ferramentas MCP.
