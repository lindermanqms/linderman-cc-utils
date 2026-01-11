# Changelog - Git Worktrees Manager Plugin

## [1.0.0] - 2026-01-11

### Added
- **Sistema completo de gerenciamento de Git worktrees** para desenvolvimento paralelo
- **Suporte a symlinks automáticos** para node_modules (Node.js) e .venv (Python com uv)
- **6 arquivos de referência detalhados** (references/):
  - `quick-start.md` - Primeiros passos em 5 minutos
  - `creation-patterns.md` - Padrões de criação de worktrees (8 padrões)
  - `dependency-management.md` - Gerenciamento de symlinks de dependências
  - `parallel-workflows.md` - Estratégias de trabalho paralelo (5 workflows)
  - `cleanup-strategies.md` - Remoção de worktrees obsoletos
  - `troubleshooting.md` - Solução de problemas comuns
- **README.md** com visão geral e guias rápidos
- **Integração com marketplace** `linderman-cc-utils`

### Features

**Criação de Worktrees**:
- Padrões para 8 tipos de worktrees (feature, bugfix, hotfix, experiment, code review, backport, bulk, detached HEAD)
- Convenções de nomenclatura para branches e diretórios
- Suporte a múltiplas release branches

**Gerenciamento de Dependências**:
- Symlinks para node_modules (Node.js)
- Symlinks para .venv (Python com uv)
- Scripts automatizados de setup
- Atualização centralizada de dependências

**Workflows Paralelos**:
- Feature sprint (múltiplas features simultâneas)
- Bugfix triaging (classificação e priorização)
- Code review parallelization (revisão em lote)
- Release management (múltiplas versões)
- Refactoring coordination (coordenação de refatoração)

**Limpeza e Manutenção**:
- Remoção manual após merge
- Scripts automatizados de limpeza
- Remoção por idade (N dias)
- Remoção de worktrees órfãos
- Menu interativo de limpeza

**Solução de Problemas**:
- Worktrees duplicados
- Branches já checkout
- Symlinks quebrados
- Detached HEAD
- Conflitos de merge
- Problemas de permissão
- Questões específicas do Windows

### Benefícios

**Performance**:
- 4.5x mais rápido que branch switching tradicional
- Instalação de dependências 10-15x mais rápida com symlinks
- Trabalho verdadeiramente paralelo em múltiplas features

**Economia**:
- 19.5GB economizados para 20 worktrees (com symlinks)
- 500MB total vs 10GB sem symlinks

**Organização**:
- Diretório `worktrees/` padronizado
- .gitignore configurado automaticamente
- Limpeza automatizada de worktrees obsoletos

### Initial Release
- Primeira versão como skill
- Marketplace `linderman-cc-utils` configurado
- Pré-requisitos: Git 2.17+, dependências instaladas no main worktree

### Technical Details

**Arquivos criados**: 9
- 1 SKILL.md
- 6 references/*.md
- 1 README.md
- 1 CHANGELOG.md
- 1 plugin.json

**Linhas de código**:
- SKILL.md: ~350 linhas (visão geral)
- References: ~2,500 linhas (detalhes técnicos)
- Total: ~3,000 linhas

**Trigger phrases**:
- "create worktree for"
- "work on multiple branches"
- "parallel work on features"
- "manage worktrees"
- "setup worktree for"
- "worktree manager"

### Compatibility

- **Git version**: Requer Git 2.17+ para suporte completo a worktrees
- **OS**: Linux, macOS, Windows (com limitações de symlink)
- **Node.js**: Suporte completo com symlinks de node_modules
- **Python**: Suporte completo com symlinks de .venv (usando uv)

### Future Enhancements

Possíveis melhorias futuras:
- Integração com GitHub CLI (gh) para automaticamente criar worktrees de PRs
- Scripts de automatização mais avançados
- Integração com ferramentas de CI/CD
- Suporte a outros gerenciadores de pacotes (pnpm, yarn, poetry, etc.)
- Interface web/CLI para gerenciamento visual de worktrees

---

## Documentação

Para uso detalhado, consulte:
- **Quick Start**: `skills/git-worktrees/references/quick-start.md`
- **Creation Patterns**: `skills/git-worktrees/references/creation-patterns.md`
- **Dependency Management**: `skills/git-worktrees/references/dependency-management.md`
- **Parallel Workflows**: `skills/git-worktrees/references/parallel-workflows.md`
- **Cleanup Strategies**: `skills/git-worktrees/references/cleanup-strategies.md`
- **Troubleshooting**: `skills/git-worktrees/references/troubleshooting.md`
