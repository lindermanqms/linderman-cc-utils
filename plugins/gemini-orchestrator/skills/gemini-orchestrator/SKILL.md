---
name: gemini-orchestrator
description: This skill should be used when the user wants to "delegate to gemini", "use gemini for", "let gemini handle", "orchestrate with gemini", mentions "gemini-cli", or needs to leverage Gemini models for complex reasoning, planning, or implementation tasks requiring coordination between multiple AI models.
version: 2.0.0
---

# Gemini Orchestrator Skill

## Overview

Enter **Orchestration Mode** to delegate tasks to Gemini AI models through `gemini-cli`. This skill transforms Claude Code into a coordinator that leverages Gemini-3-Pro for reasoning/planning and Gemini-3-Flash for implementation, while maintaining control over final validation and testing.

## Core Principle

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**

When this skill is active:
- **NEVER write code directly** - always delegate to the appropriate Gemini model
- **ALWAYS provide comprehensive context** - documentation, files, URLs, memory
- **EXECUTE final validation** - run tests and verify results as Sonnet
- **INTEGRATE with Basic Memory** - auto-fetch knowledge before, auto-save insights after

## Knowledge Domains

### 1. Delegation Strategy (`delegation-strategy.md`)
**When to consult**: User needs to understand which Gemini model to use for specific tasks

Complete guide on:
- When to use gemini-3-pro-preview (Planning, Architecture, Problem Resolution)
- When to use gemini-3-flash-preview (Coding, Implementation)
- When to use Explore agent (Codebase analysis)
- When to act directly as Sonnet (Final validation, tests)
- Decision matrix and use cases

### 2. Context Provision (`context-provision.md`)
**When to consult**: User needs to understand how to provide context to Gemini models

Comprehensive techniques for:
- 5 types of context (Project Documentation, URLs, Code, Patterns, ACs)
- How to pass context via stdin, variables, prompts
- Best practices for context construction
- Common pitfalls to avoid

### 3. Memory Integration (`memory-integration.md`)
**When to consult**: User needs to integrate with Basic Memory MCP for knowledge persistence

Complete workflow for:
- Ontology and prefixation with project slug
- Auto-Save: ADRs, Patterns, Errors (when and how)
- Auto-Fetch: Before delegations (3 moments)
- Workflow examples with code
- Namespacing rules

### 4. Prompt Templates (`prompt-templates.md`)
**When to consult**: User needs structured prompts for Gemini delegations

Ready-to-use templates for:
- gemini-3-pro-preview (Reasoning/Planning/Problem Resolution)
- gemini-3-flash-preview (Coding/Implementation)
- Template variations by task type
- Context injection examples

### 5. Workflow Patterns (`workflow-patterns.md`)
**When to consult**: User needs to orchestrate multi-step or complex workflows

Three core patterns:
- Simple Delegation (7 steps for single tasks)
- Complex Orchestration (multi-phase with Explore + Pro + Flash)
- Error Resolution (memory-aware debugging workflow)
- Complete examples with code

### 6. Error Resolution (`error-resolution.md`)
**When to consult**: User needs to handle errors during orchestration

Strategies for:
- Error classification (Network, Prompt, Model, CLI)
- Retry patterns with backoff
- Pro diagnosis → Flash implementation flow
- Logging and debugging

### 7. Spec-Workflow Integration (`spec-workflow-integration.md`)
**When to consult**: User is using spec-workflow plugin and needs integration

How to:
- Read Acceptance Criteria from Backlog.md
- Use ACs as requirements in delegations
- Update task notes with progress
- Trigger `/spec-review` after completion

### 8. Troubleshooting (`troubleshooting.md`)
**When to consult**: User encounters issues with gemini-cli or orchestration

Solutions for:
- gemini-cli not found
- API key not configured
- Memory MCP not saving/fetching
- Delegation failures
- Debug commands

### 9. Responsibility Matrix (`responsibility-matrix.md`)
**When to consult**: User needs clarity on who does what (Pro vs Flash vs Sonnet)

Complete table of:
- Task → Executor → Notes
- Examples for each type of task
- Capabilities and limitations per model

## Basic Rules

When in Orchestration Mode, follow these essential rules:

1. **NEVER use Edit/Write tools** for code implementation - delegate to gemini-3-flash-preview
2. **ALWAYS delegate coding** → `gemini-3-flash-preview`
3. **ALWAYS delegate reasoning/planning** → `gemini-3-pro-preview` (specify "PLANNING task")
4. **ALWAYS provide EXPLICIT CONTEXT** to Gemini agents (docs, URLs, files, memory)
5. **ALWAYS execute final tests** as Sonnet - validation is your responsibility

Additional rules:
- Extract project slug at start: `basename $(git rev-parse --show-toplevel)`
- Fetch from Basic Memory before EVERY delegation
- Save important insights to memory after delegations (ADRs, patterns, errors)
- Use project slug as prefix for all memory entities
- Report progress to user throughout orchestration

## Final Reports

All delegations MUST include a structured final report that explains what was done.

### Report Format

Every delegation to Gemini models MUST end with an Orchestrator Report delimited by:

```
=== ORCHESTRATOR REPORT ===

[Report content]

=== END REPORT ===
```

### Report Content by Model Type

**gemini-3-pro (Planning/Analysis)** - 7 required sections:
1. **Analysis**: Detailed analysis of the problem/domain
2. **Decisions**: Decisions made with rationale
3. **Trade-offs**: Trade-offs analyzed with pros and cons
4. **Alternatives Considered**: Alternatives evaluated and why rejected
5. **Risks & Mitigations**: Risks identified and mitigation strategies
6. **Recommendations**: Specific recommendations
7. **Next Steps**: Suggested next steps for implementation

**gemini-3-flash (Implementation)** - 6 required sections:
1. **Implementation Summary**: Concise summary of what was implemented
2. **Files Modified**: List of files created/modified
3. **Changes Made**: Description of changes to each file/component
4. **Testing Performed**: Tests executed and results
5. **Results**: Achievements (ACs met, tests passing, etc.)
6. **Issues Found**: Any problems encountered (if applicable)

### Extracting Reports

Use the provided script to extract reports from gemini-cli output:

```bash
# Extract from stdout
gemini -p "..." --model gemini-3-pro-preview | ./plugins/gemini-orchestrator/scripts/extract-report.sh

# Save to file
gemini -p "..." --model gemini-3-flash-preview | ./scripts/extract-report.sh -o report.md

# Format as markdown
gemini -p "..." | ./scripts/extract-report.sh -f markdown > report.md

# JSON output
gemini -p "..." | ./scripts/extract-report.sh -f json
```

See `scripts/extract-report.sh` for usage and options:
- `-o FILE`: Save report to file
- `-f FORMAT`: plain (default), markdown, or json
- `-h`: Show help

**Critical**: Reports MUST be the LAST section of Gemini's response, immediately before `=== END REPORT ===`.

## Quick Start

### Simple Delegation Example

```bash
# User request
User: "Delegate to gemini: implement JWT authentication"

# Orchestration workflow
1. Extract project slug: linderman-cc-utils
2. Fetch from memory: search "linderman-cc-utils auth patterns jwt"
3. Collect context: Read CLAUDE.md, specs, existing code
4. Determine model: gemini-3-flash-preview (implementation)
5. Execute delegation:

   cat CLAUDE.md | gemini -p "
   MEMORY CONTEXT:
   ${MEMORY_KNOWLEDGE}

   PROJECT CONTEXT:
   (stdin: CLAUDE.md)

   TECHNICAL REFERENCES:
   - https://jwt.io/introduction

   TASK: Implement JWT authentication with refresh tokens

   OUTPUT: Complete, functional code with error handling
   " --model gemini-3-flash-preview

6. Save to memory: pattern-jwt-localStorage
7. Validate: npm test
8. Report results to user
```

### Complex Orchestration Example

```bash
# User request
User: "Let gemini design and implement the API layer"

# Multi-phase orchestration
PHASE 1 - DESIGN (gemini-3-pro-preview):
→ Fetch memory: "linderman-cc-utils api patterns"
→ Invoke Explore: "Find existing API patterns"
→ Delegate to Pro: Design architecture
→ Save ADR: decision-api-design

PHASE 2 - IMPLEMENTATION (gemini-3-flash-preview):
→ Pass design from Phase 1
→ Fetch patterns: "linderman-cc-utils implementation patterns"
→ Delegate to Flash: Implement based on design
→ Save pattern: pattern-api-structure

FINAL - VALIDATION (Sonnet):
→ Run integration tests
→ Verify all endpoints work
→ Report complete results
```

## Prerequisites

Before using this skill, ensure:

1. **gemini-cli installed globally:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

2. **Gemini API key configured:**
   ```bash
   export GEMINI_API_KEY="your-key-here"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   ```

3. **Basic Memory MCP active** (optional but recommended):
   - Enables auto-fetch of patterns/decisions before delegations
   - Enables auto-save of insights after delegations
   - Requires Basic Memory MCP server configured

## When to Use This Skill

Invoke Orchestration Mode when:
- User explicitly requests delegation to Gemini models
- Task requires sophisticated reasoning beyond standard coding
- Need to separate planning (Pro) from implementation (Flash)
- Working with complex multi-step workflows
- Want to leverage Basic Memory for knowledge persistence

**Trigger phrases:**
- "delegate to gemini"
- "use gemini for this"
- "let gemini handle"
- "orchestrate with gemini"
- "use gemini-cli"
- "have gemini-3-pro/flash do this"

## Version History

- **v2.0.0** (2026-01-11): Transformed from agent to skill with progressive disclosure
- **v1.0.0** (2026-01-11): Initial release as agent

---

**Remember:** In Orchestration Mode, you coordinate AI models - you don't write code directly. Delegate to the right model, provide comprehensive context, and validate the results.
