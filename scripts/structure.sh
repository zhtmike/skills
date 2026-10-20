#!/bin/sh
# structure.sh — shape checks for the repo and its skill bodies:
#
#   frontmatter  name matches its directory, kebab-case, <=64 chars;
#                description <=512 chars, opening with the trigger phrase (warn)
#   ceiling      content <=130 lines / <=1600 words, the frozen wind-down
#                handoff excluded (self-learn has none — whole file counts);
#                from 105/1300 it warns (Growth)
#   registry     one SKILL.md per directory, a README row per skill and back;
#                scripts/ holds only this checker set (repo-wide parts skip
#                when scoped)
#
# Usage: scripts/structure.sh [skill]

# bootstrap: locate the repo, then the shared harness
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/common.sh"

# frontmatter: the description is the only routing surface
frontmatter() {
  for s in $SKILLS; do
    name=$(fm_name "$s") desc=$(fm_desc "$s")
    [ "$name" = "$s" ] || fail_ "frontmatter $s: name '$name' != directory"
    printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' || fail_ "frontmatter $s: '$name' not kebab-case"
    [ "${#name}" -le "$NAME_MAX" ] || fail_ "frontmatter $s: name over $NAME_MAX chars"
    [ -n "$desc" ] || { fail_ "frontmatter $s: no description"; continue; }
    n=$(printf '%s' "$desc" | wc -m | tr -d '[:space:]')
    [ "$n" -le "$DESC_MAX" ] || fail_ "frontmatter $s: description $n chars > $DESC_MAX"
    case $desc in "MUST load"*) ;; *) warn_ "frontmatter $s: description lacks a 'MUST load' opener" ;; esac
  done
}

# ceiling: bodies stay compact; the warn zone is where Growth payment bites.
# The frozen wind-down handoff is structural — excluded from both counts.
ceiling() {
  for s in $SKILLS; do
    f=$s/SKILL.md
    lines=$(awk '/^## Wind-down handoff$/{exit} {n++} END{print n+0}' "$f")
    words=$(awk '/^## Wind-down handoff$/{exit} {w += NF} END{print w+0}' "$f")
    [ "$lines" -le "$CEIL_LINES" ] || fail_ "ceiling $s: $lines lines > $CEIL_LINES"
    [ "$words" -le "$CEIL_WORDS" ] || fail_ "ceiling $s: $words words > $CEIL_WORDS"
    if [ "$lines" -le "$CEIL_LINES" ] && [ "$words" -le "$CEIL_WORDS" ] &&
      { [ "$lines" -ge "$WARN_LINES" ] || [ "$words" -ge "$WARN_WORDS" ]; }; then
      left=$((CEIL_WORDS - words)) axis=words
      [ $(( (CEIL_LINES - lines) * CEIL_WORDS )) -lt $(( left * CEIL_LINES )) ] &&
        { left=$((CEIL_LINES - lines)); axis=lines; }
      warn_ "ceiling $s: $lines lines / $words words — near ceiling, $axis bind with $left left"
    fi
  done
}

# registry: directories, README table, and the scripts/ whitelist agree
registry() {
  for s in $SKILLS; do
    stray=$(ls -A "$s" | grep -v '^SKILL.md$' | tr '\n' ' ')
    [ -z "$stray" ] || fail_ "registry $s: stray entries — $stray"
    grep -q "^| \`$s\`" README.md || fail_ "registry: README has no row for $s"
  done
  scoped && return 0
  for row in $(grep -oE '^\| `[a-z0-9-]+`' README.md | tr -d '|` '); do
    [ -d "$row" ] || fail_ "registry: README row '$row' has no skill directory"
  done
  EXPECTED='README.md check.sh common.sh commit-msg.sh content.sh handoff.sh report.sh structure.sh'
  for e in $EXPECTED; do
    [ -f "scripts/$e" ] || fail_ "registry: scripts/$e missing"
  done
  for f in $(ls -A scripts); do
    case " $EXPECTED " in *" $f "*) ;; *) fail_ "registry: unexpected entry scripts/$f" ;; esac
  done
}

frontmatter
ceiling
registry
finish structure
