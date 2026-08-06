#!/bin/bash
input=$(cat)

# Currently used model:
MODEL=$(echo "$input" | jq -r '.model.display_name')

# Current directory:
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Current cost in USD:
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Percentage of context used:
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Token counts:
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
TOTAL_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS))

# Duration in ms:
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH="$(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")

# Format a token count as e.g. 12.3k, or leave as-is if under 1000
fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000 ]; then
        awk -v t="$n" 'BEGIN { printf "%.1fk", t/1000 }'
    else
        echo "$n"
    fi
}

TOTAL_FMT=$(fmt_tokens "$TOTAL_TOKENS")
INPUT_FMT=$(fmt_tokens "$INPUT_TOKENS")
OUTPUT_FMT=$(fmt_tokens "$OUTPUT_TOKENS")

printf "%-10s${CYAN}[%s]${RESET}\n" "Model:" "$MODEL"
printf "%-10s${DIR##*/} ${RED}(%s)${RESET}\n" "Project:" "$BRANCH"
printf "%-10s${BAR_COLOR}%s${RESET} %s%%\n" "Context:" "$BAR" "$PCT"
printf "%-10s%s (%s in / %s out)\n" "Tokens:" "$TOTAL_FMT" "$INPUT_FMT" "$OUTPUT_FMT"
printf "%-10s%sm %ss\n" "Time:" "$MINS" "$SECS"

# Uncomment to display the cost of the current session in dollars
# printf "%-10s${YELLOW}%s${RESET}\n" "Cost:" "$COST_FMT"
