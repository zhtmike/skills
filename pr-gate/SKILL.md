---
name: pr-gate
description: "MUST load before any PR operation — create, merge, close, reopen, delete, label change, title/body update, comment, or reply. Approval-gated PR lifecycle on the user's behalf: fresh-ask rules, what never bundles, and agent-authored PR text conventions. Not for read-only PR views (status, checks, diff) or for git write actions (commit, amend/rebase, push)."
---

# PR Gate

**Load this before any PR operation: create, merge, close, reopen, delete, label change, PR text update, comment, or reply.**

## Scope — PR operations

Approvals for the PR lifecycle and PR text; the agent's PR authorship rules.

## PR operations — approval-gated
- Never create, close, reopen, delete, or merge a PR, edit PR text — comment, reply, body, or title update — or change labels without the user's explicit approval.
  - Not approval: silence, work looking finished, an outcome-naming request ("merge main into the PR", "land it"), a request to read something.
  - A label or lifecycle action needs a fresh ask — a standing instruction from an earlier session (a handover note) is not approval.
  - Close, delete, and branch deletion never ride a bundle: each takes its own explicit go.
  - Exception: a clearly bot-authored message (bot account or auto-generated banner) may be replied to unapproved — keep the AI-assistance line and the change's verified facts.
- PR operations stay on the one PR the change belongs to.
- PRs are the user's by default: the agent opens one only on an explicit ask.
  - When the change is pushed, write `pr_<branch-slug>.md` in the project root (`feat/job-retry-lifecycle` → `pr_job-retry-lifecycle.md`) and stop.
  - Writing or later editing that file is not a gated action.

## PR text
- Follow the repo's PR template if one exists; paste-ready, self-contained: what/why, root-cause narrative, test commands + real results, disclosures (AI assistance, duplicate-work checks).
- Agent-posted or agent-edited PR text on the remote ends with a visible AI-assistance line naming agent and model, verified from what the session exposes — readers tell agent text from human.
- PR bodies are self-contained: links supplement the account, never replace it.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
