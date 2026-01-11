# Troubleshooting

Solutions for common issues when using Gemini Orchestrator.

## Installation Issues

### gemini-cli Not Found

**Symptom**:
```
bash: gemini: command not found
```

**Solution**:
```bash
# Install globally via npm
npm install -g gemini-cli

# Verify installation
gemini --version

# If npm not found, install Node.js first:
# - Ubuntu/Debian: sudo apt install nodejs npm
# - macOS: brew install node
# - Windows: Download from nodejs.org
```

**Alternative**:
```bash
# If global install fails due to permissions
# Use npx (comes with npm)
npx gemini-cli -p "..." --model ...

# Or install locally in project
npm install gemini-cli
npx gemini -p "..." --model ...
```

### API Key Not Configured

**Symptom**:
```
Error: GEMINI_API_KEY environment variable not set
```

**Solution**:
```bash
# Set for current session
export GEMINI_API_KEY="your-api-key-here"

# Persist in shell config
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.bashrc
# or for zsh:
echo 'export GEMINI_API_KEY="your-api-key-here"' >> ~/.zshrc

# Reload shell
source ~/.bashrc  # or source ~/.zshrc

# Verify
echo $GEMINI_API_KEY
```

**Get API Key**:
- Visit: https://aistudio.google.com/app/apikey
- Create new API key
- Copy and set as environment variable

## Memory Integration Issues

### Memory Not Saving

**Symptom**:
```
Warning: Failed to save to memory
```

**Causes & Solutions**:

1. **Basic Memory MCP not active**
   ```bash
   # Check if MCP server is running
   # (Check Claude Code MCP settings)

   # If not configured, skill will warn but continue
   # Install Basic Memory MCP server to enable
   ```

2. **Invalid entity name format**
   ```bash
   # ❌ Wrong
   mcp__memory__create_entities({
     entities: [{
       name: "pattern-jwt",  # Missing project slug prefix
       ...
     }]
   })

   # ✅ Correct
   PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
   mcp__memory__create_entities({
     entities: [{
       name: "${PROJECT_SLUG}/global/pattern-jwt",  # With prefix
       ...
     }]
   })
   ```

3. **Empty observations array**
   ```bash
   # ❌ Won't save
   mcp__memory__create_entities({
     entities: [{
       name: "...",
       entityType: "...",
       observations: []  # Empty!
     }]
   })

   # ✅ Will save
   mcp__memory__create_entities({
     entities: [{
       name: "...",
       entityType: "...",
       observations: ["Observation 1", "Observation 2"]
     }]
   })
   ```

### Memory Searches Return Nothing

**Symptom**:
```bash
MEMORY=$(mcp__memory__search_nodes({ query: "auth patterns" }))
# MEMORY is empty, but you know there are auth patterns saved
```

**Causes & Solutions**:

1. **Missing project slug prefix in query**
   ```bash
   # ❌ Wrong - searches all projects
   mcp__memory__search_nodes({ query: "auth patterns" })

   # ✅ Correct - searches only this project
   PROJECT_SLUG=$(basename $(git rev-parse --show-toplevel))
   mcp__memory__search_nodes({ query: "${PROJECT_SLUG} auth patterns" })
   ```

2. **Too specific keywords**
   ```bash
   # Try broader search
   # Instead of: "jwt authentication with refresh tokens"
   # Use: "auth jwt"
   ```

3. **Wrong project slug**
   ```bash
   # Verify you're using correct slug
   echo "Project slug: $(basename $(git rev-parse --show-toplevel))"

   # Should match the prefix used when saving entities
   ```

## Delegation Issues

### Delegation Failed

**Symptom**:
```
Error: Delegation to gemini-3-flash-preview failed
```

**Common Causes**:

1. **Network issues**
   ```bash
   # Test connectivity
   curl -I https://generativelanguage.googleapis.com

   # If times out, check network/firewall
   ```

2. **Invalid API key**
   ```bash
   # Test API key
   gemini -p "Hello" --model gemini-3-flash-preview

   # If "401 Unauthorized", regenerate API key
   ```

3. **Prompt too long**
   ```bash
   # Check prompt length
   echo "Prompt length: ${#PROMPT} characters"

   # If > 30,000, summarize context instead of full content
   CONTEXT_SUMMARY=$(echo "$FULL_CONTEXT" | head -n 100)
   ```

4. **Rate limiting**
   ```
   Error: 429 Too Many Requests
   ```

   Solution:
   ```bash
   # Add retry with backoff
   attempt=1
   while [ $attempt -le 3 ]; do
     gemini -p "..." --model ... && break
     sleep $((2 ** attempt))
     ((attempt++))
   done
   ```

### Flash Produces Invalid Code

**Symptom**:
- Syntax errors
- Type errors
- Missing imports
- Doesn't follow project conventions

**Solutions**:

1. **Insufficient context**
   ```bash
   # ❌ Minimal context
   gemini -p "Implement auth service" --model gemini-3-flash-preview

   # ✅ Full context
   cat CLAUDE.md | gemini -p "
   PROJECT CONTEXT (stdin):
   Standards from CLAUDE.md

   EXISTING CODE:
   $(cat src/existing-service.ts)

   TASK: Implement auth service following existing patterns
   " --model gemini-3-flash-preview
   ```

2. **Missing technical references**
   ```bash
   # Include library documentation URLs
   gemini -p "
   TECHNICAL REFERENCES:
   - TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/
   - Framework docs: https://...

   TASK: ...
   " --model gemini-3-flash-preview
   ```

3. **Validate and refine**
   ```bash
   # Run linter/compiler after Flash
   npx tsc --noEmit

   # If errors, re-delegate with error messages
   TS_ERRORS=$(npx tsc --noEmit 2>&1)
   gemini -p "
   FIX THESE ERRORS:
   ${TS_ERRORS}

   CODE:
   $(cat src/file.ts)
   " --model gemini-3-flash-preview
   ```

### Pro Returns Vague Design

**Symptom**:
- Design lacks specifics
- No component diagrams
- Unclear architecture

**Solutions**:

1. **Specify output format explicitly**
   ```bash
   gemini -p "
   IMPORTANT: This is a PLANNING task.

   TASK: Design authentication system

   OUTPUT FORMAT (REQUIRED):
   1. Component Diagram (text-based)
   2. Data Flow Diagram
   3. API Contracts
   4. Security Considerations
   5. Implementation Steps
   " --model gemini-3-pro-preview
   ```

2. **Request JSON for structured output**
   ```bash
   gemini -p "
   ...

   OUTPUT FORMAT:
   Return JSON:
   {
     \"components\": [...],
     \"dataFlow\": {...},
     \"apiContracts\": [...],
     \"security\": [...]
   }
   " --model gemini-3-pro-preview --output-format json
   ```

## Performance Issues

### Delegations Are Slow

**Symptom**:
Delegations take > 30 seconds

**Solutions**:

1. **Reduce context size**
   ```bash
   # Instead of full files
   cat large-file.ts  # 10,000 lines

   # Use relevant snippets
   grep -A 20 "function auth" large-file.ts
   ```

2. **Use --output-format json for faster parsing**
   ```bash
   # Structured output is faster to process
   gemini -p "..." --model ... --output-format json
   ```

3. **Run delegations in parallel (when independent)**
   ```bash
   # Sequential (slow)
   DESIGN=$(gemini -p "design A" --model ...)
   IMPL=$(gemini -p "implement B" --model ...)

   # Parallel (faster)
   gemini -p "design A" --model ... > /tmp/design &
   gemini -p "implement B" --model ... > /tmp/impl &
   wait
   DESIGN=$(cat /tmp/design)
   IMPL=$(cat /tmp/impl)
   ```

## Debugging Tips

### Enable Verbose Logging

```bash
# Set debug flag
DEBUG=true

# Log all delegations
log_delegation() {
  echo "[$(date)] Delegating to $1" | tee -a orchestration.log
  echo "Prompt: $2" | tee -a orchestration.log
}

log_delegation "gemini-3-flash-preview" "$PROMPT"
```

### Inspect Prompts Before Execution

```bash
# Show prompt to user before sending
echo "=== PROMPT TO GEMINI ==="
echo "$PROMPT"
echo "========================"
read -p "Execute? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi
```

### Save Failed Delegations for Analysis

```bash
# On error, save context
if ! gemini -p "$PROMPT" --model ... > output.txt 2> error.txt; then
  echo "Delegation failed"
  echo "Prompt saved to: failed-prompt-$(date +%s).txt"
  echo "$PROMPT" > "failed-prompt-$(date +%s).txt"
  echo "Error: $(cat error.txt)"
fi
```

## Getting Help

If issues persist:

1. **Check gemini-cli version**
   ```bash
   gemini --version
   # Update if outdated: npm update -g gemini-cli
   ```

2. **Test with simple prompt**
   ```bash
   gemini -p "Hello, what is 2+2?" --model gemini-3-flash-preview
   # If this works, issue is with complex prompts
   ```

3. **Review logs**
   ```bash
   # Check orchestration logs
   tail -f orchestration.log

   # Check Claude Code logs
   # (Location varies by installation)
   ```

4. **Minimal reproduction**
   ```bash
   # Create minimal test case
   PROJECT_SLUG="test-project"
   PROMPT="Simple task"
   gemini -p "$PROMPT" --model gemini-3-flash-preview
   ```

## Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `command not found: gemini` | CLI not installed | `npm install -g gemini-cli` |
| `GEMINI_API_KEY not set` | Missing API key | Set env variable |
| `401 Unauthorized` | Invalid API key | Regenerate key |
| `429 Too Many Requests` | Rate limited | Retry with backoff |
| `Prompt too long` | Context > limit | Reduce context size |
| `Failed to save to memory` | MCP not active | Check MCP configuration |
| `TypeError: Cannot read property` | Invalid data format | Check entity structure |
