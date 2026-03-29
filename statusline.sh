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

echo -e "MDL: ${CYAN}[$MODEL]${RESET}"
echo -e "DIR: ${DIR##*/} ${RED}($BRANCH)${RESET}"
echo -e "CTX: ${BAR_COLOR}${BAR}${RESET} ${PCT}%"
echo -e "TME: ${MINS}m ${SECS}s"
# Uncomment to display cost in USD
# echo -e "CST: ${YELLOW}${COST_FMT}${RESET}"
