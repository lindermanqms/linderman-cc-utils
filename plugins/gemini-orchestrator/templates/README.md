# ⚠️ DEPRECATED - Templates Directory Removed in v2.6.0

**This directory is deprecated and should not be used.**

## What Changed in v2.6.0

### ❌ REMOVED:
- `TEMPLATE-pro-planning.txt`
- `TEMPLATE-flash-implementation.txt`
- `SETUP-GUIDE.md`
- All instructions to copy template files

### ✅ NEW APPROACH:
Templates are now **inline** in the skill references, not external files.

## Why the Change?

**Problem:** Agents could not find template files in the plugin cache directory.
- Templates lived in `~/.claude/plugins/cache/.../templates/`
- Agents executed from user's project directory
- No `$CLAUDE_PLUGIN_ROOT` variable available at runtime
- Result: Agents wasted time searching for files they could never locate

**Solution:** Templates are now documented inline in `references/prompt-templates.md`

## How to Use Templates Now (v2.6.0+)

### 1. Consult Template Reference

Read the complete templates in:
```
plugins/gemini-orchestrator/skills/gemini-orchestrator/references/prompt-templates.md
```

### 2. Create Prompt File Inline

Use heredoc to create prompt files directly:

```bash
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
# IMPLEMENTATION TASK - [Task Title]

You are Gemini-3-Flash, expert [language] developer.

## PROJECT CONTEXT
[Paste CLAUDE.md]

## MEMORY CONTEXT
[Paste search_nodes results]

## TASK DESCRIPTION
[Describe task]

[... see references/prompt-templates.md for complete template ...]
EOF
```

### 3. Execute Directly via gemini-cli

```bash
# No delegate.sh script needed
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md
```

## Migration from v2.5 → v2.6

**BEFORE (v2.5):**
```bash
# ❌ This no longer works
cp plugins/gemini-orchestrator/templates/TEMPLATE-flash.txt prompts/task-10.txt
./plugins/gemini-orchestrator/scripts/delegate.sh prompts/task-10.txt
```

**NOW (v2.6):**
```bash
# ✅ Create prompt inline
cat > .claude/gemini-orchestrator/prompts/task-10.txt <<'EOF'
[content from references/prompt-templates.md]
EOF

# ✅ Execute directly
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-orchestrator/reports/flash-$(date +%Y%m%d-%H%M).md
```

## Documentation Locations

All template documentation is now in:

1. **Complete Templates**: `skills/gemini-orchestrator/references/prompt-templates.md`
2. **Workflow Examples**: `skills/gemini-orchestrator/examples/`
   - `simple-delegation.md` - Single task workflow
   - `complex-orchestration.md` - Multi-phase workflow
3. **Main Skill**: `skills/gemini-orchestrator/SKILL.md`

## Why This is Better

✅ **No path discovery** - Templates always accessible in references/
✅ **Progressive disclosure** - Templates loaded only when needed
✅ **Always up-to-date** - Templates inline with skill
✅ **No external dependencies** - Everything self-contained
✅ **Easier to find** - Agent knows where to look

---

**See `../README.md` for v2.6.0 changelog and complete migration guide.**
