---
name: code-review
description: "MUST load before reviewing a PR or a review branch on the user's behalf. Deep, necessity-first review — every claim verified, every cited link resolved, every hunk held to scope — spanning dispatched agents when the target is large. Lower priority than project-specific skills."
---

# Personal Code Review

**Load this before reviewing a PR or a review branch on the user's behalf.**

## Scope — PRs and review branches only

Two target kinds, both on the user's request:

- **PRs** — fetched from GitHub (`gh pr diff`, files, comments, CI artifacts), no checkout.
  - Read the full conversation each round — comments, reviews, threads.
  - Feedback newer than the head commit is unaddressed; a summary's claims are checked against what it summarizes.
- **Review branches** — changes pending review, local or remote, read from `git diff <base>...<head>`.

A **deep and comprehensive** review: whole diff, call paths, every behavioral claim, the same defect class swept repo-wide.

Out of scope: the agent's pre-commit self-check of its staged change.

## Working-tree isolation
- Never switch, create, or rebase the current branch for a review — different targets' reviews run in parallel.
- Repo-wide context (grep, call paths, defect-class sweep) runs in a throwaway detached worktree at the target head.
  - Fetch the head if needed (PRs: `pull/<N>/head` from the base remote), then `git worktree add --detach <tmpdir> <head>`.

## Depth — verify everything; span agents when needed
- Every finding is verified before it is written — read the surrounding code, trace the call path, check the test asserts the behavior.
- Never hand the author a verification the reviewer could run — consumer greps, upstream reads, reachability checks; only what needs a real run (GPU, live engine) goes to the author, naming what a run alone can show.
- Every external reference the diff, its comments, or commit messages cite — issues, PRs, upstream commits, release assets — is resolved and checked to cover the claim (scope, state, in-tag).
  - A link is a claim, not proof — `tracked in #X` against a mismatched issue scope is a finding.
  - A change that reimplements a published method, or rests on another codebase's behavior, is checked against ground truth — the reference implementation, the dependency's source — not the reviewed repo alone.
- Large or multi-subsystem targets: one wave of parallel read-only agents, one per subsystem or file group, on a cheap fast model — whatever agent-dispatch mechanism your harness provides.
  - Each hands back `file:line` findings; the parent merges, dedupes, re-verifies the borderline.
  - No dispatch mechanism: review in this session, say so, narrow to the files that fit.

## Output contract — never post
- A re-review accounts for every prior-round finding — verified fixed, re-flagged, or retracted with evidence; none silently vanishes from the author-facing file.
  - A reviewer-side withdrawal — scope or taste, not an author action — drops from the author-facing file; internal accounting only.
  - Verified-fixed findings may share a line — accounting outranks the cap.
- Write to `review_<pr-number>.md` (PRs) or `review_<branch-slug>.md` (branches) in the project root; re-reviews overwrite the same file.
  - Delete it once consumed — a stale `review_*.md` misleads fresh sessions.
- When the round ends, written or not, remove every other artifact — worktree, saved diffs, briefs, lane outputs; the review file and handover drafts (patch, upstream issue) are the only leftovers, deleted once consumed.
- NEVER post, submit, or push the review — no review/comment/API calls anywhere, no committing or pushing the file; you draft it, the user posts it.
- Keep it compact: ≤ 30 lines.
  - One-line verdict, then numbered findings, 1–3 lines each: `file:line` + imperative ask + at most one fact or cross-link (fix snippets excepted).
  - No preamble, tables, praise sections, or `[verified]` tags — verify silently; cite a run/artifact only when it carries the finding.
  - Blocking findings all ship, cap or no cap; past ~7 findings, only non-blocking nits drop or one-line.
- Severity by verb choice, not labels.
  - Blocking: "drop the fallback", "fix it"; grounded cleanups get the same imperative however small.
  - "consider…" is for genuine taste calls where either shape is defensible.
  - When you know the fix, name the exact functions/APIs; cross-link, assign an owner, re-flag ignored feedback.
- End with: `AI assistance (<agent>, <model> via <provider>) was used for this review.` — verified from what the session exposes, never assumed; omit what's unverified.

## Review order — flag in this priority
1. **Necessity** — for every addition ask: why does this exist? Hooks, protections, abstractions, defensive checks must justify themselves. Default answer: delete it.
   - An unused parameter on a public signature stays — the signature is the contract; a defensive check of an invariant already validated at the declaration is the deletion.
2. **Scope** — anything unrelated to the target's purpose: drop it.
   - Read the file list before the hunks — files outside the purpose are findings.
   - In a fix round, every hunk must map to a requested finding or follow from one — unrequested refactors or behavior changes riding along get flagged however defensible.
   - Sibling fixes of the same defect class are in scope on the original change; on a fix round they map to a requested finding or get reported — an unasked expansion past a many-site sweep is itself a finding.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades, any fallback with no `TODO(owner)` and no real tracking issue: drop them and fix formally.
   - Drop deadline is the author's: when the fix lands or the floor moves (pin bump, dropped platform or version), the workaround, its dead callers, and its tests are deleted in that change — not rewritten.
   - Until that change, the workaround's end-user surface (examples, launchers, config recipes) keeps serving the legacy path — retargets ship with the closing change.
4. **Generality & reuse** — does this solve only one case? Prefer extending existing infra over parallel mechanisms.
   - Duplication against already-landed work: identical or near-identical copies must become one — deliberate test-fixture copies excepted.
   - A new public surface is held to the closest analog — the repo's or the dependency's same-kind equivalent — flag departures with no align-or-diverge decision, or width without justification.
   - Domain-free helpers in domain modules belong in the utils layer — or an upstream dependency may ship them.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — every behavior change needs a test in the same PR; prefer cheap CPU tests; never fake an import system or mock what you could construct.
   - Fail-silent defects need the test to assert the observable signature of correct behavior, not just exit codes.
   - CI-covered tests are read, not run — the user triggers CI; a missing CI run is never a finding.
   - A new test the CI job would not collect — naming, path filters — is a finding.
   - GPU claims are checked by plausibility, never asserted as run.
   - A red check is root-caused, not relayed — trace the failing frame via the run's artifacts; a validation claim CI contradicts is itself a finding.
   - Evidence (curves, counts) must be plausible — sanity-check the data, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it; flag names that hide intent.
   - Self-documenting code is the bar — flag WHAT-comments, section banners, version-dated comments outliving their version, and comments the diff orphaned (comment erosion).
   - Only WHY-comments earn their line, capped at two; WHY means an invariant, never provenance.
   - Status declarations of the artifact (frozen, superseded, slated for migration) are provenance's one exception — flag the missing or duplicated one, and schedule prose.
   - Flag comments citing PR/issue/commit numbers (a tracked `TODO(owner)` excepted) and edit-narration (`# now retries`, `# changed from X`).
   - Flag register mismatches in code or docs — the test is a reader who never saw the design document: docstrings are API reference (usage examples fine, design narrative not), guides guide, motivation lives in the design doc.
   - Public docs never route into machine-instruction layers — the machine layer points at the human docs, not the reverse.
   - New or changed public/open APIs (exported names, entry points, HTTP/RPC/CLI handlers): document every parameter and return, plus error conditions when real — flag undocumented surface.
   - New or changed modules declare that surface up front (`__all__` or equivalent), helpers below it — flag the undeclared or inverted layout, and constants parked mid-file.
8. **Docs sync** — README/docs updated in the same PR, dates aligned.
9. **Same defect, elsewhere** — when a finding lands, check whether the same pattern exists elsewhere in the diff or repo.
   - Flag the class, not just the instance found.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Precedence

Project-specific skills and repo conventions (`AGENTS.md`, review skills, templates) win where they define a rubric; this skill covers the rest.
- Discover them before writing the verdict — a repo-defined verdict vocabulary beats this skill's plain-language default.
- One exception: the citation ban and comment length cap hold even in comment-heavy repos.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
