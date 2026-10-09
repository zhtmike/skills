---
name: code-review
description: "MUST load before reviewing a PR or a review branch on the user's behalf. Deep, necessity-first review — every claim verified, every cited link resolved, every hunk held to the target's scope — spanning dispatched agents when the target is large. Lower priority than project-specific skills."
---

# Personal Code Review

**Load this before reviewing a PR or a review branch on the user's behalf.**

## Scope — PRs and review branches only

This skill reviews exactly two kinds of target, on the user's request:

1. **PRs** — fetched from GitHub (`gh pr diff`, files, comments, CI artifacts), no checkout needed. Read the full conversation each round — comments, reviews, inline threads, edits, replies; feedback newer than the head commit is unaddressed, and a summary's claims are checked against what it summarizes.
2. **Review branches** — a branch whose changes are pending review, local or remote, reviewed from its diff (`git diff <base>...<head>`).

It is a **deep and comprehensive** review: read the whole diff, trace call paths, verify every behavioral claim, sweep the repo for the same defect class. Out of scope: the agent's pre-commit self-check of its own staged change — do not reach for this skill to self-check a commit.

Precedence: project-specific skills and repo conventions (`AGENTS.md`, review templates) win where they define a rubric; this skill covers the rest. One exception: the provenance-citation ban and comment length cap hold even in comment-heavy repos — don't let local comment style excuse them.

## Working-tree isolation

- Never switch, create, or rebase the current branch for a review — reviews of different targets may run in parallel.
- When repo-wide context is needed (grep, call paths, the defect-class sweep): use a throwaway detached worktree at the target head — fetch the head if needed, then `git worktree add --detach <tmpdir> <head>` (PRs: `git fetch <base-remote> pull/<N>/head && git worktree add --detach <tmpdir> FETCH_HEAD` — `<base-remote>` = the PR's base repo, often `upstream` not `origin`; `git remote -v` first) — and `git worktree remove <tmpdir>` when the round ends, written or not.

## Depth — verify everything; span agents when needed

- Every finding is verified before it is written: read the surrounding code, trace the call path, check the test actually asserts the behavior. No skimming, no speculative findings.
- Never hand the author a verification the reviewer could have run — consumer greps, upstream reads, reachability checks. A draft saying "verify or justify X" means the check wasn't done: run it, then ask with evidence or drop the item. Only what needs a real run (GPU, live engine) goes to the author, naming what a run alone can show.
- Every external reference the diff, its code comments, or the commit messages cite — issues, PRs, upstream commits, release assets — is resolved and checked to exist and to cover what the citation claims (scope, state, in-tag); a link is a claim, not proof. A `tracked in #X` whose issue's scope doesn't match the TODO is a finding.
- Large or multi-subsystem targets: dispatch parallel read-only agents, one per subsystem or file group, through whatever agent-dispatch mechanism your harness provides; each hands back `file:line` findings — merge, dedupe, re-verify the borderline, then write the single review file.
- One review file per target, no matter how many agents contributed.

## Output contract — never post

- A re-review accounts for every prior-round finding — verified fixed, withdrawn with evidence, or re-flagged; none silently vanishes.
- Write the review to `review_<pr-number>.md` (PRs) or `review_<branch-slug>.md` (branches) in the project root; re-reviews overwrite the same file. Delete it only once the user confirms it is posted or otherwise consumed — a stale `review_*.md` misleads fresh sessions.
- When the round ends, written or not, remove every other artifact it created — the throwaway worktree, saved diffs, dispatched agents' briefs and outputs; the review file and the round's handover drafts (patch, upstream issue) are the only deliberate leftovers, deleted once consumed, per the bullet above.
- NEVER post, submit, or push the review anywhere — no GitHub comments, `gh pr review` / `gh pr comment` / API calls, and no committing or pushing the file. You only draft it; the user pastes it personally or reviews by hand.
- Keep it compact: ≤ 30 lines. One-line verdict, then a numbered list — each finding 1–3 lines: `file:line` + imperative ask + at most one fact or cross-link (fix snippets excepted). No preamble, tables, praise/evidence sections, or `[verified]` tags; verify silently first, cite a run/artifact inline only when it carries the finding. Over ~7 findings: keep the top, one-line or drop the rest.
- Severity by verb choice, not labels — blocking: "drop the fallback", "fix it"; grounded cleanups get the same imperative however small; "consider…" is for genuine taste calls where either shape is defensible. When you know the fix, name the exact functions/APIs. Cross-link issues/PRs; assign an owner; re-flag ignored feedback.
- End with: `AI assistance (<agent>, <model> via <provider>) was used for this review.` — verified from what the session exposes, never assumed; omit what's unverified.

## Review order — flag in this priority

1. **Necessity** — For every addition ask: why does this exist? Hooks, protections, abstractions, and defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — Anything unrelated to the target's purpose: drop it. Read the file list before the hunks: files outside the purpose are findings before their content is; in a fix round, every hunk must map to a requested finding or follow directly from one — unrequested refactors or behavior changes riding along get flagged however defensible. Change too huge? Split it — interface/RFC first PR, implementation second.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code. A dependency or pin bump is the drop deadline: audit every tracked workaround whose upstream fix rode the bump — it must be deleted, not rewritten.
4. **Generality & reuse** — Does this solve only one model/case? Prefer extending existing infra over introducing parallel mechanisms. Check duplication against already-landed work; duplicated functions — byte-identical or near-identical copies — must become one.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — New behavior needs a test; prefer cheap CPU tests, and flag tests that materially increase CI cost. Fixes for defects that fail silently need the test to assert the observable signature of correct behavior, not just exit codes. Lightweight CPU tests may run locally (real output only); GPU claims are checked by plausibility, never asserted as run. A red check is root-caused, not relayed — trace the failing frame to its origin via the run's artifacts; a validation claim deterministic CI contradicts is itself a finding. Evidence (curves, counts) must be plausible — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it. Flag names that hide intent. Comments: self-documenting code is the bar — flag WHAT-comments, section banners, version-dated comments outliving their version, and comments the diff just orphaned (comment erosion); only WHY-comments earn their line, capped at two lines. WHY means an invariant, never provenance — flag comments citing PR/issue/commit numbers (a tracked `TODO(owner)` excepted) and edit-narration (`# now retries`, `# changed from X`). New or changed public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers) must document every parameter and return, plus error conditions when real — flag undocumented public surface. New or changed modules declare that surface up front (`__all__` or the language's equivalent), helpers below it — flag the undeclared or inverted layout.
8. **Workaround hygiene** — Temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.
10. **Same defect, elsewhere** — When a finding lands, check whether the same pattern or risk exists elsewhere in the diff or repo; flag the class ("this same unchecked-NaN pattern appears in 3 more places"), not just the instance found.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Verdict heuristic

A target is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.

## Wind-down handoff

At the task's wind-down, one question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
