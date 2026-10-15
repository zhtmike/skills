#!/bin/sh
# commit-msg.sh — gate the commit message's attribution trailers.
#
# Hook mode (git's commit-msg contract): commit-msg.sh <msgfile>
#   FAIL when the drafted message carries no Co-authored-by trailer;
#   WARN when AI-assistance is absent (an unverifiable segment drops,
#   per the commit gate's own rule — a bare Co-authored-by is valid).
#   Merge commits are exempt — attribution rides the merged commits.
#
# Audit mode: commit-msg.sh --audit <rev-range>
#   The same check over landed commits — diagnoses a batch that never
#   passed the gate (e.g. fetched in from another clone).
#
# Hook wiring, once per clone:
#   pre-commit install --hook-type pre-commit --hook-type commit-msg

set -u
failures=0 warnings=0
fail_() { failures=$((failures + 1)); printf 'FAIL %s\n' "$*"; }
warn_() { warnings=$((warnings + 1)); printf 'WARN %s\n' "$*"; }

check_msg() { # $1 = label (commit sha or "draft"), $2 = message text
  if ! printf '%s\n' "$2" | grep -q '^Co-authored-by: .'; then
    fail_ "trailers $1: no Co-authored-by trailer — attribution is never optional"
  fi
  if ! printf '%s\n' "$2" | grep -q '^AI-assistance: .'; then
    warn_ "trailers $1: no AI-assistance trailer — name agent, model, and provider, or drop the segment as unverifiable"
  fi
}

verdict() {
  if [ "$failures" -eq 0 ]; then
    printf 'commit-msg: PASS (%d warning%s)\n' "$warnings" "$([ "$warnings" -eq 1 ] || printf s)"
    exit 0
  fi
  printf 'commit-msg: FAIL — %d failure%s\n' "$failures" "$([ "$failures" -eq 1 ] || printf s)"
  exit 1
}

case "${1:-}" in
  -h|--help)
    printf 'usage: %s <msgfile> | --audit <rev-range>   (menu: scripts/README.md)\n' "$0"
    exit 0
    ;;
  --audit)
    range=${2:-}
    [ -n "$range" ] || { printf 'FATAL --audit needs a rev-range\n' >&2; exit 2; }
    [ -z "${3:-}" ] || { printf 'FATAL --audit takes exactly one rev-range\n' >&2; exit 2; }
    shas=$(git rev-list --no-merges "$range") || exit 2
    for sha in $shas; do
      msg=$(git log -1 --format=%B "$sha")
      check_msg "$(git rev-parse --short "$sha")" "$msg"
    done
    verdict
    ;;
  "")
    printf 'FATAL no message file — usage: %s <msgfile> | --audit <rev-range>\n' "$0" >&2
    exit 2
    ;;
esac

[ -f "$1" ] || { printf 'FATAL no such message file: %s\n' "$1" >&2; exit 2; }
if [ -n "$(git rev-parse -q --verify MERGE_HEAD 2>/dev/null)" ]; then
  printf 'commit-msg: PASS (merge commit — exempt)\n'
  exit 0
fi
check_msg "draft" "$(cat "$1")"
verdict
