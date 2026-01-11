# Prompt Templates

Ready-to-use templates for Gemini delegations. Copy, customize, and execute.

## Template for gemini-3-pro-preview (Reasoning/Planning)

### Structure

```bash
gemini -p "
IMPORTANT: This is a [PLANNING | PROBLEM RESOLUTION | ARCHITECTURE REVIEW] task (NOT implementation).

You are Gemini-3-Pro, an expert in [DOMAIN].

TASK: [specific objective]

MEMORY CONTEXT (Previous Learnings):
${MEMORY_KNOWLEDGE}

PROJECT CONTEXT:
- Standards: [CLAUDE.md content or description]
- Architecture: [patterns from Explore]
- Documentation: [relevant URLs]

DOMAIN CONTEXT:
- [background information]
- [constraints]
- [requirements]

ANALYSIS REQUIRED:
1. [aspect 1]
2. [aspect 2]
3. [aspect 3]

YOUR CAPABILITIES:
- Read and analyze code (DO NOT implement)
- Adjust file permissions if needed (for problem resolution)
- Identify root causes
- Propose solutions
- Design architectures

OUTPUT FORMAT:
- Structured reasoning
- Trade-off analysis
- Recommendation with rationale
- Risks and mitigations
- (If debugging) Root cause + proposed solution

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

After your analysis, create a structured report using this EXACT format:

=== ORCHESTRATOR REPORT ===

## Analysis
[Your analysis of the problem/domain]

## Decisions
[Decisions made with rationale]

## Trade-offs
[Trade-offs analyzed with pros and cons]

## Alternatives Considered
[Alternatives evaluated and why rejected]

## Risks & Mitigations
[Risks identified and mitigation strategies]

## Recommendations
[Specific recommendations]

## Next Steps
[Suggested next steps for implementation]

=== END REPORT ===

IMPORTANT: The report MUST be the LAST section of your response, immediately before \"=== END REPORT ===\".
" --model gemini-3-pro-preview --yolo
```

**Note**: The `--yolo` flag enables autonomous operation, allowing the agent to:
- Adjust file permissions during problem resolution
- Execute commands without approval prompts
- Perform analysis tasks without user intervention

### Example 1: System Design

```bash
cat CLAUDE.md | gemini -p "
IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, an expert in web application architecture.

TASK: Design a scalable authentication system for a Chrome extension that interacts with a legacy court system (PJe)

MEMORY CONTEXT:
$(mcp__memory__search_nodes({ query: \"linderman-cc-utils auth patterns\" }))

PROJECT CONTEXT (stdin):
Project standards from CLAUDE.md

TECHNICAL REFERENCES:
- JWT Introduction: https://jwt.io/introduction
- Chrome Extension Auth: https://developer.chrome.com/docs/extensions/mv3/messaging/

DOMAIN CONTEXT:
- Legacy system uses cookie-based sessions
- Extension needs to make authenticated API calls
- Must handle token expiry gracefully
- Security is critical (court data)

ANALYSIS REQUIRED:
1. Authentication flow (extension → backend → PJe)
2. Token storage strategy (localStorage vs cookies vs chrome.storage)
3. Refresh token mechanism
4. Error handling for expired sessions

YOUR CAPABILITIES:
- Read existing auth code (DO NOT implement)
- Design architecture and data flows
- Propose security best practices
- Identify potential issues

OUTPUT FORMAT:
1. Architecture Design
   - Component diagram (text)
   - Data flow diagram
   - Sequence diagrams for key operations
2. Trade-off Analysis
   - Storage options compared
   - Security considerations
3. Recommendation
   - Chosen approach with rationale
   - Implementation steps (high-level)
4. Risks & Mitigations
   - Security risks
   - Edge cases
" --model gemini-3-pro-preview --yolo
```

### Example 2: Problem Resolution

```bash
gemini -p "
IMPORTANT: This is a PROBLEM RESOLUTION task (NOT implementation).

You are Gemini-3-Pro, an expert in debugging Node.js applications.

TASK: Diagnose why the server returns 500 on /api/auth/login endpoint

MEMORY CONTEXT:
$(mcp__memory__search_nodes({ query: \"linderman-cc-utils error 500\" }))

ERROR DETAILS:
- Endpoint: POST /api/auth/login
- Status: 500 Internal Server Error
- Logs: \"TypeError: Cannot read property 'hash' of undefined\"
- Occurs: Only for specific users
- Works: For other users with same credentials format

CODE TO ANALYZE:
\`\`\`typescript
$(cat src/auth/service.ts)
\`\`\`

DATABASE SCHEMA:
\`\`\`sql
$(cat db/schema.sql | grep -A 10 \"users\")
\`\`\`

ANALYSIS REQUIRED:
1. Identify root cause of TypeError
2. Explain why it only affects some users
3. Propose solution
4. Suggest prevention strategy

YOUR CAPABILITIES:
- Read and analyze code
- Identify logic errors
- Propose fixes (DO NOT implement)

OUTPUT FORMAT:
1. Root Cause
   - Exact line/file causing error
   - Why it occurs
2. Why Only Some Users?
   - Data condition analysis
3. Proposed Solution
   - Fix description (not code)
   - Changes needed
4. Prevention
   - Validation to add
   - Tests to write
" --model gemini-3-pro-preview --yolo
```

## Template for gemini-3-flash-preview (Implementation)

### Structure

```bash
gemini -p "
You are Gemini-3-Flash, expert [LANGUAGE] developer.

TASK: [specific coding task]

MEMORY CONTEXT (Patterns & Solutions):
${MEMORY_KNOWLEDGE}

PROJECT CONTEXT:
- Standards: [CLAUDE.md content]
- Existing code: [files from Explore]
- Architecture: [from Pro if applicable]

TECHNICAL REFERENCES:
- [URL 1: API docs]
- [URL 2: framework guides]
- [URL 3: best practices]

REQUIREMENTS:
- [functional requirement 1]
- [functional requirement 2]
- [non-functional requirement]

ACCEPTANCE CRITERIA (if from spec):
- [ ] AC 1
- [ ] AC 2
- [ ] AC 3

CODE TO MODIFY (if applicable):
\`\`\`[language]
[existing code]
\`\`\`

YOUR CAPABILITIES:
- Write and edit code
- Execute Bash commands during development
- Run scripts and start servers
- Use MCP servers when needed
- Implement solutions designed by Pro

OUTPUT:
- Complete, functional code
- Error handling
- Comments for complex logic
- [LANGUAGE] best practices
- Validate all ACs

MANDATORY PRE-REPORT REQUIREMENTS:
Before creating your final Orchestrator Report, you MUST:

1. **Run Static Code Analysis** (choose appropriate commands):
   - TypeScript/JavaScript: `npm run lint` and `npm run typecheck`
   - Python: `ruff check .` and `mypy .`
   - Rust: `cargo clippy` and `cargo fmt --check`
   - Go: `go vet ./...` and `gofmt -l .`

2. **Error Retry Protocol (3 attempts)**:
   - If static analysis fails:
     * Attempt 1: Auto-fix (e.g., `npm run lint -- --fix`)
     * Attempt 2: Analyze and fix specific errors
     * Attempt 3: Document difficulties in report

3. **Test Execution**:
   - Run project tests: `npm test`, `pytest`, `cargo test`, etc.
   - Verify all Acceptance Criteria are met

4. **Only Then Create Report**:
   - After static analysis passes (or documented failures)
   - After tests pass
   - Document any remaining issues

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

After implementation, create a structured report using this EXACT format:

=== ORCHESTRATOR REPORT ===

## Implementation Summary
[Concise summary of what was implemented]

## Files Modified
- [file path] (created/modified)
- [file path] (created/modified)

## Changes Made
[Description of changes made to each file/component]

## Testing Performed
- [Test type]: [command] → [result]
- [Test type]: [command] → [result]

## Static Analysis Results
✅ [PASSED/FAILED]

**Commands Run**:
- [Static analysis command 1]: [result]
- [Static analysis command 2]: [result]

[If failed after 3 attempts, document remaining issues and why they couldn't be resolved]

## Results
✓ [Achievement 1]
✓ [Achievement 2]
✓ [Achievement 3]

## Issues Found
[If any issues were encountered, document here]

**IMPORTANT REMINDER**:
- You CANNOT delete files or perform destructive operations
- You CANNOT remove packages or dependencies
- Mark files for cleanup instead; Orchestrator will handle deletion

=== END REPORT ===

IMPORTANT: The report MUST be the LAST section of your response, immediately before \"=== END REPORT ===\".
" --model gemini-3-flash-preview --yolo
```

**Note**: The `--yolo` flag enables full implementation autonomy:
- Create, edit, and delete files without confirmation
- Execute Bash commands and scripts
- Start/stop development servers
- Use MCP servers and tools
- Run tests and validation commands

### Example 1: New Feature Implementation

```bash
cat CLAUDE.md | gemini -p "
You are Gemini-3-Flash, expert TypeScript developer.

TASK: Implement JWT authentication service

MEMORY CONTEXT:
$(mcp__memory__search_nodes({ query: \"linderman-cc-utils auth patterns jwt\" }))

Found from memory:
- Decision: JWT + refresh tokens in httpOnly cookies
- Pattern: Use jose library for JWT operations
- Error fix: Handle token expiry with 401 status

PROJECT CONTEXT (stdin):
Standards from CLAUDE.md

TECHNICAL REFERENCES:
- JWT Introduction: https://jwt.io/introduction
- jose library: https://github.com/panva/jose
- Express.js middleware: https://expressjs.com/en/guide/using-middleware.html

ARCHITECTURE (from Pro):
- AuthService class with login/refresh/logout methods
- JWT middleware for route protection
- Refresh token stored in database

REQUIREMENTS:
- Access token expires in 15 minutes
- Refresh token expires in 7 days
- Tokens stored in httpOnly cookies
- Password hashing with bcrypt
- Token blacklist for logout

ACCEPTANCE CRITERIA:
- [ ] User can login with email/password
- [ ] Access token auto-refreshes when expired
- [ ] Logout invalidates both tokens
- [ ] Protected routes return 401 when unauthorized
- [ ] All endpoints have error handling

YOUR CAPABILITIES:
- Write TypeScript code
- Use npm packages (jose, bcrypt)
- Create database schemas
- Write tests

OUTPUT:
Create these files:
1. src/auth/service.ts - AuthService class
2. src/auth/middleware.ts - JWT verification middleware
3. src/auth/routes.ts - Express routes
4. src/auth/types.ts - TypeScript interfaces
5. tests/auth.test.ts - Unit tests
6. db/migrations/001_auth.sql - Database schema

Follow project standards:
- Use async/await
- Error handling with AppError class
- Response format: { success, data/error }
" --model gemini-3-flash-preview --yolo
```

### Example 2: Bug Fix Implementation

```bash
cat src/auth/service.ts | gemini -p "
You are Gemini-3-Flash, expert TypeScript developer.

TASK: Fix the TypeError in login endpoint

DIAGNOSIS FROM PRO:
Root Cause: user.password is undefined for users created before password field was added to schema
Why: Migration didn't backfill password hashes for existing users
Solution: Add null check and handle gracefully

CODE TO MODIFY (stdin):
Current auth service implementation

MEMORY CONTEXT:
$(mcp__memory__search_nodes({ query: \"linderman-cc-utils error handling patterns\" }))

REQUIREMENTS:
- Add null check for user.password
- Return clear error message for users without password
- Log warning for admin to review
- Don't crash on null/undefined

YOUR CAPABILITIES:
- Modify existing TypeScript code
- Add error handling
- Write defensive code

OUTPUT:
Modified src/auth/service.ts with:
1. Null check for password field
2. Clear error message to client
3. Warning log for admins
4. Comments explaining the fix
5. Maintain existing code style
" --model gemini-3-flash-preview --yolo
```

## Template Variations

### For Architecture Review

```bash
gemini -p "
IMPORTANT: This is an ARCHITECTURE REVIEW task.

You are Gemini-3-Pro, expert software architect.

TASK: Review proposed API design and suggest improvements

PROPOSED DESIGN:
\`\`\`
[paste design document or code]
\`\`\`

REVIEW CRITERIA:
- RESTful best practices
- Security considerations
- Scalability concerns
- Error handling patterns
- Documentation completeness

OUTPUT:
1. Strengths - What works well
2. Concerns - Potential issues
3. Recommendations - Specific improvements
4. Priority - Critical vs Nice-to-have
" --model gemini-3-pro-preview --yolo
```

### For Refactoring

```bash
cat file-to-refactor.ts | gemini -p "
You are Gemini-3-Flash, expert refactoring specialist.

TASK: Refactor authentication to use dependency injection

EXISTING CODE (stdin):
Current tightly-coupled implementation

ARCHITECTURE (from Pro):
- Use constructor injection
- Interface-based abstractions
- Inversion of Control pattern

REQUIREMENTS:
- Maintain existing behavior
- Improve testability
- Follow SOLID principles
- Add unit tests

OUTPUT:
Refactored code maintaining exact same API but with DI pattern
" --model gemini-3-flash-preview --yolo
```

### For Test Generation

```bash
cat src/auth/service.ts | gemini -p "
You are Gemini-3-Flash, expert test engineer.

TASK: Generate comprehensive unit tests for AuthService

CODE TO TEST (stdin):
AuthService implementation

TESTING REQUIREMENTS:
- Use Jest framework
- Test all public methods
- Test error cases
- Mock dependencies
- Achieve 100% coverage

OUTPUT:
tests/auth/service.test.ts with:
- Setup/teardown
- Happy path tests
- Error case tests
- Edge case tests
- Clear test descriptions
" --model gemini-3-flash-preview --yolo
```

## Context Injection Patterns

### Pattern 1: Project Documentation

```bash
cat CLAUDE.md README.md | gemini -p "
PROJECT CONTEXT (stdin above):
Review project standards

TASK: ...
" --model ...
```

### Pattern 2: Memory + Project Docs

```bash
MEMORY=$(mcp__memory__search_nodes({ query: "..." }))

cat CLAUDE.md | gemini -p "
MEMORY CONTEXT:
${MEMORY}

PROJECT CONTEXT (stdin):
...

TASK: ...
" --model ...
```

### Pattern 3: Architecture + Code

```bash
PRO_DESIGN=$(previous Pro delegation result)
EXISTING_CODE=$(cat src/existing.ts)

cat CLAUDE.md | gemini -p "
ARCHITECTURE (from Pro):
${PRO_DESIGN}

EXISTING CODE:
\`\`\`typescript
${EXISTING_CODE}
\`\`\`

PROJECT CONTEXT (stdin):
...

TASK: ...
" --model gemini-3-flash-preview --yolo
```

## Output Format Hints

Guide Gemini to structured output:

```bash
gemini -p "
...

OUTPUT FORMAT:
Return JSON with this structure:
{
  \"analysis\": \"...\",
  \"recommendation\": \"...\",
  \"risks\": [\"...\"],
  \"nextSteps\": [\"...\"]
}
" --model gemini-3-pro-preview --output-format json --yolo
```

Or for code:

```bash
gemini -p "
...

OUTPUT FORMAT:
For each file, provide:
1. File path
2. Full code (not snippets)
3. Brief explanation of changes
" --model gemini-3-flash-preview --yolo
```
