#!/bin/sh
# report.sh — the growth dashboard (read-only): body sizes against the hard
# ceiling and the Growth warn zone, plus README row presence. The budget
# answer for "an addition pays per Growth". Not part of the gate.
#
# Usage: scripts/report.sh [skill]

# bootstrap: locate the repo, then the shared harness
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/common.sh"

# one row per skill
printf '%-20s %11s %13s  %s\n' skill lines words notes
near=0
for s in $SKILLS; do
  f=$s/SKILL.md
  lines=$(awk 'END{print NR}' "$f") words=$(wc -w < "$f" | tr -d '[:space:]')
  notes=
  if [ "$lines" -gt "$CEIL_LINES" ] || [ "$words" -gt "$CEIL_WORDS" ]; then
    notes=OVER-CEILING
  elif [ "$lines" -ge "$WARN_LINES" ] || [ "$words" -ge "$WARN_WORDS" ]; then
    notes=near-ceiling
    near=$((near + 1))
  fi
  grep -q "^| \`$s\`" README.md || notes="${notes:+$notes }no-README-row"
  printf '%-20s %5s/%-5s %6s/%-6s  %s\n' "$s" "$lines" "$CEIL_LINES" "$words" "$CEIL_WORDS" "$notes"
done

# footer: the budgets
total=$(printf '%s\n' $SKILLS | wc -w | tr -d '[:space:]')
printf '\nwarn zone from %s lines / %s words (hard ceiling %s / %s) — %s of %s bodies in it\n' \
  "$WARN_LINES" "$WARN_WORDS" "$CEIL_LINES" "$CEIL_WORDS" "$near" "$total"
exit 0
