---
name: code-review
description: "MUST load before reviewing a PR or a review branch on the user's behalf. Deep, necessity-first review — every claim verified, every cited link resolved, every hunk held to the target's scope — spanning dispatched agents when the target is large. Lower priority than project-specific skills."
---

# Personal Code Review

**Load this before reviewing a PR or a review branch on the user's behalf.**

## Scope — PRs and review branches only

This skill reviews exactly two kinds of target, on the user's request:

1. **PRs** — fetched from GitHub (`gh pr diff`, files, comments, CI artifacts), no checkout needed.
   - Read the full conversation each round — comments, reviews, inline threads, edits, replies.
   - Feedback newer than the head commit is unaddressed; a summary's claims are checked against what it summarizes.
2. **Review branches** — a branch whose changes are pending review, local or remote, reviewed from its diff (`git diff <base>...<head>`).

It is a **deep and comprehensive** review: read the whole diff, trace call paths, verify every behavioral claim, sweep the repo for the same defect class.

Out of scope: the agent's pre-commit self-check of its own staged change — do not reach for this skill to self-check a commit.

Precedence: project-specific skills and repo conventions (`AGENTS.md`, review templates) win where they define a rubric; this skill covers the rest.
- One exception: the provenance-citation ban and comment length cap hold even in comment-heavy repos.

## Working-tree isolation
- Never switch, create, or rebase the current branch for a review — reviews of different targets may run in parallel.
- Repo-wide context (grep, call paths, the defect-class sweep) runs in a throwaway detached worktree at the target head.
  - Fetch the head if needed, then `git worktree add --detach <tmpdir> <head>`.
  - PRs: `git fetch <base-remote> pull/<N>/head && git worktree add --detach <tmpdir> FETCH_HEAD` — `<base-remote>` is the PR's base repo, often `upstream` not `origin`; `git remote -v` first.
  - `git worktree remove <tmpdir>` when the round ends, written or not.

## Depth — verify everything; span agents when needed
- Every finding is verified before it is written: read the surrounding code, trace the call path, check the test actually asserts the behavior. No skimming, no speculative findings.
- Never hand the author a verification the reviewer could have run — consumer greps, upstream reads, reachability checks.
  - A draft saying "verify or justify X" means the check wasn't done: run it, then ask with evidence or drop the item.
  - Only what needs a real run (GPU, live engine) goes to the author, naming what a run alone can show.
- Every external reference the diff, its comments, or its commit messages cite — issues, PRs, upstream commits, release assets — is resolved and checked to exist and to cover the claim (scope, state, in-tag).
  - A link is a claim, not proof: `tracked in #X` whose issue's scope doesn't match the TODO is a finding.
  - A change that reimplements a published method, or one resting on another codebase's behavior, is verified against ground truth — the reference implementation, the dependency's source — not the reviewed repo alone.
- Large or multi-subsystem targets: dispatch parallel read-only agents, one per subsystem or file group, through whatever agent-dispatch mechanism your harness provides.
  - Each hands back `file:line` findings; merge, dedupe, re-verify the borderline, then write the single review file.

## Output contract — never post
- A re-review accounts for every prior-round finding — verified fixed, withdrawn with evidence, or re-flagged; none silently vanishes.
  - Verified-fixed findings may share a line — accounting outranks the cap.
- Write the review to `review_<pr-number>.md` (PRs) or `review_<branch-slug>.md` (branches) in the project root; re-reviews overwrite the same file.
  - Delete it once the user confirms it posted or was otherwise consumed — a stale `review_*.md` misleads fresh sessions.
- When the round ends, written or not, remove every other artifact — worktree, saved diffs, dispatched agents' briefs and outputs.
  - The review file and the round's handover drafts (patch, upstream issue) are the only deliberate leftovers, deleted once consumed.
- NEVER post, submit, or push the review anywhere — no GitHub comments, `gh pr review` / `gh pr comment` / API calls, no committing or pushing the file.
  - You only draft it; the user pastes it personally or reviews by hand.
- Keep it compact: ≤ 30 lines.
  - One-line verdict, then numbered findings, 1–3 lines each: `file:line` + imperative ask + at most one fact or cross-link (fix snippets excepted).
  - No preamble, tables, praise/evidence sections, or `[verified]` tags — verify silently, citing a run/artifact only when it carries the finding.
  - Over ~7 findings: keep the top, one-line or drop the rest.
- Severity by verb choice, not labels.
  - Blocking: "drop the fallback", "fix it"; grounded cleanups get the same imperative however small.
  - "consider…" is for genuine taste calls where either shape is defensible.
  - When you know the fix, name the exact functions/APIs; cross-link issues/PRs, assign an owner, re-flag ignored feedback.
- End with: `AI assistance (<agent>, <model> via <provider>) was used for this review.` — verified from what the session exposes, never assumed; omit what's unverified.

## Review order — flag in this priority
1. **Necessity** — for every addition ask: why does this exist? Hooks, protections, abstractions, defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — anything unrelated to the target's purpose: drop it.
   - Read the file list before the hunks: files outside the purpose are findings before their content is.
   - In a fix round, every hunk must map to a requested finding or follow directly from one — unrequested refactors or behavior changes riding along get flagged however defensible.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code.
   - A dependency or pin bump is the drop deadline: every tracked workaround whose upstream fix rode the bump is deleted, not rewritten.
4. **Generality & reuse** — does this solve only one model/case? Prefer extending existing infra over parallel mechanisms.
   - Duplication against already-landed work: identical or near-identical copies must become one.
   - A new registry/protocol/base is held to the repo's closest existing analog — flag a wider surface than the analog without justification.
   - Domain-free helpers in domain modules belong in the utils layer — or an upstream dependency may already ship them.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — new behavior needs a test; prefer cheap CPU tests; flag tests that materially increase CI cost.
   - Fail-silent fixes need the test to assert the observable signature of correct behavior, not just exit codes.
   - CI-covered tests are read, not run — the user triggers CI.
   - A missing CI run is never a finding.
   - A new test the CI job would not collect — naming, path filters — is a finding unless run locally (real output only).
   - GPU claims are checked by plausibility, never asserted as run.
   - A red check is root-caused, not relayed — trace the failing frame via the run's artifacts; a validation claim deterministic CI contradicts is itself a finding.
   - Evidence (curves, counts) must be plausible — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it; flag names that hide intent.
   - Self-documenting code is the bar — flag WHAT-comments, section banners, version-dated comments outliving their version, and comments the diff orphaned (comment erosion).
   - Only WHY-comments earn their line, capped at two; WHY means an invariant, never provenance.
   - Flag comments citing PR/issue/commit numbers (a tracked `TODO(owner)` excepted) and edit-narration (`# now retries`, `# changed from X`).
   - New or changed public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers): document every parameter and return, plus error conditions when real — flag undocumented surface.
   - New or changed modules declare that surface up front (`__all__` or the language's equivalent), helpers below it — flag the undeclared or inverted layout, and shared constants parked mid-file instead of the file's constant block.
8. **Workaround hygiene** — temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.
10. **Same defect, elsewhere** — when a finding lands, check whether the same pattern or risk exists elsewhere in the diff or repo.
    - Flag the class, not just the instance found.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Verdict heuristic

A target is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
