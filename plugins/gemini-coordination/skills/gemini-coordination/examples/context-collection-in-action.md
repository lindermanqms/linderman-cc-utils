# Context Collection in Action

Real-world examples demonstrating the importance of explicit context collection and how to handle failures.

## Example 1: Successful Context Collection

### Scenario
Delegate implementation of a JWT authentication system to a Flash agent with the backend-dev persona.

### Initial Prompt

```bash
cat > .claude/gemini-coordination/prompts/task-50-jwt-auth.txt <<'EOF'
# IMPLEMENTATION TASK - JWT Authentication System

You are gemini-3-flash-preview, **Node.js/Python/Rust Backend Developer** (backend-dev persona).

## Your Expertise
- [Framework] (Express/FastAPI/Actix/etc.) API development
- REST/GraphQL endpoint design and implementation
- Authentication & authorization (JWT, OAuth2, RBAC)
- Error handling, logging, input validation
- Security best practices

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
Execute these commands before implementing:
```bash
cat CLAUDE.md
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
cat src/main.ts 2>/dev/null || cat app/main.py 2>/dev/null || cat server.js 2>/dev/null
find src -name "*auth*" -type f | head -5
cat prisma/schema.prisma 2>/dev/null || cat src/models/*.ts 2>/dev/null || cat app/models.py 2>/dev/null
cat .env.example 2>/dev/null || cat config/default.yml 2>/dev/null
```

### Phase 2: Research Requirements
For this task, you MUST research:
1. **JWT best practices** - Current JWT implementation patterns
   - Search: "JWT authentication best practices [framework] 2026"
   - Understand: Token signing, expiration, refresh tokens, secret management
2. **[Framework] JWT libraries** - Recommended JWT libraries
   - Search: "[framework] JWT library recommendations jsonwebtoken"
   - Understand: API, signing algorithms, verification, error handling
3. **Security considerations** - JWT security vulnerabilities
   - Search: "JWT security vulnerabilities token storage 2026"
   - Understand: Algorithm confusion attacks, token leakage, revocation strategies

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project uses [framework] version [X.X]+
- [ ] Database: [PostgreSQL/MySQL/etc.]
- [ ] ORM/ODM: [Prisma/TypeORM/etc.]
- [ ] JWT library: [jsonwebtoken/jose/etc.]
- [ ] Files allowed: src/auth/, src/middleware/, src/routes/, src/lib/
- [ ] Secret management: [environment variables/vault]

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Implement JWT-based authentication system with login, token refresh, and protected routes.

### Acceptance Criteria
- [ ] Login endpoint: POST /auth/login returns JWT access token (15min) + refresh token (7 days)
- [ ] Token refresh endpoint: POST /auth/refresh returns new access token
- [ ] Protected routes middleware validates JWT and extracts user info
- [ ] Tokens signed with HS256 using environment variable secret
- [ ] Refresh tokens stored in database with revocation support
- [ ] Error handling for invalid/expired tokens (401 Unauthorized)
- [ ] Login rate limiting (5 attempts per 15 minutes)
- [ ] Secure password hashing (bcrypt with salt rounds >= 10)
- [ ] Token blacklist for logout

### Technical Requirements
1. Use [framework] with [JWT library]
2. Access token expiry: 15 minutes
3. Refresh token expiry: 7 days
4. Store refresh tokens in database with user association
5. Implement token blacklist using database or Redis
6. Rate limit login endpoint
7. Bcrypt password hashing with 12 salt rounds

## Implementation Guidelines
- Follow JWT best practices from research
- Use strong secret key from environment variable (min 32 chars)
- Implement proper error handling (don't leak security information)
- Add logging for authentication events (login, logout, token refresh, failures)
- Use database transactions for token creation
- Validate all inputs (email format, password strength)

## Files to Create/Modify
- [ ] `src/auth/authService.ts` - Authentication logic (login, refresh, logout)
- [ ] `src/auth/jwtMiddleware.ts` - JWT verification middleware
- [ ] `src/routes/authRoutes.ts` - Authentication endpoints
- [ ] `src/models/refreshToken.ts` - Refresh token model (if not exists)
- [ ] `src/lib/rateLimiter.ts` - Rate limiting middleware

[Rest of standard Flash template...]
EOF
```

### Agent Execution

The agent correctly follows the context collection protocol:

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/backend-jwt-auth-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-50-jwt-auth.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### Successful Report

The agent's report includes comprehensive context collection:

```markdown
=== ORCHESTRATOR REPORT ===

## Context Collection Summary
**Files Read:**
- CLAUDE.md - Project uses TypeScript, Node.js 18, ESLint, Prettier. Follows REST API best practices.
- package.json - Express 4.18, jsonwebtoken installed, bcrypt installed, Prisma ORM configured
- src/main.ts - Express app setup, CORS enabled, helmet middleware, error handling middleware
- src/routes/userRoutes.ts - Existing user routes pattern (router pattern, async handlers)
- prisma/schema.prisma - User model exists with email, passwordHash fields. PostgreSQL database.
- .env.example - JWT_SECRET placeholder, DATABASE_URL, PORT=3000

**Research Completed:**
- JWT best practices:
  - Use HS256 algorithm for symmetric signing (appropriate for single-service auth)
  - Access tokens: short-lived (5-15 minutes)
  - Refresh tokens: long-lived (7-30 days), stored in database
  - Never include sensitive data in token payload
  - Implement token blacklist for logout (or use rotating refresh tokens)
- jsonwebtoken library API:
  - jwt.sign(payload, secret, { expiresIn }) for signing
  - jwt.verify(token, secret) for verification with automatic expiration check
  - Error handling: TokenExpiredError, JsonWebTokenError, NotBeforeError
- JWT security vulnerabilities:
  - Algorithm confusion attack mitigation (explicitly specify algorithm: { algorithm: 'HS256' })
  - Token leakage via URL parameters (use Authorization header only)
  - Secret key strength (minimum 32 bytes, cryptographically random)
  - Token revocation strategies (blacklist vs rotating refresh tokens)

**Constraints Understood:**
- ✅ Node.js 18+ with Express 4.18
- ✅ PostgreSQL database with Prisma ORM
- ✅ jsonwebtoken library available
- ✅ JWT_SECRET in environment variables
- ✅ Files allowed: src/auth/, src/middleware/, src/routes/, src/lib/
- ✅ Bcrypt available for password hashing

## Implementation Summary
Implemented complete JWT authentication system with login, token refresh, and protected routes middleware.

[... rest of implementation details ...]
```

### Why This Worked

1. **Explicit Phase 1 instructions** - Agent knew exactly which files to read
2. **Specific Phase 2 research** - Agent knew what to search for and why
3. **Mandatory web search** - Agent performed research and reported findings
4. **Constraint verification** - Agent confirmed understanding before implementing
5. **Comprehensive summary** - Orchestrator can verify context was collected

---

## Example 2: Context Collection Failure + Fix

### Scenario
Delegate React component implementation, but agent skips context collection and uses generic patterns instead of project-specific ones.

### Initial Prompt (Insufficient Context Instructions)

```bash
cat > .claude/gemini-coordination/prompts/task-60-dashboard-widget.txt <<'EOF'
# IMPLEMENTATION TASK - Dashboard Widget

You are gemini-3-flash-preview, expert React developer.

## Task Description
Create a dashboard widget component displaying user statistics.

### Acceptance Criteria
- [ ] Display total users, active users, new users this week
- [ ] Responsive design with Tailwind CSS
- [ ] Loading state while fetching data
- [ ] Error state with retry button
- [ ] Auto-refresh every 30 seconds

### Technical Requirements
1. Use React 18 with TypeScript
2. Fetch data from GET /api/stats/users
3. Display stats in card layout
4. Handle loading, error, success states

[No explicit context collection protocol specified]

## Output Requirements
Provide complete React component with TypeScript types.
EOF
```

### Agent Execution (Failed)

```bash
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-60-dashboard-widget.txt)"
```

### Problem: Agent Missed Project-Specific Patterns

Agent generated code that:
- ✅ Works in general
- ❌ Doesn't follow project's component structure
- ❌ Doesn't use existing API client
- ❌ Doesn't match existing widget patterns
- ❌ Uses different styling approach than project

**Example issues:**
```typescript
// Agent generated (wrong pattern)
import { useState, useEffect } from 'react';
import axios from 'axios'; // ❌ Project uses custom API client

export function UserStatsWidget() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true); // ❌ Project uses useSWR for data fetching

  useEffect(() => {
    axios.get('/api/stats/users') // ❌ Wrong API client
      .then(res => setStats(res.data))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="bg-white rounded-lg shadow p-6"> // ❌ Different card component
      {/* ... */}
    </div>
  );
}
```

### Revised Prompt (With Context Protocol)

```bash
cat > .claude/gemini-coordination/prompts/task-61-dashboard-widget-fixed.txt <<'EOF'
# IMPLEMENTATION TASK - Dashboard Widget

You are gemini-3-flash-preview, **React/Vue/Angular Frontend Developer** (frontend-dev persona).

## Your Expertise
- React functional components with hooks
- Data fetching patterns (useSWR, React Query)
- Component libraries (shadcn/ui, Tailwind CSS)
- TypeScript type safety

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
CRITICAL: You DO NOT have access to the coordinator's context. You MUST explicitly collect context before implementation.

Execute these commands before implementing:
```bash
cat CLAUDE.md
cat package.json
cat src/components/dashboard/*.tsx 2>/dev/null || find src/components -name "*widget*" -o -name "*dashboard*" | head -3
cat src/lib/api.ts 2>/dev/null || cat src/utils/api.ts 2>/dev/null || find src -name "*api*" -type f | head -3
cat src/components/ui/card.tsx 2>/dev/null || cat tailwind.config.js 2>/dev/null || echo "Check UI components"
```

### Phase 2: Research Requirements
For this task, you MUST research:
1. **useSWR patterns** - Data fetching patterns used in project
   - Search: "useSWR data fetching patterns auto refresh"
   - Understand: useSWR API, refreshInterval, error handling, loading states
2. **shadcn/ui Card** - UI component patterns
   - Search: "shadcn ui card component examples"
   - Understand: Card, CardHeader, CardContent, CardTitle usage
3. **React hooks patterns** - Component patterns for widgets
   - Search: "React dashboard widget hooks patterns TypeScript"
   - Understand: Custom hooks, data fetching hooks, error boundary patterns

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project uses React 18+ with TypeScript
- [ ] Data fetching: useSWR (not axios, not fetch)
- [ ] API client: src/lib/api.ts with api.get() helper
- [ ] UI components: shadcn/ui components from src/components/ui/
- [ ] Styling: Tailwind CSS with project's theme
- [ ] Widget pattern: Match existing dashboard widgets
- [ ] Files allowed: src/components/dashboard/, src/hooks/

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Create a dashboard widget component displaying user statistics, following existing project patterns.

### Acceptance Criteria
- [ ] Display total users, active users, new users this week
- [ ] Use project's API client (src/lib/api.ts) to fetch data
- [ ] Use useSWR for data fetching with 30s refresh interval
- [ ] Match existing widget component structure
- [ ] Use shadcn/ui Card component
- [ ] Responsive design with Tailwind CSS
- [ ] Loading state (matches project's loading pattern)
- [ ] Error state with retry button (matches project's error pattern)
- [ ] Auto-refresh every 30 seconds

### Technical Requirements
1. Use React 18 with TypeScript strict mode
2. Fetch from GET /api/stats/users using api.get()
3. Use useSWR for data fetching (install if missing)
4. Follow existing widget component pattern
5. Use Card component from src/components/ui/card
6. Handle loading, error, success states consistently

## Implementation Guidelines
- **IMPORTANT:** Follow existing widget patterns exactly
- Use api.get('/api/stats/users') from src/lib/api.ts
- Use useSWR with refreshInterval: 30000 for auto-refresh
- Match component structure of existing widgets
- Use project's error and loading UI patterns
- TypeScript types for API response

## Files to Read First (Before Implementing)
1. `src/components/dashboard/UserStatsWidget.tsx` - If exists, follow this pattern
2. `src/components/dashboard/AnalyticsWidget.tsx` - Existing widget example
3. `src/lib/api.ts` - API client helper functions
4. `src/components/ui/card.tsx` - Card component usage

## Files to Create/Modify
- [ ] `src/components/dashboard/UserStatsWidget.tsx` - New widget component
- [ ] `src/types/stats.ts` - TypeScript types for stats API response (if not exists)

[Rest of standard Flash template with Context Collection Summary requirement...]
EOF
```

### Agent Execution (Fixed)

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/frontend-dashboard-widget-fixed-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-61-dashboard-widget-fixed.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### Successful Report (With Context Collection)

```markdown
=== ORCHESTRATOR REPORT ===

## Context Collection Summary
**Files Read:**
- CLAUDE.md - React 18, TypeScript strict mode, useSWR for data fetching, shadcn/ui components, Tailwind CSS
- package.json - React 18.2, useSWR 2.0, shadcn/ui components installed, Tailwind CSS 3.3
- src/components/dashboard/AnalyticsWidget.tsx - Found existing widget pattern:
  - Uses useSWR for data fetching with refreshInterval
  - Imports Card from src/components/ui/card
  - Uses api.get() from src/lib/api.ts
  - Custom hook useAnalytics() for data fetching
  - Loading state: <Skeleton /> from shadcn/ui
  - Error state: <Alert /> variant="destructive" with retry button
  - Component structure: Card → CardHeader → CardContent
- src/lib/api.ts - API client helper:
  - export const api = { get: (url) => fetch(...), post: (url, data) => fetch(...) }
  - Includes error handling, auth token injection
  - Base URL from environment variable
- src/components/ui/card.tsx - Card component API:
  - Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter exports
  - Uses className for styling with Tailwind

**Research Completed:**
- useSWR patterns:
  - useSWR(key, fetcher, options) API
  - refreshInterval: 30000 for 30s auto-refresh
  - revalidateOnFocus, revalidateOnReconnect options
  - mutate() for manual revalidation (retry)
  - error object accessible from useSWR return
- shadcn/ui Card usage:
  - Compose subcomponents: Card, CardHeader, CardTitle, CardContent
  - Use className prop for custom styling
  - Consistent spacing and layout patterns
- React widget patterns:
  - Extract data fetching logic to custom hook
  - Use TypeScript interface for API response
  - Handle null/undefined states explicitly

**Constraints Understood:**
- ✅ React 18+ with TypeScript strict mode
- ✅ Use useSWR for data fetching (not axios, not fetch)
- ✅ API client: src/lib/api.ts with api.get() helper
- ✅ UI components: shadcn/ui from src/components/ui/
- ✅ Follow existing widget structure exactly
- ✅ Use Card component with subcomponents
- ✅ Files allowed: src/components/dashboard/, src/hooks/

## Implementation Summary
Created UserStatsWidget component following existing project patterns exactly.

## Files Created
- `src/components/dashboard/UserStatsWidget.tsx` - Dashboard widget component
- `src/types/stats.ts` - TypeScript types for stats API response

## Changes Made
1. Created UserStatsWidget.tsx following AnalyticsWidget.tsx pattern:
   - Custom hook useUserStats() for data fetching
   - useSWR with refreshInterval: 30000 for auto-refresh
   - api.get('/api/stats/users') for API calls
   - Card component with CardHeader, CardTitle, CardContent
   - Loading state: <Skeleton /> from shadcn/ui
   - Error state: <Alert /> with retry button calling mutate()
   - TypeScript types for API response

2. Created stats.ts types:
   - UserStatsResponse interface
   - StatsData interface (totalUsers, activeUsers, newUsersThisWeek)

[... rest of implementation details ...]
```

### Why This Worked

1. **Explicit file reading instructions** - Agent knew exactly which existing components to read
2. **Project-specific constraints** - Agent knew to use useSWR, not axios
3. **Pattern matching requirement** - Agent explicitly told to follow existing widget pattern
4. **Verification in Phase 3** - Agent confirmed understanding before implementing
5. **Context summary verification** - Orchestrator could see agent read the right files

---

## Key Lessons

### Lesson 1: Always Include Explicit Context Protocol

**❌ Without context protocol:**
- Agent makes assumptions
- Uses generic patterns instead of project-specific ones
- Code works but doesn't fit project architecture
- Requires revision and rework

**✅ With context protocol:**
- Agent knows exactly what to read
- Follows project patterns correctly
- Code fits project architecture
- Reduces rework

### Lesson 2: Make Phase 1 Specific

**Too generic:**
```markdown
### Phase 1: Read Project Context
Read relevant files to understand the project.
```

**Specific and actionable:**
```markdown
### Phase 1: Read Project Context (MANDATORY)
Execute these commands before implementing:
```bash
cat CLAUDE.md
cat package.json
cat src/components/dashboard/*.tsx
cat src/lib/api.ts
```
```

### Lesson 3: Require Verification in Phase 3

**Phase 3 should confirm:**
- [ ] Technology versions
- [ ] Available libraries
- [ ] Project-specific patterns
- [ ] File locations
- [ ] What NOT to do

**Example:**
```markdown
### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project uses React 18+ with TypeScript
- [ ] Data fetching: useSWR (not axios, not fetch)
- [ ] UI components: shadcn/ui from src/components/ui/
- [ ] Widget pattern: Match existing dashboard widgets
- [ ] Files allowed: src/components/dashboard/, src/hooks/

**DO NOT proceed until Phase 1-3 complete.**
```

### Lesson 4: Verify Context Collection in Report

**Always require Context Collection Summary:**
```markdown
## Context Collection Summary
**Files Read:**
- CLAUDE.md - [summary of key findings]
- package.json - [dependencies, versions]
- [Existing components] - [patterns observed]

**Research Completed:**
- [Topic 1]: [key findings]
- [Topic 2]: [key findings]

**Constraints Understood:**
- ✅ [Constraint 1]
- ✅ [Constraint 2]
```

**Benefits:**
- Orchestrator can verify agent read the right files
- Orchestrator can see what patterns agent observed
- Orchestrator can confirm agent understood constraints
- If agent missed something, easy to provide targeted feedback

### Lesson 5: Handle Context Collection Failures

**When agent skips context collection:**

1. **Review the report** - Check Context Collection Summary section
2. **Identify what's missing** - Which files weren't read? Which patterns weren't observed?
3. **Provide targeted feedback** - Revise prompt with more explicit instructions
4. **Re-delegate** - Send revised prompt with explicit context protocol
5. **Require verification** - Ask agent to confirm specific patterns observed

**Example feedback:**
```markdown
Your implementation doesn't follow project patterns. Please revise:

**Missing from context collection:**
- You didn't read src/components/dashboard/AnalyticsWidget.tsx
- You didn't observe the useSWR pattern
- You used axios instead of api.get()

**Revised prompt requirements:**
1. Read AnalyticsWidget.tsx FIRST before implementing
2. Use the exact same patterns (useSWR, api.get, Card component)
3. Confirm you've read and understood the existing widget pattern

Please re-implement following existing patterns exactly.
```

### Lesson 6: When to Include Phase 2 (Research)

**Include Phase 2 when:**
- Technology is new or rapidly evolving (e.g., React 19 features)
- Best practices aren't stable or well-known
- Security considerations are critical
- Multiple valid approaches exist (need to choose best one)
- Agent needs latest official documentation

**Skip Phase 2 when:**
- Using stable, well-established patterns
- Project has clear existing patterns to follow
- Task is straightforward implementation
- No ambiguity about best practices

**Example with Phase 2:**
```markdown
### Phase 2: Research Requirements
For this task, you MUST research:
1. **JWT security** - Latest JWT security best practices
   - Search: "JWT authentication best practices 2026"
   - Understand: Token signing algorithms, expiration, revocation

**IMPORTANT: Web search is MANDATORY for Phase 2.**
```

**Example without Phase 2:**
```markdown
### Phase 2: No Research Required
Follow existing project patterns from Phase 1. No external research needed.
```

---

## Quick Reference: Context Protocol Checklist

### ✅ Good Context Protocol

```markdown
## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
CRITICAL: You DO NOT have access to the coordinator's context.

Execute these commands:
```bash
cat CLAUDE.md
cat package.json
cat [specific existing implementation files]
cat [relevant config files]
```

### Phase 2: Research (IF specified)
For this task, research:
- [specific topic 1]
- [specific topic 2]

Search: "[specific search query]"
Understand: [what to look for]

**IMPORTANT: Web search is MANDATORY when Phase 2 is included.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] [Specific constraint 1]
- [ ] [Specific constraint 2]
- [ ] [What NOT to do]

**DO NOT proceed until Phase 1-3 complete.**
```

### ❌ Insufficient Context Protocol

```markdown
## Context

Please read the relevant files and understand the project before implementing.

Make sure to follow best practices.
```

**Problems:**
- No specific files to read
- No research instructions
- No constraint verification
- Agent will make assumptions

---

## Conclusion

Explicit context collection is critical for successful delegation:

1. **Always include Phase 1** - Specify exact files to read
2. **Include Phase 2 when needed** - Research latest best practices
3. **Require Phase 3 verification** - Confirm constraints understood
4. **Verify in report** - Check Context Collection Summary
5. **Handle failures gracefully** - Revise prompt with more specific instructions

**Result:** Agents follow project patterns correctly, reducing rework and improving code quality.
