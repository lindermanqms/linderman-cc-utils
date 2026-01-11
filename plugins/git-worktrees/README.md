# Git Worktrees Manager Plugin

Sistema de gerenciamento de Git worktrees para desenvolvimento paralelo em múltiplas branches com symlinks automáticos de dependências.

## O que é

O **Git Worktrees Manager** é uma skill que transforma o Claude Code em um gerenciador eficiente de worktrees Git, permitindo:

- Trabalhar em múltiplas features simultaneamente sem trocar de branch
- Compartilhar dependências via symlinks (node_modules, .venv)
- Economizar espaço em disco e tempo de instalação
- Limpar worktrees obsoletos automaticamente

### Princípio Core

> **"Work in parallel, share dependencies."**

## Instalação

Este plugin já está registrado no marketplace `linderman-cc-utils`. Basta usar os triggers de ativação.

### Pré-requisitos

1. **Git 2.17+ com suporte a worktree**:
   ```bash
   git --version  # → 2.17+ required
   git worktree --version
   ```

2. **Projeto inicializado com Git**:
   ```bash
   git init  # ou git clone
   ```

3. **Dependências instaladas no worktree principal**:
   ```bash
   npm install  # Node.js
   # ou
   uv venv && uv pip install -r requirements.txt  # Python com uv
   ```

## Como Usar

### Invocação Automática

A skill é ativada quando você usa estas frases:

- "create worktree for"
- "work on multiple branches"
- "parallel work on features"
- "manage worktrees"
- "setup worktree for"
- "worktree manager"

### Exemplos Rápidos

**Criar primeiro worktree**:
```bash
# Criar worktree para nova feature
git worktree add -b feature/user-auth worktrees/feature-user-auth

# Criar symlink para dependências
cd worktrees/feature-user-auth
ln -s ../../node_modules node_modules

# Trabalhar normalmente
vim src/auth.ts
git add . && git commit -m "feat: add authentication"
```

**Trabalhar em múltiplas features simultaneamente**:
```bash
# Criar 3 worktrees
git worktree add -b feature/auth worktrees/feature-auth
git worktree add -b feature/api worktrees/feature-api
git worktree add -b bugfix/login worktrees/bugfix-login

# Setup symlinks em todos
for dir in worktrees/*/; do
  cd "$dir"
  ln -s ../../node_modules node_modules
  cd ../..
done

# Trabalhar nos 3 ao mesmo tempo!
# Terminal 1: cd worktrees/feature-auth && vim src/auth.ts
# Terminal 2: cd worktrees/feature-api && vim src/api.ts
# Terminal 3: cd worktrees/bugfix-login && vim src/login.ts
```

**Limpar worktree após merge**:
```bash
# Remover worktree
git worktree remove worktrees/feature-auth

# Deletar branch (opcional)
git branch -d feature/auth
```

## Documentação Completa

A skill usa **progressive disclosure** - conteúdo detalhado é carregado sob demanda.

### Guias de Referência

1. **[`quick-start.md`](skills/git-worktrees/references/quick-start.md)**
   Primeiros passos com worktrees em 5 minutos

2. **[`creation-patterns.md`](skills/git-worktrees/references/creation-patterns.md)**
   Padrões para criar worktrees (feature, bugfix, hotfix, experiment, etc.)

3. **[`dependency-management.md`](skills/git-worktrees/references/dependency-management.md)**
   Gerenciar symlinks de node_modules (Node.js) e .venv (Python com uv)

4. **[`parallel-workflows.md`](skills/git-worktrees/references/parallel-workflows.md)**
   Estratégias para trabalhar em múltiplas tarefas simultaneamente

5. **[`cleanup-strategies.md`](skills/git-worktrees/references/cleanup-strategies.md)**
   Remover worktrees obsoletos e manter workspace limpo

6. **[`troubleshooting.md`](skills/git-worktrees/references/troubleshooting.md)**
   Solução de problemas: symlinks, permissões, conflitos, etc.

## Configuração

### .gitignore

Adicione ao `.gitignore` na raiz do projeto:
```
# Worktrees directory
worktrees/
```

### Estrutura de Diretórios

```
project/
├── .git/                    # Repositório Git
├── .gitignore              # Inclui "worktrees/"
├── node_modules/           # Dependências compartilhadas
├── worktrees/              # Todos os worktrees (gitignored)
│   ├── feature-auth/       # Worktree para feature/auth
│   │   ├── node_modules → ../../node_modules  # Symlink
│   │   └── src/
│   └── feature-api/        # Worktree para feature/api
│       ├── node_modules → ../../node_modules  # Symlink
│       └── src/
└── src/                    # Branch principal
```

## Benefícios

### Velocidade

**Sem worktrees** (branch switching):
```
feature-a (2h) → feature-b (2h) → feature-c (2h) = 6h total
+ npm install a cada troca = +3h
= 9h total
```

**Com worktrees** (parallel):
```
feature-a (2h) ┐
feature-b (2h) ├→ = 2h total (4.5x mais rápido!)
feature-c (2h) ┘
```

### Economia de Espaço

**Sem symlinks**:
```
1 worktree × 500MB = 500MB
10 worktrees × 500MB = 5GB
20 worktrees × 500MB = 10GB
```

**Com symlinks**:
```
1 main × 500MB + 10 worktrees × 0MB = 500MB total
1 main × 500MB + 20 worktrees × 0MB = 500MB total
```

Economia: **19.5GB** para 20 worktrees!

## Comandos Úteis

```bash
# Listar worktrees
git worktree list

# Criar worktree
git worktree add -b branch-name worktrees/worktree-name

# Remover worktree
git worktree remove worktrees/worktree-name

# Limpar metadados de worktrees órfãos
git worktree prune

# Mover worktree
git worktree move old-path new-path
```

## Versão

**v1.0.0** (2026-01-11) - Lançamento inicial: Gerenciamento de worktrees com symlinks

## Recursos Adicionais

- **CHANGELOG.md**: Histórico de versões
- **Plugin Manifest**: `plugins/git-worktrees/.claude-plugin/plugin.json`
- **Marketplace**: `.claude-plugin/marketplace.json`

---

**"Work in parallel, share dependencies."**
