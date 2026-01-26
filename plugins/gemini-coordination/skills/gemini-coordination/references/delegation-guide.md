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

## Persona Selection Guide

Personas provide role-specific expertise and tailored context collection for different task types. Select the appropriate persona before delegating.

### Quick Reference Table

| Task Type | Primary Persona | Model | Example |
|-----------|-----------------|-------|---------|
| React/Vue/Angular components | frontend-dev | Flash | Implement user registration form with validation |
| Node.js/Python/Rust APIs | backend-dev | Flash | Create REST API endpoints for user management |
| System architecture design | architect | Pro | Design microservices architecture for e-commerce platform |
| Security review/vulnerabilities | security-expert | Pro | Review authentication system for OWASP Top 10 compliance |
| Database schema/optimization | database-specialist | Pro/Flash* | Design database schema for multi-tenant SaaS (Pro) |
|  |  |  | Add indexes to improve query performance (Flash) |
| Test implementation | test-engineer | Flash | Write unit tests for authentication service |
| CI/CD/infrastructure | devops-engineer | Pro/Flash* | Design CI/CD pipeline strategy (Pro) |
|  |  |  | Implement GitHub Actions workflows (Flash) |
| Performance optimization | performance-engineer | Pro/Flash* | Analyze API performance bottlenecks (Pro) |
|  |  |  | Implement caching layer (Flash) |

*Use Pro for design/planning, Flash for implementation

### Detailed Persona Descriptions

#### frontend-dev

**When to use:**
- React/Vue/Angular component development
- Form state management and validation
- Responsive design and CSS implementation
- UI/UX features and interactions
- Accessibility improvements (WCAG compliance)
- State management (Redux, Zustand, Pinia, NgRx)

**Typical tasks:**
- Implement login form with React Hook Form + Zod
- Create dashboard widget with useSWR data fetching
- Build responsive navigation component with Tailwind CSS
- Add ARIA labels and keyboard navigation to form
- Integrate Redux Toolkit for global state

**Model choice:** Flash (90% of time)

#### backend-dev

**When to use:**
- REST/GraphQL API endpoint implementation
- Business logic development
- Service layer implementation
- Data processing pipelines
- Authentication & authorization implementation
- File upload/download handling

**Typical tasks:**
- Create CRUD endpoints for user management
- Implement JWT authentication with refresh tokens
- Build data processing pipeline for analytics
- Add rate limiting middleware
- Integrate third-party API services

**Model choice:** Flash (90% of time)

#### architect

**When to use:**
- System design and architecture decisions
- Microservices vs monolith evaluation
- Technology stack selection
- Scalability and performance architecture
- Migration strategies
- Cross-cutting concerns design

**Typical tasks:**
- Design microservices architecture for SaaS platform
- Evaluate database technologies for new use case
- Plan migration from monolith to microservices
- Design event-driven architecture for real-time features
- Create API design strategy (REST vs GraphQL vs gRPC)

**Model choice:** Pro (for design and analysis)

#### security-expert

**When to use (Analysis - Pro):**
- Security review and vulnerability assessment
- Threat modeling (STRIDE methodology)
- OWASP Top 10 compliance review
- Authentication/authorization architecture review
- Security architecture design

**When to use (Implementation - Flash):**
- Implement security fixes
- Add security headers and CORS policies
- Implement rate limiting
- Add input validation and sanitization

**Typical tasks (Pro):**
- Review authentication system for security vulnerabilities
- Perform threat modeling for payment processing
- Analyze API for OWASP Top 10 compliance
- Design secure authentication architecture

**Typical tasks (Flash):**
- Fix SQL injection vulnerability
- Implement rate limiting middleware
- Add security headers (helmet, CORS)
- Sanitize user input to prevent XSS

**Model choice:** Pro for analysis, Flash for fixes

#### database-specialist

**When to use (Design - Pro):**
- Database schema design
- Data modeling for new features
- Database architecture decisions
- Scalability and replication strategy

**When to use (Implementation - Flash):**
- Database migrations
- Query optimization
- Index optimization
- Performance tuning

**Typical tasks (Pro):**
- Design database schema for multi-tenant SaaS
- Plan migration from PostgreSQL to MongoDB
- Design data partitioning strategy for scale
- Evaluate database technologies for time-series data

**Typical tasks (Flash):**
- Create migration to add user preferences table
- Optimize slow query with indexes
- Fix N+1 query problem with eager loading
- Add database backup strategy

**Model choice:** Pro for design, Flash for migrations

#### test-engineer

**When to use:**
- Unit test implementation
- Integration test setup
- E2E test scenarios
- Test data management
- Coverage improvement
- Testing strategy design

**Typical tasks:**
- Write unit tests for authentication service
- Create integration tests for API endpoints
- Build E2E tests for user registration flow
- Set up test fixtures and factories
- Improve code coverage from 60% to 90%

**Model choice:** Flash (90% of time), Pro for test strategy design

#### devops-engineer

**When to use (Design - Pro):**
- CI/CD pipeline architecture design
- Infrastructure design and strategy
- Deployment strategy planning
- Monitoring and observability design
- Security architecture for infrastructure

**When to use (Implementation - Flash):**
- CI/CD pipeline implementation
- Docker containerization
- Kubernetes configuration
- Infrastructure as Code (Terraform, Pulumi)
- Monitoring and alerting setup

**Typical tasks (Pro):**
- Design CI/CD pipeline strategy for microservices
- Plan Kubernetes cluster architecture
- Design monitoring and observability stack
- Plan migration to cloud infrastructure

**Typical tasks (Flash):**
- Implement GitHub Actions workflows
- Create Dockerfiles for microservices
- Write Kubernetes manifests for deployment
- Set up Prometheus and Grafana monitoring

**Model choice:** Pro for design, Flash for implementation

#### performance-engineer

**When to use (Analysis - Pro):**
- Performance bottleneck analysis
- Profiling and hotspot identification
- Performance testing strategy
- Optimization planning

**When to use (Implementation - Flash):**
- Performance optimization implementation
- Caching layer implementation
- Query optimization
- Code optimization

**Typical tasks (Pro):**
- Analyze slow API endpoint performance bottlenecks
- Profile memory usage in Node.js application
- Design caching strategy for high-traffic API
- Plan performance optimization roadmap

**Typical tasks (Flash):**
- Implement Redis caching for API responses
- Optimize database queries with indexes
- Add CDN for static assets
- Implement lazy loading for frontend components

**Model choice:** Pro for analysis, Flash for optimization

### Persona-Model Alignment

**Flash (90% of implementation tasks):**
- frontend-dev - UI components, forms, state management
- backend-dev - API endpoints, business logic, services
- test-engineer - Test implementation, fixtures, coverage
- database-specialist - Migrations, query optimization
- security-expert - Security fixes, vulnerability patches
- performance-engineer - Performance optimization, caching
- devops-engineer - CI/CD implementation, Docker, Kubernetes

**Pro (all planning, complex analysis, architecture):**
- architect - System design, architecture decisions
- security-expert - Security review, threat modeling, compliance
- database-specialist - Database design, data modeling
- performance-engineer - Performance analysis, profiling
- devops-engineer - Infrastructure design, CI/CD architecture

### Using Personas in Delegation

**Step 1: Select Persona**
Choose persona based on task type (see quick reference above)

**Step 2: Copy Persona Template**
See `references/persona-library.md` for complete persona definitions with:
- Identity and expertise
- Context collection protocol (Phase 1-3)
- Prompt injection template

**Step 3: Create Prompt**
Combine persona template with standard Flash/Pro template from `references/prompt-templates.md`

**Step 4: Execute Delegation**
Use gemini-cli with appropriate model (Flash or Pro)

**Example:**
```bash
# Task: Implement React form with validation
# Persona: frontend-dev
# Model: Flash

cat > prompt.txt <<'EOF'
# IMPLEMENTATION TASK - User Registration Form

You are gemini-3-flash-preview, **React/Vue/Angular Frontend Developer** (frontend-dev persona).

## Your Expertise
[Copy from persona-library.md]

## Context Collection Protocol
[Copy from persona-library.md - includes Phase 1-3]

[Rest of Flash template...]
EOF

gemini -m gemini-3-flash-preview --approval-mode yolo -p "$(cat prompt.txt)"
```

### Combining Personas

For complex tasks requiring multiple domains:

**Sequential Delegation:**
1. architect (Pro) → Design system architecture
2. database-specialist (Pro) → Design database schema
3. backend-dev (Flash) → Implement API endpoints
4. test-engineer (Flash) → Write tests

**Parallel Delegation:**
- frontend-dev (Flash) + backend-dev (Flash) for full-stack feature
- Delegate to both personas simultaneously, then integrate

**Two-Phase Delegation:**
- performance-engineer (Pro) → Analyze bottlenecks
- performance-engineer (Flash) → Implement optimizations

### Persona Library Location

Complete persona definitions with:
- Full capability descriptions
- Context collection protocols (Phase 1-3)
- Prompt injection templates
- Research topics and web search queries

See: `references/persona-library.md`

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
