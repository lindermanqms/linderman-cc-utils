---
name: gemini-orchestrator
description: This skill should be used when the user wants to "delegate to gemini", "use gemini for", "let gemini handle", "orchestrate with gemini", mentions "gemini-cli", "delegate.sh", or needs to leverage Gemini models for complex reasoning, planning, or implementation tasks requiring coordination between multiple AI models. Scripts are located at plugins/gemini-orchestrator/scripts/ and are executed directly from their installation location (NOT copied to project). Templates are in plugins/gemini-orchestrator/templates/ and must be copied to .claude/gemini-orchestrator/prompts/ during setup.
version: 2.3.1
---

# Gemini Orchestrator Skill

## Overview

Enter **Orchestration Mode** to delegate tasks to Gemini AI models. This skill transforms Claude Code into a coordinator that leverages:
- **gemini-3-pro-preview** for reasoning, planning, and problem analysis
- **gemini-3-flash-preview** for code implementation
- **Orchestrator (Sonnet)** for final validation and project management

**Recommended workflow**: Use `delegate.sh` script for reliable, organized delegations.

## Core Principle

**"You are the conductor of a symphony of AI models. Coordinate, don't code."**

### 🚨 GOLDEN RULE - NEVER BREAK THIS 🚨

**YOU (Orchestrator) MUST NEVER WRITE CODE DIRECTLY**

- ❌ **NEVER** use Edit tool for code implementation
- ❌ **NEVER** use Write tool for code files
- ❌ **NEVER** implement features yourself
- ❌ **NEVER** fix bugs by editing code directly
- ❌ **NEVER** refactor code yourself
- ❌ **NEVER** write tests yourself

**EXCEPTION**: Only if user **EXPLICITLY** says:
- "You write the code" or
- "Don't delegate, do it yourself" or
- "Implement this directly, don't use gemini"

**DEFAULT BEHAVIOR**: ALWAYS delegate coding to agents via delegate.sh

When this skill is active:
- **ALWAYS delegate code to agents** via `delegate.sh` script
- **ALWAYS use template-based prompts** - create from templates in `.claude/gemini-orchestrator/prompts/`
- **ALWAYS provide comprehensive context** - documentation, files, memory, URLs
- **EXECUTE final validation yourself** - build, test, validate as Orchestrator (Sonnet)
- **MANAGE project state yourself** - ALL Backlog.md MCP operations stay with you

## Recommended Workflow: delegate.sh Script

**ALWAYS prefer this workflow** over manual `gemini` commands:

### Script Location

The delegate.sh script is located at (relative to project root):
```
plugins/gemini-orchestrator/scripts/delegate.sh
```

**IMPORTANT**: Always use this exact path from the project root. Do NOT search for the script.

### How Scripts Work

**CRITICAL UNDERSTANDING**: Scripts are **NOT copied** to your project. They are **executed directly** from the plugin installation location.

**Why this design?**
- ✅ **Single source of truth** - One delegate.sh version across all projects
- ✅ **Automatic updates** - Plugin updates automatically update the script
- ✅ **No duplication** - No need to copy files across projects
- ✅ **Consistent behavior** - Same script behavior everywhere

**What this means:**
- ❌ **DO NOT** expect scripts to be in your project root
- ❌ **DO NOT** copy scripts to your project directory
- ✅ **DO** reference scripts with full path from project root
- ✅ **DO** execute scripts directly from plugin location

**Usage pattern (always from project root):**
```bash
# Correct - full path from project root
./plugins/gemini-orchestrator/scripts/delegate.sh prompt.txt

# Wrong - script is not in current directory
./delegate.sh prompt.txt  # ❌ Will fail

# Wrong - script is not copied to project
delegate.sh prompt.txt    # ❌ Will fail
```

**If you get "Script not found" error:**
1. Verify you're in project root: `pwd`
2. Verify script exists: `ls -la plugins/gemini-orchestrator/scripts/delegate.sh`
3. Use full path: `./plugins/gemini-orchestrator/scripts/delegate.sh`

### Setup (One-Time)

```bash
# 1. Verify script exists
ls -la plugins/gemini-orchestrator/scripts/delegate.sh

# 2. Create orchestration directory structure
mkdir -p .claude/gemini-orchestrator/prompts
mkdir -p .claude/gemini-orchestrator/reports

# 3. Copy templates and setup guide from plugin to your project
cp plugins/gemini-orchestrator/templates/TEMPLATE-*.txt \
   .claude/gemini-orchestrator/prompts/

cp plugins/gemini-orchestrator/templates/SETUP-GUIDE.md \
   .claude/gemini-orchestrator/README.md

# 4. Verify templates were copied
ls -la .claude/gemini-orchestrator/prompts/TEMPLATE-*.txt
ls -la .claude/gemini-orchestrator/README.md
```

**Important**: Templates and setup guide are stored in the plugin at `plugins/gemini-orchestrator/templates/` and must be copied to your project's `.claude/gemini-orchestrator/` directory for easy reference.

### Standard Delegation Process

**Step 1: Create prompt from template**
```bash
# For implementation (Flash)
cp .claude/gemini-orchestrator/prompts/TEMPLATE-flash-implementation.txt \
   .claude/gemini-orchestrator/prompts/task-ID-description.txt

# For planning (Pro)
cp .claude/gemini-orchestrator/prompts/TEMPLATE-pro-planning.txt \
   .claude/gemini-orchestrator/prompts/task-ID-design.txt
```

**Step 2: Edit prompt** - Fill in all sections:
- Project Context (CLAUDE.md, architecture)
- Memory Context (patterns from search_nodes)
- Task Description (detailed requirements)
- Acceptance Criteria (from Backlog.md if using spec-workflow)
- Technical Requirements

**Step 3: Execute delegation**
```bash
# Auto-detects model based on keywords
# NOTE: Script automatically adds --approval-mode yolo, do NOT add it manually
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .claude/gemini-orchestrator/prompts/task-ID-description.txt

# Force specific model if needed
./plugins/gemini-orchestrator/scripts/delegate.sh -m flash \
  .claude/gemini-orchestrator/prompts/task-ID-description.txt
```

**Step 4: Review report**
```bash
# Report saved automatically
cat .claude/gemini-orchestrator/reports/flash-YYYY-MM-DD-HH-MM.md
```

**Step 5: Validate (as Orchestrator)**
```bash
# YOU run these (NOT the agent)
npm run build
npm test
npm start  # For end-to-end validation
```

**Step 6: Update Backlog (if using spec-workflow)**
```javascript
// YOU do this (NOT the agent)
await backlog_task_update({
  id: "task-ID",
  notes: "Implementation completed via Gemini Flash. Report: .claude/gemini-orchestrator/reports/flash-*.md"
})
```

### Alternative: Manual `gemini` Command (When delegate.sh fails)

If `delegate.sh` script is not working, use manual `gemini` command with report capture:

**Step 1: Create prompt from template** (same as above)

**Step 2: Edit prompt** (same as above)

**Step 3: Execute delegation manually**
```bash
# For Flash implementation
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-description.txt)" \
  2>&1 | tee "$REPORT_FILE"

# For Pro planning
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-ID-design.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

**IMPORTANT**:
- Always use `--approval-mode yolo` for auto-approval
- Capture output with `2>&1 | tee` to save report AND see it live
- Timestamp ensures unique report names
- Full path required: `.claude/gemini-orchestrator/prompts/`

**Step 4: Review report**
```bash
# Report saved with timestamp
cat .claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md
```

**Step 5: Validate** (same as above)

**Step 6: Update Backlog** (same as above)

### Why Use delegate.sh?

| Aspect | Manual `gemini -p "..."` | **delegate.sh (Recommended)** |
|--------|-------------------------|-------------------------------|
| Multiline prompts | ❌ Breaks with parse errors | ✅ Reads from file reliably |
| Report extraction | ❌ Manual | ✅ Automatic |
| Report storage | ❌ Manual redirection | ✅ Auto-saved with timestamp |
| Prompt reusability | ❌ Lost after execution | ✅ Saved in prompts/ |
| Model detection | ❌ Manual specification | ✅ Auto-detects via keywords |
| Debugging | ❌ Output lost | ✅ Full log saved |
| Organization | ❌ Inconsistent | ✅ Standardized structure |

## Knowledge Domains

### 1. Delegation Strategy (`delegation-strategy.md`)
**When to consult**: User needs to understand which Gemini model to use for specific tasks

Complete guide on:
- When to use gemini-3-pro-preview (Planning, Architecture, Problem Resolution)
- When to use gemini-3-flash-preview (Coding, Implementation)
- When to use Explore agent (Codebase analysis)
- When YOU act directly as Sonnet (Final validation, Backlog.md, tests)
- Decision matrix and use cases

### 2. Context Provision (`context-provision.md`)
**When to consult**: User needs to understand how to provide context to Gemini models

Comprehensive techniques for:
- 5 types of context (Project Documentation, URLs, Code, Patterns, ACs)
- How to pass context via files, variables, prompts
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
- Simple Delegation (single task via delegate.sh)
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
- Read Acceptance Criteria from Backlog.md (YOU do this, not agents)
- Use ACs as requirements in delegations
- Update task notes with progress (YOU do this, not agents)
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

### 10. CLI Configuration (`cli-configuration.md`)
**When to consult**: User needs to configure gemini-cli for autonomous operation

Complete guide on:
- `--yolo` flag for full autonomy
- `--approval-mode` options (yolo, auto_edit, default)
- Tool allowlists via `--allowed-tools` or settings.json
- MCP server configuration with `trust: true`
- Static analysis requirements
- Error retry protocol (3 attempts)
- Operation boundaries (no destructive operations by agents)

### 11. Delegate Script Workflow (`delegate-script-workflow.md`)
**When to consult**: User wants complete guide on delegate.sh script

**CRITICAL**: This is the **primary recommended workflow**. Consult for:
- Complete delegate.sh usage guide
- Template-based prompt creation
- Auto-detection of model (Pro vs Flash)
- Automatic report extraction and saving
- `.claude/gemini-orchestrator/` directory structure
- Integration with spec-workflow and memory
- Troubleshooting delegation errors
- Examples and best practices

### 12. Agents vs Orchestrator (`agents-vs-orchestrator.md`)
**When to consult**: User needs clarity on separation of responsibilities

Complete guide on:
- What agents CAN do (during development)
- What agents CANNOT do (validation, Backlog.md, destructive ops)
- What YOU MUST do (validation, Backlog.md, final decisions)
- During development vs final validation
- Visual workflows and examples
- Troubleshooting common mistakes

## Basic Rules

When in Orchestration Mode, follow these rules **without exception**:

### 🚨 RULE #0: NEVER CODE (unless user explicitly requests)

**CRITICAL**: This is the MOST IMPORTANT rule. Breaking this defeats the entire purpose of the skill.

- ❌ **DO NOT** use Edit/Write tools for code implementation
- ❌ **DO NOT** implement features yourself
- ❌ **DO NOT** fix bugs directly
- ❌ **DO NOT** refactor code yourself
- ❌ **DO NOT** write tests yourself
- ❌ **DO NOT** create code files yourself

**ALWAYS**: Create prompt from template → delegate via delegate.sh → validate results

**ONLY EXCEPTION**: User says explicitly "you write the code" or "don't delegate, do it yourself"

### Delegation Rules

1. **USE delegate.sh script** for all delegations (recommended workflow)
   ```bash
   ./plugins/gemini-orchestrator/scripts/delegate.sh prompts/task-ID.txt
   ```

2. **NEVER use Edit/Write tools** for code implementation - delegate to agents

3. **ALWAYS create prompts from templates** in `.claude/gemini-orchestrator/prompts/`

4. **ALWAYS delegate coding** → `gemini-3-flash-preview` (via delegate.sh)

5. **ALWAYS delegate reasoning/planning** → `gemini-3-pro-preview` (specify "PLANNING task")

6. **ALWAYS provide EXPLICIT CONTEXT** to agents via prompt files:
   - Project documentation (CLAUDE.md)
   - Memory patterns (search_nodes results)
   - Existing code (relevant files)
   - Technical references (URLs)

### Orchestrator Responsibilities (YOU, not agents)

7. **ALWAYS execute final validation** yourself:
   - Final compilation/build (`npm run build`, `cargo build --release`)
   - Final test execution (`npm test`, `pytest`)
   - Running servers for validation (start app, verify endpoints)
   - End-to-end testing (complete workflows)

8. **NEVER let agents use Backlog.md MCP** - this is YOUR exclusive job:
   - Reading tasks: `backlog_task_get()`
   - Updating notes: `backlog_task_update()`
   - Listing tasks: `backlog_task_list()`
   - Marking ACs as completed
   - Updating task status

9. **Agents can run commands DURING development** - but YOU do final validation:
   - Agents CAN: `npm install`, `npm run dev`, `npm run lint`
   - Agents CANNOT: `npm run build` (final), `npm test` (final), use Backlog.md MCP
   - YOU do final builds and tests after delegation completes

### Memory Integration Rules

10. **Extract project slug at start:**
    ```bash
    PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
    ```

11. **Fetch from Basic Memory before EVERY delegation:**
    ```javascript
    search_nodes({ query: "${PROJECT_SLUG} ${domain} patterns" })
    ```

12. **Save insights after important delegations:**
    - ADRs: Architecture decisions from Pro
    - Patterns: Code patterns discovered by Flash
    - Errors: Resolutions after Error Resolution workflow

13. **Use project slug as prefix** for all memory entities:
    ```
    ${PROJECT_SLUG}/task-ID/pattern-jwt-auth
    ${PROJECT_SLUG}/global/decision-api-design
    ```

## Quick Start Examples

For detailed working examples with complete workflows, see:

- **`examples/simple-delegation.md`** - Single task delegation to gemini-3-flash
  - JWT authentication implementation walkthrough
  - Memory integration and Backlog.md updates
  - Complete validation workflow

- **`examples/complex-orchestration.md`** - Multi-phase workflows (Pro → Flash)
  - Design phase with gemini-3-pro
  - Implementation phase with gemini-3-flash
  - Orchestrator validation and memory persistence
  - Workflow diagrams and decision points

Additional examples in references/:
- `references/workflow-patterns.md` - Error Resolution workflow
- `references/spec-workflow-integration.md` - Backlog.md integration
- `references/error-resolution.md` - Debugging strategies

## Prerequisites

Before using this skill, ensure:

1. **gemini-cli installed:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

2. **Gemini API key configured:**
   ```bash
   export GEMINI_API_KEY="your-key-here"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   ```

3. **Orchestration directory initialized:**
   ```bash
   # Should exist with templates
   ls .claude/gemini-orchestrator/prompts/TEMPLATE-*.txt
   ```

4. **Basic Memory MCP active** (optional but strongly recommended):
   - Enables auto-fetch of patterns/decisions
   - Enables auto-save of insights
   - Check: `search_nodes({ query: "test" })`

## When to Use This Skill

Invoke Orchestration Mode when:
- User explicitly requests delegation to Gemini models
- Task requires sophisticated reasoning (Pro) or implementation (Flash)
- Need to separate planning from implementation
- Working with complex multi-step workflows
- Want to leverage Basic Memory for knowledge persistence

**Trigger phrases:**
- "delegate to gemini"
- "use gemini for this"
- "let gemini handle"
- "orchestrate with gemini"
- "use gemini-cli"
- "have gemini-3-pro/flash do this"

## Critical Reminders

### 🚨 MOST IMPORTANT - NEVER CODE DIRECTLY 🚨

**YOU ARE THE ORCHESTRATOR, NOT THE IMPLEMENTER**

If user asks for code implementation:
1. ✅ Create prompt from template
2. ✅ Execute via delegate.sh
3. ✅ Validate results
4. ❌ **NEVER** write code yourself (unless explicitly requested)

### Other Critical Rules

1. ✅ **ALWAYS use delegate.sh** - don't execute `gemini -p "..."` manually
2. ✅ **YOU validate** - agents implement, YOU run final build/test/validation
3. ✅ **YOU manage Backlog** - agents NEVER touch Backlog.md MCP
4. ✅ **Prompts in files** - create from templates, save in `.claude/gemini-orchestrator/prompts/`
5. ✅ **Reports auto-saved** - check `.claude/gemini-orchestrator/reports/` after delegations
6. ✅ **Memory integration** - fetch before, save after delegations

## Version History

- **v2.2.1** (2026-01-11): Clarified responsibilities (validation, Backlog.md = Orchestrator)
- **v2.2.0** (2026-01-11): Added delegate.sh script and .claude/gemini-orchestrator/ structure
- **v2.1.1** (2026-01-11): Added --yolo, static analysis, error protocol
- **v2.0.0** (2026-01-11): Transformed from agent to skill with progressive disclosure

---

**Remember:** You are the Orchestrator. Use `delegate.sh` to coordinate agents, provide rich context, let them develop during implementation, but YOU validate, YOU manage Backlog.md, and YOU make final decisions.
