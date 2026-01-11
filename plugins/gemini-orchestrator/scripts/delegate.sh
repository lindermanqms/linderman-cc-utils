#!/usr/bin/env bash
#
# delegate.sh - Helper script for Gemini Orchestrator delegations
#
# Usage:
#   ./delegate.sh [OPTIONS] <prompt-file>
#
# Options:
#   -m, --model <model>     Model to use (pro|flash) [default: auto-detect]
#   -o, --output <file>     Output report file [default: auto-generated]
#   -f, --format <fmt>      Report format (plain|markdown|json) [default: markdown]
#   -s, --save-prompt       Save prompt to .gemini-orchestration/prompts/
#   -h, --help              Show this help message
#
# Examples:
#   # Execute prompt from file (auto-detect model)
#   ./delegate.sh prompts/implement-auth.txt
#
#   # Use specific model
#   ./delegate.sh -m flash prompts/fix-bug.txt
#
#   # Save output to specific file
#   ./delegate.sh -o reports/auth-implementation.md prompts/implement-auth.txt
#
#   # Save prompt to orchestration directory
#   ./delegate.sh -s prompts/new-feature.txt

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PLUGIN_ROOT")"
ORCHESTRATION_DIR="$PROJECT_ROOT/.gemini-orchestration"
PROMPTS_DIR="$ORCHESTRATION_DIR/prompts"
REPORTS_DIR="$ORCHESTRATION_DIR/reports"

# Default values
MODEL=""
OUTPUT_FILE=""
FORMAT="markdown"
SAVE_PROMPT=false
PROMPT_FILE=""

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

show_help() {
    sed -n '/^# Usage:/,/^$/p' "$0" | tail -n +2 | head -n -1 | sed 's/^# //'
}

detect_model() {
    local prompt_content="$1"

    # Check for planning/analysis keywords
    if echo "$prompt_content" | grep -qiE "(PLANNING task|PROBLEM RESOLUTION|analyze|design|architecture|trade-off)"; then
        echo "gemini-3-pro-preview"
    else
        echo "gemini-3-flash-preview"
    fi
}

generate_output_filename() {
    local model="$1"
    local timestamp=$(date +%Y-%m-%d-%H-%M-%S)
    local model_short=$(echo "$model" | sed 's/gemini-3-//' | sed 's/-preview//')

    echo "$REPORTS_DIR/${model_short}-${timestamp}.md"
}

save_prompt_to_orchestration() {
    local source_file="$1"
    local filename=$(basename "$source_file")
    local dest_file="$PROMPTS_DIR/$filename"

    # Create timestamped copy if file already exists
    if [[ -f "$dest_file" ]]; then
        local timestamp=$(date +%Y-%m-%d-%H-%M-%S)
        local name="${filename%.*}"
        local ext="${filename##*.}"
        dest_file="$PROMPTS_DIR/${name}-${timestamp}.${ext}"
    fi

    cp "$source_file" "$dest_file"
    log_success "Prompt saved to: $dest_file"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -s|--save-prompt)
            SAVE_PROMPT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$PROMPT_FILE" ]]; then
                PROMPT_FILE="$1"
            else
                log_error "Multiple prompt files specified"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate prompt file
if [[ -z "$PROMPT_FILE" ]]; then
    log_error "No prompt file specified"
    show_help
    exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    log_error "Prompt file not found: $PROMPT_FILE"
    exit 1
fi

# Ensure orchestration directories exist
mkdir -p "$PROMPTS_DIR" "$REPORTS_DIR"

# Read prompt content
PROMPT_CONTENT=$(cat "$PROMPT_FILE")

if [[ -z "$PROMPT_CONTENT" ]]; then
    log_error "Prompt file is empty: $PROMPT_FILE"
    exit 1
fi

# Auto-detect model if not specified
if [[ -z "$MODEL" ]]; then
    MODEL=$(detect_model "$PROMPT_CONTENT")
    log_info "Auto-detected model: $MODEL"
else
    # Normalize model names
    case "$MODEL" in
        pro|planning|analysis)
            MODEL="gemini-3-pro-preview"
            ;;
        flash|implementation|coding)
            MODEL="gemini-3-flash-preview"
            ;;
        gemini-3-pro-preview|gemini-3-flash-preview)
            # Already normalized
            ;;
        *)
            log_error "Unknown model: $MODEL (use 'pro' or 'flash')"
            exit 1
            ;;
    esac
fi

# Generate output filename if not specified
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE=$(generate_output_filename "$MODEL")
    log_info "Output will be saved to: $OUTPUT_FILE"
fi

# Save prompt if requested
if [[ "$SAVE_PROMPT" == true ]]; then
    save_prompt_to_orchestration "$PROMPT_FILE"
fi

# Check if gemini-cli is installed
if ! command -v gemini &> /dev/null; then
    log_error "gemini-cli not found. Install with: npm install -g gemini-cli"
    exit 1
fi

# Check if GEMINI_API_KEY is set
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    log_warning "GEMINI_API_KEY not set. Gemini CLI may fail."
fi

# Execute delegation
log_info "Executing delegation with $MODEL..."
log_info "Prompt file: $PROMPT_FILE"

TEMP_OUTPUT=$(mktemp)

if gemini -p "$PROMPT_CONTENT" --model "$MODEL" --approval-mode yolo > "$TEMP_OUTPUT" 2>&1; then
    log_success "Delegation completed successfully"

    # Extract report using extract-report.sh
    EXTRACT_SCRIPT="$SCRIPT_DIR/extract-report.sh"

    if [[ -f "$EXTRACT_SCRIPT" ]]; then
        if "$EXTRACT_SCRIPT" -f "$FORMAT" < "$TEMP_OUTPUT" > "$OUTPUT_FILE" 2>/dev/null; then
            log_success "Report extracted to: $OUTPUT_FILE"

            # Show preview of report
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "REPORT PREVIEW:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            head -n 50 "$OUTPUT_FILE"

            LINES=$(wc -l < "$OUTPUT_FILE")
            if [[ $LINES -gt 50 ]]; then
                echo ""
                echo "[... $(($LINES - 50)) more lines ...]"
                echo ""
                log_info "Full report: $OUTPUT_FILE"
            fi
        else
            log_warning "No orchestrator report found in output"
            log_info "Saving raw output instead"
            cp "$TEMP_OUTPUT" "$OUTPUT_FILE"
        fi
    else
        log_warning "extract-report.sh not found, saving raw output"
        cp "$TEMP_OUTPUT" "$OUTPUT_FILE"
    fi

    # Also save full output
    FULL_OUTPUT="${OUTPUT_FILE%.md}-full.log"
    cp "$TEMP_OUTPUT" "$FULL_OUTPUT"
    log_info "Full output saved to: $FULL_OUTPUT"

else
    log_error "Delegation failed"

    # Save error output
    ERROR_OUTPUT="${OUTPUT_FILE%.md}-error.log"
    cp "$TEMP_OUTPUT" "$ERROR_OUTPUT"
    log_error "Error output saved to: $ERROR_OUTPUT"

    # Show error preview
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ERROR OUTPUT:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -n 30 "$TEMP_OUTPUT"

    rm "$TEMP_OUTPUT"
    exit 1
fi

rm "$TEMP_OUTPUT"

echo ""
log_success "Delegation workflow complete!"
echo ""
echo "Files created:"
echo "  - Report: $OUTPUT_FILE"
echo "  - Full output: $FULL_OUTPUT"
if [[ "$SAVE_PROMPT" == true ]]; then
    echo "  - Prompt: $PROMPTS_DIR/$(basename "$PROMPT_FILE")"
fi
