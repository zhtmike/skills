#!/bin/sh
# handoff.sh — the frozen wind-down handoff: present, exactly once, last
# section, verbatim against CONTRIBUTING's canonical block; self-learn is the
# one body exempt from carrying it.
#
# Usage: scripts/handoff.sh [skill]           check (every skill, or one)
#        scripts/handoff.sh --fix <skill>     repair: append the canonical
#                                              block when missing, rewrite the
#                                              tail when it diverged; refuses
#                                              ambiguous cases (duplicate,
#                                              not the last section)
# A non-verbatim body prints the diff against canonical under its FAIL line:
# `<` is what the body has, `>` is what canonical requires.

# bootstrap: locate the repo, then the shared harness
FIX=0
if [ "${1:-}" = --fix ]; then
  FIX=1
  shift
  [ -n "${1:-}" ] || { printf 'usage: scripts/handoff.sh --fix <skill>\n' >&2; exit 2; }
fi
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/common.sh"
if [ "$FIX" -eq 1 ] && [ "$SKILLS" = "$ALL_SKILLS" ]; then
  printf 'usage: scripts/handoff.sh --fix <skill>\n' >&2
  exit 2
fi

TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT INT TERM

# the canonical block: CONTRIBUTING's indented ```markdown fence starting
# with the handoff heading — single source of truth, extracted on every run.
canonical() {
  awk '
    /^  ```markdown$/ {inf = 1; buf = ""; next}
    inf && /^  ```$/ {if (buf ~ /^## Wind-down handoff/) {printf "%s", buf; exit}; inf = 0; next}
    inf {sub(/^  /, ""); buf = buf $0 "\n"}
  ' CONTRIBUTING.md
}

# one body's tail: from the handoff heading to end of file
body_handoff() {
  awk '/^## Wind-down handoff$/{on = 1} on{print}' "$1/SKILL.md"
}

# repair: keep the body up to (excluding) its handoff heading, trim trailing
# blanks, then one blank line and the canonical block.
rewrite_tail() {
  awk '/^## Wind-down handoff$/{exit} {print}' "$1" > "$TMP/head"
  trim_trailing_blanks "$TMP/head"
  { cat "$TMP/head"; printf '\n'; cat "$TMP/canonical"; } > "$1"
}

trim_trailing_blanks() {
  awk '{a[NR] = $0; if ($0 !~ /^[[:space:]]*$/) last = NR} END {for (i = 1; i <= last; i++) print a[i]}' "$1" > "$1.trimmed"
  mv "$1.trimmed" "$1"
}

canonical > "$TMP/canonical"
[ -s "$TMP/canonical" ] || { fail_ 'handoff: cannot extract canonical block — check the fence in CONTRIBUTING is indented by exactly two spaces'; finish handoff; }

for s in $SKILLS; do
  f=$s/SKILL.md
  cnt=$(grep -c '^## Wind-down handoff$' "$f")
  if [ "$s" = self-learn ]; then
    [ "$cnt" -eq 0 ] || fail_ "handoff self-learn: carries a handoff — the one body exempt from it"
    continue
  fi

  if [ "$cnt" -eq 0 ]; then
    if [ "$FIX" -ne 1 ]; then
      fail_ "handoff $s: missing"
      continue
    fi
    rewrite_tail "$f"   # no heading to cut — pastes canonical at the trimmed end
    printf 'handoff %s: canonical appended (--fix)\n' "$s"
    continue
  fi

  [ "$cnt" -eq 1 ] || { fail_ "handoff $s: appears $cnt times — ambiguous, fix by hand"; continue; }
  [ "$(grep '^## ' "$f" | tail -1)" = '## Wind-down handoff' ] ||
    { fail_ "handoff $s: not the last section — real content follows, fix by hand"; continue; }

  body_handoff "$s" > "$TMP/body"
  if cmp -s "$TMP/body" "$TMP/canonical"; then
    [ "$FIX" -eq 1 ] && printf 'handoff %s: already canonical\n' "$s"
    continue
  fi

  if [ "$FIX" -eq 1 ]; then
    rewrite_tail "$f"
    body_handoff "$s" > "$TMP/body"
    cmp -s "$TMP/body" "$TMP/canonical" &&
      printf 'handoff %s: tail rewritten from canonical (--fix)\n' "$s" ||
      fail_ "handoff $s: --fix rewrite did not converge — inspect by hand"
    continue
  fi
  fail_ "handoff $s: not verbatim vs CONTRIBUTING canonical — diff (< body, > canonical):"
  diff "$TMP/body" "$TMP/canonical" > "$TMP/d" || true
  nd=$(wc -l < "$TMP/d" | tr -d '[:space:]')
  if [ "$nd" -gt 20 ]; then
    head -20 "$TMP/d" | sed 's/^/    /'
    printf '    … (%s diff lines total — scripts/handoff.sh %s shows all)\n' "$nd" "$s"
  else
    sed 's/^/    /' "$TMP/d"
  fi
done

finish handoff
