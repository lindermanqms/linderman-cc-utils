#!/bin/bash
# extract-report.sh - Extrai relatório do orchestrator da saída do gemini-cli

set -euo pipefail

# Usage
usage() {
  echo "Usage: $0 [OPTIONS] [INPUT_FILE]"
  echo ""
  echo "Extract Orchestrator Report from gemini-cli output"
  echo ""
  echo "Arguments:"
  echo "  INPUT_FILE    File to extract report from (default: stdin)"
  echo ""
  echo "Options:"
  echo "  -o, --output FILE   Save report to file instead of stdout"
  echo "  -f, --format FORMAT Output format (plain|markdown|json) (default: plain)"
  echo "  -h, --help          Show this help"
  echo ""
  echo "Examples:"
  echo "  gemini -p '...' --model gemini-3-pro-preview | $0"
  echo "  gemini -p '...' --model gemini-3-flash-preview > output.txt && $0 output.txt"
  echo "  gemini -p '...' | $0 -o report.md -f markdown"
}

# Defaults
INPUT_FILE="-"
OUTPUT_FILE="-"
FORMAT="plain"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      usage
      exit 1
      ;;
    *)
      INPUT_FILE="$1"
      shift
      ;;
  esac
done

# Extract report using awk
extract_report() {
  local input="$1"

  if [[ "$input" == "-" ]]; then
    # Read from stdin
    awk '
      /=== ORCHESTRATOR REPORT ===/ { in_report=1; next }
      /=== END REPORT ===/ { in_report=0; print ""; exit }
      in_report { print }
    '
  else
    # Read from file
    awk '
      /=== ORCHESTRATOR REPORT ===/ { in_report=1; next }
      /=== END REPORT ===/ { in_report=0; print ""; exit }
      in_report { print }
    ' "$input"
  fi
}

# Format output
format_output() {
  local report="$1"
  local format="$2"

  case "$format" in
    plain)
      echo "$report"
      ;;
    markdown)
      # Wrap in code block and add header
      echo "# Orchestrator Report"
      echo ""
      echo '```'
      echo "$report"
      echo '```'
      ;;
    json)
      # Convert to simple JSON structure
      local json_content=$(echo "$report" | jq -Rs .)
      echo '{"report": '"$json_content"'}'
      ;;
    *)
      echo "Error: Unknown format $format" >&2
      exit 1
      ;;
  esac
}

# Main
REPORT=$(extract_report "$INPUT_FILE")

if [[ -z "$REPORT" ]]; then
  echo "Error: No Orchestrator Report found in output" >&2
  exit 1
fi

# Check if report is empty
if [[ "$(echo "$REPORT" | wc -l)" -lt 5 ]]; then
  echo "Warning: Report appears to be empty or incomplete" >&2
fi

# Format and output
FORMATTED=$(format_output "$REPORT" "$FORMAT")

if [[ "$OUTPUT_FILE" == "-" ]]; then
  # Print to stdout
  echo "$FORMATTED"
else
  # Save to file
  echo "$FORMATTED" > "$OUTPUT_FILE"
  echo "Report saved to: $OUTPUT_FILE"
fi
