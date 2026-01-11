# Troubleshooting

Solutions for common issues when working with Git worktrees.

## Worktree Creation Issues

### Issue: "fatal: A worktree with this name already exists"

**Symptom**:
```bash
$ git worktree add -b feature/x worktrees/feature-x
fatal: 'worktrees/feature-x' already exists
```

**Cause**: Worktree directory or metadata already exists

**Solutions**:

1. **Check existing worktrees**:
   ```bash
   git worktree list
   # → Check if worktrees/feature-x is listed
   ```

2. **If worktree is listed**:
   ```bash
   # Remove the existing worktree
   git worktree remove worktrees/feature-x

   # Try creation again
   git worktree add -b feature/x worktrees/feature-x
   ```

3. **If worktree is NOT listed but directory exists**:
   ```bash
   # Orphaned directory (metadata corrupted)
   # Remove directory manually
   rm -rf worktrees/feature-x

   # Prune worktree metadata
   git worktree prune

   # Try creation again
   git worktree add -b feature/x worktrees/feature-x
   ```

### Issue: "fatal: '<branch>' is already checked out"

**Symptom**:
```bash
$ git worktree add -b feature/x worktrees/feature-x
fatal: 'feature/x' is already checked out at '/path/to/worktree'
```

**Cause**: Branch is already active in another worktree

**Solutions**:

1. **Find where branch is checked out**:
   ```bash
   git worktree list
   # → /path/to/worktrees/feature-y      abc1234 [feature/x]
   ```

2. **Option 1: Remove other worktree**:
   ```bash
   git worktree remove worktrees/feature-y
   git worktree add -b feature/x worktrees/feature-x
   ```

3. **Option 2: Use different branch name**:
   ```bash
   git worktree add -b feature/x-v2 worktrees/feature-x-v2
   ```

## Symlink Issues

### Issue: Symlink doesn't work, packages not found

**Symptom**:
```bash
$ cd worktrees/feature-x
$ npm test
Error: Cannot find module 'express'
```

**Cause**: Symlink broken or not created

**Solutions**:

1. **Verify symlink exists**:
   ```bash
   cd worktrees/feature-x
   ls -la | grep node_modules
   # → Should show: node_modules -> ../../node_modules
   ```

2. **If symlink missing**:
   ```bash
   ln -s ../../node_modules node_modules
   ```

3. **If symlink broken (points to wrong location)**:
   ```bash
   # Remove broken symlink
   rm node_modules

   # Create correct symlink
   ln -s ../../node_modules node_modules
   ```

4. **If main node_modules missing**:
   ```bash
   # Install in main worktree first
   cd ../..
   npm install

   # Then symlink in worktree
   cd worktrees/feature-x
   ln -s ../../node_modules node_modules
   ```

### Issue: "File exists" when creating symlink

**Symptom**:
```bash
$ ln -s ../../node_modules node_modules
ln: failed to create symbolic link 'node_modules': File exists
```

**Cause**: Directory or file already exists at target

**Solutions**:

1. **Check what exists**:
   ```bash
   ls -la node_modules
   ```

2. **If directory (not symlink)**:
   ```bash
   # Remove directory and create symlink
   rm -rf node_modules
   ln -s ../../node_modules node_modules
   ```

3. **If symlink already exists**:
   ```bash
   # Good! Symlink already setup, nothing to do
   echo "Symlink already exists"
   ```

## Detached HEAD Issues

### Issue: Worktree in detached HEAD state

**Symptom**:
```bash
$ cd worktrees/inspect-commit
$ git status
HEAD detached at abc1234
```

**Cause**: Worktree created from specific commit (not branch)

**Solutions**:

1. **Create branch from detached HEAD**:
   ```bash
   cd worktrees/inspect-commit
   git checkout -b experiment/new-idea
   # Now worktree has a branch
   ```

2. **Or keep detached HEAD (for inspection only)**:
   ```bash
   # This is fine if you're just inspecting
   # Just don't commit (commits will be lost)
   ```

## Merge Conflict Issues

### Issue: Conflicts when merging main into worktree

**Symptom**:
```bash
$ cd worktrees/feature-x
$ git merge main
Auto-merging src/file.ts
CONFLICT (content): Merge conflict in src/file.ts
```

**Cause**: Worktree and main modified same files

**Solutions**:

1. **Resolve conflicts in worktree**:
   ```bash
   # Edit conflicted files
   vim src/file.ts

   # Mark conflicts as resolved
   git add src/file.ts

   # Complete merge
   git commit
   ```

2. **Or abort merge and rebase instead**:
   ```bash
   git merge --abort
   git rebase main
   # Resolve conflicts during rebase
   ```

3. **Prevent future conflicts**:
   ```bash
   # Merge main more frequently (avoid divergence)
   # Or isolate worktree changes to different files
   ```

### Issue: Conflicts across multiple worktrees

**Symptom**: Multiple worktrees have conflicts with main

**Solution**:
```bash
# Merge main into all worktrees (in sequence, not parallel)
for dir in worktrees/*/; do
  cd "$dir"
  echo "Merging main into: $dir"
  git merge main
  # Resolve conflicts if any
  cd ../..
done
```

## Permission Issues

### Issue: "Permission denied" when creating worktree

**Symptom**:
```bash
$ git worktree add -b feature/x worktrees/feature-x
fatal: cannot create directory at 'worktrees/feature-x': Permission denied
```

**Cause**: User lacks write permission

**Solutions**:

1. **Check directory permissions**:
   ```bash
   ls -la worktrees/
   ```

2. **Fix permissions**:
   ```bash
   # Make worktrees/ writable by user
   chmod u+w worktrees/
   ```

3. **Or create with sudo**:
   ```bash
   sudo git worktree add -b feature/x worktrees/feature-x
   # Then fix ownership
   sudo chown -R $USER:$USER worktrees/feature-x
   ```

## Disk Space Issues

### Issue: Worktrees using too much disk space

**Symptom**:
```bash
$ du -sh worktrees/
10G    worktrees/
```

**Cause**: Worktrees have local node_modules (not symlinks)

**Solution**:
```bash
# Find worktrees with local node_modules
for dir in worktrees/*/; do
  if [ -d "$dir/node_modules" ] && [ ! -L "$dir/node_modules" ]; then
    echo "Local node_modules found in: $dir"
    du -sh "$dir/node_modules"
  fi
done

# Remove local node_modules and create symlinks
for dir in worktrees/*/; do
  cd "$dir"
  if [ -d "node_modules" ] && [ ! -L "node_modules" ]; then
    echo "Removing local node_modules in: $dir"
    rm -rf node_modules
    ln -s ../../node_modules node_modules
  fi
  cd ../..
done
```

## Windows-Specific Issues

### Issue: Symlinks not supported on Windows

**Symptom**:
```bash
$ ln -s ../../node_modules node_modules
ln: creating symbolic link 'node_modules': Operation not permitted
```

**Cause**: Windows requires Developer Mode or Admin privileges for symlinks

**Solutions**:

1. **Enable Developer Mode** (Windows 10/11):
   - Settings → Update & Security → For developers
   - Enable "Developer Mode"
   - Restart terminal

2. **Run as Administrator**:
   ```bash
   # Right-click Command Prompt/PowerShell
   # Run as Administrator
   ```

3. **Use junction points** (git-bash):
   ```bash
   # Use cmd //c mklink instead
   cmd //c mklink /J node_modules ..\\..\\node_modules
   ```

4. **Copy dependencies** (slower but reliable):
   ```bash
   # Instead of symlinks, copy node_modules
   xcopy /E /I /Y ..\\..\\node_modules node_modules
   ```

## Performance Issues

### Issue: Too many worktrees slow down Git operations

**Symptom**:
```bash
$ git status
(takes 10+ seconds)
```

**Cause**: 20+ worktrees registered

**Solution**:
```bash
# Clean up old worktrees
./cleanup-old.sh 30  # Remove worktrees older than 30 days

# Or manually remove unused worktrees
git worktree remove worktrees/old-feature-1
git worktree remove worktrees/old-feature-2
# ...
```

## Recovery Issues

### Issue: Recover deleted worktree

**Symptom**: Accidentally removed worktree with important work

**Solution**:
```bash
# 1. Branch still exists
git branch -a | grep feature-x

# 2. Recreate worktree from branch
git worktree add -b feature/x worktrees/feature-x

# 3. Setup symlinks
cd worktrees/feature-x
ln -s ../../node_modules node_modules
```

### Issue: Worktree directory deleted, Git still thinks it exists

**Symptom**:
```bash
$ git worktree list
/path/to/worktrees/feature-x  abc1234 [feature/x]
$ ls worktrees/feature-x
ls: cannot access 'worktrees/feature-x': No such file or directory
```

**Cause**: Worktree directory manually deleted

**Solution**:
```bash
# Prune worktree metadata
git worktree prune

# Verify
git worktree list
# → worktrees/feature-x removed from list
```

## Getting Help

### Debug Commands

```bash
# List all worktrees with detailed info
git worktree list --porcelain

# Check worktree metadata
ls -la .git/worktrees/

# Prune stale worktree metadata
git worktree prune

# Check Git version (worktree support)
git --version
# Should be 2.17+ for full worktree support
```

### Verbose Output

```bash
# Create worktree with verbose output
git worktree add -v -b feature/x worktrees/feature-x

# Remove worktree with verbose output
git worktree remove -v worktrees/feature-x
```

## Next Steps

- **Quick Start**: See `quick-start.md` for basic workflows
- **Creation Patterns**: See `creation-patterns.md` for advanced creation
- **Cleanup**: See `cleanup-strategies.md` for removing worktrees
