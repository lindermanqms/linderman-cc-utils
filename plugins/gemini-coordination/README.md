# Gemini Coordination Plugin

Skill for coordinating delegations to Gemini AI models (Pro and Flash) with specialized personas and explicit context collection protocols.

## What It Does

Transforms Claude Code into a coordinator that leverages multiple AI models with role-specific expertise:

- **gemini-3-pro-preview**: System design, architecture, security analysis, performance optimization
- **gemini-3-flash-preview**: Code implementation, bug fixes, testing, infrastructure
- **Claude Code (Orchestrator)**: Final validation, testing, project management

**Core Principle**: Coordinate, don't code. Delegate everything to appropriate models with specialized personas, then validate results.

## v2.0.0 - What's New

### 🎭 Specialized Personas
8 role-specific personas with domain expertise:
- **frontend-dev** - React/Vue/Angular UI development, forms, validation
- **backend-dev** - Node.js/Python/Rust APIs, REST/GraphQL, authentication
- **architect** - System design, microservices vs monolith, technology choices
- **security-expert** - Security review, threat modeling, vulnerability assessment
- **database-specialist** - Schema design, migrations, query optimization
- **test-engineer** - Unit/integration/E2E tests, mocking, coverage
- **devops-engineer** - CI/CD, Docker, Kubernetes, infrastructure
- **performance-engineer** - Performance analysis, profiling, optimization

### 📚 Explicit Context Collection Protocol
Every persona includes a 3-phase context collection protocol:
1. **Phase 1**: Read project context (CLAUDE.md, package.json, existing code)
2. **Phase 2**: Research latest best practices (web search MANDATORY when specified)
3. **Phase 3**: Understand constraints before implementing

**Result**: Agents now follow project patterns correctly and understand what to read/research before coding.

### 📖 Complete Documentation
- **persona-library.md**: 8 complete persona definitions with templates
- **persona-driven-delegation.md**: 3 real-world examples
- **context-collection-in-action.md**: Success/failure case studies

## Installation

### Prerequisites

1. **Install gemini-cli:**
   ```bash
   npm install -g gemini-cli
   gemini --version
   ```

2. **Configure API key:**
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   ```

Get API key: https://makersuite.google.com/app/apikey

### Activate Plugin

This plugin is registered in the `linderman-cc-utils` marketplace. The skill activates automatically when you use trigger phrases.

## Usage

### Automatic Activation

The skill activates when you use these phrases:

- "delegate to gemini"
- "use gemini for"
- "let gemini handle"
- "coordinate with gemini"
- "orchestrate with gemini"
- "gemini-cli"

### Quick Example with Persona

```bash
# 1. Select persona (frontend-dev for React form)
# 2. Create prompt with persona template
cat > .claude/gemini-coordination/prompts/task-20-user-registration.txt <<'EOF'
# IMPLEMENTATION TASK - User Registration Form

You are gemini-3-flash-preview, **React/Vue/Angular Frontend Developer** (frontend-dev persona).

## Your Expertise
- React functional components with hooks
- Form state management (React Hook Form, Formik)
- Validation patterns (Zod, Yup)
- Responsive design with Tailwind CSS
- Accessibility (WCAG 2.1 AA, ARIA labels)

## Context Collection Protocol

### Phase 1: Read Project Context (MANDATORY)
Execute these commands before implementing:
```bash
cat CLAUDE.md
cat package.json
cat src/components/*.tsx
cat src/lib/api.ts
```

### Phase 2: Research Requirements
For this task, you MUST research:
1. **React Hook Form** - Latest API and best practices
   Search: "react hook form documentation 2026"
2. **Zod validation** - Schema validation patterns
   Search: "zod validation schema examples"
3. **Tailwind forms** - Form styling
   Search: "tailwind css form styling best practices"

**IMPORTANT: Web search is MANDATORY for Phase 2.**

### Phase 3: Understand Constraints
Before implementing, confirm:
- [ ] Project uses React 18+ with TypeScript
- [ ] Form library: react-hook-form (install if missing)
- [ ] Validation: zod (install if missing)
- [ ] Styling: Tailwind CSS configured
- [ ] Files allowed: src/components/, src/lib/

**DO NOT proceed until Phase 1-3 complete.**

## Task Description
Implement a user registration form with real-time validation.

### Acceptance Criteria
- [ ] Form uses React Hook Form with Zod schema
- [ ] Fields: email, password, confirm password
- [ ] Real-time validation with error messages
- [ ] Responsive design with Tailwind CSS
- [ ] Accessible: ARIA labels, keyboard navigation
- [ ] Loading state during submission

[Rest of template...]
EOF

# 3. Execute delegation
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat .claude/gemini-coordination/prompts/task-20-user-registration.txt)" \
  2>&1 | tee .claude/gemini-coordination/reports/frontend-form-$(date +%Y%m%d-%H%M).md

# 4. Review report (includes Context Collection Summary)
cat .claude/gemini-coordination/reports/frontend-form-*.md
```

## Persona Selection

### Quick Reference

| Task Type | Persona | Model | Example |
|-----------|---------|-------|---------|
| React/Vue/Angular components | frontend-dev | Flash | Implement login form with validation |
| Node.js/Python/Rust APIs | backend-dev | Flash | Create REST API endpoints |
| System architecture design | architect | Pro | Design microservices architecture |
| Security review/vulnerabilities | security-expert | Pro | Review auth for OWASP Top 10 |
| Database schema/optimization | database-specialist | Pro/Flash* | Design schema / Add indexes |
| Test implementation | test-engineer | Flash | Write unit/integration tests |
| CI/CD/infrastructure | devops-engineer | Pro/Flash* | Design CI/CD / Implement workflows |
| Performance optimization | performance-engineer | Pro/Flash* | Analyze bottlenecks / Implement caching |

*Use Pro for design/planning, Flash for implementation

### Detailed Guide

See `references/delegation-guide.md` for complete persona descriptions and when to use each.

## Documentation

The skill uses **progressive disclosure** - detailed content loaded on demand.

### Core Documentation (SKILL.md)

- Overview and workflow
- Model selection guide (Pro vs Flash)
- Persona-based delegation
- Context collection protocol
- Critical reminders

### Reference Documentation

- **`references/persona-library.md`** ⭐ NEW - Complete persona definitions with context protocols
- **`references/prompt-templates.md`** - Enhanced Flash/Pro templates with persona integration
- **`references/delegation-guide.md`** - When and how to delegate, persona selection guide
- **`references/validation-protocol.md`** - Validation procedures
- **`references/troubleshooting.md`** - Common issues and solutions

### Working Examples

- **`examples/persona-driven-delegation.md`** ⭐ NEW - 3 complete examples with personas:
  - React Form (frontend-dev)
  - Security Review (security-expert)
  - Performance Optimization (performance-engineer - two-phase)

- **`examples/context-collection-in-action.md`** ⭐ NEW - Success/failure case studies:
  - Successful context collection
  - Context collection failure + fix

- **`examples/simple-delegation.md`** - Single-task workflow
- **`examples/complex-orchestration.md`** - Multi-phase (Pro→Flash) workflow

## Key Features

✅ **8 Specialized Personas** - Role-specific expertise for different domains
✅ **Explicit Context Protocol** - Agents know exactly what to read/research
✅ **Zero external dependencies** - No scripts, no external template files
✅ **Direct execution** - Execute via `gemini --approval-mode yolo`
✅ **Inline prompt creation** - Use heredoc with persona templates
✅ **Progressive disclosure** - Templates and personas in references/
✅ **Context verification** - Reports include Context Collection Summary

## Workflow (with Personas)

1. **Select persona** - Choose appropriate persona for task type
2. **Copy persona template** - From `references/persona-library.md`
3. **Create prompt** - Inline using heredoc with persona + context protocol
4. **Execute delegation** - Direct gemini-cli invocation (Flash or Pro)
5. **Validate results** - Review Context Collection Summary in report
6. **Test and approve** - Orchestrator runs tests and approves

## Model Selection

### gemini-3-pro-preview

**Use for:**
- System design and architecture
- Security review and threat modeling
- Performance analysis and profiling
- Database schema design
- Complex problem analysis
- Trade-off evaluation
- Infrastructure design

**Persona archetypes:** architect, security-expert, database-specialist, performance-engineer, devops-engineer

### gemini-3-flash-preview

**Use for:**
- Feature implementation
- Code refactoring
- Bug fixes
- Test writing
- Database migrations
- CI/CD implementation
- Security fixes
- Performance optimization

**Persona archetypes:** frontend-dev, backend-dev, test-engineer, database-specialist, security-expert, performance-engineer, devops-engineer

## Benefits of Personas

### Before (v1.0.0)
- ❌ Generic prompts without domain expertise
- ❌ Agents skip reading project files
- ❌ Code works but doesn't follow project patterns
- ❌ Multiple revision cycles needed

### After (v2.0.0)
- ✅ Role-specific expertise (8 personas)
- ✅ Explicit context collection (3-phase protocol)
- ✅ Agents follow project patterns correctly
- ✅ Reduced rework, better code quality

## Context Collection Protocol

Every persona includes a mandatory 3-phase context collection protocol:

**Phase 1: Read Project Context (MANDATORY)**
- Execute specific commands to read CLAUDE.md, package.json, existing code
- Persona-specific files (e.g., schema.prisma for database-specialist)

**Phase 2: Research (IF specified)**
- Web search for latest best practices
- Official documentation for libraries/frameworks
- Domain-specific patterns
- **IMPORTANT**: When Phase 2 is included, web search is MANDATORY

**Phase 3: Understand Constraints**
- Confirm project coding standards
- Verify existing patterns to follow
- Check files allowed/forbidden
- Understand dependencies available
- Review security/performance considerations

**Agents must NOT proceed until all phases complete.**

## Version History

**v2.0.0** (2026-01-27) - Personas and Context Collection Protocol
- Added 8 specialized personas with domain expertise
- Implemented explicit 3-phase context collection protocol
- Added persona library with complete templates
- Enhanced prompt templates with persona integration
- Added examples: persona-driven-delegation, context-collection-in-action
- Updated delegation guide with persona selection guide
- Backward compatible with v1.0.0

**v1.0.0** (2026-01-23) - Initial release
- Basic Pro/Flash model coordination
- Three-step workflow
- Progressive disclosure documentation

## Migration from v1.0.0

**Fully backward compatible** - Existing prompts still work without personas.

**To adopt personas (recommended):**
1. Select appropriate persona for your task
2. Copy persona template from `references/persona-library.md`
3. Replace generic "You are Gemini..." with persona identity
4. Include context collection protocol (3 phases)
5. Execute as usual

**Example migration:**

Before (v1.0.0):
```markdown
You are Gemini-3-Flash, expert TypeScript developer.
```

After (v2.0.0):
```markdown
You are gemini-3-flash-preview, **Node.js/Python/Rust Backend Developer** (backend-dev persona).

## Your Expertise
- [Framework] API development
- Authentication & authorization (JWT, OAuth2, RBAC)
- Database integration (PostgreSQL, MongoDB, Redis)
- Error handling, logging, input validation

## Context Collection Protocol
[3-phase protocol...]
```

## License

Part of linderman-cc-utils plugin marketplace.
