# Delegation Strategy

This reference guide explains when to use each model in the Gemini Orchestrator workflow.

## Model Selection Matrix

| Task Type | Model | Specify in Prompt | Can Read Code | Can Write Code | Can Execute Bash |
|-----------|-------|-------------------|---------------|----------------|------------------|
| Planning/Design | gemini-3-pro-preview | "PLANNING task" | ✅ Yes | ❌ No | ❌ No |
| Problem Diagnosis | gemini-3-pro-preview | "PROBLEM RESOLUTION task" | ✅ Yes | ❌ No | ✅ Adjust permissions only |
| Coding/Implementation | gemini-3-flash-preview | N/A | ✅ Yes | ✅ Yes | ✅ Yes |
| Codebase Analysis | Explore agent (via Task tool) | N/A | ✅ Yes | ❌ No | ❌ No |
| Final Validation | Orchestrator (Sonnet) | N/A | ✅ Yes | ❌ No (in this mode) | ✅ Yes (tests only) |

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
- ✅ Execute Bash commands during development
- ✅ Run scripts and start development servers
- ✅ Use MCP servers when needed
- ✅ Implement solutions designed by Pro
- ✅ Read existing code to understand context

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
- **Running servers for validation**: Starting apps to verify functionality
- **End-to-end validation**: Testing complete workflows
- **Acceptance Criteria verification**: Checking all ACs are met
- **Using MCP servers for validation**: Verifying data, checking states
- **Final approval decision**: Deciding if work is complete and correct
- **Reporting results**: Synthesizing and presenting outcomes to user

### Why?
- You have the full context of the orchestration
- You're responsible for the final quality
- You understand the user's original intent
- You can make the final decision on completeness

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
