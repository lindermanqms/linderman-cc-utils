# Workflow Patterns

Three core orchestration patterns for different complexity levels.

## Pattern 1: Simple Delegation (Single Task)

**When to use**: Straightforward coding or planning task

**Steps**:
1. Analyze user request
2. Extract project slug: `basename $(git rev-parse --show-toplevel)`
3. Fetch from memory: `{slug} {domain} patterns`
4. Collect context: Read CLAUDE.md, specs, existing code
5. Determine model (Pro vs Flash)
6. Structure prompt with all context + memory
7. Execute: `gemini -p "..." --model ...`
8. Process response
9. Save to memory if important (ADR/pattern/error)
10. Run tests/validations (as Sonnet)
11. Report to user

**Example**:
```bash
# User: "Delegate to gemini: implement JWT authentication"

# 1-2: Extract slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
# → linderman-cc-utils

# 3: Fetch memory
MEMORY=$(mcp__memory__search_nodes({ query: "${PROJECT_SLUG} auth jwt patterns" }))
# → Found: pattern-jwt-cookies, decision-refresh-tokens

# 4: Collect context
CLAUDE_MD=$(cat CLAUDE.md)
SPEC=$(cat backlog/specs/SPEC-010-auth.backlog)

# 5: Determine model
MODEL="gemini-3-flash-preview"  # Implementation task

# 6-7: Execute delegation
cat CLAUDE.md | gemini -p "
MEMORY CONTEXT:
${MEMORY}

PROJECT CONTEXT (stdin):
Standards from CLAUDE.md

SPEC REQUIREMENTS:
${SPEC}

TECHNICAL REFERENCES:
- https://jwt.io/introduction

TASK: Implement JWT authentication with refresh tokens
" --model ${MODEL}

# 8: Extract and save report
OUTPUT=$(gemini -p "..." --model ${MODEL})
REPORT_FILE="report-$(date +%s).md"
./plugins/gemini-orchestrator/scripts/extract-report.sh -o "$REPORT_FILE" <<< "$OUTPUT"
cat "$REPORT_FILE"

# 9: Save new patterns
mcp__memory__create_entities({
  entities: [{
    name: "${PROJECT_SLUG}/global/pattern-jwt-implementation",
    entityType: "code-pattern",
    observations: [...]
  }]
})

# 10: Validate
npm test

# 11: Report
echo "✓ JWT authentication implemented"
```

## Pattern 2: Complex Orchestration (Multi-Step)

**When to use**: Large features requiring design + implementation

**Steps**:
1. Analyze and decompose task
2. Extract project slug
3. Fetch memory context (global + task/spec specific)
4. Collect initial context (Explore agent)
5. Create orchestration plan (TodoWrite)
6. For each subtask:
   - Collect additional context
   - Fetch related memory
   - Select model
   - Execute delegation
   - Capture result
   - Save insights
   - Pass context to next step
7. Run final tests (Sonnet)
8. Save final learnings
9. Synthesize results
10. Report outcome

**Example**:
```bash
# User: "Let gemini design and implement the API layer"

# 1-2: Decompose + extract slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# 3: Fetch memory
GLOBAL=$(mcp__memory__search_nodes({ query: "${PROJECT_SLUG} api patterns" }))
TASK=$(mcp__memory__open_nodes({ names: ["${PROJECT_SLUG}/task-15"] }))

# 4: Collect initial context via Explore
EXPLORE_RESULTS=$(Task({
  subagent_type: "Explore",
  prompt: "Find existing API patterns, routing structure, and data models"
}))

# 5: Plan
TodoWrite([
  "PHASE 1: Design API architecture (Pro)",
  "PHASE 2: Implement endpoints (Flash)",
  "PHASE 3: Write integration tests (Flash)",
  "PHASE 4: Validate end-to-end (Sonnet)"
])

# 6a: PHASE 1 - Design (Pro)
cat CLAUDE.md | gemini -p "
IMPORTANT: This is a PLANNING task.

MEMORY CONTEXT:
${GLOBAL}
${TASK}

CODEBASE ANALYSIS:
${EXPLORE_RESULTS}

TASK: Design RESTful API architecture
" --model gemini-3-pro-preview

# Extract design report
PRO_OUTPUT=$(gemini -p "..." --model gemini-3-pro-preview)
./plugins/gemini-orchestrator/scripts/extract-report.sh -o "design-report.md" <<< "$PRO_OUTPUT"
cat design-report.md

PRO_DESIGN=$(capture output)

# Save ADR
mcp__memory__create_entities({
  entities: [{
    name: "${PROJECT_SLUG}/spec-015/decision-api-design",
    entityType: "architecture-decision",
    observations: [...]
  }]
})

# 6b: PHASE 2 - Implement (Flash)
IMPL_PATTERNS=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} implementation patterns express"
}))

cat CLAUDE.md | gemini -p "
ARCHITECTURE (from Pro):
${PRO_DESIGN}

MEMORY PATTERNS:
${IMPL_PATTERNS}

TASK: Implement API endpoints based on design
" --model gemini-3-flash-preview

# Extract implementation report
IMPL_OUTPUT=$(gemini -p "..." --model gemini-3-flash-preview)
./plugins/gemini-orchestrator/scripts/extract-report.sh -o "implementation-report.md" <<< "$IMPL_OUTPUT"
cat implementation-report.md

# Save implementation patterns
mcp__memory__create_entities({
  entities: [{
    name: "${PROJECT_SLUG}/global/pattern-api-structure",
    entityType: "code-pattern",
    observations: [...]
  }]
})

# 6c: PHASE 3 - Tests (Flash)
gemini -p "
CODE IMPLEMENTED:
(generated API code)

TASK: Write integration tests for all endpoints
" --model gemini-3-flash-preview

# 7: PHASE 4 - Validate (Sonnet)
npm run test:integration
npm run test:e2e

# 9-10: Synthesize and report
echo "✓ API layer complete: ${ENDPOINT_COUNT} endpoints, ${TEST_COUNT} tests passing"
```

## Pattern 3: Error Resolution (Memory-Aware)

**When to use**: Debugging errors during implementation

**Steps**:
1. Error occurs
2. Extract project slug
3. Check memory for similar errors
4. If found: Apply known solution
5. If not found:
   - Delegate to Pro (PROBLEM RESOLUTION)
   - Pro diagnoses + proposes solution
   - Delegate to Flash (implement fix)
   - Save error resolution to memory
6. Validate fix (Sonnet)
7. Report resolution

**Example**:
```bash
# Flash reports: "Error: listen EADDRINUSE :::3000"

# 2: Extract slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# 3: Check memory
KNOWN=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} error port 3000"
}))

if [ -n "$KNOWN" ]; then
  # 4: Apply known solution
  echo "Found previous solution in memory"
  gemini -p "
  KNOWN SOLUTION (from memory):
  ${KNOWN}

  Apply this solution.
  " --model gemini-3-flash-preview
else
  # 5a: Pro diagnosis
  DIAGNOSIS=$(gemini -p "
  IMPORTANT: This is a PROBLEM RESOLUTION task.

  ERROR: listen EADDRINUSE :::3000

  Diagnose root cause and propose solution.
  " --model gemini-3-pro-preview)

  # Extract diagnosis report
  ./plugins/gemini-orchestrator/scripts/extract-report.sh -o "diagnosis-report.md" <<< "$DIAGNOSIS"
  cat diagnosis-report.md

  # 5b: Flash implements fix
  gemini -p "
  DIAGNOSIS:
  ${DIAGNOSIS}

  Implement the fix.
  " --model gemini-3-flash-preview

  # Extract fix report
  FIX_OUTPUT=$(gemini -p "..." --model gemini-3-flash-preview)
  ./plugins/gemini-orchestrator/scripts/extract-report.sh -o "fix-report.md" <<< "$FIX_OUTPUT"
  cat fix-report.md

  # 5c: Save to memory
  mcp__memory__create_entities({
    entities: [{
      name: "${PROJECT_SLUG}/global/error-port-conflict",
      entityType: "resolved-error",
      observations: [
        "Symptom: EADDRINUSE :::3000",
        "Cause: Previous dev server not terminated",
        "Solution: lsof -ti:3000 | xargs kill -9",
        "Prevention: Add cleanup script"
      ]
    }]
  })
fi

# 6: Validate
curl http://localhost:3000/health  # Should work now

# 7: Report
echo "✓ Port conflict resolved"
```

## Workflow Diagrams

### Simple Delegation Flow
```
User Request
    ↓
Extract Slug → Fetch Memory
    ↓
Collect Context (CLAUDE.md, specs, code)
    ↓
Select Model (Pro or Flash)
    ↓
Execute Delegation
    ↓
Save Insights → Validate → Report
```

### Complex Orchestration Flow
```
User Request
    ↓
Decompose Task → Extract Slug → Fetch Memory
    ↓
Invoke Explore (codebase analysis)
    ↓
Create Plan (TodoWrite)
    ↓
┌─────────────────────────────────────┐
│ For Each Phase:                     │
│   1. Fetch phase-specific memory    │
│   2. Select model (Pro or Flash)    │
│   3. Execute delegation              │
│   4. Save insights                   │
│   5. Pass context to next phase     │
└─────────────────────────────────────┘
    ↓
Validate All (Sonnet tests)
    ↓
Synthesize → Report
```

### Error Resolution Flow
```
Error Occurs
    ↓
Extract Slug
    ↓
Search Memory for Similar Error
    ↓
┌─────────┴─────────┐
│ Found?            │
├─ Yes ─────────────┤─ No
│                   │
Apply Known         Delegate to Pro
Solution            (PROBLEM RESOLUTION)
(via Flash)                 ↓
    ↓               Pro Diagnoses
    │                       ↓
    │               Delegate to Flash
    │               (implement fix)
    │                       ↓
    │               Save to Memory
    │                       │
    └───────┬───────────────┘
            ↓
    Validate Fix (Sonnet)
            ↓
    Report Resolution
```

## Pattern Selection Guide

| Scenario | Pattern | Why |
|----------|---------|-----|
| "Implement feature X" | Simple Delegation | Straightforward coding task |
| "Design and build API" | Complex Orchestration | Needs design then implementation |
| "Fix this error" | Error Resolution | Debugging workflow |
| "Refactor module Y" | Simple → Pro design, Flash refactor | May need design phase |
| "Add 10 endpoints" | Complex Orchestration | Multiple related subtasks |

## Best Practices

✅ **Simple first**: Start with Simple Delegation, escalate to Complex if needed
✅ **Check memory**: Always search for similar work before delegating
✅ **Pass context forward**: In Complex, each phase builds on previous
✅ **Save learnings**: Store ADRs after Pro, patterns after Flash, errors after fixes
✅ **Validate everything**: Sonnet always runs final tests
✅ **Report progress**: Keep user informed in Complex workflows

❌ **Over-orchestrate**: Don't use Complex for simple tasks
❌ **Skip memory**: Missing previous solutions wastes time
❌ **Forget validation**: Always test before reporting success
❌ **Omit context**: Each delegation needs full context, not just task description
