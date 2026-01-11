# Error Resolution

Strategies for handling errors during Gemini orchestration.

## Error Classification

### 1. Network/Temporal Errors

**Symptoms**:
- Timeout errors
- Connection refused
- Rate limiting (429)
- Temporary API outages

**Strategy**: Retry with exponential backoff

```bash
attempt=1
max_attempts=3

while [ $attempt -le $max_attempts ]; do
  gemini -p "..." --model ... && break

  if [ $attempt -lt $max_attempts ]; then
    sleep_time=$((2 ** attempt))
    echo "Attempt $attempt failed, retrying in ${sleep_time}s..."
    sleep $sleep_time
  fi

  ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
  echo "Error: Delegation failed after $max_attempts attempts"
  # Inform user, suggest checking network/API status
fi
```

### 2. Invalid Prompt Errors

**Symptoms**:
- "Prompt too long"
- "Invalid format"
- "Unsupported content"

**Strategy**: Refine and retry

```bash
# If prompt too long, truncate context
if [[ $ERROR == *"too long"* ]]; then
  # Use summary instead of full context
  CONTEXT_SUMMARY=$(summarize CLAUDE.md)

  gemini -p "
  CONTEXT (summarized):
  ${CONTEXT_SUMMARY}

  TASK: ...
  " --model ...
fi

# If format invalid, restructure
if [[ $ERROR == *"invalid format"* ]]; then
  # Simplify prompt structure
  gemini -p "Task: ... Context: ..." --model ...
fi
```

### 3. Model Limitation Errors

**Symptoms**:
- "Model cannot perform this task"
- Incorrect output format despite clear instructions
- Hallucinations or nonsensical responses

**Strategy**: Switch model or approach

```bash
# If Pro fails at implementation (shouldn't happen, but...)
if [[ $PRO_OUTPUT == *"code implementation"* ]]; then
  echo "Pro attempted implementation, switching to Flash"
  gemini -p "..." --model gemini-3-flash-preview
fi

# If Flash produces poor design
if [[ $FLASH_OUTPUT == *"architecture design"* ]]; then
  echo "Flash attempted design, re-delegating to Pro"
  gemini -p "PLANNING task: ..." --model gemini-3-pro-preview
fi
```

### 4. CLI Not Installed

**Symptoms**:
- `gemini: command not found`
- `npm: command not found` (if trying to install)

**Strategy**: Request user installation

```bash
if ! command -v gemini &> /dev/null; then
  echo "Error: gemini-cli not found"
  echo ""
  echo "Please install globally:"
  echo "  npm install -g gemini-cli"
  echo ""
  echo "Then configure API key:"
  echo "  export GEMINI_API_KEY=\"your-key-here\""
  echo "  # Add to ~/.bashrc or ~/.zshrc for persistence"
  exit 1
fi
```

## Pro Diagnosis → Flash Implementation Flow

For complex errors requiring diagnosis:

```bash
# 1. Delegate to Pro for diagnosis
DIAGNOSIS=$(gemini -p "
IMPORTANT: This is a PROBLEM RESOLUTION task.

ERROR:
${ERROR_MESSAGE}

LOGS:
${ERROR_LOGS}

CODE:
\`\`\`typescript
$(cat ${ERROR_FILE})
\`\`\`

Diagnose root cause and propose solution.
" --model gemini-3-pro-preview)

# 2. Validate Pro's diagnosis
if [[ $DIAGNOSIS == *"root cause"* ]] && [[ $DIAGNOSIS == *"solution"* ]]; then
  echo "Pro diagnosis complete"
else
  echo "Pro diagnosis incomplete, requesting clarification"
  DIAGNOSIS=$(gemini -p "
  Previous diagnosis was incomplete: ${DIAGNOSIS}

  Please provide:
  1. Exact root cause
  2. Specific solution steps
  " --model gemini-3-pro-preview)
fi

# 3. Delegate to Flash for implementation
gemini -p "
DIAGNOSIS FROM PRO:
${DIAGNOSIS}

TASK: Implement the fix based on Pro's diagnosis
" --model gemini-3-flash-preview

# 4. Validate fix
run_tests
if [ $? -eq 0 ]; then
  echo "✓ Fix validated"
else
  echo "✗ Fix failed validation, re-delegating to Pro"
  # Retry cycle
fi
```

## Logging and Debugging

### Log Structure

```bash
LOG_FILE="/tmp/gemini-orchestration-$(date +%s).log"

log() {
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

log "=== ORCHESTRATION STARTED ==="
log "Project: ${PROJECT_SLUG}"
log "Task: ${USER_REQUEST}"

# During delegation
log "Delegating to gemini-3-flash-preview"
log "Prompt length: ${#PROMPT} chars"

# After delegation
log "Delegation completed in ${DURATION}s"
log "Output length: ${#OUTPUT} chars"

# On error
log "ERROR: ${ERROR_MESSAGE}"
log "Context: ${ERROR_CONTEXT}"

log "=== ORCHESTRATION COMPLETE ==="
```

### Debug Mode

```bash
DEBUG=true  # Set to enable verbose logging

debug() {
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] $1"
  fi
}

debug "Extracted slug: ${PROJECT_SLUG}"
debug "Memory query: ${MEMORY_QUERY}"
debug "Model selected: ${MODEL}"
debug "Prompt preview: ${PROMPT:0:100}..."
```

### Prompt Inspection

```bash
# Before executing, show prompt to user
if [ "$INSPECT_PROMPTS" = true ]; then
  echo "=== PROMPT TO GEMINI ==="
  echo "$PROMPT"
  echo "========================"
  read -p "Execute? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
```

## Error Recovery Strategies

### Partial Success Handling

```bash
# Flash returns partial implementation
if [[ $OUTPUT == *"// TODO"* ]] || [[ $OUTPUT == *"not implemented"* ]]; then
  echo "Partial implementation detected"

  # Extract what was done
  COMPLETED=$(extract_completed_parts "$OUTPUT")

  # Re-delegate remaining work
  gemini -p "
  ALREADY IMPLEMENTED:
  ${COMPLETED}

  TASK: Complete the remaining parts marked as TODO
  " --model gemini-3-flash-preview
fi
```

### Rollback on Failure

```bash
# Backup before Flash modifies code
backup_files() {
  for file in "$@"; do
    cp "$file" "${file}.backup"
  done
}

# If delegation fails, rollback
if ! validate_output; then
  echo "Validation failed, rolling back"
  for file in *.backup; do
    original="${file%.backup}"
    mv "$file" "$original"
  done
fi
```

### Iterative Refinement

```bash
# If output doesn't meet requirements, iterate
attempt=1
max_iterations=3

while [ $attempt -le $max_iterations ]; do
  OUTPUT=$(gemini -p "${PROMPT}" --model ...)

  if validate_output "$OUTPUT"; then
    echo "✓ Output validated on attempt $attempt"
    break
  else
    ISSUES=$(identify_issues "$OUTPUT")
    PROMPT="
    Previous attempt had issues:
    ${ISSUES}

    Please fix and regenerate:
    ${ORIGINAL_PROMPT}
    "
  fi

  ((attempt++))
done
```

## Common Error Scenarios

### Scenario 1: Flash Produces Invalid TypeScript

**Error**: Syntax errors, type errors, missing imports

**Resolution**:
```bash
# Run TypeScript compiler check
if ! npx tsc --noEmit; then
  TS_ERRORS=$(npx tsc --noEmit 2>&1)

  # Re-delegate with errors
  gemini -p "
  TASK: Fix TypeScript compilation errors

  ERRORS:
  ${TS_ERRORS}

  CODE:
  \`\`\`typescript
  $(cat src/file.ts)
  \`\`\`
  " --model gemini-3-flash-preview
fi
```

### Scenario 2: Pro Returns Vague Design

**Error**: Design lacks specifics, unclear architecture

**Resolution**:
```bash
# Check if design has required sections
if ! grep -q "Component Diagram" "$PRO_OUTPUT" || \
   ! grep -q "Data Flow" "$PRO_OUTPUT"; then

  # Request clarification
  gemini -p "
  PREVIOUS DESIGN:
  ${PRO_OUTPUT}

  This design is missing:
  - Component Diagram
  - Data Flow description
  - API contracts

  Please provide a complete design with all sections.
  " --model gemini-3-pro-preview
fi
```

### Scenario 3: Memory Save Fails

**Error**: Basic Memory MCP not responding

**Resolution**:
```bash
# Attempt save with error handling
save_to_memory() {
  if ! mcp__memory__create_entities "$1"; then
    echo "Warning: Failed to save to memory"
    echo "Reason: Basic Memory MCP may not be active"
    echo "Knowledge will be lost unless you configure MCP server"

    # Optionally: Save to local file as backup
    echo "$1" > "memory-backup-$(date +%s).json"
    echo "Saved backup to memory-backup-*.json"
  fi
}
```

## Best Practices

✅ **Capture all errors** - Log everything for debugging
✅ **Provide context** - Include error logs/stack traces in Pro delegations
✅ **Validate outputs** - Always check before accepting results
✅ **Backup before modify** - Save files before Flash edits
✅ **Iterate when needed** - Re-delegate with feedback if first attempt fails
✅ **Check prerequisites** - Verify gemini-cli installed before starting

❌ **Silent failures** - Always report errors to user
❌ **Assume success** - Validate even if delegation completes
❌ **Skip diagnostics** - Use Pro for complex error diagnosis
❌ **Infinite retries** - Set max attempts to avoid loops
