# Persona-Driven Delegation Examples

Complete examples demonstrating how to use personas for different task types with the gemini-coordination skill.

## Example 1: React Form Implementation (frontend-dev)

### Task Description
Implement a user registration form with validation using React, React Hook Form, Zod, and Tailwind CSS.

### Persona Selection
- **Persona:** frontend-dev
- **Model:** gemini-3-flash-preview
- **Rationale:** Frontend implementation task with React, forms, and validation

### Complete Prompt

```bash
cat > .claude/gemini-coordination/prompts/task-20-user-registration-form.txt <<'EOF'
# IMPLEMENTATION TASK - User Registration Form

You are gemini-3-flash-preview, **React/Vue/Angular Frontend Developer** (frontend-dev persona).

## Your Expertise
- React functional components with hooks (useState, useEffect, useContext)
- Form state management (React Hook Form, Formik)
- Validation patterns (Zod, Yup)
- Responsive design with Tailwind CSS
- Accessibility (WCAG 2.1 AA, ARIA labels, keyboard navigation)
- Error handling and user feedback
- Loading states for async operations

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
Execute these commands before implementing:
```bash
cat CLAUDE.md
cat package.json
cat tsconfig.json 2>/dev/null || echo "No TypeScript config"
cat tailwind.config.js 2>/dev/null || cat vite.config.ts 2>/dev/null || echo "Check build config"
find src/components -name "*form*" -o -name "*input*" -type f | head -3
cat src/styles/globals.css 2>/dev/null || cat src/index.css 2>/dev/null || echo "Check styling"
```

### Phase 2: Research Requirements
For this task, you MUST research:
1. **React Hook Form** - Latest API and best practices
   - Search: "react hook form documentation 2026"
   - Understand: useForm, register, validation schema integration
2. **Zod validation** - Schema validation patterns
   - Search: "zod validation schema examples react hook form"
   - Understand: z.object(), z.string(), email validation, password requirements
3. **Tailwind CSS forms** - Form styling
   - Search: "tailwind css form plugin styling best practices"
   - Understand: Form plugin, responsive form layouts, focus states
4. **Accessibility** - Form accessibility patterns
   - Search: "accessible form validation WCAG ARIA"
   - Understand: ARIA attributes, error announcement, keyboard navigation

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project uses React 18+ with TypeScript strict mode
- [ ] Form library available: react-hook-form (install if missing)
- [ ] Validation library: zod (install if missing)
- [ ] Styling: Tailwind CSS configured with @tailwindcss/forms plugin
- [ ] Files allowed: src/components/forms/, src/lib/validation/, src/types/
- [ ] No existing registration form component

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Implement a user registration form with real-time validation, accessible error messages, and responsive design.

### Acceptance Criteria
- [ ] Form uses React Hook Form with Zod schema validation
- [ ] Fields: full name, email, password, confirm password
- [ ] Real-time validation with error messages
- [ ] Password requirements: min 8 chars, 1 uppercase, 1 lowercase, 1 number
- [ ] Email validation format
- [ ] Confirm password matches password
- [ ] Accessible: proper labels, ARIA attributes, error announcements
- [ ] Responsive: mobile-first with Tailwind CSS
- [ ] Loading state during form submission
- [ ] Success message after submission
- [ ] Form submission handler calls API endpoint (mock for now)

### Technical Requirements
1. Use React functional components with TypeScript
2. React Hook Form for form state management
3. Zod for validation schema
4. Tailwind CSS for styling
5. Accessible error messages (role="alert", aria-live)
6. Responsive design (mobile-first)
7. Loading state with disabled submit button during submission

## Implementation Guidelines
- Follow React best practices from research
- Ensure WCAG 2.1 AA compliance
- Use semantic HTML (form, label, input, button)
- Provide clear, helpful error messages
- Show loading state with visual feedback
- Use Tailwind's form plugin for consistent styling
- Implement proper error boundary handling

## Files to Create/Modify
- [ ] `src/components/forms/RegistrationForm.tsx` - Main registration form component
- [ ] `src/lib/validation/registrationSchema.ts` - Zod validation schema
- [ ] `src/types/registration.ts` - TypeScript types for form data

## Output Requirements
For each file, provide:
1. Complete file with imports
2. Full TypeScript code (not snippets)
3. Brief explanation of key patterns used

---

MANDATORY PRE-REPORT REQUIREMENTS:

**Context Collection Summary (Must include in report):**

Before final report, document what context was collected:
- **Files Read:** List all files read with brief summaries
- **Research Completed:** Key findings from web search (React Hook Form, Zod, Tailwind forms, accessibility)
- **Constraints Understood:** Confirm understanding of project constraints

**Static Code Analysis:**
Run linting/type checking before final report:
```bash
npm run lint
npm run typecheck
```

**Error Retry Protocol:**
If static analysis fails:
- Attempt 1: Auto-fix with `npm run lint -- --fix`
- Attempt 2: Fix specific errors manually
- Attempt 3: Document difficulties in report

**Limitations:**
- ❌ NEVER delete files
- ❌ NEVER remove packages
- ❌ NEVER run final validation (Orchestrator's responsibility)

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Context Collection Summary
**Files Read:**
- CLAUDE.md - [summary of project standards]
- package.json - [dependencies: React, Tailwind, available libraries]
- [Other key files and summaries]

**Research Completed:**
- React Hook Form: [key API learnings - useForm, register, validation]
- Zod validation: [schema patterns, error handling]
- Tailwind forms: [responsive patterns, form plugin usage]
- Accessibility: [ARIA attributes, error announcements]

**Constraints Understood:**
- ✅ React 18+ with TypeScript strict mode
- ✅ Tailwind CSS configured
- ✅ Install react-hook-form and zod if missing
- ✅ Files allowed: src/components/forms/, src/lib/validation/, src/types/

## Implementation Summary
[Concise summary of what was implemented]

## Files Modified
- `src/components/forms/RegistrationForm.tsx` - [description]
- `src/lib/validation/registrationSchema.ts` - [description]
- `src/types/registration.ts` - [description]

## Changes Made
[Description of changes in each file]

## Static Analysis Results
✅ PASSED - All linting and type checking passed
(or)
❌ FAILED - [details after 3 attempts]

## Testing Performed
[Manual testing performed - e.g., form validation, error display, responsiveness]

## Results
**Achievements:**
- [x] All acceptance criteria completed
- [x] Accessible form with proper ARIA attributes
- [x] Responsive design working on mobile and desktop

## Issues Found
[Any problems encountered and how they were resolved]

=== END REPORT ===
EOF
```

### Execution

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/frontend-user-registration-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-20-user-registration-form.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### Validation

After delegation completes, review the report and validate:

```bash
# Check report
cat "$REPORT_FILE"

# Run tests (if available)
npm test

# Start development server for visual validation
npm run dev
```

---

## Example 2: Security Review (security-expert)

### Task Description
Review authentication system for security vulnerabilities and OWASP Top 10 compliance.

### Persona Selection
- **Persona:** security-expert
- **Model:** gemini-3-pro-preview (for analysis and threat modeling)
- **Rationale:** Security analysis requires deep reasoning and threat modeling

### Complete Prompt

```bash
cat > .claude/gemini-coordination/prompts/task-30-auth-security-review.txt <<'EOF'
# SECURITY TASK - Authentication System Security Review

You are gemini-3-pro-preview, **Application Security Specialist** (security-expert persona).

## Your Expertise
- Threat modeling (STRIDE, attack trees, risk assessment)
- OWASP Top 10 mitigation (injection, broken auth, XSS, CSRF, etc.)
- Authentication & authorization (JWT, OAuth2, session management, RBAC)
- Cryptography (encryption, hashing, key management)
- API security (rate limiting, CORS, API key management)
- Secure coding practices (input validation, error handling, logging)
- Dependency security (vulnerability scanning, supply chain)
- Compliance (GDPR, HIPAA, PCI DSS, SOC 2)
- Security testing (SAST, DAST, penetration testing)

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
Execute these commands before security analysis:
```bash
cat CLAUDE.md
cat README.md 2>/dev/null || echo "No README"
cat src/auth/*.ts 2>/dev/null || cat src/auth/*.py 2>/dev/null || find src -path "*auth*" -type f | head -5
cat .env.example 2>/dev/null || cat config/security.yml 2>/dev/null || echo "Check security config"
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
cat src/routes/*.ts 2>/dev/null || cat app/routes/ 2>/dev/null || find src -name "*route*" | head -5
cat prisma/schema.prisma 2>/dev/null || cat src/models/*.ts 2>/dev/null || cat app/models.py 2>/dev/null
cat src/middleware/*.ts 2>/dev/null || cat app/middleware/ 2>/dev/null || find src -name "*security*" | head -5
```

### Phase 2: Research Requirements
For this security review, you MUST research:
1. **Authentication vulnerabilities** - Common auth security issues
   - Search: "authentication security vulnerabilities OWASP 2026"
   - Understand: JWT attacks, session fixation, brute force, credential stuffing
2. **OWASP guidelines** - Relevant OWASP resources
   - Search: "OWASP authentication cheat sheet broken authentication"
   - Understand: OWASP Top 10, ASVS requirements, authentication security
3. **JWT security** - If JWT is used
   - Search: "JWT security best practices token storage 2026"
   - Understand: Token storage, signing algorithms, expiration, refresh tokens
4. **Compliance** - If applicable
   - Search: "authentication security compliance GDPR password requirements"
   - Understand: Password requirements, MFA requirements, data protection

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before analysis, confirm:
- [ ] Application type: [web/API/mobile]
- [ ] Authentication mechanism: [JWT/OAuth2/session/etc.]
- [ ] Data sensitivity: [public/internal/confidential/PII/PHI]
- [ ] Compliance requirements: [GDPR/HIPAA/PCI/etc.]
- [ ] User base: [internal/external/public/privileged]
- [ ] Infrastructure: [cloud/on-premise/container/serverless]
- [ ] Testing constraints: [production access/staging environment]

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Perform comprehensive security review of the authentication system, identify vulnerabilities, and provide remediation plan.

### Scope
1. Authentication flow (login, logout, token management)
2. Authorization mechanisms (RBAC, permissions)
3. Session management
4. Password handling (hashing, validation, reset)
5. Token handling (JWT generation, validation, refresh)

### Security Requirements
1. Comply with OWASP Top 10
2. Protect against common authentication attacks
3. Secure password handling (hashing, storage)
4. Proper token management (generation, validation, expiration)
5. Secure session management
6. Rate limiting and brute force protection
7. Secure error handling (no information leakage)
8. Audit logging for security events

### Analysis Required
1. **Threat Model** - Identify threats using STRIDE methodology
2. **Vulnerability Assessment** - Known and potential vulnerabilities with CVE references
3. **Risk Analysis** - Severity (CVSS), impact, likelihood
4. **Compliance Review** - OWASP ASVS, compliance requirements

## Output Requirements
Provide structured security analysis with:

1. **Threat Model** - Identified threats using STRIDE methodology
2. **Vulnerability Assessment** - Known and potential vulnerabilities (CVE references)
3. **Risk Analysis** - Severity (CVSS), impact, likelihood
4. **Security Findings** - Categorized by severity (Critical/High/Medium/Low)
5. **Remediation Plan** - Specific fixes prioritized by risk
6. **Security Best Practices** - Recommendations for hardening
7. **Compliance Review** - Compliance gaps (if applicable)
8. **Security Testing Strategy** - Recommended security tests

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Context Collection Summary
**Files Read:**
- CLAUDE.md - [security policies and standards]
- README.md - [application overview]
- [Auth/security files - authentication flow, token handling]

**Research Completed:**
- Authentication vulnerabilities: [common attack vectors, recent CVEs]
- OWASP guidelines: [relevant controls and requirements]
- JWT security: [token storage, signing, expiration best practices]
- Compliance: [requirement gaps]

**Constraints Understood:**
- ✅ Application type: [web/API]
- ✅ Authentication: [mechanism]
- ✅ Data sensitivity: [level]
- ✅ Compliance: [requirements]

## Threat Model
[Identified threats with STRIDE categories - Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege]

## Vulnerability Assessment
[Known/potential vulnerabilities with CVE references and descriptions]

## Risk Analysis
[Risk matrix with CVSS scores, impact, likelihood]

## Security Findings
**Critical:**
- [ ] [vulnerability] - [description, CWE, CVSS score]

**High:**
- [ ] [vulnerability] - [description, CWE, CVSS score]

**Medium:**
- [ ] [vulnerability] - [description, CWE, CVSS score]

**Low:**
- [ ] [vulnerability] - [description, CWE, CVSS score]

## Remediation Plan
**Priority 1 (Critical - Fix Immediately):**
1. [vulnerability] - [specific fix steps]

**Priority 2 (High - Fix Within 7 Days):**
1. [vulnerability] - [specific fix steps]

**Priority 3 (Medium - Fix Within 30 Days):**
1. [vulnerability] - [specific fix steps]

**Priority 4 (Low - Fix Next Cycle):**
1. [vulnerability] - [specific fix steps]

## Security Best Practices
[Hardening recommendations for authentication system]

## Compliance Review
[Compliance status for OWASP ASVS, GDPR, HIPAA, PCI DSS, etc.]

## Security Testing Strategy
[Recommended security tests - SAST, DAST, penetration testing, dependency scanning]

=== END REPORT ===
EOF
```

### Execution

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/security-auth-review-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-30-auth-security-review.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

---

## Example 3: Performance Optimization (performance-engineer)

### Task Description
Diagnose and fix slow API endpoint causing timeout issues.

### Persona Selection
- **Persona:** performance-engineer
- **Model:** gemini-3-pro-preview (for analysis) → gemini-3-flash-preview (for fixes)
- **Rationale:** Two-phase approach - analyze bottleneck first, then implement optimizations

### Phase 1: Analysis (Pro)

```bash
cat > .claude/gemini-coordination/prompts/task-40-api-performance-analysis.txt <<'EOF'
# PERFORMANCE TASK - API Endpoint Performance Analysis

You are gemini-3-pro-preview, **Performance Optimization Specialist** (performance-engineer persona).

## Your Expertise
- Profiling tools (Chrome DevTools, pprof, flamegraphs)
- Backend performance (DB queries, caching, connection pooling)
- API performance (rate limiting, pagination, compression)
- Database optimization (indexes, query optimization)
- Caching strategies (Redis, Memcached, application caching)
- Load testing (k6, Artillery, JMeter)
- Performance monitoring (APM, profiling)
- Scaling strategies (horizontal vs vertical, load balancing)

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
Execute these commands before performance analysis:
```bash
cat CLAUDE.md
cat src/main.ts 2>/dev/null || cat app/main.py 2>/dev/null || cat server.js 2>/dev/null
cat src/routes/*.ts 2>/dev/null || cat app/routes/ 2>/dev/null || find src -name "*route*" | head -5
cat prisma/schema.prisma 2>/dev/null || cat src/models/*.ts 2>/dev/null || cat app/models.py 2>/dev/null
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
cat docker-compose.yml 2>/dev/null | grep -A 5 "redis\|postgres" || echo "Check infrastructure"
```

### Phase 2: Research Requirements
For this performance analysis, you MUST research:
1. **[Language/Framework] profiling** - Profiling tools and techniques
   - Search: "[Node.js/Python] profiling performance bottlenecks 2026"
   - Understand: Profiling tools, flamegraph interpretation, hotspot identification
2. **Database optimization** - Query optimization patterns
   - Search: "database query optimization indexing N+1 problem"
   - Understand: Indexes, query patterns, N+1 problem, connection pooling
3. **API optimization** - API performance patterns
   - Search: "REST API performance optimization caching pagination"
   - Understand: Pagination, compression, response optimization
4. **Load testing tools** - Performance testing approaches
   - Search: "k6 load testing API performance examples"
   - Understand: Test design, metrics, threshold setting

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before analysis, confirm:
- [ ] Application type: [Node.js/Python/etc.]
- [ ] Performance target: [e.g., latency < 200ms p95]
- [ ] Current bottleneck: [symptoms - timeout, slow response]
- [ ] Scale requirements: [users/requests per second]
- [ ] Caching available: [Redis/Memcached]
- [ ] Monitoring: [APM/profiling tools available]

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Analyze slow API endpoint causing timeout issues (>30s response time). Identify bottlenecks and recommend optimizations.

### Scope
1. Endpoint: GET /api/users/:id with related data
2. Database queries (N+1 problem suspected)
3. Response serialization
4. Network overhead

### Performance Requirements
1. Target: p95 latency < 500ms
2. Current: p95 latency > 30s
3. Scale: 10k requests/minute

### Analysis Required
1. **Current Performance** - Baseline measurement and bottleneck identification
2. **Database Analysis** - Query performance, N+1 queries, missing indexes
3. **Caching Opportunities** - Data that can be cached
4. **Serialization** - Response transformation overhead
5. **Optimization Strategy** - Specific optimizations with expected impact

## Output Requirements
Provide structured performance analysis with:

1. **Performance Baseline** - Current performance metrics
2. **Profiling Results** - Hotspots, bottlenecks (with data)
3. **Database Analysis** - Slow queries, N+1 problems, missing indexes
4. **Caching Strategy** - What to cache, cache keys, TTL
5. **Optimization Recommendations** - Prioritized by impact
6. **Expected Improvement** - Estimated performance gains
7. **Implementation Plan** - Step-by-step optimization approach

CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===

## Context Collection Summary
**Files Read:**
- CLAUDE.md - [performance standards]
- [Application code - endpoint implementation]

**Research Completed:**
- [Language/Framework] profiling: [profiling tools and techniques]
- Database optimization: [query patterns, indexing]
- API optimization: [caching, pagination strategies]
- Load testing: [testing tools and approaches]

**Constraints Understood:**
- ✅ Application type: [Node.js/Python]
- ✅ Target: p95 < 500ms
- ✅ Current: p95 > 30s
- ✅ Caching: [Redis available]

## Performance Baseline
[Current performance metrics - p50, p95, p99 latency, throughput]

## Profiling Results
[Bottleneck identification with profiling data]
- Database queries: [X]% of time
- Serialization: [X]% of time
- Network: [X]% of time

## Database Analysis
[Slow queries, N+1 problems, missing indexes]

## Caching Opportunities
[Data that can be cached with cache keys and TTL]

## Optimization Recommendations
**Priority 1 (High Impact, Low Effort):**
1. [optimization] - [expected improvement]

**Priority 2 (High Impact, Medium Effort):**
1. [optimization] - [expected improvement]

**Priority 3 (Medium Impact, Medium Effort):**
1. [optimization] - [expected improvement]

## Expected Improvement
- [After Priority 1]: p95 latency < [X]ms
- [After All]: p95 latency < 500ms

## Implementation Plan
[Step-by-step optimization approach]

=== END REPORT ===
EOF
```

### Execution (Analysis Phase)

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/perf-api-analysis-$TIMESTAMP.md"
gemini -m gemini-3-pro-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-40-api-performance-analysis.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

### Phase 2: Implementation (Flash)

After receiving the analysis, create implementation prompt:

```bash
cat > .claude/gemini-coordination/prompts/task-41-api-performance-fixes.txt <<'EOF'
# IMPLEMENTATION TASK - API Performance Fixes

You are gemini-3-flash-preview, **Backend Developer** (backend-dev persona).

## Your Expertise
- [Framework] API development
- Database optimization (queries, indexes, N+1 problems)
- Caching implementation (Redis, application caching)
- API response optimization
- Performance testing

## Context Collection Protocol

### Phase 1: Read Analysis Report
Read the performance analysis report from previous phase:
```bash
cat .claude/gemini-coordination/reports/perf-api-analysis-[TIMESTAMP].md
```

### Phase 2: No Research Required
Use recommendations from analysis report.

### Phase 3: Understand Implementation Plan
Implement optimizations Priority 1 and Priority 2 from analysis report.

## Task Description
Implement performance optimizations for GET /api/users/:id endpoint based on analysis.

### Acceptance Criteria
- [ ] Implement database query optimization (fix N+1, add indexes)
- [ ] Implement caching layer (Redis cache for user data)
- [ ] Optimize response serialization
- [ ] Add performance monitoring (timing logs)
- [ ] Load test to verify improvement (p95 < 500ms)

### Implementation Requirements
1. Fix N+1 query problem with eager loading
2. Add database indexes on foreign keys
3. Implement Redis caching with TTL
4. Optimize JSON serialization
5. Add timing logs for monitoring

[Rest of standard Flash implementation template...]
EOF
```

### Execution (Implementation Phase)

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/perf-api-fixes-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-41-api-performance-fixes.txt)" \
  2>&1 | tee "$REPORT_FILE"
```

---

## Key Takeaways

### Persona Selection
1. **Match persona to task type** - frontend tasks → frontend-dev, security → security-expert
2. **Consider model choice** - Pro for analysis/planning, Flash for implementation
3. **Use two-phase delegation** for complex tasks (Pro analysis → Flash implementation)

### Context Collection
1. **Always include Phase 1** - Read project files (CLAUDE.md, package.json, existing code)
2. **Include Phase 2 when needed** - Research latest best practices, official docs
3. **Make Phase 2 explicit** - When included, web search is MANDATORY
4. **Verify Phase 3** - Confirm constraints understood before proceeding

### Prompt Structure
1. **Inject persona identity** - "You are gemini-3-flash-preview, **[Persona Name]** ([persona-id] persona)"
2. **Include expertise section** - Copy from persona library
3. **Include context protocol** - All 3 phases with specific commands
4. **Clear acceptance criteria** - Testable requirements
5. **Mandatory report section** - Context Collection Summary + findings

### Verification
1. **Review the report** - Check "Context Collection Summary" section
2. **Verify web search completed** - When Phase 2 was specified
3. **Validate implementation** - Run tests, build, manual testing
4. **Iterate if needed** - Provide more context if agent missed something

### Common Patterns

**Simple implementation (single phase):**
- frontend-dev, backend-dev, test-engineer → Flash only
- Single prompt with persona + context protocol

**Complex analysis (two phases):**
- architect, security-expert, performance-engineer → Pro for analysis
- May require Flash follow-up for implementation
- Analysis prompt → Review → Implementation prompt

**Domain-specific tasks:**
- Use specialized persona (database-specialist, devops-engineer)
- Persona provides domain-specific context protocol
- Research phase focuses on domain-specific best practices
