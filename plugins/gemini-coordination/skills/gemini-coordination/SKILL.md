---
name: gemini-coordination
description: This skill should be used when the user asks to "delegate to gemini", "use gemini for", "let gemini handle", "coordinate with gemini", "orchestrate with gemini", mentions "gemini-cli", or needs to leverage Gemini models for complex reasoning, planning, or implementation tasks requiring coordination between multiple AI models. Execute directly via gemini CLI with --approval-mode yolo for headless automation.
version: 2.0.0
---

# Gemini Coordination Skill

## Overview

Transform Claude Code into a coordinator that leverages multiple AI models for optimal task execution:

- **gemini-3-pro-preview**: Complex reasoning, planning, architecture design, problem analysis
- **gemini-3-flash-preview**: Code implementation, refactoring, bug fixes
- **Claude Code (Orchestrator)**: Final validation, testing, project management

**Core Principle**: Coordinate, don't code. Delegate everything to appropriate models, validate results.

## When to Use This Skill

Use when the user explicitly requests Gemini model delegation:
- "Delegate to gemini: [task]"
- "Use gemini for [task]"
- "Let gemini handle [task]"
- "Coordinate with gemini: [task]"
- Mentions "gemini-cli" in context

## Model Selection Guide

### ⚡ Default: gemini-3-flash-preview (Use 90% of the time)

**Use Flash for MOST tasks:**
- ✅ Feature implementation
- ✅ Code refactoring
- ✅ Bug fixes (even complex ones)
- ✅ Test writing
- ✅ Documentation generation
- ✅ Code exploration and analysis
- ✅ Simple corrections
- ✅ Straightforward tasks
- ✅ **When in doubt → Use Flash**

### 🎯 Exception: gemini-3-pro-preview (Use only when essential)

**Use Pro ONLY for:**
- ⚠️ System design and architecture decisions
- ⚠️ Complex problem analysis requiring deep reasoning
- ⚠️ Trade-off evaluation for major decisions
- ⚠️ Requirements breakdown for large features
- ⚠️ Strategic technical planning

**DO NOT use Pro for:**
- ❌ Regular bug fixes (use Flash)
- ❌ Code implementation (use Flash)
- ❌ Error diagnosis (use Flash first)
- ❌ Code exploration (use Flash)
- ❌ Simple analysis (use Flash)

## Standard Workflow

Follow this three-step workflow for all delegations:

### Step 1: Create Prompt File

Create prompt file inline using heredoc (no external templates):

```bash
# Create directory structure
mkdir -p .claude/gemini-coordination/{prompts,reports}

# Create prompt file
cat > .claude/gemini-coordination/prompts/task-ID-description.txt <<'EOF'
# Task: [Task Title]

You are Gemini-3-[Pro|Flash], expert in [domain].

## Task Description
[Detailed task description]

### Acceptance Criteria
- [ ] AC 1: [Description]
- [ ] AC 2: [Description]

### Technical Requirements
1. [Requirement 1]
2. [Requirement 2]

[See references/prompt-templates.md for complete template structure]
EOF
```

### Step 2: Execute Delegation

Execute directly via gemini-cli (no wrapper scripts):

```bash
# For Flash (implementation)
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-ID-description.txt)" \
  2>&1 | tee "$REPORT_FILE"

# For Pro (planning)
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-ID-description.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### Step 3: Validate Results

After delegation completes, validate as Orchestrator:

```bash
# Review generated report
cat "$REPORT_FILE"

# Run final validation
npm run build
npm test
npm start &  # For end-to-end validation
```

## Persona-Based Delegation

The plugin includes 8 specialized personas for different task types. Using personas provides role-specific expertise, tailored context collection instructions, and domain-specific research guidelines.

### Available Personas

**Implementation Personas (Flash):**
- **frontend-dev** - React/Vue/Angular UI development, forms, validation, responsive design
- **backend-dev** - Node.js/Python/Rust API development, REST/GraphQL, authentication
- **test-engineer** - Unit/integration/E2E tests, mocking, coverage
- **database-specialist** - Database migrations, query optimization, schema changes
- **security-expert** - Secure implementation practices, vulnerability fixes
- **performance-engineer** - Performance optimization, profiling, caching
- **devops-engineer** - CI/CD pipelines, Docker/Kubernetes, infrastructure

**Planning Personas (Pro):**
- **architect** - System design, microservices vs monolith, technology choices
- **security-expert** - Security review, threat modeling, OWASP Top 10 analysis
- **database-specialist** - Database architecture design, data modeling, scalability
- **performance-engineer** - Performance analysis, bottleneck identification, optimization strategy
- **devops-engineer** - Infrastructure design, CI/CD architecture, deployment strategies

### Using Personas

1. **Select persona** based on task type and domain (see quick reference below)
2. **Copy Prompt Injection Template** from `references/persona-library.md`
3. **Include Context Collection Protocol** - Each persona has specific research instructions
4. **Execute delegation** as usual with Flash or Pro model

### Quick Persona Selection

| Task Type | Persona | Model |
|-----------|---------|-------|
| React/Vue/Angular components | frontend-dev | Flash |
| Node.js/Python/Rust APIs | backend-dev | Flash |
| System architecture design | architect | Pro |
| Security review/vulnerabilities | security-expert | Pro (analysis), Flash (fixes) |
| Database schema/optimization | database-specialist | Pro (design), Flash (migrations) |
| Test implementation | test-engineer | Flash |
| CI/CD/infrastructure | devops-engineer | Pro (design), Flash (implementation) |
| Performance optimization | performance-engineer | Pro (analysis), Flash (fixes) |

### Persona Library

Complete persona definitions with:
- **Identity** - Role, model preference, expertise level
- **Capabilities** - Specific skills and technologies
- **Context Requirements** - Files to read and research strategy
- **Prompt Injection Template** - Ready-to-use prompt structure

See `references/persona-library.md` for all 8 personas with complete templates.

### Context Collection Protocol

Every persona includes a **Context Collection Protocol** with 3 phases:

**Phase 1: Read Project Context (MANDATORY)**
- Always read CLAUDE.md, package.json, existing implementation
- Persona-specific files (e.g., Dockerfile for devops, schema.prisma for database)

**Phase 2: Research (IF specified)**
- Web search for latest best practices
- Official documentation for libraries/frameworks
- Domain-specific patterns and anti-patterns
- **IMPORTANT: When Phase 2 is included, web search is MANDATORY**

**Phase 3: Understand Constraints**
- Project coding standards
- Existing patterns to follow
- Files allowed/forbidden to modify
- Dependencies available
- Security/performance considerations

**Agents must NOT proceed until all phases complete.**

## Prompt Templates Reference

Complete prompt templates are available in `references/prompt-templates.md`:

- **Flash Implementation Template**: Full structure for coding tasks
- **Pro Planning Template**: Full structure for design/architecture tasks
- **Inline Creation Examples**: How to create prompts via heredoc
- **Execution Commands**: Direct gemini-cli invocation patterns

**Always consult prompt-templates.md before creating prompts.**

## Critical Reminders

**Orchestrator Responsibilities:**
- ✅ Create structured prompts
- ✅ Execute gemini-cli delegations
- ✅ Review and validate results
- ✅ Run final tests and validation
- ✅ Make final approval decisions

**Orchestrator NEVER:**
- ❌ Implement code directly (use Edit/Write tools)
- ❌ Perform manual bug fixes
- ❌ Write tests directly
- ❌ Skip delegation to implement

**Direct Execution Only:**
- Execute via `gemini --approval-mode yolo -p "$(cat prompt.txt)"`
- No wrapper scripts
- No external template files
- No path discovery issues

## Additional Resources

### Reference Documentation
- **`references/persona-library.md`** - Complete persona definitions with context protocols
- **`references/prompt-templates.md`** - Complete Flash and Pro templates with persona integration
- **`references/delegation-guide.md`** - When and how to delegate, persona selection guide
- **`references/validation-protocol.md`** - Validation procedures
- **`references/troubleshooting.md`** - Common issues and solutions

### Working Examples
- **`examples/simple-delegation.md`** - Single-task workflow
- **`examples/complex-orchestration.md`** - Multi-phase orchestration (Pro → Flash → Validation)

---

**Remember: Coordinate, don't code. Delegate to appropriate Gemini models, then validate results.**
