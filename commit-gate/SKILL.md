---
name: commit-gate
description: "MUST load before any git action — commit, amend/rebase, push, PR. Approval-gated actions on the user's fork, commit-message conventions, and the fresh-review gate that must pass before every commit."
---

# Commit Gate

**Load this before any git action: commit, amend/rebase, push, or PR.**

## Scope — git actions only

Approvals, remotes, branches, commit messages, and the pre-commit fresh review.

## Git actions — approval-gated

- Never commit, push, or create a PR without the user's explicit approval. Silence is not approval; work being finished is not approval. A request naming an outcome that implies a commit ("merge main into the PR", "land it") states the goal, not the approval — the approval is an explicit go on a presented diff and message. An instruction to read or check something approves reading, not acting on what it finds. Commit approval bundles exactly that commit and its push to the fork — it does not extend to later commits.
- Just before every commit, on every path (review-triggered or not): run the repo's pre-commit hooks (if configured) and the relevant CPU tests (if they exist) — fix or report failures first; any diff those fixes produce joins the delta re-review. At commit time only, not after every edit.
- A hook failing only on files outside the change and outside git history (untracked scratch, another task's workspace) is an environment failure, not a change failure: run the hook's check over the tracked tree, and if that is clean, bypass that hook alone and disclose both the bypass and the proof in the commit body.
- Pushes go to the user's fork remote only. Identify the fork remote before the first push (`git remote -v`, `gh repo view --json parent`); if ambiguous or no fork exists, ask. Never push upstream, even if it is `origin`.
- Branches on the fork use a short kebab-case slug with a type prefix: `feat/job-retry-lifecycle`, `fix/port-bind-fail-fast`.
- PRs are always submitted by the user — never by the agent. When the change is pushed, write `pr_<branch-slug>.md` in the project root (branch's kebab-case slug: `feat/job-retry-lifecycle` → `pr_job-retry-lifecycle.md`) and stop. Writing or later editing that file is not a gated action.
- Follow the repo's PR template if one exists; paste-ready: what/why, root-cause narrative, test commands + real results, cross-links, required disclosures (AI assistance, duplicate-work checks).

## Commit messages

- Follow the repo's own commit convention when it defines one. Otherwise: `[modules] type: subject (#PR)` — modules comma-listed, type in `feat|fix|chore|refactor|test`. Prepend `[BREAKING]` when APIs change.
- Body = root-cause narrative with numbers and issue links, not a diff restatement.
- Review fixes: title `address review` + bullet list of changed areas.
- Trailers: `AI-assistance: <agent> (<model> via <provider>)` + `Co-authored-by: <agent> <noreply@<provider-domain>>` + `Signed-off-by: <user's name and email from git config>` (only where the repo expects sign-off — DCO check or docs). Verify model and provider from what the session exposes before writing — never assume the vendor; a false attribution is worse than none. If a segment is unverifiable, drop it (a bare `Co-authored-by: <agent>` is valid).

## Fresh review — the commit gate

**Trigger:** a commit approval event — the user asks for a commit (or approves the agent's proposal to commit), or an amend/rebase that rewrites one — and no fresh review has run on this exact artifact: the final diff plus the full drafted commit message. Nothing earlier: no review because work looks done, none offered unprompted. An approval inferred from the task rather than stated by the user is not an approval event. Once triggered, run it directly; don't just offer. Post-review edits don't re-fire this trigger — they follow the loop below.

**Single dispatch, real review.** Dispatch exactly ONE read-only agent (no edit tools — the reviewer must not touch what it reviews; use whatever agent-dispatch mechanism your harness provides). Hand it the user's coding-convention rules in force — project `AGENTS.md` and contributing guides supersede — the final diff, and the full drafted commit message. Its job is a genuine review, not a style pass: correctness, logic and edge cases, tests that actually test the behavior, security where relevant — plus the conventions in force and this file's message rules (root-cause narrative, numbers, verified trailers), all checked against what the diff and message can show. What only editing time could show is out of scope — no speculating. Findings come back with `file:line` evidence, each graded **blocking** or **nit** by the reviewer. The editing session rubber-stamping its own draft is not a review; if the harness cannot dispatch an agent, stop and ask the user to review the diff — any qualified fresh pass, dispatched or the user's own, satisfies the gate for that artifact. Self-review never does.

**After the review returns:**
1. Fix each finding, blocking or nit, or report what's disputed and why — never silently skip. Every changed diff gets step 2; only blocking findings arm the round cap (3) and the findings-based pre-check in (4).
2. **Delta re-review** everything the fixes changed — including diff produced by hook or test fixes — the same single-dispatch way, full standard on the delta. Message-only edits get a message-only pass: do the claims still match the certified diff? A **full** re-review re-fires only on structural change: new files, public signatures, materially changed message claims (root cause, scope, numbers).
3. **Two-round cap.** A second delta re-review still returning blocking findings is a disagreement — stop and ask the user to arbitrate.
4. **Size check — approval licenses small changes only.** Whatever grade armed the loop, the line-count check below is an approval invariant, not review machinery. Small code deltas proceed under the existing approval; commit-message and PR-description edits are never large. Large = a new file, a public-signature change, or a new dependency (check the diff itself before fixing), or >~50 changed lines of code delta since approval, whatever its origin (check after fixing and again after any commit-time hook/test fix). A large change voids the commit approval: notify the user; commit nothing under the old approval. Their direction licenses the work, never the commit — after directed work, rerun the review and stop for a fresh approval.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.
