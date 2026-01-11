# Example: Simple Implementation Task

This example demonstrates a single-task delegation to gemini-3-flash-preview for implementing JWT authentication.

## Complete Workflow

```bash
# 1. Extract project slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
# Output: linderman-cc-utils

# 2. Fetch from memory (YOU do this)
search_nodes({ query: "linderman-cc-utils auth patterns" })
# Results: pattern-jwt-storage, pattern-chrome-extension-auth

# 3. Create prompt from template
cp .gemini-orchestration/prompts/TEMPLATE-flash-implementation.txt \
   .gemini-orchestration/prompts/task-10-jwt-auth.txt

# 4. Edit prompt - fill in:
#    - Memory Context (paste patterns from step 2)
#    - Project Context (CLAUDE.md relevant sections)
#    - Acceptance Criteria (from Backlog.md if using spec-workflow)
#    - Task description

# 5. Execute delegation via script
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .gemini-orchestration/prompts/task-10-jwt-auth.txt

# Script outputs:
# ℹ Auto-detected model: gemini-3-flash-preview
# ✓ Delegation completed successfully
# ✓ Report extracted to: .gemini-orchestration/reports/flash-2026-01-11-15-30.md

# 6. Review report
cat .gemini-orchestration/reports/flash-2026-01-11-15-30.md

# 7. Validate (YOU do this, not agent)
npm run build
npm test

# 8. Update Backlog (YOU do this, not agent)
await backlog_task_update({
  id: "task-10",
  notes: "JWT auth implemented. Report: .gemini-orchestration/reports/flash-2026-01-11-15-30.md"
})
```

## Key Points

- ✅ **Memory fetched first** - Context from previous work
- ✅ **Template used** - Standardized prompt structure
- ✅ **delegate.sh handles execution** - No manual gemini-cli commands
- ✅ **Orchestrator validates** - Final build/test by YOU, not agent
- ✅ **Backlog updated by Orchestrator** - Agent doesn't touch MCP

## When to Use

Use this pattern when:
- Single, well-defined implementation task
- No design/planning phase needed
- Task has clear Acceptance Criteria
- Implementation is straightforward

## Related Examples

- `complex-orchestration.md` - Multi-phase workflows (Pro → Flash)
- `spec-workflow-integration.md` - Integration with Backlog.md
- `error-resolution.md` - Debugging and error handling
