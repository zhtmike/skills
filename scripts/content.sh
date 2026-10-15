#!/bin/sh
# content.sh — what a body's text may say:
#
#   crossrefs   no sibling-skill references outside the wind-down handoff
#               (self-containment; the handoff is the one sanctioned crossing)
#   harness     no harness names, flags, or paths (harness-agnostic principle;
#               vocabulary in common.sh)
#   incident    no incident specifics (PR/issue numbers, commit SHAs, local
#               paths) outside h800-* bodies; fenced examples and backtick
#               spans are exempt (spellings may appear as examples)
#   rule-lines  no rule line over ~40 words; prose, tables, code fences,
#               frontmatter, and the frozen handoff are exempt
#
# Usage: scripts/content.sh [skill]

# bootstrap: locate the repo, then the shared harness
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/common.sh"

# crossrefs: self-containment — the handoff is the only sanctioned mention
crossrefs() {
  for s in $SKILLS; do
    for other in $ALL_SKILLS; do
      [ "$other" = "$s" ] && continue
      hit=$(awk '/^## Wind-down handoff$/{exit} {print}' "$s/SKILL.md" |
        grep -nE "(^|[^a-z0-9-])$other([^a-z0-9-]|$)")
      [ -z "$hit" ] || fail_ "crossrefs $s: references sibling '$other' — $(printf '%s' "$hit" | head -1 | cut -c1-70)"
    done
  done
}

# harness: no harness vocabulary in any body
harness() {
  for s in $SKILLS; do
    hit=$(grep -inE "$HARNESS_PAT" "$s/SKILL.md")
    [ -z "$hit" ] || fail_ "harness $s: harness-specific content — $(printf '%s' "$hit" | head -1 | cut -c1-70)"
  done
}

# incident: shape, not place — h800-* bodies keep their environment facts
incident() {
  for s in $SKILLS; do
    case $s in h800-*) continue ;; esac
    hit=$(awk '/^```/{inf = !inf; next} inf{next} {gsub(/`[^`]*`/, ""); print}' "$s/SKILL.md" |
      grep -nE "$INCIDENT_PAT")
    [ -z "$hit" ] || fail_ "incident $s: incident specifics — $(printf '%s' "$hit" | head -1 | cut -c1-70)"
  done
}

# rule-lines: one line, one rule — nothing over ~40 words
rule_lines() {
  for s in $SKILLS; do
    hit=$(awk -v s="$s" '
      /^---$/ {fm++; next} fm == 1 {next}          # skip frontmatter
      /^```/ {inf = !inf; next} inf {next}         # skip code fences
      /^## Wind-down handoff$/ {exit}              # frozen block is exempt
      /^\|/ {next}                                 # table rows are exempt
      (/^ *[-*+] / || /^ *[0-9]+\. /) && NF > 40 {printf "%s:%d (%d words) %s\n", s, FNR, NF, $0}
    ' "$s/SKILL.md")
    [ -z "$hit" ] || fail_ "rule-lines $s: over 40 words — $(printf '%s' "$hit" | head -1 | cut -c1-90)"
  done
}

crossrefs
harness
incident
rule_lines
finish content
