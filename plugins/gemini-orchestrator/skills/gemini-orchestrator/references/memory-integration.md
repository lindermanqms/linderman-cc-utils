# Memory Integration

Complete guide for integrating Gemini Orchestrator with Basic Memory MCP for knowledge persistence and reuse.

## Overview

Basic Memory integration enables:
- **Auto-Fetch**: Retrieve relevant knowledge before delegations
- **Auto-Save**: Persist insights after delegations
- **Namespace**: Project-specific prefixing prevents cross-project pollution
- **Knowledge Types**: ADRs, Patterns, Errors

## Ontology and Prefixation

**Project Slug**: Base identifier for all memory entities
```bash
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
# Example: linderman-cc-utils
```

**Entity Structure**:
- `{slug}/task-{id}/*` - Task-specific knowledge
- `{slug}/spec-{id}/*` - Spec-specific knowledge
- `{slug}/agents/{name}/*` - Agent knowledge
- `{slug}/global/*` - Project-wide knowledge

**Example Entities**:
```
linderman-cc-utils/global/pattern-jwt-auth
linderman-cc-utils/spec-010/decision-api-design
linderman-cc-utils/task-05/error-port-conflict
```

## Auto-Save: When and What

### 1. ADRs (Architecture Decision Records)

**When**: After gemini-3-pro delegation results in architectural decision

**Entity**: `{slug}/spec-{id}/decision-{slug}` or `{slug}/task-{id}/decision-{slug}`

**Observations**:
- Context: Why the decision was needed
- Decision: What was chosen
- Alternatives: What was rejected and why
- Consequences: Trade-offs and implications

**Example**:
```javascript
mcp__memory__create_entities({
  entities: [{
    name: "linderman-cc-utils/spec-010/decision-jwt-auth",
    entityType: "architecture-decision",
    observations: [
      "Context: PJe extensions need stateless authentication",
      "Decision: JWT with refresh tokens in httpOnly cookies",
      "Alternatives: Session cookies (rejected - CORS issues), OAuth2 (overkill)",
      "Consequences: + Stateless + Secure - Requires token rotation strategy"
    ]
  }]
})
```

### 2. Patterns (Code Patterns)

**When**: Delegation identifies reusable code pattern or solution

**Entity**: `{slug}/global/pattern-{slug}`

**Observations**:
- Pattern: Description of the pattern
- Usage: How/when to apply it
- Examples: Code snippets
- When: Situations where it's useful

**Example**:
```javascript
mcp__memory__create_entities({
  entities: [{
    name: "linderman-cc-utils/global/pattern-gemini-context",
    entityType: "code-pattern",
    observations: [
      "Pattern: Always include CLAUDE.md in Gemini delegations",
      "Usage: cat CLAUDE.md | gemini -p \"...\"",
      "When: Every gemini-3-pro and gemini-3-flash delegation",
      "Benefit: Ensures consistency with project standards"
    ]
  }]
})
```

### 3. Errors (Resolved Errors)

**When**: After Error Resolution workflow (Pro diagnosis + Flash fix)

**Entity**: `{slug}/task-{id}/error-{slug}` or `{slug}/global/error-{slug}`

**Observations**:
- Symptom: Error message/behavior
- Root Cause: Why it occurred
- Solution: How it was fixed
- Prevention: How to avoid it

**Example**:
```javascript
mcp__memory__create_entities({
  entities: [{
    name: "linderman-cc-utils/global/error-port-3000",
    entityType: "resolved-error",
    observations: [
      "Symptom: Error: listen EADDRINUSE :::3000",
      "Root Cause: Previous dev server not terminated",
      "Solution: lsof -ti:3000 | xargs kill -9",
      "Prevention: Add cleanup script to package.json"
    ]
  }]
})
```

## Auto-Fetch: 3 Moments

### 1. Start of Delegation (ALWAYS)

Before EVERY Gemini delegation:

```bash
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# Fetch global knowledge
GLOBAL=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} conventions patterns gotchas"
}))

# If in task/spec context, fetch specific knowledge
TASK=$(mcp__memory__open_nodes({
  names: ["${PROJECT_SLUG}/task-10", "${PROJECT_SLUG}/spec-010"]
}))

# Include in delegation
MEMORY_CONTEXT="
=== PROJECT KNOWLEDGE ===
${GLOBAL}

=== TASK/SPEC KNOWLEDGE ===
${TASK}
"

gemini -p "${MEMORY_CONTEXT}\n\nTASK: ..." --model ...
```

### 2. Context Gathering Phase

When collecting context for delegation:

```bash
# Search domain-specific patterns
DOMAIN_PATTERNS=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} {domain} patterns"
}))

# Example: auth domain
AUTH_PATTERNS=$(mcp__memory__search_nodes({
  query: "linderman-cc-utils auth patterns jwt"
}))
```

### 3. Error Resolution

Before delegating error to Pro:

```bash
# Check if error was solved before
KNOWN_ERROR=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} error {error-keywords}"
}))

if [ -n "$KNOWN_ERROR" ]; then
  # Apply known solution
  echo "Found previous solution in memory"
  # Use it directly or pass to Flash
else
  # Delegate to Pro for diagnosis
  gemini -p "PROBLEM RESOLUTION task: ..." --model gemini-3-pro-preview
fi
```

## Complete Workflow Examples

### Example 1: Save ADR After Pro Design

```bash
# User: "Let gemini design authentication system"

# Step 1: Delegate to Pro
PRO_DESIGN=$(gemini -p "
IMPORTANT: This is a PLANNING task.

TASK: Design authentication system for PJe extensions
" --model gemini-3-pro-preview)

# Step 2: Extract decision from Pro's response
# (Parse JSON or text response)

# Step 3: Save ADR to memory
mcp__memory__create_entities({
  entities: [{
    name: "linderman-cc-utils/spec-010/decision-jwt-auth",
    entityType: "architecture-decision",
    observations: [
      "Context: Sistema de autenticação para PJe extensions",
      "Decision: JWT + refresh tokens in httpOnly cookies",
      "Alternatives: Session (CORS), OAuth2 (overkill)",
      "Consequences: + Stateless - Token rotation needed"
    ]
  }]
})

# Step 4: Create relation
mcp__memory__create_relations({
  relations: [{
    from: "linderman-cc-utils/spec-010",
    to: "linderman-cc-utils/spec-010/decision-jwt-auth",
    relationType: "contains-decision"
  }]
})
```

### Example 2: Fetch Knowledge Before Implementation

```bash
# User: "Delegate to gemini: implement JWT authentication"

# Step 1: Extract slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# Step 2: Search memory for auth patterns
MEMORY=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} auth patterns jwt"
}))

# Step 3: Include in delegation
cat CLAUDE.md | gemini -p "
MEMORY CONTEXT (Previous Learnings):
${MEMORY}

Found from memory:
- Decision to use JWT with refresh tokens
- Pattern for httpOnly cookie storage
- Error resolution for token expiry handling

PROJECT CONTEXT (stdin):
(CLAUDE.md content)

TASK: Implement JWT authentication following memory patterns
" --model gemini-3-flash-preview

# Step 4: After implementation, save any new patterns discovered
mcp__memory__create_entities({
  entities: [{
    name: "${PROJECT_SLUG}/global/pattern-jwt-cookie-storage",
    entityType: "code-pattern",
    observations: [
      "Pattern: Store JWT in httpOnly cookies",
      "Usage: res.cookie('accessToken', token, { httpOnly: true, secure: true })",
      "When: All JWT implementations",
      "Benefit: Prevents XSS attacks"
    ]
  }]
})
```

### Example 3: Error Resolution with Memory Check

```bash
# Flash reports: "Error: listen EADDRINUSE :::3000"

# Step 1: Extract slug
PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))

# Step 2: Check if we've seen this error before
KNOWN_ERROR=$(mcp__memory__search_nodes({
  query: "${PROJECT_SLUG} error port 3000"
}))

if [ -n "$KNOWN_ERROR" ]; then
  # Step 3a: Use known solution
  echo "Found previous solution in memory:"
  echo "$KNOWN_ERROR"

  # Apply it via Flash
  gemini -p "
  KNOWN SOLUTION (from memory):
  ${KNOWN_ERROR}

  Apply this solution to resolve the port conflict.
  " --model gemini-3-flash-preview

else
  # Step 3b: Delegate to Pro for diagnosis
  PRO_DIAGNOSIS=$(gemini -p "
  IMPORTANT: This is a PROBLEM RESOLUTION task.

  ERROR: listen EADDRINUSE :::3000

  Diagnose root cause and propose solution.
  " --model gemini-3-pro-preview)

  # Step 4: Flash implements fix
  gemini -p "
  DIAGNOSIS FROM PRO:
  ${PRO_DIAGNOSIS}

  Implement the fix.
  " --model gemini-3-flash-preview

  # Step 5: Save solution to memory
  mcp__memory__create_entities({
    entities: [{
      name: "${PROJECT_SLUG}/global/error-port-conflict",
      entityType: "resolved-error",
      observations: [
        "Symptom: Error: listen EADDRINUSE :::3000",
        "Cause: Previous dev server not terminated",
        "Solution: lsof -ti:3000 | xargs kill -9",
        "Prevention: Add cleanup script to package.json"
      ]
    }]
  })
fi
```

## Prefixation Rules

1. **ALWAYS use project slug as prefix** for all entities
2. **NEVER create unprefixed entities** (causes cross-project pollution)
3. **ALWAYS search with prefix** in queries
4. **VALIDATE slug before operations**: `basename $(git rev-parse --show-toplevel)`
5. **Use consistent namespacing** for predictable organization

**Good**:
```javascript
// Entity name
"linderman-cc-utils/global/pattern-jwt-auth"

// Search query
mcp__memory__search_nodes({ query: "linderman-cc-utils auth patterns" })
```

**Bad**:
```javascript
// Entity name (missing prefix)
"global/pattern-jwt-auth"  // ❌ Will pollute other projects

// Search query (missing prefix)
mcp__memory__search_nodes({ query: "auth patterns" })  // ❌ Gets results from all projects
```

## Best Practices

✅ **Extract slug at orchestration start** - Do once, use throughout
✅ **Fetch before every delegation** - Always include memory context
✅ **Save important insights** - ADRs, patterns, errors
✅ **Use specific queries** - Include domain keywords
✅ **Create relations** - Link related entities (task → decision, etc.)
✅ **Prefix everything** - Consistent namespacing

❌ **Skip memory fetch** - Missing previous knowledge
❌ **Forget to prefix** - Cross-project pollution
❌ **Over-save** - Don't save trivial information
❌ **Generic queries** - "patterns" too broad, use "auth patterns jwt"
❌ **Skip relations** - Harder to trace knowledge graph

## Troubleshooting

**Memory not saving?**
- Check Basic Memory MCP server is running
- Verify entity name format: `{slug}/{category}/{specific-name}`
- Ensure observations array is not empty

**Searches returning nothing?**
- Verify project slug is correct
- Check query includes project slug prefix
- Try broader keywords

**Wrong project's knowledge appearing?**
- You forgot to prefix with project slug
- Always use: `{PROJECT_SLUG}/...` for entities
- Always search: `{PROJECT_SLUG} {keywords}`
