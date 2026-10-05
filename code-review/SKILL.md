---
name: code-review
description: "MUST load before reviewing a PR or a review branch on the user's behalf. Deep, necessity-first review, spanning dispatched agents when the target is large. Lower priority than project-specific skills."
---

# Personal Code Review

**Load this before reviewing a PR or a review branch on the user's behalf.**

## Scope — PRs and review branches only

This skill reviews exactly two kinds of target, on the user's request:

1. **PRs** — fetched from GitHub (`gh pr diff`, files, comments, CI artifacts), no checkout needed.
2. **Review branches** — a branch whose changes are pending review, local or remote, reviewed from its diff (`git diff <base>...<head>`).

It is a **deep and comprehensive** review: read the whole diff, trace call paths, verify every behavioral claim, sweep the repo for the same defect class. Out of scope: the agent's pre-commit self-check of its own staged change — do not reach for this skill to self-check a commit.

Precedence: project-specific skills and repo conventions (`AGENTS.md`, review templates) win where they define a rubric; this skill covers the rest.

## Working-tree isolation

- Never switch, create, or rebase the current branch for a review — reviews of different targets may run in parallel.
- When repo-wide context is needed (grep, call paths, the defect-class sweep): use a throwaway detached worktree at the target head — fetch the head if needed, then `git worktree add --detach <tmpdir> <head>` (PRs: `git fetch origin pull/<N>/head && git worktree add --detach <tmpdir> FETCH_HEAD`) — and `git worktree remove <tmpdir>` after writing the review.

## Depth — verify everything; span agents when needed

- Every finding is verified before it is written: read the surrounding code, trace the call path, check the test actually asserts the behavior. No skimming, no speculative findings.
- Large or multi-subsystem targets: dispatch parallel read-only agents, one per subsystem or file group, through whatever agent-dispatch mechanism your harness provides. Each hands back findings with `file:line` evidence; merge and dedupe, re-verify borderline findings yourself, then write the single review file.
- One review file per target, no matter how many agents contributed.

## Output contract — never post

- Write the review to `review_<pr-number>.md` (PRs) or `review_<branch-slug>.md` (branches) in the project root; re-reviews overwrite the same file.
- NEVER post, submit, or push the review anywhere — no GitHub comments, `gh pr review` / `gh pr comment` / API calls, and no committing or pushing the file. You only draft it; the user pastes it personally or reviews by hand.
- Keep it compact: ≤ 30 lines. One-line verdict, then a numbered list — each finding 1–3 lines: `file:line` + imperative ask + at most one fact or cross-link (a one-liner fix snippet is fine when it's the point). No preamble, tables, praise/evidence sections, or `[verified]` tags; verify silently first, cite a run/artifact inline only when it carries the finding. Over ~7 findings: keep the top, one-line or drop the rest.
- Severity by verb choice, not labels — blocking: "drop the fallback", "fix it"; suggestion: "consider…", "I think…". When you know the fix, name the exact functions/APIs. Cross-link issues/PRs; assign an owner; re-flag ignored feedback.
- End with: `AI assistance (<agent>, <model> via <provider>) was used for this review.` — verified from what the session exposes, never assumed; omit what's unverified.

## Review order — flag in this priority

1. **Necessity** — For every addition ask: why does this exist? Hooks, protections, abstractions, and defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — Anything unrelated to the target's purpose: drop it. Change too huge? Split it — interface/RFC first PR, implementation second.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code.
4. **Generality & reuse** — Does this solve only one model/case? Prefer extending existing infra over introducing parallel mechanisms. Check duplication against already-landed work.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — New behavior needs a test; prefer cheap CPU tests, and flag tests that materially increase CI cost. Lightweight CPU tests may run locally (real output only); GPU claims are checked by plausibility, never asserted as run. Evidence (curves, counts) must be plausible — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it. Flag names that hide intent. Comments: self-documenting code is the bar — flag WHAT-comments, section banners, and comments the diff just orphaned (comment erosion); only WHY-comments earn their line. New or changed public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers) must document every parameter and return (`Args:` / `Returns:`); flag undocumented public surface.
8. **Workaround hygiene** — Temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.
10. **Same defect, elsewhere** — When a finding lands, check whether the same pattern or risk exists elsewhere in the diff or repo; flag the class ("this same unchecked-NaN pattern appears in 3 more places"), not just the instance found.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Verdict heuristic

A target is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.
