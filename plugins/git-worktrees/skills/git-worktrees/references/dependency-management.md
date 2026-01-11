# Dependency Management

Share dependencies across worktrees using symlinks to save disk space and install time.

## Core Principle

**Share dependencies, isolate code.**

- **node_modules** (Node.js): Symlink all worktrees to main worktree's node_modules
- **.venv** (Python with uv): Symlink all worktrees to main worktree's .venv
- **Result**: 10+ worktrees with shared dependencies = 1x disk space, 1x install time

## Node.js Projects

### Initial Setup (Main Worktree)

```bash
# 1. In main worktree (project root)
cd /path/to/project

# 2. Install dependencies
npm install
# → node_modules/ created with 500MB of packages

# 3. Verify installation
ls -la node_modules/ | head -10
```

### Creating Symlinks in Worktrees

```bash
# 1. Create worktree
git worktree add -b feature/new-feature worktrees/feature-new-feature

# 2. Navigate to worktree
cd worktrees/feature-new-feature

# 3. Create symlink to main worktree's node_modules
ln -s ../../node_modules node_modules

# 4. Verify symlink
ls -la | grep node_modules
# → node_modules -> ../../node_modules

# 5. Verify packages accessible
ls node_modules/ | head -5
# → react, typescript, eslint, etc.

# 6. Test that everything works
npm test
npm run build
```

### Automated Symlink Creation

```bash
#!/bin/bash
# setup-symlinks.sh - Create symlinks in all worktrees

MAIN_NODE_MODULES="/path/to/project/node_modules"

# Find all worktrees
for worktree in worktrees/*/; do
  echo "Setting up symlink in: $worktree"

  cd "$worktree"

  # Remove existing node_modules if it's a directory (not symlink)
  if [ -d "node_modules" ] && [ ! -L "node_modules" ]; then
    echo "  Removing existing node_modules directory"
    rm -rf node_modules
  fi

  # Create symlink if it doesn't exist
  if [ ! -e "node_modules" ]; then
    ln -s "../../node_modules" node_modules
    echo "  ✓ Symlink created"
  else
    echo "  ✓ Symlink already exists"
  fi

  cd ../..
done

echo "✓ All worktrees setup with shared node_modules"
```

### Updating Dependencies

```bash
# 1. Update in main worktree
cd /path/to/project
npm update

# 2. ALL worktrees automatically have updated dependencies!
# (Because they share the same node_modules via symlink)

# 3. Test in all worktrees
for worktree in worktrees/*/; do
  echo "Testing: $worktree"
  cd "$worktree"
  npm test
  cd ../..
done
```

### Project-Specific Dependencies

**Scenario**: Worktree needs different dependency version

```bash
# Problem: feature-x needs lodash@4.9.0, main has lodash@5.0.0

# Solution 1: Use npm link (if just one package)
cd worktrees/feature-x
npm install lodash@4.9.0  # Creates local node_modules/lodash
# lodash@4.9.0 works, other packages still symlinked

# Solution 2: Full local node_modules (if many packages differ)
cd worktrees/feature-x
rm node_modules  # Remove symlink
npm install      # Create local node_modules
# This worktree now has its own dependencies
```

## Python Projects with uv

### Initial Setup (Main Worktree)

```bash
# 1. In main worktree (project root)
cd /path/to/project

# 2. Create virtual environment with uv
uv venv
# → .venv/ created

# 3. Install dependencies
uv pip install -r requirements.txt

# 4. Verify installation
source .venv/bin/activate
python -c "import requests; print(requests.__version__)"
```

### Creating Symlinks in Worktrees

```bash
# 1. Create worktree
git worktree add -b feature/new-api worktrees/feature-new-api

# 2. Navigate to worktree
cd worktrees/feature-new-api

# 3. Create symlink to main worktree's .venv
ln -s ../../.venv .venv

# 4. Verify symlink
ls -la | grep venv
# → .venv -> ../../.venv

# 5. Verify Python packages accessible
source .venv/bin/activate
python -c "import fastapi; print(fastapi.__version__)"

# 6. Run tests
pytest
```

### Automated Symlink Creation (Python)

```bash
#!/bin/bash
# setup-python-symlinks.sh - Create .venv symlinks in all worktrees

MAIN_VENV="/path/to/project/.venv"

# Find all worktrees
for worktree in worktrees/*/; do
  echo "Setting up .venv symlink in: $worktree"

  cd "$worktree"

  # Remove existing .venv if it's a directory (not symlink)
  if [ -d ".venv" ] && [ ! -L ".venv" ]; then
    echo "  Removing existing .venv directory"
    rm -rf .venv
  fi

  # Create symlink if it doesn't exist
  if [ ! -e ".venv" ]; then
    ln -s "../../.venv" .venv
    echo "  ✓ Symlink created"
  else
    echo "  ✓ Symlink already exists"
  fi

  cd ../..
done

echo "✓ All worktrees setup with shared .venv"
```

### Updating Python Dependencies

```bash
# 1. Update in main worktree
cd /path/to/project
source .venv/bin/activate
uv pip install --upgrade -r requirements.txt

# 2. ALL worktrees automatically have updated dependencies!
# (Because they share the same .venv via symlink)

# 3. Test in all worktrees
for worktree in worktrees/*/; do
  echo "Testing: $worktree"
  cd "$worktree"
  source .venv/bin/activate
  pytest
  cd ../..
done
```

## Mixed Projects (Node.js + Python)

### Project Structure

```
project/
├── node_modules/       # Shared Node dependencies
├── .venv/              # Shared Python dependencies
├── worktrees/
│   ├── feature-a/
│   │   ├── node_modules → ../../node_modules
│   │   └── .venv → ../../.venv
│   └── feature-b/
│       ├── node_modules → ../../node_modules
│       └── .venv → ../../.venv
```

### Setup Script for Mixed Projects

```bash
#!/bin/bash
# setup-all-symlinks.sh - Create both node_modules and .venv symlinks

PROJECT_ROOT="/path/to/project"

# Find all worktrees
for worktree in worktrees/*/; do
  echo "Setting up symlinks in: $worktree"

  cd "$worktree"

  # Setup node_modules symlink
  if [ ! -e "node_modules" ]; then
    ln -s "../../node_modules" node_modules
    echo "  ✓ node_modules symlink created"
  fi

  # Setup .venv symlink
  if [ ! -e ".venv" ]; then
    ln -s "../../.venv" .venv
    echo "  ✓ .venv symlink created"
  fi

  cd "$PROJECT_ROOT"
done

echo "✓ All worktrees setup with shared dependencies"
```

## Troubleshooting Symlinks

### Symlink Creation Failed

```bash
# Error: "File exists" when creating symlink
# Cause: Directory already exists at target

# Check if it's a directory or symlink
ls -la node_modules

# If directory (not symlink):
rm -rf node_modules
ln -s ../../node_modules node_modules

# If symlink already exists:
# Good! Symlink already setup, nothing to do
```

### Packages Not Found

```bash
# Error: "Cannot find module 'xyz'"
# Cause: Symlink broken or main node_modules incomplete

# Verify symlink points to correct location
ls -la node_modules
# → node_modules -> ../../node_modules

# Verify main node_modules has the package
ls ../node_modules/ | grep xyz

# If package missing in main:
cd ../..
npm install xyz
# → Now available in all worktrees!
```

### Permission Issues

```bash
# Error: "Permission denied" when creating symlink
# Cause: User doesn't have permission to create symlinks

# Check if user can create symlinks
ln -s /tmp/test /tmp/test-link
if [ $? -eq 0 ]; then
  echo "Symlinks supported"
  rm /tmp/test-link
else
  echo "Symlinks NOT supported (Windows?)"
  echo "Use Windows junction points instead"
fi
```

### Windows-Specific Issues

**Windows doesn't support symbolic links by default.**

```bash
# Option 1: Enable Developer Mode (Windows 10/11)
# Settings → Update & Security → For developers → Enable

# Option 2: Use junction points (works without Developer Mode)
# Requires git-bash or WSL

# Option 3: Copy dependencies (slower but reliable)
# In each worktree, instead of symlink:
xcopy /E /I ..\..\\node_modules node_modules
```

## Disk Space Comparison

### Without Symlinks (Traditional)

```
1 worktree × 500MB = 500MB
10 worktrees × 500MB = 5GB
20 worktrees × 500MB = 10GB
```

### With Symlinks (This Approach)

```
1 main worktree × 500MB = 500MB
10 worktrees × 0MB (symlinks) = 500MB total
20 worktrees × 0MB (symlinks) = 500MB total
```

**Savings**: 19.5GB for 20 worktrees!

## Performance Comparison

### Without Symlinks

```bash
# Time to create worktree and install dependencies
git worktree add -b feature/x worktrees/x
cd worktrees/x
npm install  # → 30-60 seconds
# Total: 45-75 seconds per worktree
```

### With Symlinks

```bash
# Time to create worktree and setup symlink
git worktree add -b feature/x worktrees/x
cd worktrees/x
ln -s ../../node_modules node_modules  # → <1 second
# Total: <5 seconds per worktree
```

**Speedup**: 10-15x faster!

## Best Practices

✅ **DO**:
- Install dependencies in main worktree FIRST
- Create symlinks IMMEDIATELY after creating worktree
- Test that packages are accessible in worktree
- Update dependencies in main worktree only
- Add `node_modules/` and `.venv/` to .gitignore

❌ **DON'T**:
- Run `npm install` or `pip install` in worktree (unless needed for project-specific deps)
- Commit symlinks to git (they're already in .gitignore)
- Delete symlinks accidentally
- Mix worktrees with and without symlinks (confusing)
- Forget to update main worktree dependencies

## Next Steps

- **Quick Start**: See `quick-start.md` for basic workflow
- **Creation Patterns**: See `creation-patterns.md` for worktree creation strategies
- **Parallel Workflows**: See `parallel-workflows.md` for multi-task coordination
