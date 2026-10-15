# common.sh — shared harness for the scripts/ check tools.
#
# Contract: a tool sets ROOT (repo top) then sources this file; an optional
# first argument to the tool scopes every check to that one skill. Helpers:
#   fail_/warn_  record and print a diagnostic (message prefix = concern name)
#   finish       print the tool's verdict and exit 0/1 by failure count
#   scoped       true while running scoped to one skill
# Constants below are the single shared spec — patterns live here, not in tools.
# Source this file; never run it.

set -u
: "${ROOT:?ROOT must be set before sourcing common.sh}"
cd "$ROOT" || exit 1
SCRIPTS_DIR=$ROOT/scripts

# shared limits and banned-vocabulary patterns

CEIL_LINES=130 CEIL_WORDS=1600        # hard body ceiling
WARN_LINES=105 WARN_WORDS=1300        # from here, additions pay per Growth
DESC_MAX=512 NAME_MAX=64              # frontmatter limits

# Harness vocabulary banned from bodies — extend the list, never weaken it.
HARNESS_PAT='(^|[^a-z0-9_.-])(pi|codex|claude|opencode|codemode)([^a-z0-9_-]|$)|--print|--no-session|--tools|\.pi/|exit code [0-9]'

# Incident specifics banned outside environment-bound (h800-*) bodies.
INCIDENT_PAT='#[0-9]+|[0-9a-f]{40}|~/gitlocal|/Users/'

TOOLS='structure content handoff'

# diagnostics and verdict

failures=0 warnings=0
fail_() { failures=$((failures + 1)); printf 'FAIL %s\n' "$*"; }
warn_() { warnings=$((warnings + 1)); printf 'WARN %s\n' "$*"; }

finish() {
  if [ "$failures" -eq 0 ]; then
    printf '%s: PASS (%d warning%s)\n' "$1" "$warnings" "$([ "$warnings" -eq 1 ] || printf s)"
    exit 0
  fi
  printf '%s: FAIL — %d failure%s\n' "$1" "$failures" "$([ "$failures" -eq 1 ] || printf s)"
  exit 1
}

# skill enumeration and scoping

skills() {
  for d in */; do
    [ -f "${d}SKILL.md" ] && printf '%s ' "${d%/}"
  done
}
ALL_SKILLS=$(skills)
SKILLS=$ALL_SKILLS

# -h/--help anywhere: print usage and point at the menu
# An optional first argument scopes the sourcing tool to one skill;
# repo-wide sub-checks (registry tables, scripts/ whitelist) then stay silent.
case "${1:-}" in
  -h|--help)
    printf 'usage: %s [skill]   (menu: scripts/README.md)\n' "$0"
    exit 0
    ;;
esac
[ -z "${1:-}" ] || {
  [ -f "$1/SKILL.md" ] || { printf 'FATAL no such skill: %s\n' "$1" >&2; exit 2; }
  SKILLS=$1
}
scoped() { [ "$SKILLS" != "$ALL_SKILLS" ]; }

# frontmatter readers

fm_name() { awk '/^name:/{sub(/^name:[ ]*/, ""); print; exit}' "$1/SKILL.md"; }
fm_desc() { awk '/^description:/{sub(/^description:[ ]*/, ""); gsub(/^"|"$/, ""); print; exit}' "$1/SKILL.md"; }
