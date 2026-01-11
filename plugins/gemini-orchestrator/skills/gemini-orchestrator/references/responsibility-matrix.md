# Responsibility Matrix

Complete table defining who executes what in Gemini Orchestrator workflow.

## Main Matrix

| Task | Executor | Can Read Code | Can Write Code | Can Execute Bash | Notes |
|------|----------|---------------|----------------|------------------|-------|
| **Planning / Design** | gemini-3-pro | ✅ Yes | ❌ No | ❌ No | Specify "PLANNING task" in prompt |
| **Architecture Review** | gemini-3-pro | ✅ Yes | ❌ No | ❌ No | Specify "ARCHITECTURE REVIEW task" |
| **Problem Diagnosis** | gemini-3-pro | ✅ Yes | ❌ No | ⚠️ Permissions only | Specify "PROBLEM RESOLUTION task" |
| **Trade-off Analysis** | gemini-3-pro | ✅ Yes | ❌ No | ❌ No | Compare approaches, evaluate options |
| **Code Quality Review** | gemini-3-pro | ✅ Yes | ❌ No | ❌ No | Analyze code, suggest improvements |
| **Proposing Solutions** | gemini-3-pro | ✅ Yes | ❌ No | ❌ No | Proposes, does NOT implement |
| | | | | | |
| **Coding / Implementation** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | Implements solutions |
| **Refactoring** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | Restructure existing code |
| **Bug Fixes** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | After Pro diagnosis |
| **Test Generation** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | Unit, integration, e2e tests |
| **Run Scripts (Dev)** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | During development |
| **Start Servers (Dev)** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | For development/testing |
| **Use MCP Servers (Dev)** | gemini-3-flash | ✅ Yes | ✅ Yes | ✅ Yes | When needed for implementation |
| | | | | | |
| **Codebase Analysis** | Explore agent | ✅ Yes | ❌ No | ❌ No | Via Task tool |
| **Find Patterns** | Explore agent | ✅ Yes | ❌ No | ❌ No | Locate similar code |
| **Map Structure** | Explore agent | ✅ Yes | ❌ No | ❌ No | Understand organization |
| | | | | | |
| **Final Tests** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes (tests only) | After delegations |
| **Run Validation Servers** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes (validation) | End-to-end testing |
| **Use MCP for Validation** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes (validation) | Verify states, data |
| **AC Verification** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes | Check all ACs met |
| **Final Approval** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes | Decision maker |
| **Report Results** | Orchestrator (Sonnet) | ✅ Yes | ❌ No (in this mode) | ✅ Yes | Synthesize outcomes |

## Detailed Breakdown

### gemini-3-pro-preview Capabilities

**Can Do**:
- Read and analyze code
- Design system architecture
- Evaluate trade-offs
- Review code quality
- Identify issues and anti-patterns
- Propose solutions
- Create diagrams (text-based)
- Adjust file permissions (during problem resolution only)

**Cannot Do**:
- Write or modify code files
- Implement solutions
- Execute application code
- Run development servers
- Install dependencies

**Prompt Requirement**:
- Must specify task type: "PLANNING task" or "PROBLEM RESOLUTION task" or "ARCHITECTURE REVIEW task"

**Examples**:
```bash
# Planning
gemini -p "IMPORTANT: This is a PLANNING task. Design auth system..." --model gemini-3-pro-preview

# Problem Resolution
gemini -p "IMPORTANT: This is a PROBLEM RESOLUTION task. Diagnose this error..." --model gemini-3-pro-preview

# Architecture Review
gemini -p "IMPORTANT: This is an ARCHITECTURE REVIEW task. Review this API design..." --model gemini-3-pro-preview
```

### gemini-3-flash-preview Capabilities

**Can Do**:
- Read and understand code
- Write new code files
- Modify existing code
- Execute Bash commands during development
- Run scripts (`npm run`, `python`, etc.)
- Start development servers
- Install dependencies
- Use MCP servers when needed
- Generate tests
- Refactor code

**Cannot Do**:
- Architectural planning (use Pro for this)
- Strategic decision making (use Pro)

**No Special Prompt Required**:
- Just describe the coding task clearly

**Examples**:
```bash
# Implementation
gemini -p "Implement JWT authentication service..." --model gemini-3-flash-preview

# Bug fix
gemini -p "Fix the TypeError in login endpoint..." --model gemini-3-flash-preview

# Refactoring
gemini -p "Refactor auth service to use dependency injection..." --model gemini-3-flash-preview
```

### Orchestrator (Sonnet) Responsibilities

**During Orchestration Mode**:
- Coordinate delegations
- Select appropriate model (Pro vs Flash)
- Provide comprehensive context
- Manage workflow (Simple, Complex, Error Resolution)
- Fetch from Basic Memory before delegations
- Save insights to Basic Memory after delegations

**After Delegations**:
- Run final tests (unit, integration, e2e)
- Start servers for validation
- Use MCP servers to verify states
- Check all Acceptance Criteria met
- Make final approval decision
- Synthesize and report results to user

**Never Do** (in Orchestration Mode):
- Write code directly (delegate to Flash)
- Make architectural decisions (delegate to Pro)

## Decision Tree

### "Should I use Pro or Flash?"

```
Task involves...

├─ Designing system? → gemini-3-pro (PLANNING)
├─ Choosing between approaches? → gemini-3-pro (PLANNING)
├─ Reviewing code quality? → gemini-3-pro (ARCHITECTURE REVIEW)
├─ Diagnosing an error? → gemini-3-pro (PROBLEM RESOLUTION)
│
├─ Writing code? → gemini-3-flash
├─ Fixing bugs? → gemini-3-flash (after Pro diagnosis if complex)
├─ Refactoring? → gemini-3-flash (after Pro design if large)
├─ Generating tests? → gemini-3-flash
│
├─ Understanding codebase? → Explore agent
├─ Finding similar code? → Explore agent
│
└─ Final validation? → Orchestrator (Sonnet)
```

## Example Workflows

### Example 1: New Feature

```
User: "Implement user authentication"

1. Orchestrator analyzes request
2. Explore agent → Maps existing auth code
3. gemini-3-pro → Designs auth system (PLANNING)
4. gemini-3-flash → Implements based on design
5. gemini-3-flash → Generates tests
6. Orchestrator → Runs tests, validates
7. Orchestrator → Reports results
```

### Example 2: Bug Fix

```
User: "Fix login endpoint 500 error"

1. Orchestrator captures error details
2. gemini-3-pro → Diagnoses root cause (PROBLEM RESOLUTION)
3. gemini-3-flash → Implements fix
4. Orchestrator → Runs tests, validates fix
5. Orchestrator → Reports resolution
```

### Example 3: Refactoring

```
User: "Refactor to use dependency injection"

1. Explore agent → Maps current structure
2. gemini-3-pro → Designs DI architecture (PLANNING)
3. gemini-3-flash → Refactors code
4. Orchestrator → Runs all tests (no regressions)
5. Orchestrator → Reports success
```

## Special Cases

### When Pro Needs to Read Code

**Scenario**: Pro needs to analyze existing code for review or diagnosis

**Allowed**:
```bash
cat src/auth/service.ts | gemini -p "
IMPORTANT: This is an ARCHITECTURE REVIEW task.

CODE TO REVIEW (stdin):
(AuthService implementation)

Analyze code quality and suggest improvements.
DO NOT implement - only review and recommend.
" --model gemini-3-pro-preview
```

### When Flash Needs to Execute Commands

**Scenario**: Flash needs to run tests or start dev server during implementation

**Allowed**:
```bash
gemini -p "
Implement feature X.

After implementation:
1. Run tests: npm test
2. Start dev server: npm run dev
3. Verify endpoint: curl http://localhost:3000/api/test
" --model gemini-3-flash-preview
```

Flash can execute these commands during development.

### When Orchestrator Validates

**Scenario**: After all delegations, Orchestrator must validate

**Orchestrator executes**:
```bash
# Run comprehensive tests
npm run test:unit
npm run test:integration
npm run test:e2e

# Start server for validation
npm run dev &
SERVER_PID=$!

# Test endpoints
curl http://localhost:3000/health
curl -X POST http://localhost:3000/api/auth/login

# Cleanup
kill $SERVER_PID

# Use MCP to verify database state
mcp__database__query("SELECT * FROM users WHERE ...")
```

## Common Mistakes

❌ **Using Flash for planning**
```bash
# Wrong
gemini -p "Design authentication system" --model gemini-3-flash-preview
```

✅ **Use Pro for planning**
```bash
# Correct
gemini -p "IMPORTANT: This is a PLANNING task. Design auth system" --model gemini-3-pro-preview
```

---

❌ **Using Pro for implementation**
```bash
# Wrong
gemini -p "PLANNING task: Implement JWT service" --model gemini-3-pro-preview
```

✅ **Use Flash for implementation**
```bash
# Correct
gemini -p "Implement JWT service" --model gemini-3-flash-preview
```

---

❌ **Orchestrator coding directly**
```bash
# Wrong - in Orchestration Mode
Write({ file_path: "src/auth.ts", content: "..." })
```

✅ **Orchestrator delegates to Flash**
```bash
# Correct
gemini -p "Implement auth.ts" --model gemini-3-flash-preview
```

---

❌ **Skipping final validation**
```bash
# Wrong
gemini -p "Implement feature" --model gemini-3-flash-preview
# → Report success immediately
```

✅ **Always validate**
```bash
# Correct
gemini -p "Implement feature" --model gemini-3-flash-preview
# → Orchestrator runs tests
npm test
# → Then reports success
```
