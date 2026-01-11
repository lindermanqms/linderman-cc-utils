# Spec-Workflow Integration

How to integrate Gemini Orchestrator with the spec-workflow plugin for Spec-Driven Development.

## Overview

When using both plugins together:
- **spec-workflow** manages tasks, specs, and Acceptance Criteria in Backlog.md
- **gemini-orchestrator** delegates implementation to Gemini models
- **Integration** ensures Gemini follows ACs and updates task progress

## Integration Points

### BEFORE Execution

#### 1. Verify SPEC Exists

```bash
# Check if task has associated spec
TASK_ID="task-10"
SPEC=$(backlog_task_get "$TASK_ID" | jq -r '.spec')

if [ "$SPEC" != "null" ]; then
  SPEC_FILE="backlog/specs/${SPEC}.backlog"

  if [ -f "$SPEC_FILE" ]; then
    echo "Found spec: $SPEC_FILE"
  else
    echo "Warning: Spec referenced but file not found"
  fi
else
  echo "No spec associated with this task"
fi
```

#### 2. Read Acceptance Criteria

```bash
# Extract ACs from spec
if [ -f "$SPEC_FILE" ]; then
  # ACs are in frontmatter or body
  ACS=$(grep -A 100 "acceptance_criteria:" "$SPEC_FILE" | grep "^- \[ \]")

  echo "Acceptance Criteria found:"
  echo "$ACS"
fi

# Or via MCP
TASK_DATA=$(backlog_task_get "$TASK_ID")
ACS=$(echo "$TASK_DATA" | jq -r '.acceptance_criteria[]')
```

#### 3. Use ACs as Requirements

Include ACs in Gemini delegations as mandatory requirements:

```bash
cat CLAUDE.md | gemini -p "
PROJECT CONTEXT (stdin):
Standards from CLAUDE.md

ACCEPTANCE CRITERIA (from SPEC-010-auth.backlog):
${ACS}

TASK: Implement JWT authentication

CRITICAL: All Acceptance Criteria MUST be met.
Validate each AC in your implementation.
" --model gemini-3-flash-preview
```

### DURING Execution

#### 1. Create Subtasks via TodoWrite

Break down work and track progress:

```bash
# Orchestrator creates subtasks
TodoWrite([
  {
    content: "Fetch authentication patterns from memory",
    status: "in_progress",
    activeForm: "Fetching auth patterns"
  },
  {
    content: "Delegate design to gemini-3-pro",
    status: "pending",
    activeForm: "Delegating design"
  },
  {
    content: "Delegate implementation to gemini-3-flash",
    status: "pending",
    activeForm: "Delegating implementation"
  },
  {
    content: "Validate all ACs met",
    status: "pending",
    activeForm: "Validating ACs"
  }
])
```

#### 2. Update Task Notes with Progress

Use MCP to update task notes incrementally:

```bash
# After Pro design phase
backlog_task_update "$TASK_ID" '{
  "notes": "**Design Phase Complete**\n- Pro designed JWT auth with refresh tokens\n- Architecture saved to memory\n\n**Next**: Implementation by Flash"
}'

# After Flash implementation
backlog_task_update "$TASK_ID" '{
  "notes": "**Design Phase Complete**\n...\n\n**Implementation Phase Complete**\n- Flash implemented AuthService, middleware, routes\n- All endpoints functional\n\n**Next**: Validation"
}'
```

#### 3. Mark ACs as Implemented

As work progresses, check off completed ACs:

```bash
# Get current ACs
ACS=$(backlog_task_get "$TASK_ID" | jq -r '.acceptance_criteria')

# Mark AC as complete (change [ ] to [x])
AC_UPDATED=$(echo "$ACS" | sed "s/\[ \] User can login/[x] User can login/")

# Update task
backlog_task_update "$TASK_ID" "{
  \"acceptance_criteria\": $(echo "$AC_UPDATED" | jq -R . | jq -s .)
}"
```

### AFTER Completion

#### 1. Suggest `/spec-review`

When all work is done, trigger review:

```bash
echo "=== ORCHESTRATION COMPLETE ==="
echo ""
echo "Results:"
echo "✓ All ${AC_COUNT} Acceptance Criteria implemented"
echo "✓ Tests passing"
echo "✓ Code follows project standards"
echo ""
echo "Next steps:"
echo "  Run: /spec-review $TASK_ID"
echo "  This will validate all ACs and approve/refuse the task"
```

#### 2. Validate ALL ACs Implemented

Before suggesting review, ensure completeness:

```bash
# Check all ACs are marked [x]
ACS=$(backlog_task_get "$TASK_ID" | jq -r '.acceptance_criteria[]')

TOTAL=$(echo "$ACS" | wc -l)
COMPLETED=$(echo "$ACS" | grep "\[x\]" | wc -l)

if [ "$COMPLETED" -eq "$TOTAL" ]; then
  echo "✓ All $TOTAL ACs completed"
  echo "Ready for /spec-review"
else
  echo "✗ Only $COMPLETED/$TOTAL ACs completed"
  echo "Missing:"
  echo "$ACS" | grep "\[ \]"
  echo ""
  echo "Cannot proceed to /spec-review until all ACs are complete"
fi
```

#### 3. Await Approval

After `/spec-review`, wait for approval before marking task Done:

```bash
# Review process is manual or automated
# Orchestrator doesn't mark task as Done
# That's done by /spec-retro after approval

echo "Waiting for /spec-review $TASK_ID approval..."
echo "Once approved, run: /spec-retro $TASK_ID"
```

## Complete Integration Example

```bash
#!/bin/bash

# User: "Delegate to gemini: implement task-10"

TASK_ID="task-10"
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

echo "=== GEMINI ORCHESTRATOR + SPEC-WORKFLOW ==="
echo ""

# ===== BEFORE =====
echo "[1/5] Reading spec and ACs..."

# Get task data
TASK=$(backlog_task_get "$TASK_ID")
SPEC_ID=$(echo "$TASK" | jq -r '.spec // empty')

if [ -z "$SPEC_ID" ]; then
  echo "Error: No spec associated with $TASK_ID"
  exit 1
fi

SPEC_FILE="backlog/specs/SPEC-${SPEC_ID}-*.backlog"
ACS=$(echo "$TASK" | jq -r '.acceptance_criteria[]')

echo "Spec: $SPEC_FILE"
echo "ACs: $(echo "$ACS" | wc -l) criteria found"
echo ""

# ===== DURING: Phase 1 - Planning =====
echo "[2/5] Delegating to gemini-3-pro for design..."

# Create orchestration plan
TodoWrite([
  { content: "Design architecture (Pro)", status: "in_progress", activeForm: "Designing" },
  { content: "Implement code (Flash)", status: "pending", activeForm: "Implementing" },
  { content: "Validate ACs", status: "pending", activeForm: "Validating" }
])

# Fetch memory
MEMORY=$(mcp__memory__search_nodes({ query: "${PROJECT_SLUG} auth patterns" }))

# Delegate to Pro
PRO_DESIGN=$(cat CLAUDE.md | gemini -p "
IMPORTANT: This is a PLANNING task.

MEMORY CONTEXT:
${MEMORY}

PROJECT CONTEXT (stdin):
CLAUDE.md standards

SPEC REQUIREMENTS:
$(cat "$SPEC_FILE")

ACCEPTANCE CRITERIA:
${ACS}

TASK: Design JWT authentication system
" --model gemini-3-pro-preview)

# Save ADR
mcp__memory__create_entities({
  entities: [{
    name: "${PROJECT_SLUG}/spec-${SPEC_ID}/decision-jwt-auth",
    entityType: "architecture-decision",
    observations: ["Context: ...", "Decision: ...", "Alternatives: ...", "Consequences: ..."]
  }]
})

# Update task notes
backlog_task_update "$TASK_ID" "{
  \"notes\": \"**Design Phase**\n${PRO_DESIGN}\n\n**Status**: Complete\"
}"

echo "✓ Design complete"
echo ""

# ===== DURING: Phase 2 - Implementation =====
echo "[3/5] Delegating to gemini-3-flash for implementation..."

TodoWrite([
  { content: "Design architecture (Pro)", status: "completed", activeForm: "Designing" },
  { content: "Implement code (Flash)", status: "in_progress", activeForm: "Implementing" },
  { content: "Validate ACs", status: "pending", activeForm: "Validating" }
])

# Delegate to Flash
cat CLAUDE.md | gemini -p "
ARCHITECTURE (from Pro):
${PRO_DESIGN}

MEMORY PATTERNS:
${MEMORY}

PROJECT CONTEXT (stdin):
CLAUDE.md standards

ACCEPTANCE CRITERIA (MUST ALL BE MET):
${ACS}

TASK: Implement JWT authentication based on Pro's design
" --model gemini-3-flash-preview

# Update task notes
backlog_task_update "$TASK_ID" "{
  \"notes\": \"**Design Phase**\n...\n\n**Implementation Phase**\n- AuthService implemented\n- Middleware created\n- Routes configured\n\n**Status**: Complete\"
}"

echo "✓ Implementation complete"
echo ""

# ===== DURING: Phase 3 - Validation =====
echo "[4/5] Validating Acceptance Criteria..."

TodoWrite([
  { content: "Design architecture (Pro)", status: "completed", activeForm: "Designing" },
  { content: "Implement code (Flash)", status: "completed", activeForm: "Implementing" },
  { content: "Validate ACs", status: "in_progress", activeForm: "Validating" }
])

# Run tests
npm test

if [ $? -eq 0 ]; then
  echo "✓ All tests passed"

  # Mark all ACs as complete
  # (In practice, you'd check each one individually)
  ACS_UPDATED=$(echo "$ACS" | sed "s/\[ \]/[x]/g")

  backlog_task_update "$TASK_ID" "{
    \"acceptance_criteria\": $(echo "$ACS_UPDATED" | jq -R . | jq -s .),
    \"status\": \"in-review\"
  }"

  echo "✓ All $(echo "$ACS" | wc -l") ACs validated and marked complete"
else
  echo "✗ Tests failed, ACs not met"
  exit 1
fi

echo ""

# ===== AFTER =====
echo "[5/5] Orchestration complete, ready for review"
echo ""
echo "=== RESULTS ==="
echo "✓ Design by gemini-3-pro"
echo "✓ Implementation by gemini-3-flash"
echo "✓ All Acceptance Criteria met"
echo "✓ Tests passing"
echo ""
echo "=== NEXT STEPS ==="
echo "  Run: /spec-review $TASK_ID"
echo "  This will validate and approve/refuse the implementation"
echo ""
echo "  After approval:"
echo "  Run: /spec-retro $TASK_ID"
```

## Best Practices

✅ **Always read ACs first** - Before any delegation
✅ **Include ACs in prompts** - Make them mandatory requirements
✅ **Update task notes** - Keep Backlog.md informed of progress
✅ **Validate before review** - Run tests, check all ACs
✅ **Use TodoWrite** - Track orchestration phases
✅ **Mark ACs incrementally** - As each is completed

❌ **Skip ACs** - Don't delegate without reading requirements
❌ **Forget to update** - Keep task notes current
❌ **Auto-approve** - Always suggest `/spec-review`, don't bypass
❌ **Mark Done directly** - Use `/spec-retro` workflow

## Workflow Diagram

```
User: /spec-execute task-10 (triggers gemini orchestration)
    ↓
┌────────────────────────────────────────────────┐
│ BEFORE                                         │
│ - Read spec-010-auth.backlog                   │
│ - Extract Acceptance Criteria                  │
│ - Fetch memory patterns                        │
└───────────────┬────────────────────────────────┘
                ↓
┌────────────────────────────────────────────────┐
│ DURING - Phase 1: Design (Pro)                │
│ - Include ACs in prompt                        │
│ - Pro designs architecture                     │
│ - Save ADR to memory                           │
│ - Update task notes                            │
└───────────────┬────────────────────────────────┘
                ↓
┌────────────────────────────────────────────────┐
│ DURING - Phase 2: Implement (Flash)           │
│ - Pass Pro design + ACs to Flash              │
│ - Flash implements                             │
│ - Update task notes                            │
│ - Mark ACs as completed incrementally          │
└───────────────┬────────────────────────────────┘
                ↓
┌────────────────────────────────────────────────┐
│ DURING - Phase 3: Validate (Sonnet)           │
│ - Run tests                                    │
│ - Verify all ACs met                           │
│ - Update task status to "in-review"           │
└───────────────┬────────────────────────────────┘
                ↓
┌────────────────────────────────────────────────┐
│ AFTER                                          │
│ - Suggest: /spec-review task-10               │
│ - Await approval                               │
│ - User runs: /spec-retro task-10 (after OK)   │
└────────────────────────────────────────────────┘
```

## Integration Benefits

1. **Requirements Clarity**: ACs provide clear success criteria for Gemini
2. **Progress Tracking**: Backlog.md shows orchestration progress
3. **Quality Assurance**: `/spec-review` validates all ACs before approval
4. **Knowledge Persistence**: Memory + Backlog create comprehensive project history
5. **Workflow Consistency**: Follows Spec-Driven Development methodology
