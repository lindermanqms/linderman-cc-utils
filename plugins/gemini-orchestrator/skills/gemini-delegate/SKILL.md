---
name: gemini-delegate
description: This skill should be used when the user explicitly requests to "delegate to gemini", "use gemini for", "let gemini handle", "orchestrate with gemini", mentions "gemini-cli", or wants to leverage Gemini models for complex reasoning, planning, or implementation tasks.
version: 1.0.0
---

# Gemini Delegation Skill

This skill invokes the **Gemini Orchestrator Agent** to delegate tasks to appropriate Gemini models through the `gemini-cli` interface.

## When to Use

Use this skill when:
- User explicitly asks to delegate to Gemini models
- Task requires sophisticated reasoning or architectural planning
- Need to separate planning (Pro) from implementation (Flash)
- Working with complex multi-step workflows
- User mentions "gemini-cli" or Gemini model names

## Trigger Phrases

- "delegate to gemini"
- "use gemini for this"
- "let gemini handle"
- "orchestrate with gemini"
- "use gemini-cli"
- "have gemini-3-pro/flash do this"

## What This Does

This skill spawns the **gemini-orchestrator** agent (via Task tool), which:

1. **Never codes directly** - always delegates to appropriate Gemini models
2. **Gathers comprehensive context** - documentation, files, URLs, memory
3. **Selects appropriate model**:
   - `gemini-3-pro-preview`: Planning, design, problem analysis
   - `gemini-3-flash-preview`: Implementation, coding, bug fixes
4. **Integrates with Memory MCP** - auto-fetch/save patterns, decisions, errors
5. **Validates results** - runs tests and verifications as Sonnet
6. **Reports progress** - keeps user informed throughout orchestration

## Usage Examples

### Simple Delegation

```
User: "Delegate to gemini: implement JWT authentication"
→ Spawns gemini-orchestrator
→ Orchestrator collects context (CLAUDE.md, specs, memory)
→ Delegates to gemini-3-flash-preview with full context
→ Validates implementation
→ Saves patterns to memory
```

### Complex Orchestration

```
User: "Let gemini handle designing and implementing the API layer"
→ Spawns gemini-orchestrator
→ Phase 1: gemini-3-pro designs architecture
→ Phase 2: gemini-3-flash implements based on design
→ Orchestrator runs integration tests
→ Saves architectural decisions to memory
```

### Problem Resolution

```
User: "Use gemini to fix this error"
→ Spawns gemini-orchestrator
→ Checks memory for similar errors
→ gemini-3-pro diagnoses root cause
→ gemini-3-flash implements fix
→ Saves error resolution to memory
```

## Integration with Spec-Workflow

When used with `spec-workflow` plugin:
- Reads Acceptance Criteria from specs
- Updates task notes with progress
- Marks ACs as completed
- Suggests `/spec-review` after completion

## Memory Integration

The orchestrator automatically:
- **Fetches** knowledge from Basic Memory before delegations
- **Saves** important insights after delegations:
  - Architecture Decision Records (ADRs)
  - Code patterns discovered
  - Error resolutions

## Prerequisites

Requires `gemini-cli` installed globally:
```bash
npm install -g gemini-cli
```

## Reference

For detailed orchestrator behavior, see `agents/gemini-orchestrator.md` in the plugin directory.

## How It Works

When invoked, this skill uses the Task tool to spawn the gemini-orchestrator agent:

```javascript
Task({
  subagent_type: "gemini-orchestrator",
  prompt: "[user's delegation request with full context]",
  description: "Delegate to Gemini models"
})
```

The agent then takes over and handles the entire orchestration workflow.

---

**Note**: This skill is a gateway to the orchestrator agent. The actual orchestration logic, delegation patterns, and memory integration are defined in the agent itself.
