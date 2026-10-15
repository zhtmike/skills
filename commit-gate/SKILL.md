---
name: commit-gate
description: "MUST load before any git action — commit, amend/rebase, push, PR. Approval-gated actions on the user's remote, commit-message conventions, and the fresh-review gate that must pass before every commit. Not for read-only git (status, log, diff, show)."
---

# Commit Gate

**Load this before any git action: commit, amend/rebase, push, or PR.**

## Scope — git actions only

Approvals, remotes, branches, commit messages, and the pre-commit fresh review.

## Git actions — approval-gated
- Never commit, push, or create a PR without the user's explicit approval.
  - Not approval: silence, work looking finished, an outcome-naming request ("merge main into the PR", "land it"), or a request to read or check something.
  - Approval is an explicit go on a presented diff and message.
    - "Commit this" with no diff and message on the table is not yet approval — present both and wait.
  - Commit approval bundles exactly that commit and its push to the user's own remote — never later commits.
- Just before every commit, on every path (review-triggered or not): run the repo's pre-commit hooks (if configured) and the relevant CPU tests (if they exist) — fix or report failures first. At commit time only, not after every edit.
  - Confirm the commit landed via the log — a piped hook's output masks the commit's own exit status.
  - Any diff those fixes produce joins the delta re-review.
- A hook failing only on files outside the change and outside git history (untracked scratch, another task's workspace) is an environment failure, not a change failure.
  - Run the hook's check over the tracked tree; if that is clean, bypass that hook alone.
  - Disclose both the bypass and the proof in the commit body.
- Pushes go to the user's own remote — a fork's push target, or the standalone repo's origin; identify it before the first push, asking only when ownership is ambiguous.
  - Never push upstream, even if it is `origin`.
- Branches use a short kebab-case slug with a type prefix: `feat/job-retry-lifecycle`.
- PRs are the user's by default: the agent opens one only on an explicit ask to open it.
  - When the change is pushed, write `pr_<branch-slug>.md` in the project root (`feat/job-retry-lifecycle` → `pr_job-retry-lifecycle.md`) and stop.
  - Writing or later editing that file is not a gated action.
- Follow the repo's PR template if one exists; paste-ready: what/why, root-cause narrative, test commands + real results, cross-links, required disclosures (AI assistance, duplicate-work checks).
- When the work settles, check out the repo's default branch and fast-forward it to the remote.
  - Never leave the session parked on the feature branch; a fresh session must not inherit a stale checkout.

## Commit messages
- Follow the repo's own commit convention when it defines one.
  - Otherwise: `[modules] type: subject (#PR)` — modules comma-listed, type in `feat|fix|chore|refactor|test`; prepend `[BREAKING]` when APIs change.
- Body = root-cause narrative with numbers and issue links, not a diff restatement.
- No quoted user instructions, session-habit narratives, or machine-local paths beyond what the repo already states.
- Review fixes: title `address review` + bullet list of changed areas.
- Trailers: `AI-assistance: <agent> (<model> via <provider>)` + `Co-authored-by: <agent> <noreply@<provider-domain>>` + `Signed-off-by: <user's name and email from git config>`.
  - The default set: a trailer the edited file's own rules require rides along too, never dropped for being off-list.
  - Sign-off only where the repo expects it — DCO check or docs.
  - Verify agent identity, model, and provider from what the session exposes before writing — never assume the vendor; a false attribution is worse than none.
  - If a segment is unverifiable, drop it (a bare `Co-authored-by: <agent>` is valid).

## Fresh review — the commit gate

**Trigger:** a commit approval event — an explicit go on a presented diff and message, or an amend/rebase that rewrites one — and no fresh review has run on this exact artifact: the final diff plus the full drafted commit message.
- Nothing earlier: no review because work looks done, none offered unprompted.
- An independent review from this session of this exact final diff and full message satisfies the gate.
  - A review of an earlier draft, or the session's own self-review, does not.
- Once triggered, run it directly; don't just offer.
- An approval inferred from the task rather than stated by the user is not an approval event.
- Post-review edits don't re-fire this trigger — they follow the loop below.

**Single dispatch, real review.** Dispatch exactly ONE read-only agent (no edit tools — the reviewer must not touch what it reviews; use whatever agent-dispatch mechanism your harness provides).
- Hand it the convention rules in force (project `AGENTS.md` and contributing guides supersede), the final diff, the full drafted commit message, and the writer rules this diff can trip, quoted from the body that governed the edit.
  - Comments if comments changed, tests if behavior changed, fallbacks if control flow changed — never every personal rule, never none.
- Its job is a genuine review, not a style pass: correctness, logic and edge cases, tests that actually test the behavior, security where relevant.
  - Plus the conventions in force and this file's message rules (root-cause narrative, numbers, verified trailers).
  - What only editing time could show is out of scope — no speculating.
- For each changed rule in a claim-encoding artifact, the brief states one case it must reject and one nearby case it must allow.
  - The cases come from the incident, not from the rule's own sentence.
  - Claim-encoding artifacts are skill bodies, guides, and retrospective docs.
- The pass lists each case and its verdict.
  - Not listing them — or findings all checklist-visible (format, counts, message shape) — is disengagement: re-dispatch with the cases demanded first.
  - An engaged clean pass stands.
- A rule that fails its must-allow case is blocking.
- A headline that repeats a slogan the incident rejected is blocking.
- A listed pass whose must-reject cases are rejected and whose must-allow cases hold is clean and stands.
- Findings come back with `file:line` evidence, each graded **blocking** or **nit**.
- The editing session rubber-stamping its own draft is not a review; self-review never satisfies the gate.
  - If the harness cannot dispatch an agent, stop and ask the user to review the diff — any qualified fresh pass, dispatched or the user's own, satisfies the gate.
- Right-size the lane to the artifact: an edit that cannot change behavior (message wording, typo or grammar fixes, a few prose lines with no structural change) still gets an independent dispatched pass — the lightweight one.
  - Lightweight = the harness's fast read-only model, one tight brief, short leash.
  - The full standard runs wherever the diff can change behavior, change a public signature, add a dependency, or exceed ~50 changed lines.
  - Any blocking finding, or any doubt the lightweight lane can check what this artifact needs, escalates back to the full standard.

**After the review returns:**
1. Fix each finding, blocking or nit, or report what's disputed and why — never silently skip.
   - Every changed diff gets step 2; only blocking findings arm the round cap (3) and the findings-based pre-check in (4).
2. **Delta re-review** everything the fixes changed — including hook or test fixes — the same single-dispatch way, full standard on the delta.
   - Message-only edits get a message-only pass: do the claims still match the certified diff?
   - A **full** re-review re-fires only on structural change: new files, public signatures, materially changed message claims (root cause, scope, numbers).
3. **Two-round cap.** A second delta re-review still returning blocking findings is a disagreement — stop and ask the user to arbitrate.
4. **Size check — approval licenses small changes only.** The line-count check is an approval invariant, not review machinery.
   - Small code deltas proceed under the existing approval; commit-message and PR-description edits are never large.
   - Large = a new file, a public-signature change, or a new dependency (check the diff itself before fixing), or >~50 changed lines of code delta since approval, whatever its origin.
   - Check the size after fixing and again after any commit-time hook/test fix.
   - A large change voids the commit approval: notify the user; commit nothing under the old approval.
   - Their direction licenses the work, never the commit — after directed work, rerun the review and stop for a fresh approval.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
