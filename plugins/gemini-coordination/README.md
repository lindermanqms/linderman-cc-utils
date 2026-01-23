# Gemini Coordination Plugin

Skill for coordinating delegations to Gemini AI models (Pro and Flash) for multi-model orchestration.

## What It Does

Transforms Claude Code into a coordinator that leverages multiple AI models:

- **gemini-3-pro-preview**: Complex reasoning, planning, architecture design
- **gemini-3-flash-preview**: Code implementation, refactoring, bug fixes
- **Claude Code (Orchestrator)**: Final validation, testing, project management

**Core Principle**: Coordinate, don't code. Delegate everything to appropriate models, then validate results.

## Installation

### Prerequisites

1. **Install gemini-cli:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

2. **Configure API key:**
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   ```

Get API key: https://makersuite.google.com/app/apikey

### Activate Plugin

This plugin is registered in the `linderman-cc-utils` marketplace. The skill activates automatically when you use trigger phrases.

## Usage

### Automatic Activation

The skill activates when you use these phrases:

- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "coordinate with gemini"
- "orchestrate with gemini"
- "gemini-cli"

### Quick Example

```bash
# 1. Create prompt inline (no external templates)
cat > .claude/gemini-coordination/prompts/task-10.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication

You are Gemini-3-Flash, expert TypeScript developer.

## Task Description
Implement JWT authentication with login and refresh tokens.

### Acceptance Criteria
- [ ] Generate JWT tokens on login
- [ ] Validate tokens on protected routes
- [ ] Handle token refresh

[See references/prompt-templates.md for complete template]
EOF

# 2. Execute directly via gemini-cli
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-10.txt)" \
  2>&1 | tee .claude/gemini-coordination/reports/flash-$(date +%Y%m%d-%H%M).md
```

## Documentation

The skill uses **progressive disclosure** - detailed content loaded on demand.

### Skill Structure

- **SKILL.md**: Core skill (overview, workflow, critical reminders)
- **references/**: Detailed documentation
  - `prompt-templates.md` - Complete Flash and Pro templates
  - `delegation-guide.md` - When and how to delegate
  - `validation-protocol.md` - Validation procedures
  - `troubleshooting.md` - Common issues and solutions
- **examples/**: Working examples
  - `simple-delegation.md` - Single-task workflow
  - `complex-orchestration.md` - Multi-phase (Pro→Flash) workflow

## Key Features

✅ **Zero external dependencies** - No scripts, no template files
✅ **Direct execution** - Execute via `gemini --approval-mode yolo`
✅ **Inline prompt creation** - Use heredoc, no file copying
✅ **Progressive disclosure** - Templates in references/
✅ **Simplified workflow** - Clear three-step process

## Workflow

1. **Create prompt** - Inline using heredoc (consult `prompt-templates.md`)
2. **Execute delegation** - Direct gemini-cli invocation
3. **Validate results** - Orchestrator reviews, tests, approves

## Model Selection

**Use gemini-3-pro-preview for:**
- System design and architecture
- Complex problem analysis
- Trade-off evaluation
- Requirements breakdown

**Use gemini-3-flash-preview for:**
- Feature implementation
- Code refactoring
- Bug fixes
- Test writing

## Version

**v1.0.0** (2026-01-23) - Initial release

## Differences from gemini-orchestrator

| Aspect | gemini-orchestrator | gemini-coordination |
|---------|---------------------|---------------------|
| Scripts | `delegate.sh` (problematic) | ❌ None |
| Templates | `TEMPLATE-*.txt` files | ❌ None |
| Templates location | `templates/` (external) | ✅ `references/prompt-templates.md` |
| Complexity | Basic Memory integrated | ✅ Simplified |
| Path discovery | ❌ Issues | ✅ None (no external files) |

## License

Part of linderman-cc-utils plugin marketplace.
