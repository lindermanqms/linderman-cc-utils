# Example: Simple Delegation

Complete example of a single-task delegation to gemini-3-flash-preview.

## Scenario

User requests: "Delegate to gemini: implement JWT authentication for Express.js API"

## Complete Workflow

### Step 1: Create Prompt File

```bash
# Create directory structure
mkdir -p .claude/gemini-coordination/{prompts,reports}

# Create prompt inline
cat > .claude/gemini-coordination/prompts/task-10-jwt-auth.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication

You are Gemini-3-Flash, expert Node.js/TypeScript developer.

## Task Description
Implement JWT authentication for Express.js API with login endpoint and token validation middleware.

### Acceptance Criteria
- [ ] POST /auth/login returns JWT access token (15min expiry)
- [ ] POST /auth/refresh returns new access token
- [ ] Middleware validates Authorization header
- [ ] Returns 401 for invalid/missing tokens
- [ ] Tokens signed with HS256 algorithm

### Technical Requirements
1. Use jsonwebtoken library
2. Access token expiry: 15 minutes
3. Refresh token expiry: 7 days
4. Store refresh tokens in PostgreSQL database
5. Use environment variables for JWT_SECRET

### Existing Code

**package.json:**
```json
{
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.11.0",
    "dotenv": "^16.0.0"
  }
}
```

**Current auth routes (minimal):**
```typescript
import { Router } from 'express';

const router = Router();

export default router;
```

## Files to Create
- [ ] `src/auth/jwt.service.ts` - JWT generation and validation
- [ ] `src/auth/middleware.ts` - Express middleware for token validation
- [ ] `src/auth/routes.ts` - Login and refresh endpoints
- [ ] `src/auth/database.ts` - Refresh token storage
- [ ] `tests/auth.test.ts` - Unit tests

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
[Summary of JWT auth implementation]

## Files Modified
- List of all files created/modified

## Changes Made
[Description of each file's purpose and changes]

## Static Analysis Results
✅ PASSED - All linting and type checking passed

## Testing Performed
[Unit tests executed and results]

## Results
**Achievements**:
- [x] POST /auth/login returns JWT token
- [x] POST /auth/refresh returns new token
- [x] Middleware validates tokens
- [x] Returns 401 for invalid tokens
- [x] HS256 algorithm used

**Tests**:
- ✅ Unit tests: 5/5 passed
- ✅ Coverage: 90%+

## Issues Found
[None or any issues encountered]

=== END REPORT ===
EOF
```

### Step 2: Execute Delegation

```bash
# Execute Flash delegation
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-10-jwt-auth.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Output:
# ⏳ Delegation in progress...
# ✅ Completed in 47.3s
# Report saved to: .claude/gemini-coordination/reports/flash-20260123-1430.md
```

### Step 3: Review Report

```bash
# View the generated report
cat .claude/gemini-coordination/reports/flash-20260123-1430.md

# Check Orchestrator Report section
grep -A 50 "=== ORCHESTRATOR REPORT ===" \
  .claude/gemini-coordination/reports/flash-20260123-1430.md
```

**Expected report content:**
- Implementation Summary
- Files Modified (5 files created)
- Changes Made (JWT service, middleware, routes, database, tests)
- Static Analysis Results (PASSED)
- Testing Performed (5/5 tests passed)
- Results (All ACs met)
- Issues Found (None)

### Step 4: Validate Results

```bash
# Install new dependencies
npm install jsonwebtoken

# Check created files
ls -la src/auth/
# Expected: jwt.service.ts, middleware.ts, routes.ts, database.ts

# Run static analysis
npm run lint
npm run typecheck

# Run tests
npm test tests/auth.test.ts

# Verify ACs
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
# Expected: {"accessToken":"eyJ...", "refreshToken":"..."}

curl http://localhost:3000/api/protected \
  -H "Authorization: Bearer [accessToken]"
# Expected: Protected data

curl http://localhost:3000/api/protected
# Expected: 401 Unauthorized
```

### Step 5: Final Validation (Orchestrator)

```bash
# Full validation sequence
npm run build
npm test
npm start &

# Manual testing
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}' \
  | jq -r '.accessToken')

curl http://localhost:3000/api/protected \
  -H "Authorization: Bearer $TOKEN"
# Expected: Success

# All validations pass → Implementation complete
```

## Key Points

**Workflow Characteristics:**
- ✅ **Single delegation** - One Flash execution
- ✅ **Prompt created inline** - No external template files
- ✅ **Direct execution** - No wrapper scripts
- ✅ **Clear ACs** - 5 specific acceptance criteria
- ✅ **Structured report** - Orchestrator Report section present
- ✅ **Orchestrator validates** - Final validation by Claude Code

**Critical Success Factors:**
1. Detailed prompt with complete context
2. Specific acceptance criteria
3. Explicit file structure requirements
4. Mandatory Orchestrator Report
5. Post-delegation validation by Orchestrator

## Common Variations

### Variation 1: Bug Fix

```bash
# Create prompt for bug fix
cat > prompts/task-11-fix-bug.txt <<'EOF'
# IMPLEMENTATION TASK - Fix Authentication Bug

## Bug Report
Error: JWT middleware incorrectly validates expired tokens
Symptom: Expired tokens accepted as valid

## Task Description
Fix token validation logic to properly reject expired tokens

### Acceptance Criteria
- [ ] Expired tokens return 401
- [ ] Valid tokens accepted
- [ ] Error handling improved

[... rest of Flash template ...]
EOF
```

### Variation 2: Refactoring

```bash
# Create prompt for refactoring
cat > prompts/task-12-refactor.txt <<'EOF'
# IMPLEMENTATION TASK - Refactor Auth Service

## Current Code
[Paste current auth service code]

## Task Description
Refactor to use dependency injection pattern for testability

### Acceptance Criteria
- [ ] Constructor injection of dependencies
- [ ] Mockable interfaces
- [ ] All existing tests pass

[... rest of Flash template ...]
EOF
```

### Variation 3: Test Writing

```bash
# Create prompt for test generation
cat > prompts/task-13-tests.txt <<'EOF'
# IMPLEMENTATION TASK - Write Auth Tests

## Implementation to Test
[Paste auth service code]

## Task Description
Write comprehensive unit tests for JWT service

### Acceptance Criteria
- [ ] Test all public methods
- [ ] Cover success and error cases
- [ ] 90%+ code coverage
- [ ] All tests pass

[... rest of Flash template ...]
EOF
```

## When to Use Simple Delegation

Use this pattern for:
- ✅ Straightforward implementation tasks
- ✅ Single-feature development
- ✅ Bug fixes
- ✅ Refactoring
- ✅ Test writing

**DO NOT use for:**
- ❌ System design (use Pro instead)
- ❌ Architecture decisions (use Pro instead)
- ❌ Multi-phase workflows (use complex orchestration instead)

## Related Resources

- `prompt-templates.md` - Complete Flash template
- `delegation-guide.md` - Model selection guide
- `complex-orchestration.md` - Multi-phase workflows
- `validation-protocol.md` - Validation procedures
