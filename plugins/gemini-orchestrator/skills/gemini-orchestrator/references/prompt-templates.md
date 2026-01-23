# Prompt Templates

Complete prompt templates for delegating to Gemini models. Create prompt files directly in `.claude/gemini-orchestrator/prompts/` using these templates.

## Template: Flash Implementation

Use this template for implementation tasks (coding, refactoring, bug fixes).

```markdown
# IMPLEMENTATION TASK - [Task Title]

You are Gemini-3-Flash, expert [language/framework] developer.

## PROJECT CONTEXT

**Project Slug**: [extract via basename $(git rev-parse --show-toplevel)]

**Standards (CLAUDE.md)**:
[Paste relevant CLAUDE.md content]

**Existing Code**:
[Paste relevant files]

## MEMORY CONTEXT

**Patterns**:
[Results from search_nodes({ query: "{slug} {domain} patterns" })]

**Similar Solutions**:
[Results from search_nodes({ query: "{slug} {task-type}" })]

## DESIGN CONTEXT (if from Pro)

[Paste gemini-3-pro output with design/architecture]

## TASK DESCRIPTION

[Describe implementation task in detail]

### Acceptance Criteria

- [ ] AC 1: [description]
- [ ] AC 2: [description]
- [ ] AC 3: [description]

### Technical Requirements

1. [Technical requirement 1]
2. [Technical requirement 2]
3. [Technical requirement 3]

## IMPLEMENTATION GUIDELINES

- Follow patterns from CLAUDE.md
- Use [framework/library] version [X.Y.Z]
- Match existing code style
- Include error handling
- Write tests for critical paths

## FILES TO MODIFY/CREATE

- [ ] `path/to/file1.ts` - [What to do]
- [ ] `path/to/file2.ts` - [What to do]
- [ ] `tests/file1.test.ts` - [Test description]

## OUTPUT REQUIREMENTS

For each file, provide:
1. Full file path
2. Complete code (not snippets)
3. Brief explanation of changes

---

MANDATORY PRE-REPORT REQUIREMENTS:

1. **Static Code Analysis** - Run linting and type checking:
   ```bash
   # TypeScript/JavaScript
   npm run lint && npm run typecheck

   # Python
   ruff check . && mypy .

   # Rust
   cargo clippy && cargo fmt --check
   ```

2. **Error Retry Protocol** (if static analysis fails):
   - Attempt 1: Auto-fix (e.g., `npm run lint -- --fix`)
   - Attempt 2: Analyze and fix specific errors
   - Attempt 3: Document difficulties in report

3. **Development vs Validation**:
   - ✅ CAN run commands/servers DURING development (npm install, dev server, etc.)
   - ❌ CANNOT run final validation (final build, final tests, validation servers)
   - Final validation is Orchestrator's responsibility

4. **Limitations**:
   - ❌ NEVER delete files (mark for cleanup instead)
   - ❌ NEVER remove packages
   - ❌ NEVER use Backlog.md MCP (Orchestrator handles this)
   - ❌ NEVER run final compilation/build for validation
   - ❌ NEVER run servers for final validation
   - ✅ CAN create/edit files, run dev commands, use other MCPs

---

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT using the marker:
=== ORCHESTRATOR REPORT ===

## Implementation Summary
[Concise summary of what was implemented]

## Files Modified
- `path/to/file1.ts` - [description]
- `path/to/file2.ts` - [description]

## Changes Made
[Description of changes in each file/component]

## Static Analysis Results
✅ **PASSED** - All linting and type checking passed
(or)
❌ **FAILED** - [details after 3 attempts]

## Testing Performed
[Tests executed and results]

## Results
**Achievements**:
- [x] AC 1: Completed
- [x] AC 2: Completed
- [ ] AC 3: Partial (explain)

**Tests**:
- ✅ Unit tests: X/Y passed
- ✅ Integration tests: X/Y passed

## Issues Found
[Problems encountered, if any]
[Use Error Report format if issues remain after 3 attempts]
```

## Template: Pro Planning

Use this template for planning, design, and architectural analysis tasks.

```markdown
# PLANNING TASK - [Task Title]

IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, expert in system architecture and design.

## PROJECT CONTEXT

**Project Slug**: [extract via basename $(git rev-parse --show-toplevel)]

**Standards (CLAUDE.md)**:
[Paste relevant CLAUDE.md content]

**Existing Architecture**:
[Paste findings from Explore agent]

## MEMORY CONTEXT

**Patterns**:
[Results from search_nodes({ query: "{slug} patterns" })]

**Decisions**:
[Results from search_nodes({ query: "{slug} decisions" })]

**Domain Knowledge**:
[Results from search_nodes({ query: "{slug} {domain}" })]

## TASK DESCRIPTION

[Describe planning/design task in detail]

### Requirements

1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

### Acceptance Criteria (from Spec)

- [ ] AC 1: [description]
- [ ] AC 2: [description]
- [ ] AC 3: [description]

### Constraints

- [Constraint 1]
- [Constraint 2]

## ANALYSIS REQUIRED

1. [Aspect to analyze 1]
2. [Aspect to analyze 2]
3. [Aspect to analyze 3]

## OUTPUT REQUIREMENTS

Provide structured reasoning with:

1. **Analysis** - Detailed problem/domain analysis
2. **Decisions** - Decisions made with justification
3. **Trade-offs** - Trade-offs analyzed with pros and cons
4. **Alternatives Considered** - Alternatives evaluated and why rejected
5. **Risks & Mitigations** - Risks identified and mitigation strategies
6. **Recommendations** - Specific recommendations
7. **Next Steps** - Next steps for implementation

---

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT using the marker:
=== ORCHESTRATOR REPORT ===

[7 sections as listed above]
```

## Creating Prompt Files Inline

Instead of copying external templates, create prompt files directly using cat heredoc:

### Example: Flash Implementation Prompt

```bash
cat > .claude/gemini-orchestrator/prompts/task-10-jwt-auth.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication

You are Gemini-3-Flash, expert TypeScript developer.

## PROJECT CONTEXT

**Project Slug**: my-project

**Standards (CLAUDE.md)**:
- Use TypeScript strict mode
- Follow existing auth patterns
- Include error handling

**Existing Code**:
[paste relevant auth files]

## MEMORY CONTEXT

**Patterns**:
- pattern-chrome-extension-storage
- pattern-jwt-cookies

## TASK DESCRIPTION

Implement JWT authentication for Chrome extension.

### Acceptance Criteria

- [ ] Generate JWT tokens on login
- [ ] Store tokens securely in chrome.storage.local
- [ ] Validate tokens on protected routes
- [ ] Handle token refresh

### Technical Requirements

1. Use jsonwebtoken library
2. Token expiry: 15 minutes
3. Refresh token: 7 days
4. Secure storage only

## IMPLEMENTATION GUIDELINES

- Follow CLAUDE.md patterns
- Use chrome.storage.local API
- Include error handling
- Write unit tests

## FILES TO MODIFY/CREATE

- [ ] `src/auth/jwt.service.ts` - JWT service
- [ ] `src/auth/storage.ts` - Secure storage
- [ ] `tests/auth/jwt.test.ts` - Unit tests

## OUTPUT REQUIREMENTS

For each file, provide:
1. Full file path
2. Complete code
3. Brief explanation

---

[... rest of mandatory requirements ...]

EOF
```

### Example: Pro Planning Prompt

```bash
cat > .claude/gemini-orchestrator/prompts/task-15-api-design.txt <<'EOF'
# PLANNING TASK - API Layer Design

IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, expert in system architecture and design.

## PROJECT CONTEXT

**Project Slug**: my-project

**Standards (CLAUDE.md)**:
- RESTful API design
- JWT authentication
- OpenAPI 3.0 documentation

**Existing Architecture**:
[paste Explore agent findings]

## MEMORY CONTEXT

**Patterns**:
- pattern-rest-api-versioning
- decision-auth-strategy

**Decisions**:
- Use JWT tokens (not sessions)
- API versioning via URL path

## TASK DESCRIPTION

Design complete API layer for the application.

### Requirements

1. RESTful endpoints for all entities
2. Authentication and authorization
3. Rate limiting and caching
4. Error handling and logging

### Acceptance Criteria

- [ ] All endpoints documented in OpenAPI
- [ ] Authentication flow designed
- [ ] Rate limiting strategy defined
- [ ] Caching strategy defined

### Constraints

- Must work with existing database schema
- Must support future mobile app
- Performance: < 100ms response time

## ANALYSIS REQUIRED

1. Endpoint design and organization
2. Authentication and authorization flow
3. Rate limiting and caching strategies
4. Error handling and logging approach

## OUTPUT REQUIREMENTS

[... 7 sections as per template ...]

EOF
```

## Usage with gemini-cli

Execute the prompt file directly:

```bash
# Flash implementation
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-10-jwt-auth.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Pro planning
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
REPORT_FILE=".claude/gemini-orchestrator/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-orchestrator/prompts/task-15-api-design.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

## Template Customization

Customize templates for your project by:

1. **Adding project-specific sections** (e.g., "Database Schema", "API Contracts")
2. **Including reference URLs** (documentation, examples)
3. **Specifying allowed/forbidden files** (critical for spec-workflow integration)
4. **Adding domain-specific guidelines** (e.g., security policies, performance requirements)

### Example: Adding File Restrictions (spec-workflow)

```markdown
## 📁 ARQUIVOS PERMITIDOS:
- src/auth/models/user.ts
- src/auth/services/auth.service.ts
- src/auth/controllers/auth.controller.ts

## 🚫 ARQUIVOS PROIBIDOS:
- src/main.ts (CRÍTICO - aplicação principal)
- src/config/database.ts (CRÍTICO - configuração DB)
- package.json (usar npm install, não editar diretamente)
```

## Best Practices

1. **Always provide memory context** - Search Basic Memory before creating prompts
2. **Include relevant code** - Paste existing files the agent needs to understand
3. **Be specific with ACs** - Clear, testable acceptance criteria
4. **Specify file operations** - List exactly which files to create/modify
5. **Reference documentation** - Include URLs to official docs, examples
6. **Set clear boundaries** - Specify allowed/forbidden operations
7. **Use file restrictions** - Critical when using spec-workflow to prevent conflicts

## Related Resources

- `delegation-strategy.md` - When to use Pro vs Flash
- `context-provision.md` - How to gather and provide context
- `workflow-patterns.md` - Orchestration patterns
- `spec-workflow-integration.md` - Integration with Backlog.md
