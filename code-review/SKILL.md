---
name: code-review
description: "MUST load before reviewing any diff or PR on the user's behalf. The user's (zhtmike's) personal way to review code — necessity-first, scope-disciplined, zero tolerance for fallback shims, evidence-backed claims. Lower priority than built-in and project-specific skills."
---

# Personal Code Review

> "zhtmike" always means the user — the human running the agent.

## Precedence

Project-specific review skills and repo rubrics (a repo's `self-review` skill, templates in `AGENTS.md`) take priority — run those first; apply this skill only to what they don't cover.

## Output contract — never post reviews

- Write the review to `review_<pr-number>.md` in the project root (`review_428.md` for PR #428); for pre-PR/local diffs — including the self-review before `pr_<branch-slug>.md` — use `review_<branch-slug>.md`. Re-reviews overwrite the same file.
- NEVER post, submit, or push the review anywhere — no GitHub comments, `gh pr review` / `gh pr comment` / API calls, and no committing or pushing the file. You only draft it; zhtmike pastes it personally or reviews by hand.
- Keep it compact: ≤ 30 lines. One-line verdict (an optional one-line thanks before it is fine), then a numbered list — each finding 1–3 lines: `file:line` + imperative ask + at most one fact or cross-link (a one-liner fix snippet is fine when it's the point). No preamble, tables, praise/evidence sections, or `[verified]` tags; verify silently first, cite a run/artifact inline only when it carries the finding. Over ~7 findings: keep the top, one-line or drop the rest.
- Sound human, not report-like — substance over tone: plain, direct, casual is fine; no AI-report phrasing.
- Fix snippets inline, one-liners only, and only when the recipe is the point.
- End with: `AI assistance (<tool>) was used for this review.` — substitute the one tool actually running the review.

## Philosophy

Minimal, general, honest diffs: no hook or fallback without justification, no scope creep, no permanent workarounds — and behavioral claims proven with data.

## Working-tree isolation

- Never switch, create, or rebase the current branch for a review — reviews of different PRs may run in parallel.
- Diff-only reviews: read from GitHub (`gh pr diff`, files, comments, CI artifacts) without any checkout.
- When repo-wide context is needed (grep, call paths, the defect-class sweep): use a throwaway detached worktree at the PR head — `git fetch origin pull/<N>/head && git worktree add --detach <tmpdir> FETCH_HEAD` — and `git worktree remove <tmpdir>` after writing the review.

## Review Order — flag in this priority

1. **Necessity** — For every addition ask: why does this exist? Hooks, protections, abstractions, and defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — Anything unrelated to the PR's purpose: drop it. Change too huge? Split it — interface/RFC first PR, implementation second.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code.
4. **Generality & reuse** — Does this solve only one model/case? Prefer extending existing infra over introducing parallel mechanisms. Check duplication against already-landed work.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — New behavior needs a test; prefer cheap CPU tests, and flag tests that materially increase CI cost. Lightweight CPU tests may run locally (real output only); GPU claims are checked by plausibility, never asserted as run. Evidence (curves, counts) must be plausible — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it. Flag names that hide intent. Comments: self-documenting code is the bar — flag WHAT-comments, section banners, and comments the diff just orphaned (comment erosion); only WHY-comments earn their line.
8. **Workaround hygiene** — Temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.
10. **Same defect, elsewhere** — When a finding lands, check whether the same pattern or risk exists elsewhere in the diff or repo; flag the class ("this same unchecked-NaN pattern appears in 3 more places"), not just the instance found.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Comment style (inside the review file)

- Severity by verb choice, not labels — blocking: "drop the fallback", "fix it", "non-readable. Fix it."; suggestion: "consider…", "better to…", "I think…".
- When you know the fix, name the exact functions/APIs.
- Cross-link issues/PRs; assign an owner; re-flag ignored feedback.
- Tone is secondary to substance — write plainly and directly; avoid "This PR introduces…", "It would be great if…", "Nit:"/"Suggestion:" labels, and polished report phrasing.

## Verdict heuristic

A PR is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.
