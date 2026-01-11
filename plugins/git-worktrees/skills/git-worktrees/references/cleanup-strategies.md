# Cleanup Strategies

Remove obsolete worktrees to keep workspace clean and organized.

## When to Clean Up

**Clean up worktrees when**:
- PR/feature is merged to main
- Branch is deleted from remote
- Worktree hasn't been used in >7 days
- Experiment failed/abandoned
- Release is cut and branch no longer needed

## Cleanup After Merge

### Manual Cleanup

```bash
# 1. PR merged, time to cleanup
cd worktrees/feature-auth

# 2. Verify no uncommitted changes
git status
# → "nothing to commit, working tree clean"

# 3. Return to main worktree
cd ../..

# 4. Remove worktree
git worktree remove worktrees/feature-auth

# Output:
# Preparing worktree for removal
# Worktree worktrees/feature-auth removed

# 5. Delete branch (optional, if merged)
git branch -d feature/auth
# → Deleted branch feature/auth (was abc1234).

# 6. Verify removed
git worktree list
# → Only main worktree listed
```

### Automated Cleanup Script

```bash
#!/bin/bash
# cleanup-merged.sh - Remove worktrees for merged branches

# Find merged branches
git branch --merged | grep -E "feature/|bugfix/|hotfix/" | while read branch; do
  # Convert branch name to worktree path
  worktree_name="worktrees/$(echo $branch | tr '/' '-')"

  # Check if worktree exists
  if [ -d "$worktree_name" ]; then
    echo "Removing merged worktree: $worktree_name"
    git worktree remove "$worktree_name"
    git branch -d "$branch"
  fi
done

echo "✓ Cleanup complete: removed all merged worktrees"
```

## Cleanup by Age

### Find Stale Worktrees

```bash
# List worktrees with last modification time
for dir in worktrees/*/; do
  if [ -d "$dir" ]; then
    last_modified=$(git -C "$dir" log -1 --format=%ci 2>/dev/null || echo "unknown")
    days_since=$(( ($(date +%s) - $(date -d "$last_modified" +%s 2>/dev/null || echo 0)) / 86400 ))
    echo "$days_since days: $dir"
  fi
done | sort -rn
```

### Remove Worktrees Older Than N Days

```bash
#!/bin/bash
# cleanup-old.sh - Remove worktrees not modified in N days

DAYS_OLD=${1:-7}  # Default: 7 days

find worktrees -maxdepth 1 -type d -mtime +$DAYS_OLD | while read worktree; do
  if [ "$worktree" != "worktrees" ]; then
    echo "Removing old worktree: $worktree ($(stat -c %y "$worktree" | cut -d' ' -f1))"

    # Get branch name from worktree
    branch=$(git -C "$worktree" branch --show-current)

    # Remove worktree
    git worktree remove "$worktree"

    # Delete branch (optional, comment out if you want to keep branch)
    git branch -d "$branch" 2>/dev/null
  fi
done

echo "✓ Removed worktrees older than $DAYS_OLD days"
```

## Cleanup by Remote Status

### Remove Worktrees for Deleted Remote Branches

```bash
#!/bin/bash
# cleanup-orphaned.sh - Remove worktrees whose remote branches were deleted

# Prune stale remote tracking branches
git remote prune origin

# Find local branches whose remote is gone
git branch -vv | grep ': gone]' | while read branch_info; do
  # Extract branch name
  branch=$(echo "$branch_info" | awk '{print $1}')

  # Check if branch has worktree
  worktree="worktrees/$(echo $branch | tr '/' '-')"

  if [ -d "$worktree" ]; then
    echo "Removing orphaned worktree: $worktree (remote deleted)"
    git worktree remove "$worktree"
    git branch -D "$branch"
  fi
done

echo "✓ Removed orphaned worktrees"
```

## Bulk Cleanup

### Interactive Cleanup Menu

```bash
#!/bin/bash
# cleanup-interactive.sh - Interactive worktree cleanup menu

echo "=== Git Worktree Cleanup ==="
echo ""
echo "Active worktrees:"
git worktree list
echo ""

# List worktrees with numbers
select worktree in $(git worktree list | grep worktrees | awk '{print $1}'); do
  if [ -n "$worktree" ]; then
    echo ""
    echo "Selected: $worktree"
    echo "Branch: $(git -C "$worktree" branch --show-current)"
    echo "Last commit: $(git -C "$worktree" log -1 --oneline)"
    echo ""
    echo "Actions:"
    echo "  1) Remove worktree and keep branch"
    echo "  2) Remove worktree and delete branch"
    echo "  3) Skip"
    echo ""
    read -p "Choose action [1-3]: " action

    case $action in
      1)
        git worktree remove "$worktree"
        echo "✓ Worktree removed, branch kept"
        ;;
      2)
        branch=$(git -C "$worktree" branch --show-current)
        git worktree remove "$worktree"
        git branch -d "$branch"
        echo "✓ Worktree and branch removed"
        ;;
      3)
        echo "Skipped"
        ;;
    esac
  fi
  break
done
```

### Bulk Remove Multiple Worktrees

```bash
# Remove all worktrees matching pattern
git worktree list | grep "feature/" | awk '{print $1}' | while read worktree; do
  echo "Removing: $worktree"
  git worktree remove "$worktree"
done
```

## Emergency Cleanup

### Force Remove Worktree with Uncommitted Changes

```bash
# Warning: This will discard uncommitted changes!

# Method 1: Use --force flag
git worktree remove --force worktrees/feature-auth

# Method 2: Manually delete
rm -rf worktrees/feature-auth
git worktree prune  # Clean up Git metadata

# Method 3: Stash changes first
cd worktrees/feature-auth
git stash
cd ../..
git worktree remove worktrees/feature-auth
```

### Fix Corrupted Worktree Metadata

```bash
# Worktree directory exists but git worktree list doesn't show it
# → Worktree metadata is corrupted

# 1. Prune worktree metadata
git worktree prune

# 2. Manually remove directory if it still exists
rm -rf worktrees/corrupted-worktree

# 3. Verify
git worktree list
```

## Cleanup Verification

### Check for Orphaned Files

```bash
# Sometimes worktree removal leaves files behind
# Check for leftover worktree directories

find worktrees -maxdepth 1 -type d | while read dir; do
  if [ "$dir" != "worktrees" ]; then
    # Check if this worktree is registered
    if ! git worktree list | grep -q "$dir"; then
      echo "Orphaned directory: $dir"
      echo "  (Worktree not registered in Git)"
    fi
  fi
done
```

### Verify All Worktrees Are Valid

```bash
# Check each worktree for valid Git state
git worktree list | grep worktrees | awk '{print $1}' | while read worktree; do
  if git -C "$worktree" rev-parse --git-dir > /dev/null 2>&1; then
    echo "✓ Valid: $worktree"
  else
    echo "✗ Invalid: $worktree"
  fi
done
```

## Automated Cleanup Schedule

### Cron Job for Daily Cleanup

```bash
# Add to crontab (crontab -e)
# Run daily at 6 PM:

0 18 * * * /path/to/cleanup-merged.sh >> /tmp/worktree-cleanup.log 2>&1
0 18 * * 0 /path/to/cleanup-old.sh 30 >> /tmp/worktree-cleanup.log 2>&1
```

### Git Hook for Post-Merge Cleanup

```bash
# .git/hooks/post-merge (make executable)
#!/bin/bash
# Automatically prompt to cleanup worktree after merge

CURRENT_BRANCH=$(git branch --show-current)

# Check if this was a merge commit
if git log -1 --merges > /dev/null; then
  MERGED_BRANCH=$(git log -1 --merges --pretty=format:%P | awk '{print $2}' | xargs git branch --contains | grep -v "$CURRENT_BRANCH" | head -1)

  if [ -n "$MERGED_BRANCH" ]; then
    WORKTREE="worktrees/$(echo $MERGED_BRANCH | tr '/' '-')"

    if [ -d "$WORKTREE" ]; then
      echo "Branch $MERGED_BRANCH was merged"
      echo "Remove worktree $WORKTREE? [y/N]"
      read -r response

      if [[ "$response" =~ ^[Yy]$ ]]; then
        git worktree remove "$WORKTREE"
        echo "✓ Worktree removed"
      fi
    fi
  fi
fi
```

## Cleanup Best Practices

✅ **DO**:
- Clean up immediately after PR merge
- Verify no uncommitted changes before removal
- Delete both worktree and branch when done
- Run cleanup weekly to prevent accumulation
- Use automated scripts for bulk cleanup

❌ **DON'T**:
- Keep worktrees for "just in case" (clutter)
- Delete worktree without checking branch status
- Remove worktree with uncommitted work (use stash)
- Forget to run `git worktree prune` after manual deletion
- Leave experimental worktrees after failure

## Cleanup Checklist

Before removing a worktree, verify:

- [ ] All changes are committed and pushed
- [ ] PR is merged (or intentionally abandoned)
- [ ] No uncommitted stashes in worktree
- [ ] No processes running in worktree directory
- [ ] Branch can be safely deleted (if merged)
- [ ] Worktree is not needed for reference

## Next Steps

- **Quick Start**: See `quick-start.md` for basic worktree removal
- **Creation Patterns**: See `creation-patterns.md` for creating new worktrees
- **Troubleshooting**: See `troubleshooting.md` for fixing corrupted worktrees
