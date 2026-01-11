# Context Provision

Providing comprehensive context is **CRITICAL** for successful Gemini delegations. This guide explains what context to provide and how to pass it to Gemini models.

## Types of Context

### 1. Project Documentation

**What**: Files that define project standards, conventions, and architecture.

**Examples**:
- `CLAUDE.md` - Project-specific instructions for AI
- `README.md` - Project overview, setup, usage
- `CONTRIBUTING.md` - Development guidelines
- `docs/architecture.md` - System design documents
- `.backlog` files - Specs and requirements

**Why**: Ensures Gemini respects project conventions and coding standards.

### 2. Reference URLs

**What**: External documentation, API references, tutorials.

**Examples**:
- `https://jwt.io/introduction` - JWT documentation
- `https://expressjs.com/en/guide/routing.html` - Express.js guides
- `https://docs.python.org/3/library/asyncio.html` - Python asyncio docs
- Framework documentation for libraries being used

**Why**: Provides authoritative technical knowledge that Gemini can reference.

### 3. Existing Code

**What**: Files that Gemini needs to understand or modify.

**Examples**:
- Current implementation to be refactored
- Similar patterns in the codebase (from Explore)
- Related modules that will interact with new code
- Test files showing expected behavior

**Why**: Helps Gemini understand existing patterns and maintain consistency.

### 4. Project Patterns

**What**: Conventions, architectural decisions, recurring solutions.

**Examples**:
- Error handling patterns
- API response formats
- Database query structures
- Naming conventions
- Directory organization

**Why**: Ensures new code follows established patterns.

### 5. Acceptance Criteria

**What**: Specific requirements the solution must meet.

**Examples**:
- From Backlog.md specs (if using spec-workflow)
- User requirements from the original request
- Performance requirements
- Security requirements
- Edge cases to handle

**Why**: Provides clear success criteria for validation.

## How to Provide Context

### Method 1: Via stdin (Recommended for Files)

Pass file content directly to Gemini via stdin:

```bash
# Single file
cat CLAUDE.md | gemini -p "
TASK: Implement authentication

PROJECT CONTEXT (from stdin above):
Review the project standards and implement JWT auth following those conventions.
" --model gemini-3-flash-preview

# Multiple files
cat CLAUDE.md README.md | gemini -p "
TASK: Design API structure

PROJECT CONTEXT (from stdin above):
Review project documentation and design RESTful API following conventions.
" --model gemini-3-pro-preview
```

### Method 2: Via Shell Variables

Capture content in variables for reusable context:

```bash
# Capture context
PROJECT_DOCS=$(cat CLAUDE.md)
EXISTING_CODE=$(cat src/auth/service.ts)

# Use in prompt
gemini -p "
PROJECT CONTEXT:
${PROJECT_DOCS}

EXISTING CODE TO REFACTOR:
\`\`\`typescript
${EXISTING_CODE}
\`\`\`

TASK: Refactor authentication service to use dependency injection
" --model gemini-3-flash-preview
```

### Method 3: Inline in Prompt

Include URLs and short context directly in the prompt:

```bash
gemini -p "
TECHNICAL REFERENCES:
- JWT spec: https://jwt.io/introduction
- Express middleware: https://expressjs.com/en/guide/using-middleware.html

PROJECT CONVENTIONS:
- Use async/await (no callbacks)
- Error handling via custom AppError class
- All endpoints return { success, data/error }

TASK: Implement JWT authentication middleware
" --model gemini-3-flash-preview
```

### Method 4: From Memory (Auto-Fetch)

Include knowledge from Basic Memory:

```bash
# Fetch from memory
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
MEMORY_PATTERNS=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} auth patterns jwt"
}))

# Include in delegation
cat CLAUDE.md | gemini -p "
MEMORY CONTEXT (Previous Learnings):
${MEMORY_PATTERNS}

PROJECT CONTEXT (from stdin):
(CLAUDE.md content)

TASK: Implement JWT authentication using patterns from memory
" --model gemini-3-flash-preview
```

## Best Practices

### ✅ DO

1. **Always include CLAUDE.md** - Project standards are critical
2. **Provide examples** - Show existing code patterns from Explore
3. **Include URLs** - Link to authoritative documentation
4. **Be explicit** - Don't assume Gemini knows your conventions
5. **Pass Acceptance Criteria** - Clear success metrics
6. **Use Memory** - Include relevant patterns/decisions from previous work
7. **Provide full context** - Better too much than too little
8. **Structure prompts** - Use clear sections (CONTEXT, TASK, OUTPUT)

### ❌ DON'T

1. **Assume knowledge** - Don't rely on Gemini's training data for project-specific patterns
2. **Omit context** - "Just implement auth" without standards → inconsistent code
3. **Use relative references** - "Follow the pattern in that file" → specify which file
4. **Skip URLs** - "Use JWT" → include https://jwt.io/introduction
5. **Provide too little** - Minimal context → suboptimal solutions
6. **Forget Memory** - Missing previous decisions → reinventing the wheel

## Context Construction Pattern

**Recommended structure for all delegations**:

```bash
# 1. Extract project slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# 2. Fetch from Memory (if available)
MEMORY_CONTEXT=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} {domain} patterns"
}))

# 3. Read project docs
PROJECT_DOCS=$(cat CLAUDE.md)

# 4. Get existing code (from Explore if needed)
EXISTING_CODE=$(cat src/relevant/file.ts)

# 5. Construct full context
FULL_CONTEXT="
=== MEMORY CONTEXT (Previous Learnings) ===
${MEMORY_CONTEXT}

=== PROJECT CONTEXT ===
${PROJECT_DOCS}

=== EXISTING CODE ===
\`\`\`typescript
${EXISTING_CODE}
\`\`\`

=== TECHNICAL REFERENCES ===
- Relevant URL 1
- Relevant URL 2

=== ACCEPTANCE CRITERIA ===
- [ ] AC 1
- [ ] AC 2
"

# 6. Execute delegation
gemini -p "
${FULL_CONTEXT}

TASK: [specific task]

OUTPUT: [expected format]
" --model [appropriate-model]
```

## Example: Complete Context for Authentication Task

```bash
#!/bin/bash

# Extract project slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# Fetch auth patterns from memory
MEMORY=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} auth patterns jwt"
}))

# Construct delegation
cat CLAUDE.md | gemini -p "
=== MEMORY CONTEXT ===
${MEMORY}

Found previous decisions:
- Use JWT with refresh tokens
- Store in httpOnly cookies (not localStorage)
- 15min access token, 7day refresh token

=== PROJECT CONTEXT (stdin above) ===
Project standards from CLAUDE.md

=== TECHNICAL REFERENCES ===
- JWT Introduction: https://jwt.io/introduction
- Express JWT Middleware: https://github.com/auth0/express-jwt
- Refresh Token Best Practices: https://auth0.com/blog/refresh-tokens-what-are-they-and-when-to-use-them/

=== ACCEPTANCE CRITERIA (from SPEC-010-auth.backlog) ===
- [ ] User can login with email/password
- [ ] Access token expires after 15 minutes
- [ ] Refresh token automatically renews access token
- [ ] Logout invalidates both tokens
- [ ] Tokens stored in httpOnly cookies

TASK: Implement complete JWT authentication system

OUTPUT:
- src/auth/service.ts - Authentication service
- src/auth/middleware.ts - JWT verification middleware
- src/auth/routes.ts - Login/logout/refresh endpoints
- tests/auth.test.ts - Comprehensive tests
" --model gemini-3-flash-preview
```

## Common Pitfalls

### Pitfall 1: Insufficient Context

❌ **Bad**:
```bash
gemini -p "Implement JWT auth" --model gemini-3-flash-preview
```

✅ **Good**:
```bash
cat CLAUDE.md | gemini -p "
PROJECT CONTEXT (stdin): CLAUDE.md standards

TECHNICAL REFERENCES:
- https://jwt.io/introduction

REQUIREMENTS:
- 15min access, 7day refresh
- httpOnly cookies
- Auto-renewal on refresh

TASK: Implement JWT auth following project standards
" --model gemini-3-flash-preview
```

### Pitfall 2: Missing URLs

❌ **Bad**:
```bash
gemini -p "Use React Query for data fetching" --model gemini-3-flash-preview
```

✅ **Good**:
```bash
gemini -p "
TECHNICAL REFERENCES:
- React Query Docs: https://tanstack.com/query/latest/docs/react/overview

TASK: Implement data fetching using React Query
" --model gemini-3-flash-preview
```

### Pitfall 3: Ignoring Memory

❌ **Bad**:
```bash
# Not checking if we already solved this
gemini -p "Fix port 3000 already in use error" --model gemini-3-pro-preview
```

✅ **Good**:
```bash
# Check memory first
KNOWN_ERROR=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} error port 3000"
}))

if [ -n "$KNOWN_ERROR" ]; then
  # Use known solution
  echo "Found previous solution: $KNOWN_ERROR"
else
  # Delegate to Pro for diagnosis
  gemini -p "PROBLEM RESOLUTION task: diagnose port 3000 conflict" --model gemini-3-pro-preview
fi
```

## Advanced: Multi-Step Context Accumulation

For complex orchestrations, accumulate context across steps:

```bash
# Step 1: Explore codebase
EXPLORE_RESULTS=$(invoke Explore agent)

# Step 2: Pro designs with Explore context
PRO_DESIGN=$(gemini -p "
CODEBASE ANALYSIS:
${EXPLORE_RESULTS}

TASK: Design API layer
" --model gemini-3-pro-preview)

# Step 3: Flash implements with Pro design + Explore context
cat CLAUDE.md | gemini -p "
PROJECT CONTEXT (stdin): CLAUDE.md

CODEBASE ANALYSIS:
${EXPLORE_RESULTS}

ARCHITECTURE (from Pro):
${PRO_DESIGN}

TASK: Implement API based on design
" --model gemini-3-flash-preview
```

This pattern ensures each step builds on previous knowledge.
