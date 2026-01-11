# Parallel Workflows

Strategies for working on multiple tasks simultaneously using worktrees.

## The Power of Parallel Worktrees

**Traditional approach** (sequential):
```
Task A (2 hours) → Task B (2 hours) → Task C (2 hours) = 6 hours total
```

**Worktrees approach** (parallel):
```
Task A (2 hours) ┐
Task B (2 hours) ├→ = 2 hours total (3x faster!)
Task C (2 hours) ┘
```

## Workflow 1: Feature Sprint

**Scenario**: Implement 3 related features for upcoming release

```bash
# 1. Create worktrees for all 3 features
git worktree add -b feature/auth worktrees/feature-auth
git worktree add -b feature/api worktrees/feature-api
git worktree add -b feature/ui worktrees/feature-ui

# 2. Setup symlinks in all worktrees
for dir in worktrees/*/; do
  cd "$dir"
  ln -s ../../node_modules node_modules
  cd ../..
done

# 3. Work on all features simultaneously (3 terminals)
# Terminal 1:
cd worktrees/feature-auth
vim src/auth/service.ts
npm test  # Test auth in isolation

# Terminal 2 (simultaneously):
cd worktrees/feature-api
vim src/api/routes.ts
npm test  # Test API in isolation

# Terminal 3 (simultaneously):
cd worktrees/feature-ui
vim src/components/Login.tsx
npm test  # Test UI in isolation

# 4. Push all features when ready
cd worktrees/feature-auth && git push origin feature/auth &
cd worktrees/feature-api && git push origin feature/api &
cd worktrees/feature-ui && git push origin feature/ui &
wait
```

### Task Prioritization Matrix

| Priority | High Complexity | Low Complexity |
|----------|----------------|----------------|
| **High Value** | Do first (hard & important) | Parallel with other tasks |
| **Low Value** | Delegate or defer | Batch process |

## Workflow 2: Bugfix Triaging

**Scenario**: Multiple bugs reported, need to prioritize and fix

```bash
# 1. Create worktrees for all reported bugs
bugs=(
  "bugfix/login-crash"
  "bugfix/api-timeout"
  "bugfix/memory-leak"
  "bugfix/typo-homepage"
)

for bug in "${bugs[@]}"; do
  worktree="worktrees/$(echo $bug | tr '/' '-')"
  git worktree add -b "$bug" "$worktree"
  cd "$worktree"
  ln -s ../../node_modules node_modules
  cd ../..
done

# 2. Quick diagnosis in all worktrees (parallel)
for dir in worktrees/bugfix-*/; do
  (
    cd "$dir"
    echo "Diagnosing: $dir"
    npm test 2>&1 | head -20
  ) &
done
wait

# 3. Prioritize based on diagnosis
# - login-crash: Critical (affects all users) → Fix NOW
# - api-timeout: High (affects many users) → Fix NOW
# - memory-leak: Medium (affects some users) → Fix later
# - typo-homepage: Low (cosmetic) → Fix when time permits

# 4. Fix critical bugs in parallel (2 terminals)
# Terminal 1:
cd worktrees/bugfix-login-crash
vim src/login.ts
npm test
git commit -m "fix: resolve login crash"

# Terminal 2 (simultaneously):
cd worktrees/bugfix-api-timeout
vim src/api/timeout.ts
npm test
git commit -m "fix: resolve API timeout"

# 5. Push critical fixes
git push origin bugfix/login-crash
git push origin bugfix/api-timeout

# 6. Remove worktrees for non-critical bugs (defer to later)
git worktree remove worktrees/bugfix-memory-leak
git worktree remove worktrees/bugfix-typo-homepage
```

## Workflow 3: Code Review Parallelization

**Scenario**: Review 5 PRs from team

```bash
# 1. Fetch all PR branches
git fetch origin pr-1:pr-1
git fetch origin pr-2:pr-2
git fetch origin pr-3:pr-3
git fetch origin pr-4:pr-4
git fetch origin pr-5:pr-5

# 2. Create worktrees for each PR
for i in {1..5}; do
  git worktree add "pr-$i" "worktrees/review-pr-$i"
  cd "worktrees/review-pr-$i"
  ln -s ../../node_modules node_modules
  cd ../..
done

# 3. Quick smoke tests in all PRs (parallel)
for dir in worktrees/review-pr-*/; do
  (
    cd "$dir"
    pr_name=$(basename "$dir")
    echo "Testing $pr_name..."
    npm test 2>&1 | grep -E "(passing|failing)"
  ) &
done
wait

# 4. Review PRs in parallel (3 terminals)
# Terminal 1: Review PR-1 and PR-2
cd worktrees/review-pr-1
vim src/feature.ts
git log --oneline -5

cd ../review-pr-2
vim src/feature.ts
git log --oneline -5

# Terminal 2 (simultaneously): Review PR-3 and PR-4
cd worktrees/review-pr-3
vim src/feature.ts

cd ../review-pr-4
vim src/feature.ts

# Terminal 3 (simultaneously): Review PR-5
cd worktrees/review-pr-5
vim src/feature.ts

# 5. Approve/reject PRs based on review
# 6. Cleanup all review worktrees
for dir in worktrees/review-pr-*/; do
  git worktree remove "$dir"
done
```

## Workflow 4: Release Management

**Scenario**: Prepare release for multiple versions (v1.2, v2.0, v2.1)

```bash
# 1. Create worktrees for each release version
versions=(
  "v1.2.3:release-1.2"
  "v2.0.1:release-2.0"
  "v2.1.0:release-2.1"
)

for entry in "${versions[@]}"; do
  tag="${entry%%:*}"
  branch="${entry##*:}"
  worktree="worktrees/release-$(echo $branch | tr '/' '-')"

  git worktree add -b "$branch" "$tag" "$worktree"
  cd "$worktree"
  ln -s ../../node_modules node_modules
  cd ../..
done

# 2. Update version numbers in all releases (parallel)
for dir in worktrees/release-*/; do
  (
    cd "$dir"
    echo "Updating version in: $dir"
    # Update package.json, changelog, etc.
    npm version patch --no-git-tag-version
    git add .
    git commit -m "chore: bump version"
  ) &
done
wait

# 3. Test all releases (parallel)
for dir in worktrees/release-*/; do
  (
    cd "$dir"
    echo "Testing: $dir"
    npm test
  ) &
done
wait

# 4. Create and push tags for all releases
for dir in worktrees/release-*/; do
  (
    cd "$dir"
    version=$(node -p "require('./package.json').version")
    git tag "v$version"
    git push origin "v$version"
  ) &
done
wait
```

## Workflow 5: Refactoring Coordination

**Scenario**: Refactor shared module used by multiple features

```bash
# 1. Identify affected features (via git log)
git log --oneline --all -- "src/shared/auth.ts"
# → Used by feature/auth, feature/api, feature/ui

# 2. Create worktrees for all affected features
features=(
  "feature/auth"
  "feature/api"
  "feature/ui"
)

for feature in "${features[@]}"; do
  worktree="worktrees/$(echo $feature | tr '/' '-')"
  git worktree add -b "$feature" "$worktree"
  cd "$worktree"
  ln -s ../../node_modules node_modules
  cd ../..
done

# 3. Refactor shared module in feature/auth worktree first
cd worktrees/feature-auth
vim src/shared/auth.ts  # Refactor interface
npm test  # Ensure auth feature still works
git commit -m "refactor: update auth interface"

# 4. Propagate changes to other features (in parallel)
# Terminal 2:
cd worktrees/feature-api
git merge feature/auth  # Bring in refactor
npm test  # Fix any breakage
vim src/api/auth.ts  # Adapt to new interface
git commit -m "feat(api): adapt to new auth interface"

# Terminal 3 (simultaneously):
cd worktrees/feature-ui
git merge feature/auth  # Bring in refactor
npm test  # Fix any breakage
vim src/components/auth.tsx  # Adapt to new interface
git commit -m "feat(ui): adapt to new auth interface"

# 5. Test integration of all features
cd ../..
# Run integration tests that span all features
npm run test:integration

# 6. Push all features together
cd worktrees/feature-auth && git push origin feature/auth &
cd worktrees/feature-api && git push origin feature/api &
cd worktrees/feature-ui && git push origin feature/ui &
wait
```

## Conflict Resolution Strategies

### Strategy 1: Merge Early

```bash
# Merge main into each worktree frequently to avoid conflicts
for dir in worktrees/*/; do
  (
    cd "$dir"
    git merge main --no-edit
    npm test
  ) &
done
wait
```

### Strategy 2: Isolate Changes

```bash
# Design features to minimize file overlap
# - feature/auth: src/auth/* (exclusive)
# - feature/api: src/api/* (exclusive)
# - feature/ui: src/components/* (exclusive)
# → Minimal conflicts, easier parallel work
```

### Strategy 3: Communication Protocol

```bash
# When 2 worktrees modify same file:
# 1. Coordinate changes in Slack/issue tracker
# 2. Agree on interface/contract
# 3. Implement in one worktree first
# 4. Merge and adapt in second worktree
# 5. Test integration together
```

## Performance Optimization

### Limit Parallel Jobs

```bash
# Don't run too many parallel jobs (overwhelms CPU)
# Use job control with `xargs` or GNU parallel

# Max 4 parallel npm tests
find worktrees -name "package.json" -print0 | \
  xargs -0 -P4 -I{} bash -c "cd $(dirname {}) && npm test"
```

### Background Services

```bash
# If features need dev servers, use different ports
# Terminal 1:
cd worktrees/feature-auth
PORT=3000 npm run dev

# Terminal 2 (simultaneously):
cd worktrees/feature-api
PORT=3001 npm run dev

# Terminal 3 (simultaneously):
cd worktrees/feature-ui
PORT=3002 npm run dev
```

## Best Practices

✅ **DO**:
- Plan parallel tasks before creating worktrees
- Use different terminals/panes for each worktree
- Test in isolation before integration
- Communicate conflicts early
- Limit parallel work to 3-5 tasks at once

❌ **DON'T**:
- Create worktree for every minor task (overhead)
- Work on dependent tasks in parallel (blocking)
- Forget to integrate and test together
- Leave too many worktrees active (confusing)
- Run resource-intensive tasks in parallel (overwhelms CPU)

## Next Steps

- **Creation Patterns**: See `creation-patterns.md` for worktree setup
- **Cleanup**: See `cleanup-strategies.md` for removing obsolete worktrees
- **Troubleshooting**: See `troubleshooting.md` for conflict resolution
