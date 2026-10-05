---
name: coding-style
description: "MUST load before touching any code and before any git action — commit, amend/rebase, push, PR. The user's conventions for edits and change structure, any language or repo: minimal diffs, approval-gated git actions, fresh-review commit gate. Defers to built-in and project-specific skills."
---

# Personal Coding Style

**Load this before any code modification or git action.** These rules are also the rubric for the fresh review at commit time (see "Fresh review" below).

## Core Principle

Write code that fails fast, explains why it exists, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Rules

### Keep the diff minimal
- Touch only what the task needs — small, clean diffs make personal review fast. No drive-by reformat or rename of untouched lines.
- A refactor or any big change: ask first and get the user's go-ahead before starting (separate from any later git-action approval).

### Fix the class, not just the instance
- After fixing a bug, check whether the same pattern or risk exists elsewhere — same root cause means the fix applies there too.
- Sibling fixes for the same defect class are in scope, not drive-by changes; if the sweep turns up many sites or grows into a refactor, report and ask instead of expanding the diff.

### Fail fast, never silently fall back
- Raise with actionable messages: `raise ValueError(f"Invalid backend: {x}. Must be one of {sorted(valid)}")`
- A silent downgrade (catch-and-continue, default substitution) hides broken setups.
- If a fallback is genuinely temporary: `# TODO(owner): drop this and raise instead — tracked in <issue>` plus a real tracking issue. No permanent workarounds.
- Chain exceptions: `raise ImportError(...) from e`.

### Be explicit
- Modern typing on code you write or modify: `str | None`, `list[int]`, annotated non-obvious locals.
- Long linear functions are fine; dense code that needs a pause to parse is not.
- Inline helpers, globals, and configs that are used exactly once.
- Scripts: env-overridable defaults (`VAR=${VAR:-default}`); deprecated paths get a header naming the replacement.

### Comments & docstrings
- Self-documenting code first: intent-revealing names, clear structure, named constants over magic numbers — the code itself carries the explanation. Comments stay rare; each must earn its line (a tracked `TODO(owner)` counts). If the code says it plainly, no comment.
- Comment only the non-trivial. WHY, not WHAT. Cross-reference the invariant or upstream behavior: `# stride at 16kHz; keep in sync with the feature extractor's hop_length`
- Docstrings only on non-obvious or public functions; state the invariant or contract they pin, when there is one.
- Prevent comment erosion: update or delete the comments a behavior change invalidates, in the same PR — an inaccurate comment is worse than none.

### Tests ship with the change
- Every behavior change gets a test in the same PR. Prefer cheap CPU tests (`importorskip`, `monkeypatch`) over heavy e2e; never fake import systems or mock what you could really construct.
- No tautological asserts (asserting what the mock returns).
- Test runs: lightweight CPU tests (seconds-to-minutes, no GPU/network/downloads) may run locally — report only real observed output; if deps are missing, say so and list remote commands instead — don't install heavy stacks. GPU/heavy tests run remotely: give commands + expected evidence; never claim a run you didn't see.

### Docs are part of the diff
- README/docs updated in the same PR, dates aligned.
- Claims need plausible evidence — don't attach numbers or curves that look wrong.

### Prune relentlessly
- Finish renames completely: delete emptied packages, files, and dead logging in the same PR that obsoletes them.
- Constants: module-level `SCREAMING_CASE` tuples/frozensets over scattered literals — consolidate the ones your diff touches.
- Logging: module-level `logger = logging.getLogger(__name__)`, lazy `%-style` args.

## Commit messages

- Follow the repo's own commit convention when it defines one. Otherwise: `[modules] type: subject (#PR)` — modules comma-listed, type in `feat|fix|chore|refactor|test`. Prepend `[BREAKING]` when APIs change.
- Body = root-cause narrative with numbers and issue links, not a diff restatement.
- Review fixes: title `address review` + bullet list of changed areas.
- Trailers: `AI-assistance: <agent> (<model> via <provider>)` + `Co-authored-by: <agent> <noreply@<provider-domain>>` + `Signed-off-by:`. Verify model and provider from what the session exposes before writing — never assume the vendor; a false attribution is worse than none. If a segment is unverifiable, drop it (a bare `Co-authored-by: <agent>` is valid).

## Git actions — approval-gated

- Never commit, push, or create a PR without the user's explicit approval. Silence is not approval; work being finished is not approval. Commit approval bundles exactly that commit and its push to the fork — it does not extend to later commits.
- Just before every commit, on every path (review-triggered or not): run the repo's pre-commit hooks (if configured) and the relevant CPU tests (if they exist) — fix or report failures first; any diff those fixes produce joins the delta re-review. At commit time only, not after every edit.
- Pushes go to the user's fork remote only. Identify the fork remote before the first push (`git remote -v`, `gh repo view --json parent`); if ambiguous or no fork exists, ask. Never push upstream, even if it is `origin`.
- Branches on the fork use a short kebab-case slug with a type prefix: `feat/async-rollout-lifecycle`, `fix/fa3-fail-fast`.
- PRs are always submitted by the user — never by the agent. When the change is pushed, write `pr_<branch-slug>.md` in the project root (branch's kebab-case slug: `feat/async-rollout-lifecycle` → `pr_async-rollout-lifecycle.md`) and stop. Writing or later editing that file is not a gated action.
- Follow the repo's PR template if one exists; paste-ready: what/why, root-cause narrative, test commands + real results, cross-links, required disclosures (AI assistance, duplicate-work checks).

## Fresh review — the commit gate

**Trigger:** a commit approval event — the user asks for a commit (or approves the agent's proposal to commit), or an amend/rebase that rewrites one — and no fresh review has run on this exact artifact: the final diff plus the full drafted commit message. Nothing earlier: no review because work looks done, none offered unprompted. Once triggered, run it directly; don't just offer. Post-review edits don't re-fire this trigger — they follow the loop below.

**Single dispatch, real review.** Dispatch exactly ONE read-only agent (no edit tools — the reviewer must not touch what it reviews; use whatever agent-dispatch mechanism your harness provides). Hand it this skill file, the final diff, and the full drafted commit message. Its job is a genuine review, not a style pass: correctness, logic and edge cases, tests that actually test the behavior, security where relevant — plus every rule above checkable from the diff and message (minimal diff, silent fallbacks, comment hygiene, tests shipped, docs synced, pruned leftovers; message: root-cause narrative, numbers, verified trailers). What only editing time could show is out of scope — no speculating. Findings come back with `file:line` evidence, each graded **blocking** or **nit** by the reviewer. The editing session rubber-stamping its own draft is not a review; if the harness cannot dispatch an agent, stop and ask the user to review the diff — any qualified fresh pass, dispatched or the user's own, satisfies the gate for that artifact. Self-review never does.

**After the review returns:**
1. Fix each finding, blocking or nit, or report what's disputed and why — never silently skip. Every changed diff gets step 2; only blocking findings arm the round cap (3) and the findings-based pre-check in (4).
2. **Delta re-review** everything the fixes changed — including diff produced by hook or test fixes — the same single-dispatch way, full standard on the delta. Message-only edits get a message-only pass: do the claims still match the certified diff? A **full** re-review re-fires only on structural change: new files, public signatures, materially changed message claims (root cause, scope, numbers).
3. **Two-round cap.** A second delta re-review still returning blocking findings is a disagreement — stop and ask the user to arbitrate.
4. **Size check — approval licenses small changes only.** Whatever grade armed the loop, the line-count check below is an approval invariant, not review machinery. Small code deltas proceed under the existing approval; commit-message and PR-description edits are never large. Large = a new file, a public-signature change, or a new dependency (visible in the findings — check before fixing), or >~50 changed lines of code delta since approval, whatever its origin (check after fixing and again after any commit-time hook/test fix). A large change voids the commit approval: notify the user; commit nothing under the old approval. Their direction licenses the work, never the commit — after directed work, rerun the review and stop for a fresh approval.

## Design posture

- Iterate on a verified working example over perfect upfront design; state Goals / Non-Goals for big changes, phase them.
- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
- Make things general: solve the class of problem, not one instance; reuse existing infra instead of building parallel new paths.
- Fix formally at the source (ideally upstream) instead of patching around it locally.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't — baseline personal taste, carried across repos.
