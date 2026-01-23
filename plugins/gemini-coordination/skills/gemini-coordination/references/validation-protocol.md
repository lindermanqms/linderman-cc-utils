# Validation Protocol

Protocol for validating results from Gemini delegations.

## Orchestrator's Validation Responsibilities

After Gemini delegation completes, Orchestrator (Claude Code) MUST:

1. **Review the Report** - Read the complete Orchestrator Report section
2. **Verify Implementation** - Check that all acceptance criteria are met
3. **Run Validation Tests** - Execute build, test, and end-to-end validation
4. **Make Final Decision** - Approve or request revisions

## Validation Checklist

### For Flash Implementations

**Code Quality:**
- [ ] Code follows project standards (style, patterns)
- [ ] Error handling implemented appropriately
- [ ] No obvious bugs or logic errors
- [ ] Self-documenting code with clear naming

**Acceptance Criteria:**
- [ ] All ACs marked as completed in report
- [ ] Each AC verified as actually implemented
- [ ] Edge cases considered

**Static Analysis:**
- [ ] Linting passes (npm run lint, ruff check, etc.)
- [ ] Type checking passes (npm run typecheck, mypy, etc.)
- [ ] No critical warnings

**Testing:**
- [ ] Tests written for critical paths
- [ ] Tests pass successfully
- [ ] Coverage adequate for changes

**Build:**
- [ ] Project builds successfully
- [ ] No build errors or critical warnings
- [ ] Dependencies installed correctly

### For Pro Planning

**Analysis Completeness:**
- [ ] All 7 report sections present and complete
- [ ] Analysis covers requested aspects
- [ ] Decisions have clear rationale

**Quality of Reasoning:**
- [ ] Trade-offs identified and evaluated
- [ ] Alternatives considered
- [ ] Risks identified with mitigations
- [ ] Recommendations are actionable

**Actionability:**
- [ ] Next steps are clear and specific
- [ ] Recommendations can be directly implemented
- [ ] Design is complete enough for implementation

## Validation Commands

### Standard Validation Sequence

```bash
# 1. Review the report
cat .claude/gemini-coordination/reports/flash-*.md
cat .claude/gemini-coordination/reports/pro-*.md

# 2. Check for new/modified files
git status
git diff [file]  # Review changes

# 3. Run static analysis
npm run lint      # or: ruff check .
npm run typecheck # or: mypy .

# 4. Run tests
npm test          # or: pytest, cargo test, etc.

# 5. Build project
npm run build     # or: cargo build, etc.

# 6. Start server (if applicable)
npm start &       # For end-to-end validation

# 7. Test manually (if applicable)
curl http://localhost:3000/api/health
# Or: open browser, test UI, etc.
```

### Language-Specific Commands

**TypeScript/JavaScript:**
```bash
npm run lint
npm run typecheck
npm test
npm run build
```

**Python:**
```bash
ruff check .
mypy .
pytest
python -m build
```

**Rust:**
```bash
cargo clippy
cargo fmt --check
cargo test
cargo build --release
```

**Go:**
```bash
go vet ./...
gofmt -l .
go test ./...
go build ./...
```

## Decision Protocol

### Approve When:

1. **All Acceptance Criteria Met** - Every AC verified as complete
2. **Tests Pass** - All tests passing successfully
3. **Build Succeeds** - Clean build with no errors
4. **Static Analysis Clean** - No linting or type errors
5. **Code Quality Good** - Follows standards, well-structured

**Action:**
- Mark task as complete
- Commit changes
- Update project documentation if needed

### Request Revision When:

1. **Acceptance Criteria Incomplete** - Some ACs not met
2. **Tests Failing** - Test failures after code review
3. **Build Errors** - Compilation or build errors
4. **Static Analysis Failures** - Linting/type errors after 3 attempts
5. **Code Quality Issues** - Violates standards, unclear code

**Action:**
- Identify specific issues in report
- Create revised prompt addressing issues
- Delegate again with additional context
- Specify what needs fixing

### Reject When:

1. **Fundamental Misunderstanding** - Wrong approach to task
2. **Severe Quality Issues** - Security vulnerabilities, major bugs
3. **Incomplete Report** - Missing Orchestrator Report section
4. **Wrong Model Used** - Pro used for implementation, Flash for design

**Action:**
- Explain why rejection occurred
- Provide guidance on correct approach
- Consider delegating again with clearer requirements

## Error Handling Protocol

### When Static Analysis Fails

Gemini agents have 3-attempt protocol for static analysis:

**Attempt 1: Auto-fix**
```bash
npm run lint -- --fix
npm run typecheck
```

**Attempt 2: Manual Fix**
- Agent identifies specific errors
- Manually fixes reported issues
- Re-runs analysis

**Attempt 3: Document**
- If still failing, documents in report
- Orchestrator reviews remaining issues
- Decides if acceptable or needs revision

### When Tests Fail

**Investigate:**
1. Are tests valid? (not broken, not flaky)
2. Is implementation correct?
3. Are test requirements clear?

**Actions:**
- If tests are valid → Request revision
- If tests are invalid → Fix tests, re-run
- If requirements unclear → Clarify, delegate again

### When Build Fails

**Investigate:**
1. Are all dependencies installed? (`npm install`, etc.)
2. Are there compilation errors?
3. Are there configuration issues?

**Actions:**
- Fix immediate issues if trivial
- Request revision if implementation problems
- Delegate with additional context if unclear

## Common Validation Issues

### Issue 1: Missing Orchestrator Report

**Symptom:** Report section missing, incomplete, or malformed

**Action:** Reject and delegate again with emphasis on report format

### Issue 2: Acceptance Criteria Not Met

**Symptom:** ACs marked complete but actually missing

**Action:** Request revision specifying missing ACs

### Issue 3: Static Analysis Failures

**Symptom:** Linting/type errors after agent's 3 attempts

**Action:** Review issues, decide if acceptable or needs revision

### Issue 4: Test Failures

**Symptom:** Tests failing after implementation

**Action:** Investigate if tests or implementation is at fault

### Issue 5: Build Errors

**Symptom:** Compilation errors, missing dependencies

**Action:** Fix trivial issues or request revision

## Multi-Phase Validation

For complex workflows (Pro → Flash → Validation):

### After Pro Phase

**Validate:**
- [ ] Report has all 7 sections complete
- [ ] Analysis is thorough and actionable
- [ ] Recommendations are clear
- [ ] Design is ready for implementation

**If issues:** Delegate again to Pro with clarifications

### After Flash Phase

**Validate:**
- [ ] Implementation follows Pro's design (if applicable)
- [ ] All ACs met
- [ ] Code quality good
- [ ] Tests pass
- [ ] Build succeeds

**If issues:** Delegate again to Flash with specific fixes

### Final Validation

**After both phases complete:**
```bash
# Review both reports
cat reports/pro-*.md
cat reports/flash-*.md

# Run full validation
npm install
npm run lint && npm run typecheck
npm test
npm run build
npm start &
# Manual testing
```

## Reporting Results

After validation, communicate results clearly:

**Success:**
```
✅ Validation Complete

All acceptance criteria met:
- [x] AC 1: [Description]
- [x] AC 2: [Description]

Tests: Passing
Build: Successful
Static Analysis: Clean

Changes committed: [commit hash]
```

**Needs Revision:**
```
❌ Validation Failed - Revision Required

Issues found:
1. AC 2 not fully implemented - [details]
2. Test failure in [test name] - [details]
3. Linting errors in [file] - [details]

Actions: Re-delegating with specific fixes...
```

## Best Practices

1. **Always Review Reports** - Don't skip to tests without reading
2. **Verify ACs Manually** - Don't trust agent's self-assessment
3. **Run Full Validation** - Don't skip build/test steps
4. **Document Issues** - Be specific when requesting revisions
5. **Learn from Patterns** - Note common issues to prevent future occurrences
