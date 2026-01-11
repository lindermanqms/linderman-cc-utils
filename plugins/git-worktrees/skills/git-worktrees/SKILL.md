---
name: git-worktrees
description: This skill should be used when the user wants to "create worktree", "manage worktrees", "parallel work on branches", "worktree manager", mentions "git worktree", or needs to work on multiple features simultaneously using Git worktrees with automatic dependency symlinks.
version: 1.0.0
---

# Git Worktrees Manager Skill

## Overview

Manage Git worktrees for parallel development on multiple branches simultaneously. This skill automates worktree creation, dependency management via symlinks, and cleanup, enabling efficient task parallelization without branch switching overhead.

## Core Principle

**"Work in parallel, share dependencies."**

When this skill is active:
- **CREATE** isolated worktrees for each feature/bugfix branch
- **SHARE** dependencies via symlinks (node_modules, .venv)
- **WORK** on multiple tasks simultaneously without context switching
- **CLEANUP** merged/obsolete worktrees automatically

## Why Worktrees?

**Traditional Branch Switching** (slow):
```
main branch → git checkout feature-a → npm install → work
→ git checkout feature-b → npm install → work
(repeat for each branch)
```

**Worktrees Approach** (fast, parallel):
```
main/ → worktrees/feature-a/ → symlink node_modules → work
      → worktrees/feature-b/ → symlink node_modules → work
      → worktrees/feature-c/ → symlink node_modules → work
(work simultaneously on all 3 branches!)
```

## Knowledge Domains

### 1. Quick Start (`quick-start.md`)
**When to consult**: First time using worktrees or need basic workflow

Essential commands:
- Creating your first worktree
- Setting up symlinks for dependencies
- Working in multiple branches simultaneously
- Cleaning up after merging

### 2. Worktree Creation Patterns (`creation-patterns.md`)
**When to consult**: Need to create worktree for specific use case

Patterns for:
- New feature branch (from main)
- Bugfix branch (from release tag)
- Hotfix branch (from production)
- Experimental branch (from any commit)

### 3. Dependency Management (`dependency-management.md`)
**When to consult**: Setting up symlinks for node_modules, .venv, etc.

Complete guide for:
- Creating symlinks for Node.js projects (node_modules)
- Creating symlinks for Python projects (.venv with uv)
- Handling project-specific dependency overrides
- Updating dependencies across all worktrees

### 4. Parallel Workflows (`parallel-workflows.md`)
**When to consult**: Working on multiple tasks simultaneously

Strategies for:
- Task prioritization and parallelization
- Conflict resolution between worktrees
- Synchronization patterns
- Testing across multiple branches

### 5. Cleanup Strategies (`cleanup-strategies.md`)
**When to consult**: Removing obsolete worktrees

Best practices for:
- Identifying merged branches
- Safe worktree removal
- Bulk cleanup operations
- Automated cleanup scripts

### 6. Troubleshooting (`troubleshooting.md`)
**When to consult**: Encountering issues with worktrees

Solutions for:
- Symlink errors
- Detached HEAD states
- Merge conflicts across worktrees
- Permission issues

## Basic Rules

When managing worktrees, follow these essential rules:

1. **ALWAYS create worktrees in `worktrees/` directory** - keeps workspace organized
2. **ALWAYS use symlinks for dependencies** - node_modules and .venv should point to main worktree
3. **NEVER commit worktree directory** - add `worktrees/` to .gitignore
4. **ALWAYS remove worktrees after merge** - keeps worktrees/ directory clean
5. **NEVER push from worktree directly** - use main worktree for operations
6. **ALWAYS check branch exists before creating worktree** - avoid duplicate worktrees

## Quick Start

### Creating Your First Worktree

```bash
# 1. Ensure main worktree has dependencies installed
cd /path/to/project/main
npm install
# or for Python:
uv venv
uv pip install -r requirements.txt

# 2. Create worktree for new feature
git worktree add -b feature/user-auth worktrees/feature-user-auth

# 3. Create symlinks to shared dependencies
cd worktrees/feature-user-auth
ln -s ../../node_modules node_modules
# or for Python:
ln -s ../../.venv .venv

# 4. Work on the feature
# (edit files, commit, push as normal)

# 5. After merge, remove worktree
cd ../..
git worktree remove worktrees/feature-user-auth
```

### Working on Multiple Tasks Simultaneously

```bash
# Create 3 worktrees for parallel work
git worktree add -b feature/auth worktrees/feature-auth
git worktree add -b feature/api worktrees/feature-api
git worktree add -b bugfix/login worktrees/bugfix-login

# Setup symlinks in each worktree
for dir in worktrees/*/; do
  cd "$dir"
  ln -s ../../node_modules node_modules
  cd ../..
done

# Now work on all 3 tasks simultaneously!
# Terminal 1: cd worktrees/feature-auth && vim src/auth.ts
# Terminal 2: cd worktrees/feature-api && vim src/api.ts
# Terminal 3: cd worktrees/bugfix-login && vim src/login.ts
```

### .gitignore Configuration

**Add to project root .gitignore**:
```
# Worktrees directory
worktrees/
```

This prevents committing worktree directories to the repository.

## Directory Structure

```
project/
├── .git/                    # Git repository
├── .gitignore              # Includes "worktrees/"
├── node_modules/           # Shared dependencies (main worktree)
├── worktrees/              # All worktrees (gitignored)
│   ├── feature-auth/       # Worktree for feature/auth branch
│   │   ├── node_modules → ../../node_modules  # Symlink
│   │   ├── src/
│   │   └── .git            # Worktree-specific .git file
│   ├── feature-api/        # Worktree for feature/api branch
│   │   ├── node_modules → ../../node_modules  # Symlink
│   │   └── src/
│   └── bugfix-login/       # Worktree for bugfix/login branch
│       ├── node_modules → ../../node_modules  # Symlink
│       └── src/
├── src/                    # Main branch files
└── package.json
```

## When to Use This Skill

Invoke Git Worktrees Manager when:
- Starting work on multiple features simultaneously
- Need to fix a critical bug without stopping current feature work
- Want to review/test multiple branches at once
- Need to backport fixes across multiple release branches
- Performing parallel code reviews

**Trigger phrases**:
- "create worktree for"
- "work on multiple branches"
- "parallel work on features"
- "manage worktrees"
- "setup worktree for"
- "worktree manager"

## Prerequisites

Before using this skill, ensure:
1. **Git 2.17+ installed with worktree support**:
   ```bash
   git worktree --version
   # Should show version info
   ```

2. **Project initialized with Git**:
   ```bash
   git init  # or git clone
   ```

3. **For symlinks to work**: Main worktree must have dependencies installed
   ```bash
   npm install  # or
   uv venv && uv pip install -r requirements.txt
   ```

## Version History

- **v1.0.0** (2026-01-11): Initial release - Worktree management with symlinks

---

**Remember**: Worktrees enable true parallel development. Share dependencies via symlinks, work on multiple branches simultaneously, and clean up after merging.
