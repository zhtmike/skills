---
name: code-review
description: "MUST load before reviewing a PR or a review branch on the user's behalf. Deep, necessity-first review — every claim verified, every cited link resolved, every hunk held to scope — spanning dispatched agents when the target is large. Lower priority than project-specific skills."
---

# Personal Code Review

**Load this before reviewing a PR or a review branch on the user's behalf.**

## Scope — PRs and review branches only

Both targets are on the user's request:

- **PRs** — fetched from GitHub (`gh pr diff`, files, comments, CI artifacts), no checkout.
  - Read the full conversation each round; feedback newer than the head commit is unaddressed — check summaries against what they summarize.
- **Review branches** — changes pending review, read from `git diff <base>...<head>`.

A **deep and comprehensive** review: whole diff, call paths, every behavioral claim, the same defect class swept repo-wide.

Out of scope: the agent's pre-commit self-check.

## Working-tree isolation
- Never switch, create, or rebase the current branch — different targets' reviews run in parallel.
- Repo-wide context (grep, call paths, defect-class sweep) runs in a throwaway detached worktree at the head — fetched first (`pull/<N>/head` for PRs).

## Depth — verify everything; span agents when needed
- Every finding is verified before it's written — read surrounding code, trace the call path, check the test asserts the behavior.
- Never hand the author a verification the reviewer could run; only a real run (GPU, live engine) goes to the author, naming what it alone can show.
- Every external reference the change cites — issues, PRs, upstream commits, release assets — is resolved and checked to cover the claim (scope, state, in-tag).
  - A change that reimplements a published method, or rests on another codebase's behavior, is checked against ground truth — reference implementation, dependency source — not the reviewed repo alone.
- Large or multi-subsystem targets: one wave of parallel read-only agents, one per subsystem, on a cheap fast model at mid thinking (they judge, not grep) — whatever agent-dispatch mechanism your harness provides.
  - Each hands back `file:line` findings; the parent merges, dedupes, re-verifies the borderline.
  - No dispatch mechanism: review in this session, say so, narrow to the files that fit.

## Output contract
- A re-review accounts for every prior-round finding — verified fixed, re-flagged, or retracted with evidence.
  - A reviewer-side withdrawal — scope or taste — drops from the author-facing file; internal accounting only.
  - Verified-fixed findings may share a line — accounting outranks the cap.
- Write to `review_<pr-number>.md` / `review_<branch-slug>.md` in the project root; re-reviews overwrite it.
- When the round ends, remove every artifact this review created — worktree, diffs, briefs, lane outputs; the review file and handover drafts are deleted once consumed.
- Posting is the user's by default — draft only.
  - The user's explicit go on the exact text — file and inline comments — opts in: post verbatim via gh.
    - Any post-approval edit re-opens approval.
  - Post a plain comment — never an approve or a request-changes state.
  - Posted text starts at the verdict — no title line.
  - Review text is the only remote write — never commit or push code.
- Compact: ≤ 30 lines.
  - One-line verdict, then numbered findings, 1–3 lines each: `file:line` + imperative ask + at most one fact or cross-link (fix snippets excepted).
  - No preamble, tables, praise sections, or `[verified]` tags — verify silently; cite a run/artifact only when it carries the finding.
  - Blocking findings all ship, cap or no cap; past ~7, only non-blocking nits drop or one-line.
- Severity by verb choice, not labels.
  - Blocking: "drop the fallback", "fix it"; grounded cleanups get the same imperative however small.
  - "consider…" is for genuine taste calls where either shape is defensible.
  - When you know the fix, name the exact functions/APIs; cross-link, assign an owner, re-flag ignored feedback.
- End with: `AI assistance (<agent>, <model> via <provider>) was used for this review.` — verified from what the session exposes, never assumed; omit what's unverified.
- Before handover, one dispatched fast read-only lane at mid thinking checks the file against the tree: every `file:line` matches its claim, no word overstates the code, severity verbs hold, links resolve.
  - Words only — no new findings, no re-scoring; mismatches return for fix or retract.
  - No dispatch mechanism: re-read each finding at its cite; the handover discloses the self-check.

## Review order — flag in this priority
1. **Necessity** — for every addition ask: why does this exist? Hooks, protections, abstractions, defensive checks must justify themselves. Default answer: delete it.
   - An unused parameter on a public signature stays — the signature is the contract; a defensive check of an invariant already validated at the declaration is the deletion.
2. **Scope** — anything unrelated to the target's purpose: drop it.
   - In a fix round, every hunk maps to a requested finding or follows from one — unrequested changes get flagged however defensible.
   - Sibling fixes of the same defect class are in scope on the original change; on a fix round, an unasked multi-site sweep is itself a finding.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades, any untracked fallback (no `TODO(owner)`, no issue): drop them and fix formally.
   - Drop deadline is the author's: when the fix lands or the floor moves (pin bump, dropped platform or version), the workaround, its dead callers, and its tests are deleted in that change — not rewritten.
   - Until then, the workaround's end-user surface (examples, launchers, config recipes) keeps serving the legacy path — retargets ship with the closing change.
4. **Generality & reuse** — does this solve only one case? Prefer extending existing infra over parallel mechanisms.
   - Near-identical copies of already-landed work must become one — deliberate test-fixture copies excepted.
   - A new public surface is held to the closest analog — repo or dependency same-kind equivalent — flag departures with no align-or-diverge decision, or width without justification.
   - A design or refactor change is judged against the codebase's — and, where one exists, its upstream's — established structure: read them before writing design findings; departures need an align-or-diverge decision.
   - Domain-free helpers in domain modules belong in the utils layer — or upstream ships them.
5. **Single-use indirection** — globals/helpers/configs used once: inline them.
6. **Tests & evidence** — every behavior change needs a test in the same PR; prefer cheap CPU tests; never fake imports or mock what you could construct.
   - A test that guards no distinct failure mode is a finding: re-asserts a covered path, near-identical to a sibling, or asserts internals.
   - A behavior change sweeps the suite for tests asserting the replaced semantics — a live test encoding the old contract is a finding.
   - A test suggestion names the uncovered failure mode; "consider a test" is noise.
   - Fail-silent defects: the test asserts the observable signature of correct behavior, not just exit codes.
   - CI-covered tests are read, not run; the review file names failing conditions, never CI run mechanics.
   - A new test the CI job would not collect — naming, path filters — is a finding.
   - GPU claims (curves, counts) are plausibility-checked, never asserted as run; sanity-check content, not presence.
   - A red check is root-caused, not relayed — trace the failing frame via the run's artifacts; a validation claim CI contradicts is a finding.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it; flag names that hide intent.
   - Self-documenting code is the bar — flag WHAT-comments, section banners, version-dated comments outliving their version, and comments the diff orphaned.
   - Only WHY-comments earn their line, capped at two; WHY means an invariant, never provenance.
   - Status declarations of the artifact (frozen, superseded, slated for migration) are provenance's one exception — flag missing, duplicated, or scheduled prose.
   - Flag comments citing PR/issue/commit numbers (a tracked `TODO(owner)` excepted) and edit-narration (`# now retries`, `# changed from X`).
   - Flag register mismatches in code or docs — the test: a reader who never saw the design doc. Docstrings are API reference (usage examples fine, narrative not), guides guide, motivation lives in the design doc.
   - Public docs never route into machine-instruction layers — the machine layer points at the human docs, not the reverse.
   - New or changed public/open APIs (exported names, entry points, HTTP/RPC/CLI handlers, config-constructed plugin classes): document every parameter and return, and real error conditions — flag undocumented surface.
   - New or changed modules declare that surface up front (`__all__` or equivalent), helpers below — flag the undeclared or inverted layout, and constants parked mid-file.
8. **Docs sync** — README/docs updated in the same PR, dates aligned.
   - A prose change is a delta from the old text: flag a removed mechanism's mentions rewritten as "there is no X" — unmentioned means unactioned, delete outright.
   - Flag new-machinery exposition displacing calibrated old sentences — statements stay, exposition lives in the owning reference docs.
9. **Same defect, elsewhere** — when a finding lands, check for the same pattern elsewhere in the diff or repo.
   - Flag the class, not the instance.

**Skip / low priority:** formatting, typing style, docstring formatting (not content), naming bikeshedding, commit hygiene, micro-performance.

## Precedence

Project-specific skills and repo conventions (`AGENTS.md`, review skills, templates) win where they define a rubric — discovered before the verdict; this skill covers the rest.
- A repo-defined vocabulary beats the plain-language default.
- One exception: the citation ban and comment length cap hold even in comment-heavy repos.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
