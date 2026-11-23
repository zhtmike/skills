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
  - A standing instruction from an earlier session is not approval.
  - A standing repo pre-approval the user configured stands in for it — each gated op still gets its fresh-verified text.
  - Close, delete, and branch deletion never ride a bundle: each takes its own explicit go.
  - A human other than the user in the thread: the ask is whether to reply as AI at all, before any wording go.
- The gated list names common cases, not the boundary: any write to the PR or issue — state, metadata, threads, review verdicts, reactions — needs the same approval.
- A gated step ends in an ask: the ready action or drafted text, presented for the user's go.
- A review-response round is one ask: the drafted reply, the body-sync delta, and their evidence present together.
- A posted review is a plain comment — never an approve or request-changes state; text approval is not state approval.
- Before merging a PR, re-fetch the base and re-check mergeability — an earlier fetch is stale.
- Operations stay on the PR or issue the change belongs to.
- PRs and issues are the user's by default: the agent opens either only on an explicit go.
  - When the change is pushed, ask to open the PR — the user's yes opens it.
  - Writing or editing a PR draft file is not a gated action.

## Conversation text
- Paste-ready, self-contained: what/why, root-cause narrative, test commands + real results, disclosures.
- The PR body is written for the reader: where the template leaves shape open, bullets over paragraphs, one claim each.
  - It presents the change as it stands — the substance, never a commit-by-commit walk.
- An edit of an existing body rewrites it as one current account: new facts fold into the sections they belong to.
  - Dated update blocks and `as of` snapshot framing never ride on top.
- Sentences hold one point each: stacked clause chains — em-dashes, semicolons, nested parentheses — are split into sentences.
- Prose paragraphs post as one unwrapped line: remotes render every newline as a visible break — fixed-column wrapping reads as broken sentences.
- The PR body tracks its branch's landed commits: when commits change what the body claims — scope, root cause, numbers, results, disclosures — it is updated to match before the work is called done.
  - The sync is a delta edit — stale claims change, still-true statements stand as written.
  - The update is a gated text edit with its own approval — never riding a commit or merge approval.
- Agent-authored conversation text on the remote carries exactly one AI-assistance disclosure naming agent and model — the posting tool's where it writes one, else the text's own, verified from what the session exposes.
  - An unverifiable segment is dropped, never guessed — a false attribution is worse than none.
  - A comment or reply ends with a small-print line: `AI-assisted reply — <agent> (<model>)`.
  - A standalone review closes with the review footer, never a reply marker.
  - The PR body closes with an assistance section: what the agent did, what the human reviewed and stands behind.
  - The assistance section lists modes of work only — investigation, design, implementation — never the process behind them: review rounds, dispatch lanes, gate counts.
- Posted-text register follows the poster's role on the target repo.
  - A non-committer posts suggestions — findings, evidence, fix directions; no verdicts, gating language, or CI/process narration (untriggered jobs, runs, admission): maintainer territory.
- A review reply lands in the thread it answers, never as a top-level comment.
- A review reply opens with its verdict: addressed, naming the commit that did it; or skipped, naming the reason.
- A reply names what it answers in its own text: the finding, request, or comment, quoted or restated.
  - Threading is no anchor — collapsed threads, notifications, and top-level posts all drop the parent.
- Behind the verdict, only verified facts — tests, runs, observed numbers.
- Agent-authored conversation text carries no quoted instructions, session narratives, process counts, or machine-local paths beyond what the repo states.
- Agent-authored conversation text is self-contained: links supplement the account, never replace it.
- Every reference a reader must reach — issue, PR, commit, doc, paper — posts as a working link on its destination, never as dead text.
  - Auto-link spellings render bare — cross-repo refs owner-qualified (`owner/repo#N`, never `repo#N`).
  - What the platform leaves plain — paper IDs — carries its full URL.

## Precision pass — posted text

- Posted text carrying claims its reviewed commits don't already certify — new numbers, results, root-cause narrative — gets a precision pass before the ask.
  - One dispatched fast read-only lane checks each claim against what the session observed: no word overstates, every name and number matches.
  - Every review lane runs at high or maximum thinking, whatever its model — a fast model at low thinking reviews nothing.
  - The pass also checks the artifact against its destination — right audience, right platform — and that no name or numbering minted for another venue or a retired plan reaches the post.
  - The pass also checks the final text against the Conversation-text rules above.
  - Self-containment especially: every lettering, ID, or enumeration a reader must resolve is defined in the post itself.
  - One-line acks and pure links post without the precision pass; every other reply keeps it.
  - A standalone review's text, already verified against the tree before handover, posts on that check — no duplicate pass.
  - No dispatch mechanism: re-check each claim at its source and disclose the self-check.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
