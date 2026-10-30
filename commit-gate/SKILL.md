---
name: commit-gate
description: "MUST load before any git write action — commit, amend/rebase, push. Approval-gated actions on the user's remote, commit-message conventions, and the fresh-review gate that must pass before every commit. Not for read-only git (status, log, diff, show) or for PR operations."
---

# Commit Gate

**Load this before any git write action: commit, amend/rebase, push.**

## Scope — git write actions

Approvals, remotes, branches, commit messages, and the pre-commit fresh review.

## Git actions — approval-gated
- Never commit or push without the user's explicit approval.
  - Not approval: silence, work looking finished, an outcome-naming request, a request to read something.
  - Approval is an explicit go on a presented diff and message.
  - Commit approval bundles exactly that commit and its push — never later commits.
  - A standing repo pre-approval from the user stands in for that approval — paid by the fresh review.
- Just before every commit, on every path: run the repo's pre-commit hooks (if configured) and the relevant CPU tests (if they exist) — fix or report failures first. At commit time only, not after every edit.
  - Confirm the commit landed via the log — piped hook output masks the commit's exit status.
  - Any diff those fixes produce joins the delta re-review.
- A hook failing only on files outside the change and git history (untracked scratch, another task's workspace) is an environment failure, not a change failure.
  - Run the hook's check over the tracked tree; if clean, bypass that hook alone.
  - Disclose the bypass and its proof in the commit body.
- Pushes go to the user's own remote — a fork's push target or the standalone repo's origin; identify it before the first push, asking only when ambiguous.
  - Never push upstream, even if it is `origin`.
- Re-fetch the base and re-check mergeability before pushing when verification used an earlier fetch.
  - Upstream work landing in that gap publishes against the new base; semantic drift re-opens review scope.
- Branches use a short kebab-case slug with a type prefix: `feat/job-retry-lifecycle`.
- When the work settles, check out the repo's default branch and fast-forward it to the remote — only when no live writer holds the checkout; otherwise park it and say so.
  - A parked branch is reported at handover, never assumed clean.

## Commit messages
- Follow the repo's own commit convention when it defines one.
  - Otherwise: `[modules] type: subject (#PR)` — modules comma-listed, type in `feat|fix|chore|refactor|test`; prepend `[BREAKING]` when APIs change.
- Body = root-cause narrative with numbers, not a diff restatement.
- Commit bodies are self-contained: links supplement the account, never replace it.
- No quoted user instructions, session-habit narratives, or machine-local paths beyond what the repo already states.
- Review fixes: title `address review` + bullet list of changed areas.
- Trailers: `AI-assistance: <agent> (<model>)` + `Co-authored-by: <agent> <noreply@<provider-domain>>` + `Signed-off-by: <user's name and email from git config>`.
  - The default set: a trailer the edited file's own rules require rides along too, never dropped for being off-list.
  - Sign-off only where the repo expects it — DCO check or docs.
  - Verify agent identity and model from what the session exposes before writing — a false attribution is worse than none.
  - If a segment is unverifiable, drop it (a bare `Co-authored-by: <agent>` is valid).

## Fresh review — the commit gate

**Trigger:** a licensed commit — under an explicit go, a standing repo pre-approval, or an amend/rebase rewriting one — and no fresh review has run on this exact artifact: the final diff plus the full drafted commit message.
- Nothing earlier: no review because work looks done, none offered unprompted.
- An independent review from this session of this exact artifact satisfies the gate.
  - A review of an earlier draft does not.
- Once triggered, run it directly; don't just offer.
- The review precedes the commit — an unreviewed push, amends included, is the violation; post-hoc review documents, not repairs.
- Post-review edits don't re-fire this trigger — the loop below governs.

**Single dispatch, real review.** Dispatch exactly ONE read-only agent (no edit tools; use whatever agent-dispatch mechanism your harness provides).
- A lane granted execution — it must run checks or fixtures — gets an outright destructive-command ban in its brief, and the repo is snapshotted before dispatch.
- The brief carries the artifact — final diff plus full drafted commit message — and pointers, never questions, quoted rule subsets, or summaries:
  - Rule files by path: the writer body that governed the edit, the project's `AGENTS.md`, its contributing guides; the lane reads what is named and judges applicability itself.
  - Task evidence by path, what exists: the change's design text, its investigation report, prior review rounds' findings — absent entries are skipped, never reconstructed.
- Its job is a genuine review, not a style pass: correctness, logic and edge cases, tests that actually test the behavior, security where relevant.
  - Plus the conventions in force and this file's message rules (root-cause narrative, numbers, self-contained bodies, verified trailers).
  - What only editing time could show is out of scope — no speculating.
- For each changed rule in a claim-encoding artifact, the brief states one case it must reject and one nearby case it must allow.
  - The review covers the delta: verdict cases come from changed rules only — a previously certified guarantee is re-checked when the delta touches its line, never in a regression round.
  - The cases come from the incident, not from the rule's own sentence.
  - Claim-encoding artifacts are skill bodies, guides, and retrospective docs.
- The pass lists each case and its verdict, and enumerates its recall sweep — edge cases examined, conformance to the change's design text where one exists, claim provenance.
  - Not listing them, no sweep, or findings all checklist-visible (format, counts, message shape) — is disengagement: re-dispatch, both demanded first.
  - An enumerated sweep with zero findings stands.
- A rule that fails its must-allow case is blocking.
- A headline that repeats a slogan the incident rejected is blocking.
- A listed pass whose must-reject cases are rejected and whose must-allow cases hold is clean and stands.
- Findings come back with `file:line` evidence, each graded **blocking** or **nit**.
- The editing session rubber-stamping its own draft is not a review.
  - If the harness cannot dispatch, the user's own review satisfies the gate — stop and ask for it.
- Right-size the lane to the artifact, time and cost priced into its size: behavior-capable diffs (logic, public signatures, new dependencies, >~50 changed lines) get the full standard — the harness's judgment tier; all others a dispatched lightweight pass.
  - Lightweight = the harness's fast read-only model at its lowest thinking, one tight brief, short leash.
  - A blocking finding, or a check the lightweight pass reports it could not run, escalates to the full standard.

**After the review returns:**
1. Fix each finding, blocking or nit, or report what's disputed and why — never silently skip.
   - Every changed diff gets step 2; only blocking findings arm the round cap (3) and the findings-based pre-check in (4).
2. **Delta re-review** everything the fixes changed — including hook or test fixes — the same single-dispatch way, right-sized to the delta itself.
   - Message-only edits get a message-only pass: do the claims still match the certified diff?
   - A **full** re-review re-fires only on structural change: new files, public signatures, materially changed message claims (root cause, scope, numbers).
3. **Two-round cap.** A second delta re-review still returning blocking findings is a disagreement — stop and ask the user to arbitrate.
4. **Size check — approval licenses small changes only.** The line-count check is an approval invariant, not review machinery.
   - Small code deltas proceed under the existing approval; commit-message and PR-description edits are never large.
   - Large = a new file, a public-signature change, or a new dependency (check the diff itself before fixing), or >~50 changed lines of code delta since approval, whatever its origin.
   - Check the size after fixing and again after any commit-time hook/test fix.
   - A large change voids the commit approval — a go or the standing pre-approval for this work: notify the user; commit nothing under it.
   - Their direction licenses the work, never the commit — after directed work, rerun the review and stop for a fresh approval.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
