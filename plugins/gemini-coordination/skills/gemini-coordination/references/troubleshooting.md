# Troubleshooting

Common issues and solutions for Gemini coordination workflow.

## gemini-cli Issues

### Issue: gemini: command not found

**Symptom:**
```bash
gemini: command not found
```

**Cause:** gemini-cli not installed or not in PATH

**Solution:**
```bash
# Install gemini-cli globally
npm install -g gemini-cli

# Verify installation
gemini --version
```

**If still not found:**
```bash
# Check npm global bin directory
npm config get prefix
# Add to PATH: export PATH="$PATH:$(npm config get prefix)/bin"

# Or use npx
npx gemini --version
```

### Issue: API key not configured

**Symptom:**
```bash
Error: GEMINI_API_KEY environment variable not set
```

**Cause:** Gemini API key not configured

**Solution:**
```bash
# Set API key (current session)
export GEMINI_API_KEY="your-api-key-here"

# Add to ~/.bashrc or ~/.zshrc for persistence
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $GEMINI_API_KEY
```

**Get API key:** https://makersuite.google.com/app/apikey

### Issue: Invalid API key

**Symptom:**
```bash
Error: Invalid API key
Error: 401 Unauthorized
```

**Cause:** Incorrect or expired API key

**Solution:**
```bash
# Regenerate API key at https://makersuite.google.com/app/apikey
# Update environment variable
export GEMINI_API_KEY="new-api-key"

# Test
gemini -m gemini-3-flash-preview --approval-mode yolo -p "Test"
```

### Issue: Rate limit exceeded

**Symptom:**
```bash
Error: Rate limit exceeded
Error: 429 Too Many Requests
```

**Cause:** Too many requests in short time

**Solution:**
- Wait a few minutes before retrying
- Consider using a different API key
- Reduce frequency of delegations

## Prompt Issues

### Issue: Prompt too long

**Symptom:**
```bash
Error: Prompt too long
Error: Request entity too large
```

**Cause:** Prompt exceeds token limit

**Solution:**
```bash
# Shorten prompt by:
1. Removing duplicate code
2. Summarizing large files
3. Using only relevant code sections
4. Splitting into multiple delegations

# Check prompt length
wc -c prompts/task.txt
# Aim for under 50,000 characters
```

### Issue: Malformed prompt

**Symptom:** Agent produces unexpected or incomplete results

**Cause:** Prompt structure unclear or incomplete

**Solution:**
```bash
# Ensure prompt has:
1. Clear task title
2. Role definition
3. Detailed description
4. Acceptance criteria
5. Technical requirements
6. File structure
7. Output requirements

# Review prompt-templates.md for complete structure
cat skills/gemini-coordination/references/prompt-templates.md
```

### Issue: Missing Orchestrator Report

**Symptom:** Agent response doesn't include structured report

**Cause:** Prompt doesn't explicitly require report section

**Solution:**
```bash
# Add to prompt:
CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===
[Report sections]
=== END REPORT ===

# See prompt-templates.md for exact format
```

## Delegation Issues

### Issue: Wrong model used

**Symptom:** Pro used for implementation, Flash for planning

**Cause:** Incorrect model selection in command

**Solution:**
```bash
# For planning/design:
gemini -m gemini-3-pro-preview --approval-mode yolo -p "$(cat prompts/task.txt)"

# For implementation:
gemini -m gemini-3-flash-preview --approval-mode yolo -p "$(cat prompts/task.txt)"

# Double-check model in command
```

### Issue: Agent ignores requirements

**Symptom:** Agent doesn't follow instructions or requirements

**Cause:** Requirements unclear or buried in prompt

**Solution:**
```bash
# Ensure requirements are:
1. In dedicated section
2. Numbered list
3. Specific and measurable
4. Placed early in prompt

## Technical Requirements
1. Use jsonwebtoken library
2. Token expiry: 15 minutes
3. Secure storage in chrome.storage.local

# Reference delegation-guide.md for tips
```

### Issue: Agent can't find files

**Symptom:** Agent reports files not found

**Cause:** Agent looking in wrong directory or files don't exist

**Solution:**
```bash
# Always verify files exist before delegating
ls -la path/to/file.ext

# Use correct relative paths from project root
# Not: ~/path/to/project/file.txt
# Use: path/to/file.txt

# Or provide file content directly in prompt:
## Existing Code
\`\`typescript
[Paste file content here]
\`\`\`
```

## Validation Issues

### Issue: Tests fail after delegation

**Symptom:** Tests were passing, now failing after implementation

**Cause:** Implementation broke existing functionality

**Solution:**
```bash
# Identify failing tests
npm test 2>&1 | grep "FAIL"

# Review implementation changes
git diff

# Decide: fix tests or fix implementation
# If implementation is wrong → re-delegate with fix
# If tests are wrong → fix tests manually
```

### Issue: Build fails after delegation

**Symptom:** Compilation errors, type errors

**Cause:** Agent's 3 static analysis attempts exhausted

**Solution:**
```bash
# Check specific errors
npm run typecheck

# If trivial, fix manually
# If complex, re-delegate with error details:
cat > prompts/task-fix.txt <<'EOF'
## Fix Required
Static analysis errors found:

[Errors from typecheck]

Fix these specific issues while maintaining implementation.
EOF
```

### Issue: Linting errors

**Symptom:** Linting errors after implementation

**Solution:**
```bash
# Try auto-fix first
npm run lint -- --fix

# If errors remain, check if valid
npm run lint

# If valid style issues → fix manually
# If invalid rules → disable rules or fix
```

## File System Issues

### Issue: Permission denied

**Symptom:**
```bash
Error: EACCES: permission denied
```

**Cause:** File or directory permissions

**Solution:**
```bash
# Check permissions
ls -la path/to/file

# Fix permissions
chmod 644 path/to/file
chmod 755 path/to/directory

# Or run with appropriate user
sudo chown $USER:$USER path/to/file
```

### Issue: Disk space full

**Symptom:**
```bash
Error: ENOSPC: no space left on device
```

**Solution:**
```bash
# Check disk space
df -h

# Clean up
npm cache clean --force
rm -rf node_modules/
npm install

# Or free up disk space
```

## Report Issues

### Issue: Report file not created

**Symptom:** Expected report file doesn't exist

**Cause:** Command syntax error or output redirection failed

**Solution:**
```bash
# Ensure correct syntax
TIMESTAMP=$(date +%Y%m%d-%H%M)
REPORT_FILE=".claude/gemini-coordination/reports/flash-$TIMESTAMP.md"
gemini -m gemini-3-flash-preview --approval-mode yolo \
  -p "$(cat prompts/task.txt)" \
  2>&1 | tee "$REPORT_FILE"

# Check if file exists
ls -la .claude/gemini-coordination/reports/
```

### Issue: Report malformed

**Symptom:** Report section incomplete or missing

**Cause:** Agent didn't follow report format

**Solution:**
```bash
# Review prompt to ensure report section is explicitly required
CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT

=== ORCHESTRATOR REPORT ===
## Implementation Summary
## Files Modified
## Changes Made
## Static Analysis Results
## Testing Performed
## Results
## Issues Found
=== END REPORT ===
```

## Performance Issues

### Issue: Slow delegation

**Symptom:** Delegation taking much longer than expected

**Cause:** Large prompt, complex task, network issues

**Solution:**
```bash
# Optimize prompt size
wc -c prompts/task.txt
# Aim for under 20,000 characters for speed

# Check network speed
ping api.googleapis.com

# Consider breaking into smaller delegations
```

### Issue: Memory issues

**Symptom:** System slows down or hangs during delegation

**Cause:** Large context or memory leak

**Solution:**
```bash
# Monitor memory
free -h

# Reduce prompt size
# Close unnecessary applications
# Restart gemini-cli if needed
```

## Getting Help

If issue not covered:

1. **Check documentation:**
   - `delegation-guide.md` - Delegation best practices
   - `validation-protocol.md` - Validation procedures
   - `prompt-templates.md` - Prompt structure

2. **Review examples:**
   - `examples/simple-delegation.md`
   - `examples/complex-orchestration.md`

3. **Check gemini-cli docs:**
   ```bash
   gemini --help
   ```

4. **Verify environment:**
   ```bash
   gemini --version
   echo $GEMINI_API_KEY | head -c 10
   which gemini
   ```

5. **Report issue:** Include error messages, prompt used, and system info
