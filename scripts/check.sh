#!/bin/sh
# check.sh — run every check tool; the pre-commit entry point.
#
#   structure.sh  shape: frontmatter, ceiling, registry
#   content.sh    text: crossrefs, harness, incident, rule-lines
#   handoff.sh    the frozen closing block vs CONTRIBUTING's canonical
#
# Each tool also runs alone, optionally scoped to one skill
# (scripts/<tool>.sh spike); this runner takes the same optional argument.
#
# Hook wiring, once per clone:  pre-commit install  (root .pre-commit-config.yaml)

# bootstrap: locate the repo, then the shared harness
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/common.sh"

# run the tools, passing the skill scope through
bad=0
for t in $TOOLS; do
  if scoped; then
    "$SCRIPTS_DIR/$t.sh" "$SKILLS" || bad=$((bad + 1))
  else
    "$SCRIPTS_DIR/$t.sh" || bad=$((bad + 1))
  fi
done

# verdict
total=$(printf '%s\n' $TOOLS | wc -w | tr -d '[:space:]')
if [ "$bad" -eq 0 ]; then
  printf 'check.sh: PASS — %s tools\n' "$total"
  exit 0
fi
printf 'check.sh: FAIL — %s of %s tools failed\n' "$bad" "$total"
exit 1
