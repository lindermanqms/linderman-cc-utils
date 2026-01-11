# Delegation Strategy

This reference guide explains when to use each model in the Gemini Orchestrator workflow.

## Model Selection Matrix

| Task Type | Model | Specify in Prompt | Can Read Code | Can Write Code | Can Execute Bash | Can Delete | Can Use Backlog MCP |
|-----------|-------|-------------------|---------------|----------------|------------------|-----------|---------------------|
| Planning/Design | gemini-3-pro-preview | "PLANNING task" | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| Problem Diagnosis | gemini-3-pro-preview | "PROBLEM RESOLUTION task" | ✅ Yes | ❌ No | ✅ Adjust permissions only | ❌ No | ❌ No |
| Coding/Implementation | gemini-3-flash-preview | N/A | ✅ Yes | ✅ Yes | ✅ Dev only | ❌ No | ❌ No |
| Codebase Analysis | Explore agent (via Task tool) | N/A | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| Final Validation | Orchestrator (Sonnet) | N/A | ✅ Yes | ❌ No (in mode) | ✅ Yes | ✅ Yes | ✅ Yes |
| Cleanup Operations | Orchestrator (Sonnet) | N/A | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## When to Use gemini-3-pro-preview (PLANNING/ANALYSIS)

**CRITICAL**: ALWAYS specify task type in prompt: `"This is a PLANNING task"` or `"This is a PROBLEM RESOLUTION task"`

### Use Cases:
- **System design and architecture**: High-level designs, component diagrams, API structures
- **Trade-off analysis**: Comparing approaches, evaluating pros/cons
- **Strategic decisions**: Technology selection, architectural patterns
- **Implementation planning**: Breaking down features into steps
- **Code quality review**: Analyzing existing code for improvements
- **Problem diagnosis**: Reading code, analyzing errors, identifying root causes
- **Proposing solutions**: Does NOT implement - only proposes

### Capabilities:
- ✅ Read and analyze code (DO NOT implement)
- ✅ Adjust file permissions if needed (during problem resolution)
- ✅ Identify root causes of errors
- ✅ Propose solutions and architectures
- ✅ Design system components
- ❌ Cannot write or modify code files
- ❌ Cannot execute application code

### Example Prompt Header:
```
IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, an expert in system architecture.

TASK: Design a scalable authentication system...
```

## When to Use gemini-3-flash-preview (IMPLEMENTATION)

### Use Cases:
- **Writing code**: New features, modules, functions
- **Refactoring**: Improving existing code structure
- **Bug fixes**: Implementing solutions (after Pro diagnosis)
- **Test generation**: Writing unit, integration tests
- **Executing development tasks**: Can run scripts, start servers during development
- **Using MCP servers**: Can use MCP tools when needed for implementation

### Capabilities:
- ✅ Write and edit code files
- ✅ Execute Bash commands **during development** (npm install, creating files, etc.)
- ✅ Run scripts and start development servers **for development purposes**
- ✅ Use MCP servers **except Backlog.md** (Orchestrator's responsibility)
- ✅ Implement solutions designed by Pro
- ✅ Read existing code to understand context
- ✅ Run static code analysis (REQUIRED before report)
- ❌ **CANNOT** delete files or perform destructive operations
- ❌ **CANNOT** remove dependencies or packages
- ❌ **CANNOT** run final validation (compilation, tests, servers) - Orchestrator does this
- ❌ **CANNOT** use Backlog.md MCP - Orchestrator's exclusive responsibility

### Example Prompt Header:
```
You are Gemini-3-Flash, expert TypeScript developer.

TASK: Implement JWT authentication service based on the architecture designed by Pro...
```

## When to Use Explore Agent

Invoke via Task tool when you need to:
- **Map codebase structure**: Understand project organization
- **Find existing patterns**: Locate similar implementations
- **Locate files**: Search for specific modules or components
- **Understand project conventions**: Identify coding styles, patterns
- **Quick codebase analysis**: Get overview before delegating to Gemini

### Example Invocation:
```javascript
Task({
  subagent_type: "Explore",
  prompt: "Find existing authentication patterns in the codebase. Locate files related to JWT, session management, and user authentication.",
  description: "Explore auth patterns"
})
```

## When to Act Directly (Orchestrator as Sonnet)

You perform these tasks yourself, without delegating:
- **Final test execution**: `npm test`, `pytest`, `cargo test`, etc.
- **Final compilation/build**: `npm run build`, `cargo build --release`, etc.
- **Running servers for validation**: Starting apps to verify functionality
- **End-to-end validation**: Testing complete workflows
- **Acceptance Criteria verification**: Checking all ACs are met
- **Backlog.md MCP operations**: ALL interactions with Backlog.md (reading tasks, updating notes, marking ACs)
- **Other MCP operations for validation**: Verifying data, checking states
- **Final approval decision**: Deciding if work is complete and correct
- **Reporting results**: Synthesizing and presenting outcomes to user

### Why?
- You have the full context of the orchestration
- You're responsible for the final quality
- You understand the user's original intent
- You can make the final decision on completeness
- **CRITICAL**: Backlog.md integration requires understanding of the full workflow and user's project state

## Decision Workflow

```
┌─────────────────────────────────────┐
│ User Request                        │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│ Is this a planning/design task?     │
│ Or a problem that needs diagnosis?  │
└───┬─────────────────────┬───────────┘
    │ Yes                 │ No
    ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│ gemini-3-pro     │  │ Is this coding/  │
│                  │  │ implementation?  │
│ Specify:         │  └───┬──────────┬───┘
│ - PLANNING       │      │ Yes      │ No
│ - PROBLEM        │      ▼          ▼
│   RESOLUTION     │  ┌──────────┐ ┌──────────┐
└──────────────────┘  │ gemini-  │ │ Need to  │
                      │ 3-flash  │ │ explore  │
                      │          │ │ codebase?│
                      └──────────┘ └───┬──────┘
                                       │ Yes
                                       ▼
                                  ┌──────────┐
                                  │ Explore  │
                                  │ agent    │
                                  └──────────┘
                                       │
                                       ▼
                      ┌─────────────────────────┐
                      │ After delegation(s):    │
                      │ Orchestrator validates  │
                      │ and reports             │
                      └─────────────────────────┘
```

## Use Case Examples

### Example 1: New Feature
**Task**: "Add password reset functionality"

1. **Explore** → Find existing auth patterns
2. **gemini-3-pro** → Design reset flow (email, token, expiry)
3. **gemini-3-flash** → Implement based on design
4. **Orchestrator** → Run tests, verify emails sent

### Example 2: Bug Fix
**Task**: "Fix login endpoint returning 500"

1. **gemini-3-pro** → Diagnose root cause (PROBLEM RESOLUTION)
2. **gemini-3-flash** → Implement the fix
3. **Orchestrator** → Run tests, verify fix works

### Example 3: Refactoring
**Task**: "Refactor authentication to use dependency injection"

1. **Explore** → Map current auth structure
2. **gemini-3-pro** → Design DI architecture (PLANNING)
3. **gemini-3-flash** → Refactor code
4. **Orchestrator** → Run all tests, verify no regressions

### Example 4: Investigation
**Task**: "How does the current API handle rate limiting?"

1. **Explore** → Search for rate limiting code
2. **Report findings** → No need for Gemini delegation
3. **Orchestrator** → Synthesize and present to user

## Common Mistakes

❌ **Using Flash for planning** → Flash will implement immediately, skipping design phase
❌ **Using Pro without specifying task type** → Pro might not optimize for reasoning
❌ **Using Orchestrator for coding** → Violates core principle, defeats purpose of skill
❌ **Not using Explore first** → Gemini models work better with codebase context
❌ **Skipping final validation** → Orchestrator MUST run final tests

## Best Practices

✅ **Start with Explore** if you don't know the codebase structure
✅ **Use Pro for design** before Flash for implementation (for complex features)
✅ **Specify "PLANNING task"** explicitly in Pro prompts
✅ **Pass Pro's output** to Flash as architectural guidance
✅ **Always validate** with Orchestrator tests at the end
✅ **Provide comprehensive context** to all Gemini models (CLAUDE.md, specs, etc.)

## Mandatory Protocol: Static Code Analysis

**ALL gemini-3-flash-preview delegations MUST run static analysis before final report**:

### Required Static Checks

```bash
# Run appropriate static analysis based on language

# TypeScript/JavaScript
npm run lint     # ESLint
npm run typecheck # TypeScript compiler

# Python
ruff check .     # Fast linting
mypy .           # Type checking
black --check .  # Formatting check

# Rust
cargo clippy     # Linting
cargo fmt --check # Formatting

# Go
go vet ./...     # Vetting
gofmt -l .       # Formatting
```

### Protocol on Static Analysis Failures

**Error Retry Protocol (3 attempts)**:

1. **Attempt 1**: Fix linting/type errors automatically
2. **Attempt 2**: If still failing, analyze root cause and fix
3. **Attempt 3**: If still failing, document difficulties in report

```bash
# Example error handling protocol
if ! npm run lint; then
  echo "⚠️ Linting failed, attempt 1: auto-fix..."
  npm run lint -- --fix

  if ! npm run lint; then
    echo "⚠️ Still failing, attempt 2: analyze and fix..."
    # Analyze and fix specific errors

    if ! npm run lint; then
      echo "⚠️ Still failing, attempt 3: document in report..."
      # Document difficulties in final report
    fi
  fi
fi
```

### Report Section for Failures

When static analysis fails after 3 attempts, include in Orchestrator Report:

```markdown
=== ORCHESTRATOR REPORT ===

...

## Static Analysis Results
❌ **FAILED** - Unable to resolve all linting/type errors after 3 attempts

### Remaining Issues:
- [Error 1]: Description and file location
- [Error 2]: Description and file location

### Difficulties Encountered:
[Explain why these errors couldn't be resolved:
- Contradictory requirements?
- Missing type definitions?
- External library issues?
- Configuration conflicts?]

### Recommended Next Steps:
- Manual review required for: [files]
- Consider: [suggestions]
```

## Operation Boundaries

### Gemini Agents CANNOT Do:

**Destructive Operations**:
❌ **Delete files** (rm, git rm, etc.)
❌ **Remove packages** (npm uninstall, pip uninstall, etc.)
❌ **Clean directories** (rm -rf, clean scripts, etc.)
❌ **Rollback migrations** (dangerous destructive operations)
❌ **Drop database tables** (or any destructive DB operations)
❌ **Modify git history** (rebase, reset, etc.)

**Final Validation Operations**:
❌ **Final compilation/build** for validation (Orchestrator does this)
❌ **Run servers for validation** (can run during dev, but validation is Orchestrator's job)
❌ **Execute final test suite** for approval (Orchestrator validates)

**MCP Operations**:
❌ **Use Backlog.md MCP** (reading tasks, updating tasks, marking ACs, etc.)
❌ **Any project management MCP** (Orchestrator's exclusive responsibility)

### These Operations Are Orchestrator (Sonnet) Responsibility:

**Destructive Operations** (after validation):
✅ **File cleanup** after implementation is validated
✅ **Package removal** when safe and appropriate
✅ **Migration rollbacks** after careful analysis
✅ **Git operations** (commit, branch management)

**Final Validation**:
✅ **Final compilation/build** (`npm run build`, `cargo build`, etc.)
✅ **Run servers for validation** (start app, verify endpoints, check UI)
✅ **Execute test suite** (npm test, pytest, cargo test)
✅ **End-to-end testing** (complete workflows)

**Project Management**:
✅ **ALL Backlog.md MCP operations**
  - `backlog_task_get()` - Read task details and ACs
  - `backlog_task_update()` - Update task notes and progress
  - `backlog_task_list()` - List and filter tasks
  - Mark ACs as completed
  - Update task status
✅ **Other project management MCPs** (if any)

### Example: Proper Workflow

```bash
# ❌ WRONG - Flash deletes files
gemini -p "Delete the old auth.js file" --yolo

# ✅ CORRECT - Flash marks for cleanup, Orchestrator deletes
gemini -p "Implement new auth and MARK OLD FILES FOR CLEANUP" --yolo

# Orchestrator then reviews and performs cleanup
```

## Error Handling Protocol

### For gemini-3-flash-preview (Implementation)

**When encountering errors**:

1. **Attempt 1**: Fix automatically using available tools
   - Try to resolve the error based on error message
   - Apply fix and re-test

2. **Attempt 2**: If still failing, analyze root cause
   - Read relevant code and documentation
   - Identify the underlying issue
   - Apply targeted fix

3. **Attempt 3**: If still failing, document in report
   - Explain what was attempted
   - Describe why resolution failed
   - Suggest manual intervention if needed

### Error Report Format

```markdown
## Issues Found

### Unresolved Issues (after 3 attempts):

**Issue**: [Description]
**Location**: [file:line]
**Attempts Made**:
1. [First attempt description] → Result: [outcome]
2. [Second attempt description] → Result: [outcome]
3. [Third attempt description] → Result: [outcome]

**Root Cause Analysis**: [Why couldn't it be resolved?]

**Recommended Action**: [Manual intervention needed / alternative approach]
```

### For gemini-3-pro-preview (Analysis)

**When unable to analyze**:

- Report limitations in context provided
- Suggest additional information needed
- Propose alternative analysis approaches

No retry protocol needed for Pro - it's analysis, not implementation.
