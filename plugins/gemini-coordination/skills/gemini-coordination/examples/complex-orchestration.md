# Example: Complex Orchestration

Complete example of multi-phase orchestration: Pro (design) → Flash (implementation) → Validation.

## Scenario

User requests: "Let gemini design and implement a complete REST API for user management"

## Complete Workflow

### Phase 1: Design (gemini-3-pro)

```bash
# Step 1: Create design prompt
cat > .claude/gemini-coordination/prompts/task-20-api-design.txt <<'EOF'
# PLANNING TASK - User Management API Design

IMPORTANT: This is a PLANNING task (NOT implementation).

You are Gemini-3-Pro, expert API architect and systems designer.

## Task Description
Design complete REST API for user management with authentication, authorization, and CRUD operations.

### Requirements
1. RESTful endpoints for user CRUD
2. JWT-based authentication
3. Role-based access control (admin, user)
4. Pagination and filtering
5. Rate limiting
6. Input validation

### Analysis Required
1. Endpoint design and HTTP methods
2. Authentication/authorization flow
3. Database schema design
4. Error handling strategy
5. Rate limiting approach

### Constraints
- Must use PostgreSQL
- Must work with Express.js
- Follow OpenAPI 3.0 specification
- Performance: < 100ms response time for CRUD

## Output Requirements

Provide structured reasoning with:

1. **Analysis** - Detailed API design analysis
2. **Decisions** - Endpoint structure, auth flow, database schema
3. **Trade-offs** - Design trade-offs with pros/cons
4. **Alternatives Considered** - Alternative approaches evaluated
5. **Risks & Mitigations** - Security risks, performance risks
6. **Recommendations** - Specific technical recommendations
7. **Next Steps** - Implementation roadmap

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Analysis
[Complete API design analysis]

## Decisions
- Endpoint structure: /api/users with RESTful methods
- Authentication: JWT access tokens (15min) + refresh tokens (7days)
- Authorization: Role-based middleware
- Database: PostgreSQL with users, roles tables
- Pagination: Cursor-based for performance
- Rate limiting: Token bucket algorithm

## Trade-offs
[Trade-off analysis]

## Alternatives Considered
[Alternative approaches and why rejected]

## Risks & Mitigations
- Risk: [risk with mitigation]
- Risk: [risk with mitigation]

## Recommendations
1. Use passport-jwt for authentication
2. Implement cursor pagination
3. Use express-rate-limit
4. Add request validation middleware
5. Implement audit logging

## Next Steps
1. Set up project structure
2. Implement database schema
3. Create authentication layer
4. Implement CRUD endpoints
5. Add authorization middleware
6. Write comprehensive tests

=== END REPORT ===
EOF

# Step 2: Execute Pro delegation
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/pro-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-20-api-design.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Output:
# ✅ Pro analysis completed in 32.7s
# Report: .claude/gemini-coordination/reports/pro-20260123-1500.md
```

### Phase 2: Implementation (gemini-3-flash)

```bash
# Step 3: Review Pro's design
cat .claude/gemini-coordination/reports/pro-20260123-1500.md

# Extract key decisions for implementation
DESIGN=$(cat .claude/gemini-coordination/reports/pro-20260123-1500.md | grep -A 200 "=== ORCHESTRATOR REPORT ===")

# Step 4: Create implementation prompt with Pro's design
cat > .claude/gemini-coordination/prompts/task-20-api-implementation.txt <<'EOF'
# IMPLEMENTATION TASK - User Management API Implementation

You are Gemini-3-Flash, expert Node.js/TypeScript developer.

## Design Context (from gemini-3-pro)

### Endpoint Structure
- GET /api/users - List users (paginated, filtered)
- GET /api/users/:id - Get user by ID
- POST /api/users - Create user (admin only)
- PUT /api/users/:id - Update user
- DELETE /api/users/:id - Delete user (admin only)
- POST /auth/login - Login
- POST /auth/refresh - Refresh token
- POST /auth/logout - Logout

### Authentication
- JWT access tokens: 15 minutes
- Refresh tokens: 7 days
- Stored in PostgreSQL refresh_tokens table

### Authorization
- Roles: admin, user
- Admin-only: POST, PUT, DELETE /api/users
- User or admin: GET /api/users

### Database Schema
```sql
users table:
- id (UUID, primary key)
- email (VARCHAR, unique, not null)
- password_hash (VARCHAR, not null)
- role (VARCHAR, not null, default 'user')
- created_at (TIMESTAMP, default NOW())
- updated_at (TIMESTAMP, default NOW())

refresh_tokens table:
- id (UUID, primary key)
- user_id (UUID, foreign key → users.id)
- token (VARCHAR, unique, not null)
- expires_at (TIMESTAMP, not null)
- created_at (TIMESTAMP, default NOW())
```

### Recommendations from Pro
1. Use passport-jwt for authentication
2. Use express-validator for input validation
3. Use express-rate-limit middleware
4. Implement cursor-based pagination
5. Add comprehensive logging

## Task Description
Implement complete user management API following Pro's design.

### Acceptance Criteria
- [ ] All 8 endpoints functional
- [ ] JWT authentication working
- [ ] Role-based authorization enforced
- [ ] Pagination implemented (cursor-based)
- [ ] Input validation on all endpoints
- [ ] Rate limiting configured
- [ ] Unit tests for all endpoints
- [ ] Integration tests for critical flows

### Technical Requirements
1. TypeScript 5.3+
2. Express.js 4.18+
3. PostgreSQL with pg library
4. jsonwebtoken for JWT
5. passport-jwt for auth
6. express-validator for validation
7. express-rate-limit for rate limiting

## Files to Create
- [ ] `src/database/connection.ts` - PostgreSQL connection
- [ ] `src/database/schema.sql` - Database schema
- [ ] `src/auth/jwt.service.ts` - JWT operations
- [ ] `src/auth/passport.ts` - Passport configuration
- [ ] `src/auth/middleware.ts` - Auth middleware
- [ ] `src/middleware/validation.ts` - Input validation
- [ ] `src/middleware/rate-limit.ts` - Rate limiting
- [ ] `src/middleware/authorization.ts` - Role-based access
- [ ] `src/routes/auth.routes.ts` - Auth endpoints
- [ ] `src/routes/user.routes.ts` - User CRUD endpoints
- [ ] `src/controllers/auth.controller.ts` - Auth controller
- [ ] `src/controllers/user.controller.ts` - User controller
- [ ] `tests/auth.test.ts` - Auth tests
- [ ] `tests/users.test.ts` - User tests

## Output Requirements
For each file, provide:
1. Complete file path
2. Full TypeScript code
3. Brief explanation

---

MANDATORY PRE-REPORT REQUIREMENTS:

1. **Static Code Analysis**
   ```bash
   npm run lint
   npm run typecheck
   ```

2. **Error Retry Protocol**
   If static analysis fails:
   - Attempt 1: `npm run lint -- --fix`
   - Attempt 2: Fix specific errors
   - Attempt 3: Document in report

3. **Limitations**
   - ❌ NEVER delete files
   - ❌ NEVER remove packages
   - ❌ NEVER run final validation (Orchestrator's responsibility)

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Implementation Summary
[Summary of API implementation following Pro's design]

## Files Modified
- List of all files created (14 files)

## Changes Made
[Description of each component]

## Static Analysis Results
✅ PASSED - All linting and type checking passed

## Testing Performed
[Unit and integration test results]

## Results
**Achievements**:
- [x] 8 endpoints implemented
- [x] JWT authentication functional
- [x] Role-based authorization working
- [x] Cursor-based pagination
- [x] Input validation complete
- [x] Rate limiting configured
- [x] Tests passing (24/24)

**Tests**:
- ✅ Auth tests: 8/8 passed
- ✅ User tests: 16/16 passed
- ✅ Coverage: 85%+

## Issues Found
[None or any issues]

=== END REPORT ===
EOF

# Step 5: Execute Flash delegation
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-20-api-implementation.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Output:
# ✅ Implementation completed in 94.2s
# Report: .claude/gemini-coordination/reports/flash-20260123-1530.md
```

### Phase 3: Validation (Orchestrator)

```bash
# Step 6: Review both reports
echo "=== PRO DESIGN REPORT ==="
cat .claude/gemini-coordination/reports/pro-20260123-1500.md | grep -A 100 "=== ORCHESTRATOR REPORT ==="

echo ""
echo "=== FLASH IMPLEMENTATION REPORT ==="
cat .claude/gemini-coordination/reports/flash-20260123-1530.md | grep -A 100 "=== ORCHESTRATOR REPORT ==="

# Step 7: Verify implementation follows design
# Check if all Pro recommendations are implemented:
# - passport-jwt used? ✓
# - express-validator used? ✓
# - express-rate-limit used? ✓
# - cursor pagination? ✓
# - comprehensive logging? ✓

# Step 8: Install dependencies
npm install pg jsonwebtoken passport passport-jwt express-validator express-rate-limit

# Step 9: Set up database
createdb user_management_db
psql user_management_db -f src/database/schema.sql

# Step 10: Static analysis
npm run lint
npm run typecheck

# Step 11: Run tests
npm test

# Expected output:
# Auth tests:
#   POST /auth/login
#     ✓ Returns JWT tokens
#     ✓ Rejects invalid credentials
#     ... (8 tests passed)
#
# User tests:
#   GET /api/users (paginated)
#     ✓ Returns paginated user list
#     ✓ Respects role-based access
#     ... (16 tests passed)
#
# All 24 tests passed!

# Step 12: Build and start server
npm run build
npm start &

# Step 13: End-to-end testing

# Test login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
# Expected: {"accessToken":"...", "refreshToken":"...", "user":{...}}

# Test protected endpoint
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}' \
  | jq -r '.accessToken')

curl http://localhost:3000/api/users \
  -H "Authorization: Bearer $TOKEN"
# Expected: Paginated user list

# Test rate limiting
for i in {1..100}; do
  curl http://localhost:3000/api/users \
    -H "Authorization: Bearer $TOKEN"
done
# Expected: 429 Too Many Requests after rate limit

# All validations pass → Implementation complete
```

## Key Points

**Workflow Characteristics:**
- ✅ **Two-phase delegation** - Design (Pro) → Implementation (Flash)
- ✅ **Design feeds implementation** - Pro's output becomes Flash's input
- ✅ **Clear separation of concerns** - Planning vs Coding
- ✅ **Orchestrator validates** - Final build/test/end-to-end
- ✅ **Prompts created inline** - No external template files
- ✅ **Direct execution** - No wrapper scripts

**Critical Success Factors:**
1. Pro provides complete, actionable design
2. Flash receives Pro's design as context
3. Implementation follows design decisions
4. Orchestrator validates both phases
5. End-to-end testing confirms integration

## When to Use Complex Orchestration

Use this pattern for:
- ✅ System design + implementation
- ✅ Architecture decisions + coding
- ✅ Multi-step features requiring planning
- ✅ Projects with multiple approaches to evaluate

**DO NOT use for:**
- ❌ Simple implementation tasks (use simple delegation instead)
- ❌ Pure bug fixes (use simple delegation instead)
- ❌ Straightforward CRUD (use simple delegation instead)

## Workflow Diagram

```
┌─────────────────────────────────────────┐
│           ORCHESTRATOR                   │
│  1. Create design prompt (inline)       │
│  2. Delegate to Pro (gemini-cli)        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│         GEMINI-3-PRO                     │
│  - Analyzes requirements                │
│  - Evaluates trade-offs                │
│  - Proposes architecture               │
│  - Returns design report               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│           ORCHESTRATOR                   │
│  3. Review design                      │
│  4. Create implementation prompt       │
│     (with Pro's design)                 │
│  5. Delegate to Flash (gemini-cli)      │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│         GEMINI-3-FLASH                   │
│  - Receives design context              │
│  - Implements following design         │
│  - Runs dev commands (npm install)     │
│  - Returns implementation report       │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│           ORCHESTRATOR                   │
│  6. Review implementation              │
│  7. Verify follows design              │
│  8. Run validation (build, test)        │
│  9. End-to-end testing                  │
│  10. Approve or request revision        │
└─────────────────────────────────────────┘
```

## Common Variations

### Variation 1: Problem Resolution

```bash
# Phase 1: Pro diagnosis
cat > prompts/task-diagnosis.txt <<'EOF'
# PROBLEM RESOLUTION TASK - Diagnose API Performance Issue

ERROR: API responses > 500ms for GET /api/users
CONTEXT: 10,000 users in database

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

### Variation 2: Feature Refactoring

```bash
# Phase 1: Pro design refactoring
cat > prompts/task-refactor-design.txt <<'EOF'
# PLANNING TASK - Refactor Auth to Microservices

Current: Monolithic auth service
Goal: Extract to separate microservice

[Pro template for design...]
EOF

gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat prompts/task-refactor-design.txt)" | tee reports/pro-refactor.md

# Phase 2: Flash implementation
cat > prompts/task-refactor-impl.txt <<'EOF'
## Refactoring Design (from Pro)
[Content from pro-refactor.md]

[Flash template for implementation...]
EOF

gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat prompts/task-refactor-impl.txt)" | tee reports/flash-refactor.md
```

## Related Resources

- `prompt-templates.md` - Complete Pro and Flash templates
- `delegation-guide.md` - Model selection and delegation patterns
- `simple-delegation.md` - Single-task workflow
- `validation-protocol.md` - Validation procedures
