# Quick Start Guide

Get started with Git worktrees in 5 minutes.

## Prerequisites Check

```bash
# 1. Check Git version (2.17+ required)
git --version
# → git version 2.43.0 or higher

# 2. Verify worktree support
git worktree --version
# → Should show version info

# 3. Check current branch
git branch --show-current
# → main or develop
```

## Your First Worktree

### Scenario: New Feature Branch

**Task**: Create worktree for new feature "user authentication"

```bash
# 1. Ensure dependencies are installed in main worktree
npm install
# → node_modules/ created in project root

# 2. Create worktree with new branch
git worktree add -b feature/user-auth worktrees/feature-user-auth

# Output:
# Preparing worktree (new branch 'feature/user-auth')
# HEAD is now at 1a2b3c4 Initial commit

# 3. Navigate to worktree
cd worktrees/feature-user-auth

# 4. Create symlink to shared dependencies
ln -s ../../node_modules node_modules

# 5. Verify symlink created
ls -la | grep node_modules
# → node_modules -> ../../node_modules

# 6. Start working!
# (Your normal workflow: edit files, commit, push)
```

### Python Project with uv

```bash
# 1. Create virtual environment in main worktree
cd /path/to/project
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt

# 2. Create worktree
git worktree add -b feature/new-api worktrees/feature-new-api

# 3. Create symlink
cd worktrees/feature-new-api
ln -s ../../.venv .venv

# 4. Verify
ls -la | grep venv
# → .venv -> ../../.venv
```

## Working in Multiple Branches

### Scenario: Three Parallel Tasks

**Tasks**:
1. Feature: User authentication
2. Feature: API endpoints
3. Bugfix: Login error

```bash
# 1. Create all worktrees
git worktree add -b feature/auth worktrees/feature-auth
git worktree add -b feature/api worktrees/feature-api
git worktree add -b bugfix/login-error worktrees/bugfix-login-error

# 2. Setup symlinks in each worktree
cd worktrees/feature-auth && ln -s ../../node_modules node_modules && cd ../..
cd worktrees/feature-api && ln -s ../../node_modules node_modules && cd ../..
cd worktrees/bugfix-login-error && ln -s ../../node_modules node_modules && cd ../..

# 3. Work on all tasks simultaneously
# Terminal 1:
cd worktrees/feature-auth
vim src/auth.ts
git add . && git commit -m "feat: add authentication"

# Terminal 2 (simultaneously):
cd worktrees/feature-api
vim src/api.ts
git add . && git commit -m "feat: add API endpoints"

# Terminal 3 (simultaneously):
cd worktrees/bugfix-login-error
vim src/login.ts
git add . && git commit -m "fix: resolve login error"

# All three can be worked on AT THE SAME TIME!
```

## List Active Worktrees

```bash
# List all worktrees
git worktree list

# Output:
# /path/to/project              abc1234 [main]
# /path/to/project/worktrees/feature-auth  def5678 [feature/auth]
# /path/to/project/worktrees/feature-api   ghi9012 [feature/api]
# /path/to/project/worktrees/bugfix-login-error  jkl3456 [bugfix/login-error]
```

## Remove Worktree After Merge

```bash
# 1. After PR merged, remove worktree
git worktree remove worktrees/feature-auth

# Output:
# Preparing worktree for removal
# Worktree worktrees/feature-auth removed

# 2. Delete branch (optional)
git branch -d feature/auth

# 3. Verify removed
git worktree list
# → Only main worktree listed
```

## Common Workflows

### Bugfix While Working on Feature

```bash
# Working on feature in worktrees/feature-x
cd worktrees/feature-x
vim feature.ts  # → Suddenly, critical bug reported!

# Create worktree for bugfix WITHOUT stopping feature work
cd ../..
git worktree add -b bugfix/critical-error worktrees/bugfix-critical-error
cd worktrees/bugfix-critical-error
ln -s ../../node_modules node_modules

# Fix bug, commit, push
vim fix.ts
git add . && git commit -m "fix: critical error"
git push

# Continue working on feature in Terminal 2
# (No need to stash, checkout, or re-install dependencies!)
```

### Testing Multiple Branches

```bash
# Create worktrees for different release branches
git worktree add release/1.x worktrees/release-1.x
git worktree add release/2.x worktrees/release-2.x

# Setup symlinks
cd worktrees/release-1.x && ln -s ../../node_modules node_modules && cd ../..
cd worktrees/release-2.x && ln -s ../../node_modules node_modules && cd ../..

# Test both releases simultaneously
# Terminal 1:
cd worktrees/release-1.x && npm test

# Terminal 2:
cd worktrees/release-2.x && npm test
```

## Troubleshooting Quick Fixes

### Worktree Already Exists

```bash
# Error: "A worktree with this name already exists"
# Fix: List worktrees and remove if obsolete
git worktree list
git worktree remove worktrees/obsolete-branch
```

### Symlink Failed

```bash
# Error: "File exists" when creating symlink
# Fix: Remove existing directory/file first
cd worktrees/feature-x
rm -rf node_modules
ln -s ../../node_modules node_modules
```

### Branch Already Checked Out

```bash
# Error: "Branch is already checked out"
# Fix: You're trying to create worktree for branch that's active elsewhere
git worktree list
# → Find where branch is checked out
git worktree remove /path/to/other/worktree
```

## .gitignore Setup

**Add to `.gitignore`** in project root:
```bash
echo "worktrees/" >> .gitignore
```

This prevents committing worktree directories.

## Next Steps

- **Detailed patterns**: See `creation-patterns.md` for advanced worktree creation
- **Dependency management**: See `dependency-management.md` for symlink strategies
- **Parallel workflows**: See `parallel-workflows.md` for multi-task strategies
- **Cleanup**: See `cleanup-strategies.md` for removing obsolete worktrees

## Quick Reference Commands

```bash
# Create worktree
git worktree add -b branch-name worktrees/worktree-name

# List worktrees
git worktree list

# Remove worktree
git worktree remove worktrees/worktree-name

# Prune stale worktree metadata
git worktree prune

# Move worktree
git worktree move old-path new-path
```
