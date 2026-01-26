# Prompt Templates

Complete prompt templates for Gemini delegations. Create prompts inline using these templates as reference.

## Step 1: Select and Inject Persona

Before using the templates below, select the appropriate persona for your task:

**Quick Persona Selection:**

| Task Type | Primary Persona | Model |
|-----------|-----------------|-------|
| React/Vue/Angular components | frontend-dev | Flash |
| Node.js/Python/Rust APIs | backend-dev | Flash |
| System architecture design | architect | Pro |
| Security review/vulnerability | security-expert | Pro |
| Database schema/optimization | database-specialist | Pro/Flash* |
| Test implementation | test-engineer | Flash |
| CI/CD/infrastructure | devops-engineer | Pro/Flash* |
| Performance optimization | performance-engineer | Pro |

*Use Pro for design/planning, Flash for implementation

**For complete persona definitions:** See `references/persona-library.md`

**After selecting persona:**
1. Copy the **Prompt Injection Template** from the persona's library entry
2. Replace the generic "You are Gemini..." line in the templates below
3. Include the **Context Collection Protocol** from the persona

## Flash Implementation Template

Use for coding, implementation, refactoring, and bug fixes.

**Before using:** Select and inject the appropriate persona (see Step 1 above)

```markdown
# IMPLEMENTATION TASK - [Task Title]

You are gemini-3-flash-preview, **[Persona Name]** ([persona-id] persona).

## Task Description
[Detailed description of implementation task]

## Your Expertise
[Copy from persona library - role-specific capabilities]

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
CRITICAL: You DO NOT have access to the coordinator's context. You MUST explicitly collect context before implementation.

Execute these commands before implementing:
```bash
cat CLAUDE.md
cat [relevant files from project]
cat package.json  # or: pyproject.toml, Cargo.toml
cat [existing implementation files]
```

### Phase 2: Research (IF specified in persona protocol)
For this task, research:
- [Specific topics from persona protocol]
- Official documentation: [URLs from persona protocol]

Use web search to find:
1. Latest best practices for [topics]
2. Official documentation for [libraries/frameworks]
3. Common patterns for [use case]

**IMPORTANT: When Phase 2 is included in the protocol, web search is MANDATORY.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project coding standards
- [ ] Existing patterns to follow
- [ ] Files allowed/forbidden to modify
- [ ] Dependencies available
- [ ] Security/performance considerations

**DO NOT proceed until Phase 1-3 complete.**

### Acceptance Criteria
- [ ] AC 1: [Description]
- [ ] AC 2: [Description]
- [ ] AC 3: [Description]

### Technical Requirements
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

## Implementation Guidelines
- Follow project coding standards
- Include error handling
- Write self-documenting code
- Add comments for complex logic

## Files to Create/Modify
- [ ] `path/to/file1.ext` - [Purpose]
- [ ] `path/to/file2.ext` - [Purpose]

## Output Requirements
For each file, provide:
1. Complete file path
2. Full code (not snippets)
3. Brief explanation of changes

---

MANDATORY PRE-REPORT REQUIREMENTS:

**Context Collection Summary (Must include in report):**

Before final report, document what context was collected:
- **Files Read:** List all files read with brief summaries
- **Research Completed:** Key findings from web search (if Phase 2 was specified)
- **Constraints Understood:** Confirm understanding of project constraints

Example:
```markdown
## Context Collection Summary
**Files Read:**
- CLAUDE.md - Project uses TypeScript, ESLint, Prettier
- package.json - React 18, Tailwind CSS, react-hook-form available
- src/components/LoginForm.tsx - Existing login form pattern

**Research Completed:**
- React Hook Form: useForm, register with validation schema
- Zod: z.object() with z.string().email() for validation
- Tailwind forms: responsive grid patterns, form plugin

**Constraints Understood:**
- ✅ TypeScript strict mode enabled
- ✅ Tailwind CSS configured with form plugin
- ✅ React Hook Form available, install Zod if missing
- ✅ Files allowed: src/components/, src/lib/
```

1. **Static Code Analysis**
   Run linting/type checking before final report:
   ```bash
   # TypeScript/JavaScript
   npm run lint && npm run typecheck

   # Python
   ruff check . && mypy .

   # Rust
   cargo clippy
   ```

2. **Error Retry Protocol**
   If static analysis fails:
   - Attempt 1: Auto-fix (e.g., `npm run lint -- --fix`)
   - Attempt 2: Fix specific errors manually
   - Attempt 3: Document difficulties in report

3. **Limitations**
   - ❌ NEVER delete files (mark for cleanup)
   - ❌ NEVER remove packages
   - ❌ NEVER run final validation (Orchestrator's responsibility)

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Implementation Summary
[Concise summary of what was implemented]

## Files Modified
- `path/to/file1.ext` - [description]
- `path/to/file2.ext` - [description]

## Changes Made
[Description of changes in each file/component]

## Static Analysis Results
✅ PASSED - All linting and type checking passed
(or)
❌ FAILED - [details after 3 attempts]

## Testing Performed
[Tests executed and results]

## Results
**Achievements**:
- [x] AC 1: Completed
- [x] AC 2: Completed
- [ ] AC 3: Partial (explain)

## Issues Found
[Any problems encountered]

=== END REPORT ===
```

## Pro Planning Template

Use for system design, architecture, planning, and analysis.

**Before using:** Select and inject the appropriate persona (see Step 1 above - typically architect, security-expert, database-specialist, or performance-engineer)

```markdown
# PLANNING TASK - [Task Title]

IMPORTANT: This is a PLANNING task (NOT implementation).

You are gemini-3-pro-preview, **[Persona Name]** ([persona-id] persona).

## Your Expertise
[Copy from persona library - role-specific capabilities]

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
CRITICAL: You DO NOT have access to the coordinator's context. You MUST explicitly collect context before planning.

Execute these commands before planning:
```bash
cat CLAUDE.md
cat [architecture docs, design docs]
cat [existing implementation files]
cat package.json  # or: pyproject.toml, Cargo.toml
```

### Phase 2: Research (IF specified in persona protocol)
For this task, research:
- [Specific topics from persona protocol]
- Official documentation: [URLs from persona protocol]

Use web search to find:
1. Latest best practices for [topics]
2. Official documentation for [libraries/frameworks]
3. Common patterns for [use case]

**IMPORTANT: When Phase 2 is included in the protocol, web search is MANDATORY.**

### Phase 3: Understand Constraints
Before planning, confirm:
- [ ] Project architecture and patterns
- [ ] Technology stack constraints
- [ ] Scale/performance requirements
- [ ] Budget and timeline constraints
- [ ] Security/compliance requirements

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
[Detailed description of planning task]

### Requirements
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

### Analysis Required
1. [Aspect 1 to analyze]
2. [Aspect 2 to analyze]
3. [Aspect 3 to analyze]

## Output Requirements

Provide structured reasoning with:

1. **Analysis** - Detailed problem/domain analysis
2. **Decisions** - Decisions made with justification
3. **Trade-offs** - Trade-offs analyzed with pros and cons
4. **Alternatives Considered** - Alternatives evaluated and why rejected
5. **Risks & Mitigations** - Risks identified and mitigation strategies
6. **Recommendations** - Specific recommendations
7. **Next Steps** - Next steps for implementation

**Context Collection Summary (Must include in report):**

Before final report, document what context was collected:
- **Files Read:** List all files read with brief summaries
- **Research Completed:** Key findings from web search (if Phase 2 was specified)
- **Constraints Understood:** Confirm understanding of project constraints

Example:
```markdown
## Context Collection Summary
**Files Read:**
- CLAUDE.md - Project architecture patterns and standards
- docs/architecture.md - Current system architecture
- package.json - Technology stack and dependencies

**Research Completed:**
- Architecture patterns: Microservices patterns, event-driven design
- Technology comparisons: PostgreSQL vs MongoDB for use case
- Scalability approaches: Horizontal scaling, caching strategies

**Constraints Understood:**
- ✅ Current: Monolithic architecture
- ✅ Scale: 10k users, 1M requests/day
- ✅ Budget: $500/month infrastructure
- ✅ Timeline: Migration in 3 months
```

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Context Collection Summary
[Your context collection summary as per template above]

## Analysis
[Detailed analysis of the problem/domain]

## Decisions
[Decisions made with full rationale]

## Trade-offs
[Trade-offs analyzed with pros and cons]

## Alternatives Considered
[Alternatives evaluated and why rejected]

## Risks & Mitigations
[Risks identified and mitigation strategies]

## Recommendations
[Specific recommendations with priorities]

## Next Steps
[Suggested next steps for implementation]

=== END REPORT ===
```

## Creating Prompts Inline

Always create prompts inline using heredoc (no external template files):

### Example: Flash Implementation

```bash
cat > .claude/gemini-coordination/prompts/task-10-jwt-auth.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication

You are Gemini-3-Flash, expert TypeScript developer.

## Task Description
Implement JWT authentication for the application.

### Acceptance Criteria
- [ ] Generate JWT tokens on login
- [ ] Validate tokens on protected routes
- [ ] Handle token refresh
- [ ] Secure token storage

### Technical Requirements
1. Use jsonwebtoken library
2. Token expiry: 15 minutes
3. Refresh token: 7 days

[... rest of Flash template ...]
EOF
```

### Example: Pro Planning

```bash
cat > .claude/gemini-coordination/prompts/task-15-api-design.txt <<'EOF'
# PLANNING TASK - API Layer Design

IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, expert in system architecture.

## Task Description
Design complete API layer for the application.

### Requirements
1. RESTful endpoints for all entities
2. Authentication and authorization
3. Rate limiting and caching

### Analysis Required
1. Endpoint design and organization
2. Authentication flow
3. Caching strategy

[... rest of Pro template ...]
EOF
```

## Execution Commands

Execute prompts directly via gemini-cli:

```bash
# Flash implementation
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-ID.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Pro planning
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-ID.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

## Template Customization

Customize templates for your project:

1. **Add project-specific sections** (e.g., "Database Schema", "API Contracts")
2. **Include reference URLs** (documentation, examples)
3. **Specify file restrictions** (allowed/forbidden files)
4. **Add domain-specific guidelines** (security policies, performance requirements)

## Best Practices

1. **Be specific** - Clear, detailed task descriptions
2. **Define ACs** - Testable acceptance criteria
3. **Provide context** - Paste relevant code/docs in prompt
4. **Set boundaries** - Specify allowed/forbidden operations
5. **Reference docs** - Include URLs to official documentation
