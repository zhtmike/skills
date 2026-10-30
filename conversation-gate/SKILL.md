---
name: conversation-gate
description: "MUST load before any PR or issue operation — create, merge, close, reopen, delete, label change, title/body update, comment, or reply — or while commits land on a branch with an open PR. Approval-gated PR and issue lifecycle on the user's behalf: fresh-ask rules, what never bundles, agent-authored text conventions — reader-first bullets, self-contained accounts, the PR body synced with landed commits. Not for read-only views or the git write actions themselves (commit, amend/rebase, push)."
---

# Conversation Gate

**Load this before any PR or issue operation: create, merge, close, reopen, delete, title/body update, comment, or reply — and while commits land on a branch with an open PR.**

## Scope — repo-host conversations

Approvals for the PR and issue lifecycle; the agent's authorship rules for text on those surfaces.

## Conversation operations — approval-gated
- Never create, close, reopen, or delete a PR or issue, merge a PR, edit its text — comment, reply, body, or title update — or change labels without the user's explicit approval.
  - Not approval: silence, work looking finished, an outcome-naming request ("merge main into the PR", "land it"), a request to read something.
  - A label or lifecycle action needs a fresh ask — a standing instruction from an earlier session (a handover note) is not approval.
  - Close, delete, and branch deletion never ride a bundle: each takes its own explicit go.
  - Exception: a clearly bot-authored message (bot account or auto-generated banner) may be replied to unapproved — keep the AI-assistance line and the change's verified facts.
  - A human other than the user in the thread ends the bot-reply exemption: the ask is whether to reply as AI at all, before any wording go.
- The gated list names the common cases, not the boundary: any write to the PR or issue — its state, metadata, threads, review verdicts, reactions — needs the same approval.
- A gated step ends in an ask: the ready action or the drafted text is presented for the user's go.
- A review-response round, when it needs an ask, is one ask: the drafted reply, the body-sync delta, and their evidence present together.
  - The single go covers each text's exact wording.
- The go covers the exact wording presented — a later edit re-opens the ask.
- A posted review is a plain comment — never an approve or request-changes state; text approval is not state approval.
- Before merging a PR, re-fetch the base and re-check mergeability — an earlier fetch is stale ground.
- Operations stay on the one PR or issue the change belongs to.
- PRs and issues are the user's by default: the agent opens either only on an explicit go.
  - When the change is pushed, write `pr_<branch-slug>.md` in the project root (`feat/job-retry-lifecycle` → `pr_job-retry-lifecycle.md`), then ask to open the PR — the user's yes opens it.
  - Writing or later editing that file is not a gated action.

## Conversation text
- Follow the repo's PR or issue template if one exists; paste-ready, self-contained: what/why, root-cause narrative, test commands + real results, disclosures (AI assistance, duplicate-work checks).
- The PR body is written for the reader: where the template leaves shape open, bullets over paragraphs, one claim each — what changed, why, how it was verified.
  - It presents the change as it stands — the substance, never a commit-by-commit walk; the history lives in the commits.
- The PR body tracks its branch's landed commits: when commits change what the body claims — scope, root cause, numbers, results, disclosures — the body is updated to match before the work is called done.
  - The sync is a delta edit — stale claims change, still-true statements stand as written.
  - The update is a gated text edit with its own approval — never riding a commit or merge approval.
- Agent-authored conversation text on the remote ends with a visible AI-assistance disclosure naming agent and model, verified from what the session exposes — readers tell agent text from human.
  - An unverifiable segment is dropped, never guessed — a false attribution is worse than none.
  - A comment or reply ends with a small-print line: `AI-assisted reply — <agent> (<model>)`.
  - The PR body closes with an assistance section: what the agent did, what the human reviewed and stands behind.
- A review reply opens with its verdict: addressed, naming the commit that did it; or skipped, naming the reason.
- Behind the verdict, only verified facts — tests, runs, observed numbers.
- Agent-authored conversation text carries no quoted instructions, session narratives, process counts — review rounds, gates run — or machine-local paths beyond what the repo already states.
- Agent-authored conversation text is self-contained: links supplement the account, never replace it.

## Precision pass — posted text

- Posted text carrying claims its reviewed commits don't already certify — new numbers, results, root-cause narrative — gets a precision pass before the ask.
  - One dispatched fast read-only lane at mid thinking checks each claim against what the session observed: no word overstates, every name and number matches.
  - The bot-reply exemption skips the ask, not the pass — it stands in for the missing go; one-line acks and pure links post without it.
  - No dispatch mechanism: re-check each claim at its source and disclose the self-check.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
