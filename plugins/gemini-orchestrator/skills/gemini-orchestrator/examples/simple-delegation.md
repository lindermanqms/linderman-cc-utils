# Example: Simple Implementation Task

This example demonstrates a single-task delegation to gemini-3-flash-preview for implementing JWT authentication.

## Complete Workflow

```bash
# 1. Extract project slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
# Output: linderman-cc-utils

# 2. Fetch from memory (Orchestrator does this)
search_nodes({ query: "linderman-cc-utils auth patterns" })
# Results: pattern-jwt-storage, pattern-chrome-extension-auth

# 3. Create prompt file directly (no template copying needed)
cat > .claude/gemini-orchestrator/prompts/task-10-jwt-auth.txt <<'EOF'
# Task: JWT Authentication Implementation

## 📝 Project Context
[Paste CLAUDE.md relevant sections]

## 🧠 Memory Context
**Patterns from Basic Memory:**
- pattern-jwt-storage: Use chrome.storage.local for tokens
- pattern-chrome-extension-auth: Session management in extensions

## 🎯 Task Description
Implement JWT authentication for Chrome extension

### Acceptance Criteria
- [ ] Generate JWT tokens on login
- [ ] Store tokens securely in chrome.storage.local
- [ ] Validate tokens on protected routes
- [ ] Handle token refresh

### Technical Requirements
1. Use jsonwebtoken library
2. Token expiry: 15 minutes
3. Refresh token: 7 days

## FILES TO MODIFY/CREATE
- [ ] `src/auth/jwt.service.ts` - JWT service
- [ ] `src/auth/storage.ts` - Secure storage
- [ ] `tests/auth/jwt.test.ts` - Unit tests

[... rest of mandatory requirements from prompt-templates.md ...]
EOF

# 4. Execute delegation via gemini-cli directly
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10-jwt-auth.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Script outputs:
# ✓ Delegation completed successfully
# ✓ Report saved to: .claude/gemini-orchestrator/reports/flash-2026-01-17-15-30.md

# 5. Review report
cat .claude/gemini-orchestrator/reports/flash-2026-01-17-15-30.md

# 6. Validate (Orchestrator does this, not agent)
npm run build
npm test

# 7. Update Backlog (Orchestrator does this, not agent)
await backlog_task_update({
  id: "task-10",
  notes: "JWT auth implemented. Report: .claude/gemini-orchestrator/reports/flash-2026-01-17-15-30.md"
})
```

## Key Points

- ✅ **Memory fetched first** - Context from previous work
- ✅ **Prompt created inline** - No template copying needed
- ✅ **Direct gemini-cli execution** - No wrapper scripts
- ✅ **Orchestrator validates** - Final build/test by Orchestrator, not agent
- ✅ **Backlog updated by Orchestrator** - Agent doesn't touch MCP

## When to Use

Use this pattern when:
- Single, well-defined implementation task
- No design/planning phase needed
- Task has clear Acceptance Criteria
- Implementation is straightforward

## Related Examples

- `complex-orchestration.md` - Multi-phase workflows (Pro → Flash)
- `../references/spec-workflow-integration.md` - Integration with Backlog.md
- `../references/error-resolution.md` - Debugging and error handling
- `../references/prompt-templates.md` - Complete template examples
