# ⚠️ DEPRECATED - Setup Guide Removed in v2.6.0

**This setup guide is deprecated and should not be used.**

The workflow described here (copying templates, using delegate.sh script) **no longer works** in v2.6.0+.

## Why Deprecated?

**Problem:** Templates and scripts could not be found by agents.
- Files lived in plugin cache: `~/.claude/plugins/cache/.../gemini-orchestrator/`
- Agents executed from: `/path/to/user/project/`
- No `$CLAUDE_PLUGIN_ROOT` variable available
- Result: Path discovery impossible, agents wasted time searching

## New Workflow (v2.6.0+)

### 1. Consult Template References

Read complete templates in:
```
plugins/gemini-orchestrator/skills/gemini-orchestrator/references/prompt-templates.md
```

### 2. Create Prompt Inline

```bash
# Create directory structure
mkdir -p .claude/gemini-orchestrator/prompts
mkdir -p .claude/gemini-orchestrator/reports

# Create prompt file directly using heredoc
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication

You are Gemini-3-Flash, expert TypeScript developer.

## PROJECT CONTEXT
[Paste CLAUDE.md content]

## MEMORY CONTEXT
[Paste search_nodes results]

[... complete template from references/prompt-templates.md ...]
EOF
```

### 3. Execute Directly via gemini-cli

```bash
# No delegate.sh needed!
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md
```

## Documentation

See current documentation:

1. **Main README**: `../README.md` (v2.6.0 changelog)
2. **Skill Documentation**: `../skills/gemini-orchestrator/SKILL.md`
3. **Template References**: `../skills/gemini-orchestrator/references/prompt-templates.md`
4. **Workflow Examples**: `../skills/gemini-orchestrator/examples/`

## Migration

**Old way (v2.5 - DEPRECATED):**
```bash
cp templates/TEMPLATE-flash.txt prompts/task-10.txt
./scripts/delegate.sh prompts/task-10.txt
```

**New way (v2.6):**
```bash
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
[content from references/prompt-templates.md]
EOF
gemini -m gemini-3-flash-preview --approval-mode yolo -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)"
```

---

**This file is kept for reference only. Do not follow these instructions.**
