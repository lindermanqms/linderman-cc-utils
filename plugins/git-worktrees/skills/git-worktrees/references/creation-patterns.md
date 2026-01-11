# Worktree Creation Patterns

Standardized patterns for creating worktrees for different use cases.

## Pattern 1: New Feature Branch

**Use case**: Starting development of a new feature from main branch

```bash
# Basic pattern
git worktree add -b feature/short-description worktrees/feature-short-description

# Example
git worktree add -b feature/user-authentication worktrees/feature-user-auth

# Setup symlinks
cd worktrees/feature-user-auth
ln -s ../../node_modules node_modules  # Node.js
ln -s ../../.venv .venv                # Python with uv
```

### Naming Conventions

**Branch names**: Use prefixes
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical production fixes
- `refactor/` - Code refactoring
- `test/` - Test improvements
- `docs/` - Documentation updates

**Worktree directories**: Replace `/` with `-`
- Branch: `feature/user-authentication`
- Worktree: `worktrees/feature-user-authentication`

## Pattern 2: Bugfix from Release Branch

**Use case**: Fixing bug in specific release version

```bash
# 1. Find release tag/branch
git tag | grep v1.2  # → v1.2.3

# 2. Create worktree from release tag
git worktree add -b bugfix/login-error v1.2.3 worktrees/bugfix-login-error-1.2

# 3. Setup symlinks
cd worktrees/bugfix-login-error-1.2
ln -s ../../node_modules node_modules

# 4. Fix bug, test, commit
vim src/login.ts
npm test
git commit -m "fix: resolve login error in v1.2.3"
```

### Multiple Release Versions

```bash
# Fix bug in v1.2, v1.3, and v2.0
for version in "v1.2.3" "v1.3.0" "v2.0.1"; do
  worktree="worktrees/bugfix-login-error-${version}"
  git worktree add -b "bugfix/${version}-login-error" "$version" "$worktree"

  # Setup symlinks
  cd "$worktree"
  ln -s ../../node_modules node_modules
  cd ../..
done

# Now fix bug in all 3 versions simultaneously
```

## Pattern 3: Hotfix from Production

**Use case**: Critical production fix that bypasses normal flow

```bash
# 1. Create worktree from production branch
git worktree add -b hotfix/security-patch production worktrees/hotfix-security-patch

# 2. Setup and work
cd worktrees/hotfix-security-patch
ln -s ../../node_modules node_modules

# 3. Apply fix, test, commit
vim security/patch.ts
npm test
git commit -m "hotfix: critical security vulnerability"

# 4. Merge to production AND main
git checkout production
git merge hotfix/security-patch
git checkout main
git merge hotfix/security-patch

# 5. Remove worktree
git worktree remove worktrees/hotfix-security-patch
```

## Pattern 4: Experimental Branch

**Use case**: Trying out experimental feature without cluttering main

```bash
# 1. Create worktree from current commit
git worktree add -b experiment/new-idea worktrees/experiment-new-idea

# 2. Setup symlinks
cd worktrees/experiment-new-idea
ln -s ../../node_modules node_modules

# 3. Work on experimental feature
# (No fear of breaking main branch!)

# 4. If experiment fails, just delete worktree
cd ../..
git worktree remove worktrees/experiment-new-idea
git branch -D experiment/new-idea  # Also delete branch

# If experiment succeeds, merge and cleanup
git checkout main
git merge experiment/new-idea
git worktree remove worktrees/experiment-new-idea
```

## Pattern 5: Code Review Worktree

**Use case**: Reviewing PR without changing current branch

```bash
# 1. Fetch PR branch
git fetch origin feature/pr-branch

# 2. Create worktree from fetched branch
git worktree add origin/feature/pr-branch worktrees/review-pr-branch

# 3. Setup symlinks
cd worktrees/review-pr-branch
ln -s ../../node_modules node_modules

# 4. Review code, run tests
npm test
npm run build

# 5. After review, remove worktree
cd ../..
git worktree remove worktrees/review-pr-branch
```

## Pattern 6: Backport Worktree

**Use case**: Porting fix from newer version to older release

```bash
# Scenario: Fix exists in main (commit abc1234), need to backport to v1.2

# 1. Create worktree from target release
git worktree add -b bugfix/backported-fix v1.2.3 worktrees/backport-fix-to-1.2

# 2. Cherry-pick fix commit
cd worktrees/backport-fix-to-1.2
git cherry-pick abc1234

# 3. Setup symlinks
ln -s ../../node_modules node_modules

# 4. Test and adjust if needed
npm test
# (Resolve conflicts if any)

# 5. Commit and push
git commit -m "fix: backport fix from main"
git push origin bugfix/backported-fix
```

## Pattern 7: Bulk Worktree Creation

**Use case**: Creating multiple worktrees for sprint planning

```bash
#!/bin/bash
# create-worktrees.sh - Create worktrees for all sprint tasks

# Read tasks from sprint board
tasks=(
  "feature/user-auth"
  "feature/api-endpoints"
  "bugfix/login-error"
  "refactor/database"
)

for task in "${tasks[@]}"; do
  # Convert task to worktree name
  worktree_name="worktrees/$(echo $task | tr '/' '-')"

  # Create worktree
  git worktree add -b "$task" "$worktree_name"

  # Setup symlinks
  cd "$worktree_name"
  ln -s ../../node_modules node_modules
  cd ../..

  echo "✓ Created worktree: $worktree_name"
done

echo "✓ All ${#tasks[@]} worktrees ready for parallel work!"
```

## Pattern 8: Detached HEAD Worktree

**Use case**: Inspecting specific commit without creating branch

```bash
# 1. Create worktree at specific commit (detached HEAD)
git worktree add worktrees/inspect-commit abc1234

# 2. Setup symlinks
cd worktrees/inspect-commit
ln -s ../../node_modules node_modules

# 3. Inspect code, run tests
npm test
git log --oneline

# 4. After inspection, remove worktree
cd ../..
git worktree remove worktrees/inspect-commit
```

## Workflow Decision Tree

```
Need to create worktree
    ↓
What type of work?
    ├─ New feature → Pattern 1 (feature branch)
    ├─ Bug fix → Which version?
    │             ├─ Current → Pattern 1 (bugfix/)
    │             └─ Older release → Pattern 2 (from tag)
    ├─ Hotfix → Pattern 3 (from production)
    ├─ Experiment → Pattern 4 (experiment/)
    ├─ Code review → Pattern 5 (from PR)
    ├─ Backport → Pattern 6 (cherry-pick)
    └─ Inspect commit → Pattern 8 (detached HEAD)
```

## Common Patterns by Role

### Frontend Developer
```bash
# Work on UI feature + API integration simultaneously
git worktree add -b feature/user-ui worktrees/feature-user-ui
git worktree add -b feature/api-integration worktrees/feature-api-integration
```

### Backend Developer
```bash
# Work on multiple API endpoints
git worktree add -b feature/user-api worktrees/feature-user-api
git worktree add -b feature/auth-api worktrees/feature-auth-api
git worktree add -b feature/admin-api worktrees/feature-admin-api
```

### DevOps Engineer
```bash
# Update CI/CD across branches
git worktree add -b ci/update-main worktrees/ci-update-main
git worktree add -b ci/update-release worktrees/ci-update-release
git worktree add -b ci/update-hotfix worktrees/ci-update-hotfix
```

### Tech Lead
```bash
# Review multiple PRs simultaneously
git worktree add origin/pr-123 worktrees/review-pr-123
git worktree add origin/pr-124 worktrees/review-pr-124
git worktree add origin/pr-125 worktrees/review-pr-125
```

## Best Practices

✅ **DO**:
- Use descriptive branch and worktree names
- Follow consistent naming conventions
- Always setup symlinks after creating worktree
- Remove worktrees after merge
- Add `worktrees/` to .gitignore

❌ **DON'T**:
- Create worktree for branch already checked out elsewhere
- Forget to setup symlinks (wastes disk space)
- Commit worktree directory
- Leave obsolete worktrees lying around
- Use worktree for long-lived branches (use normal clone instead)

## Next Steps

- **Dependency Management**: See `dependency-management.md` for symlink strategies
- **Parallel Workflows**: See `parallel-workflows.md` for multi-task coordination
- **Cleanup**: See `cleanup-strategies.md` for removing obsolete worktrees
