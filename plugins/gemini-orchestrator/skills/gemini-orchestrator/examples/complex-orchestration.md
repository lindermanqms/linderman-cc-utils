# Example: Complex Multi-Phase Orchestration

This example demonstrates a multi-phase delegation workflow: gemini-3-pro for design, then gemini-3-flash for implementation.

## Complete Workflow

### PHASE 1: Design (gemini-3-pro)

```bash
# 1. Create design prompt directly (no template needed)
cat > .claude/gemini-orchestrator/prompts/task-15-api-design.txt <<'EOF'
# PLANNING TASK - API Layer Design

IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, expert in system architecture and design.

## PROJECT CONTEXT
[Paste CLAUDE.md, architecture findings from Explore agent]

## MEMORY CONTEXT
[Paste results from search_nodes for patterns/decisions]

## TASK DESCRIPTION
Design complete API layer for the application

### Requirements
1. RESTful endpoints for all entities
2. Authentication and authorization
3. Rate limiting and caching

### Acceptance Criteria
- [ ] All endpoints documented
- [ ] Auth flow designed
- [ ] Rate limiting strategy defined

[... rest from prompt-templates.md ...]
EOF

# 2. Execute design phase
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-15-api-design.txt)" \
  2>&1 | tee "$REPORT_FILE"

# 3. Review design report
cat .claude/gemini-orchestrator/reports/pro-$TIMESTAMP.md
```

### PHASE 2: Implementation (gemini-3-flash)

```bash
# 4. Create implementation prompt with design from Phase 1
cat > .claude/gemini-orchestrator/prompts/task-15-api-impl.txt <<'EOF'
# IMPLEMENTATION TASK - API Layer Implementation

You are Gemini-3-Flash, expert TypeScript developer.

## DESIGN CONTEXT (from Pro)
[Paste content from pro-*.md report here]

## PROJECT CONTEXT
[Paste CLAUDE.md]

## MEMORY CONTEXT
[Paste patterns from search_nodes]

## TASK DESCRIPTION
Implement the API layer according to the design from Pro

### Acceptance Criteria
[Same ACs from design phase]

[... rest from prompt-templates.md ...]
EOF

# 5. Execute implementation
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-15-api-impl.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### PHASE 3: Validation (Orchestrator)

```bash
# 6. Final validation (Orchestrator's responsibility)
npm run build
npm test
npm start &
curl http://localhost:3000/api/health

# 7. Save to memory
create_entities([{
  name: "linderman-cc-utils/task-15/decision-api-architecture",
  entityType: "decision",
  observations: ["RESTful API with JWT auth, see pro-*.md"]
}])
```

## Key Points

- ✅ **Two-phase delegation** - Design (Pro) then Implementation (Flash)
- ✅ **Design feeds implementation** - Pro's output becomes Flash's input
- ✅ **Orchestrator validates** - Final build/test/server by Orchestrator
- ✅ **Memory persistence** - ADR saved for future reference
- ✅ **Clear separation** - Planning vs Coding vs Validation
- ✅ **No wrapper scripts** - Direct gemini-cli execution
- ✅ **Prompts created inline** - No template file dependencies

## When to Use

Use this pattern when:
- Task requires architectural design decisions
- Need to evaluate trade-offs before implementing
- Implementation depends on design choices
- Want to separate planning from execution
- Complex feature with multiple approaches possible

## Workflow Diagram

```
┌─────────────────────────────────────────────────────┐
│                  ORCHESTRATOR                        │
│   1. Create design prompt inline                    │
│   2. Delegate to Pro via gemini-cli                 │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│              GEMINI-3-PRO                            │
│   - Analyzes requirements                           │
│   - Evaluates trade-offs                            │
│   - Proposes architecture                           │
│   - Returns design report                           │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│                  ORCHESTRATOR                        │
│   3. Review design                                  │
│   4. Create implementation prompt (with design)     │
│   5. Delegate to Flash via gemini-cli               │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│            GEMINI-3-FLASH                            │
│   - Receives design context                         │
│   - Implements according to design                  │
│   - Runs dev commands (npm install, lint)           │
│   - Returns implementation report                   │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│                  ORCHESTRATOR                        │
│   6. Final validation (build, test, server)         │
│   7. Save ADR to memory                             │
│   8. Update Backlog.md (if using spec-workflow)     │
└─────────────────────────────────────────────────────┘
```

## Related Examples

- `simple-delegation.md` - Single-task delegation
- `../references/error-resolution.md` - Debugging workflow
- `../references/spec-workflow-integration.md` - Backlog.md integration
- `../references/prompt-templates.md` - Complete template examples
