# Delegation Guide

Comprehensive guide for effective delegation to Gemini models.

## When to Delegate

**Delegate when:**
- User explicitly requests: "Delegate to gemini", "Use gemini for"
- Task requires specialized AI reasoning (Pro) or coding (Flash)
- Task is complex or time-consuming
- Multiple approaches possible (design decisions needed)

**Don't delegate when:**
- Simple, quick tasks (file edits, minor fixes)
- User explicitly says "do it yourself"
- Tasks requiring human judgment/creativity only

## Model Selection

### gemini-3-pro-preview (Reasoning Model)

**Use for:**
- System design and architecture
- Complex problem analysis and diagnosis
- Trade-off evaluation
- Requirements breakdown
- Technical planning and strategy
- Security review and risk assessment

**Characteristics:**
- Strong analytical reasoning
- Good at explaining trade-offs
- Structured thinking
- Risk identification

**Example tasks:**
- "Design authentication system for multi-tenant SaaS"
- "Analyze performance bottlenecks in current architecture"
- "Evaluate NoSQL vs SQL for this use case"

### gemini-3-flash-preview (Implementation Model)

**Use for:**
- Feature implementation
- Code refactoring
- Bug fixes
- Test writing
- Documentation generation
- Database migrations
- API endpoint creation

**Characteristics:**
- Fast code generation
- Good at following patterns
- Efficient implementation
- Practical solutions

**Example tasks:**
- "Implement JWT authentication with refresh tokens"
- "Refactor user service to use dependency injection"
- "Fix race condition in order processing"

## Providing Context

**Essential context to include:**

1. **Project Standards**
   ```markdown
   ## Project Context
   - Language: TypeScript 5.3+
   - Framework: Express.js 4.18
   - Style: Airbnb style guide
   - Testing: Jest + supertest
   ```

2. **Relevant Code**
   ```markdown
   ## Existing Code
   [Paste current implementation that needs modification]
   ```

3. **Architecture/Design Decisions**
   ```markdown
   ## Design Context (if from Pro)
   [Paste Pro's analysis and recommendations]
   ```

4. **Technical References**
   ```markdown
   ## References
   - Official docs: https://example.com/docs
   - Similar implementation: https://github.com/example
   ```

## Structuring Prompts

### Effective Prompt Structure

1. **Clear Task Title**
   ```markdown
   # IMPLEMENTATION TASK - JWT Authentication Service
   ```

2. **Role Definition**
   ```markdown
   You are Gemini-3-Flash, expert Node.js/TypeScript developer.
   ```

3. **Detailed Description**
   ```markdown
   ## Task Description
   Implement a JWT authentication service with:
   - Login endpoint
   - Token validation middleware
   - Refresh token rotation
   ```

4. **Acceptance Criteria**
   ```markdown
   ### Acceptance Criteria
   - [ ] Login returns access token (15min expiry)
   - [ ] Refresh token valid for 7 days
   - [ ] Middleware validates Authorization header
   - [ ] Returns 401 for invalid tokens
   ```

5. **Technical Requirements**
   ```markdown
   ### Technical Requirements
   1. Use jsonwebtoken library
   2. Store refresh tokens in database
   3. Use HTTP-only cookies for tokens
   4. Log all authentication events
   ```

6. **File Structure**
   ```markdown
   ### Files to Create
   - `src/auth/jwt.service.ts` - JWT generation/validation
   - `src/auth/middleware.ts` - Express middleware
   - `src/auth/routes.ts` - Authentication endpoints
   - `tests/auth.test.ts` - Unit tests
   ```

## Multi-Phase Orchestration

For complex tasks requiring both planning and implementation:

### Phase 1: Planning (Pro)

```bash
# Create planning prompt
cat > .claude/gemini-coordination/prompts/task-design.txt <<'EOF'
# PLANNING TASK - API Architecture Design

[Pro template content...]
EOF

# Execute Pro delegation
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-design.txt)" \
  2>&1 | tee .claude/gemini-coordination/reports/pro-design.md
```

### Phase 2: Implementation (Flash)

```bash
# Create implementation prompt with Pro's design
cat > .claude/gemini-coordination/prompts/task-implementation.txt <<'EOF'
# IMPLEMENTATION TASK - API Implementation

## Design Context (from Pro)
[Paste relevant sections from pro-design.md]

[Flash template content...]
EOF

# Execute Flash delegation
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-implementation.txt)" \
  2>&1 | tee .claude/gemini-coordination/reports/flash-implementation.md
```

### Phase 3: Validation (Orchestrator)

```bash
# Review reports
cat .claude/gemini-coordination/reports/pro-design.md
cat .claude/gemini-coordination/reports/flash-implementation.md

# Final validation
npm run build
npm test
npm start &
```

## Common Delegation Patterns

### Pattern 1: Simple Implementation

```bash
# Single Flash delegation
# Use for: straightforward features, bug fixes, refactoring

cat > prompts/task.txt <<'EOF'
[Flash template...]
EOF

gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat prompts/task.txt)" \
  2>&1 | tee reports/flash-result.md
```

### Pattern 2: Design → Implement

```bash
# Pro → Flash delegation
# Use for: new features, architectural changes, complex systems

# Phase 1: Pro design
cat > prompts/task-design.txt <<'EOF'
[Pro template...]
EOF

gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat prompts/task-design.txt)" | tee reports/pro-design.md

# Phase 2: Flash implementation (with Pro's design)
cat > prompts/task-impl.txt <<'EOF'
## Design from Pro
[Content from pro-design.md]

[Flash template...]
EOF

gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat prompts/task-impl.txt)" | tee reports/flash-impl.md
```

### Pattern 3: Problem Resolution

```bash
# Pro diagnosis → Flash fix
# Use for: debugging, complex errors, performance issues

# Phase 1: Pro analysis
cat > prompts/task-diagnosis.txt <<'EOF'
# PROBLEM RESOLUTION TASK - Diagnose Error

ERROR: [Error message/logs]
CONTEXT: [When it happens, symptoms]

[Pro template for diagnosis...]
EOF

gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat prompts/task-diagnosis.txt)" | tee reports/pro-diagnosis.md

# Phase 2: Flash fix
cat > prompts/task-fix.txt <<'EOF'
## Root Cause (from Pro)
[Content from pro-diagnosis.md]

[Flash template for fix...]
EOF

gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat prompts/task-fix.txt)" | tee reports/flash-fix.md
```

## Tips for Effective Delegation

1. **Be Specific** - Clear requirements, clear acceptance criteria
2. **Provide Context** - Relevant code, architecture, constraints
3. **Set Boundaries** - Allowed/forbidden files and operations
4. **Reference Docs** - Include URLs to official documentation
5. **Review Reports** - Always review generated reports before validation
6. **Iterate** - If results aren't satisfactory, refine prompt and delegate again

## Troubleshooting

See `troubleshooting.md` for:
- gemini-cli installation issues
- API key configuration
- Prompt length limits
- Common delegation failures
