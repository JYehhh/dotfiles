#!/usr/bin/env bash
# Claude Code statusline: model, cwd, git branch, context-window usage bar.

input=$(cat)

parsed=$(echo "$input" | python3 -c '
import json, sys
d = json.load(sys.stdin)
model = d.get("model", {}).get("display_name") or "Claude"
cwd = d.get("workspace", {}).get("current_dir") or d.get("cwd") or "~"
pct = d.get("context_window", {}).get("used_percentage")
print(model, cwd, pct if pct is not None else "", sep="\x1f")
')
IFS=$'\x1f' read -r model cwd used_pct <<< "$parsed"

# Shorten cwd: replace $HOME with ~
short_cwd="${cwd/#$HOME/~}"

# Git branch (skip optional locks so we never block on a git lock file)
branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# ANSI colors (dimmed to match terminal theme)
DIM=$'\033[2m'
RESET=$'\033[0m'
GREEN=$'\033[2;32m'
YELLOW=$'\033[2;33m'
RED=$'\033[2;31m'
CYAN=$'\033[2;36m'
MAGENTA=$'\033[2;35m'

# Build a 10-block usage bar, color-coded by threshold
bar=""
bar_color="$GREEN"
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  filled=$(( pct_int / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))

  if [ "$pct_int" -ge 80 ]; then
    bar_color="$RED"
  elif [ "$pct_int" -ge 50 ]; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi

  bar="${bar_color}"
  for ((i = 0; i < filled; i++)); do bar="${bar}█"; done
  bar="${bar}${DIM}"
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done
  bar="${bar}${RESET} ${bar_color}${pct_int}%${RESET}"
fi

# Assemble the statusline
out="${CYAN}${model}${RESET} ${DIM}|${RESET} ${MAGENTA}${short_cwd}${RESET}"
[ -n "$branch" ] && out="${out} ${DIM}|${RESET} ${DIM}${branch}${RESET}"
[ -n "$bar" ] && out="${out} ${DIM}|${RESET} ${bar}"

printf '%s' "$out"
