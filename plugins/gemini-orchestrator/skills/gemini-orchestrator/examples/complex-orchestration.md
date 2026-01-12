# Example: Complex Multi-Phase Orchestration

This example demonstrates a multi-phase delegation workflow: gemini-3-pro for design, then gemini-3-flash for implementation.

## Complete Workflow

### PHASE 1: Design (gemini-3-pro)

```bash
# 1. Create design prompt
cp .claude/gemini-orchestrator/prompts/TEMPLATE-pro-planning.txt \
   .claude/gemini-orchestrator/prompts/task-15-api-design.txt

# 2. Fill prompt with context
# (Edit task-15-api-design.txt with requirements, constraints, etc.)

# 3. Execute design phase
./plugins/gemini-orchestrator/scripts/delegate.sh -m pro \
  .claude/gemini-orchestrator/prompts/task-15-api-design.txt

# 4. Review design report
cat .claude/gemini-orchestrator/reports/pro-2026-01-11-14-00.md
```

### PHASE 2: Implementation (gemini-3-flash)

```bash
# 5. Create implementation prompt
cp .claude/gemini-orchestrator/prompts/TEMPLATE-flash-implementation.txt \
   .claude/gemini-orchestrator/prompts/task-15-api-impl.txt

# 6. Add design from Phase 1 to "DESIGN CONTEXT" section
# (paste content from pro-*.md report into task-15-api-impl.txt)

# 7. Execute implementation
./plugins/gemini-orchestrator/scripts/delegate.sh -m flash \
  .claude/gemini-orchestrator/prompts/task-15-api-impl.txt
```

### PHASE 3: Validation (YOU as Orchestrator)

```bash
# 8. Final validation (Orchestrator's responsibility)
npm run build
npm test
npm start &
curl http://localhost:3000/api/health

# 9. Save to memory
create_entities([{
  name: "linderman-cc-utils/task-15/decision-api-architecture",
  entityType: "decision",
  observations: ["RESTful API with JWT auth, see pro-*.md"]
}])
```

## Key Points

- ✅ **Two-phase delegation** - Design (Pro) then Implementation (Flash)
- ✅ **Design feeds implementation** - Pro's output becomes Flash's input
- ✅ **Orchestrator validates** - Final build/test/server by YOU
- ✅ **Memory persistence** - ADR saved for future reference
- ✅ **Clear separation** - Planning vs Coding vs Validation

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
│   1. Create design prompt                           │
│   2. Delegate to Pro                                │
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
│   5. Delegate to Flash                              │
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
- `error-resolution.md` - Debugging workflow
- `spec-workflow-integration.md` - Backlog.md integration
