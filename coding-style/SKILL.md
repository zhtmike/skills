---
name: coding-style
description: "MUST load before touching any code. The user's (zhtmike's) conventions for edits, commits, and change structure — any language or repo: minimal diffs (big refactors need prior approval), no commit/push/PR without explicit approval, PRs drafted as pr_<branch-slug>.md and submitted by the user. Defers to built-in and project-specific skills."
---

# Personal Coding Style

> "zhtmike" always means the user — the human running the agent.

**Load this before any code modification.**

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) always win. This skill covers only what they don't — baseline personal taste, carried across repos.

## Core Principle

Write code that fails fast, explains why it exists, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Rules

### Keep the diff minimal
- Touch only what the task needs — small, clean diffs make personal review fast. No drive-by reformat or rename of untouched lines.
- A refactor or any big change: ask first and get the user's go-ahead before starting (separate from any later git-action approval).

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
- Comment only the non-trivial — if the code says it plainly, no comment. A comment must earn its line.
- WHY, not WHAT. Cross-reference the invariant or upstream behavior: `# stride at 16kHz; keep in sync with the feature extractor's hop_length`
- Docstrings only on non-obvious or public functions; state the invariant being pinned.
- Delete stale comments when behavior changes — an inaccurate comment is worse than none.

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
- Trailers: AI-assistance disclosure + `Co-authored-by: <tool>` + `Signed-off-by:`.

## Git actions & PRs — approval-gated

- Never commit, push, or create a PR without the user's explicit approval for that action. Silence is not approval; work being finished is not approval.
- With explicit approval, commits and pushes are allowed — to the user's fork remote only. Identify the fork remote before the first push (`git remote -v`, `gh repo view --json parent`); if ambiguous or no fork exists, ask. Never push upstream, even if it is `origin`.
- Branches on the fork use a short kebab-case slug with a type prefix: `feat/async-rollout-lifecycle`, `fix/fa3-fail-fast`.
- Before drafting the PR file, self-review the final diff: the repo's own review skill/rubric wins, else the personal `code-review` skill. Fix findings (or list what's still open) first.
- PRs are always submitted by the user — never by the agent. When ready, write `pr_<branch-slug>.md` in the project root (branch's kebab-case slug: `feat/async-rollout-lifecycle` → `pr_async-rollout-lifecycle.md`) and stop.
- Follow the repo's PR template if one exists; paste-ready: what/why, root-cause narrative, test commands + real results, cross-links, required disclosures (AI assistance, duplicate-work checks).

## Design posture

- Iterate on a verified working example over perfect upfront design; state Goals / Non-Goals for big changes, phase them.
- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
- Make things general: solve the class of problem, not one instance; reuse existing infra instead of building parallel new paths.
- Fix formally at the source (ideally upstream) instead of patching around it locally.
