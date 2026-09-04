---
name: coding-style
description: The user's (zhtmike's) personal coding conventions for writing/editing code, commits, and change structure — any language or repo. Also gates git actions: no commit, push, or PR without explicit approval; PRs are drafted as pr_<branch-slug>.md and submitted by the user. Defers to built-in and project-specific skills.
---

# Personal Coding Style

> "zhtmike" always means the user — the human running the agent.

## Precedence

Built-in skills and project-specific skills (e.g., a repo's own rubrics, `simplify`, `self-review`) and the repo's conventions (`AGENTS.md`, contributing guides) always win. This skill only governs the choices they don't cover — it is baseline personal taste, carried across repos.

## Core Principle

Write code that fails fast, explains why it exists, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Rules

### Fail fast, never silently fall back
- Raise with actionable messages: `raise ValueError(f"Invalid backend: {x}. Must be one of {sorted(valid)}")`
- A silent downgrade (catch-and-continue, default substitution) hides broken setups.
- If a fallback is genuinely temporary: `# TODO(owner): drop this and raise instead — tracked in <issue>` plus a real tracking issue. No permanent workarounds.
- Chain exceptions: `raise ImportError(...) from e`.

### Be explicit
- Modern typing everywhere: `str | None`, `list[int]`, annotated non-obvious locals.
- Long linear functions are fine; dense code that needs a pause to parse is not.
- Inline helpers, globals, and configs that are used exactly once.
- Scripts: env-overridable defaults (`VAR=${VAR:-default}`); deprecated paths get a header naming the replacement.

### Comments & docstrings
- WHY, not WHAT. Cross-reference the invariant or upstream behavior: `# stride at 16kHz; keep in sync with the feature extractor's hop_length`
- Docstrings only on non-obvious or public functions; state the invariant being pinned.
- Delete stale comments when behavior changes — an inaccurate comment is worse than none.

### Tests ship with the change
- Every behavior change gets a test in the same PR. Prefer cheap CPU tests (`importorskip`, `monkeypatch`) over heavy e2e; never fake import systems or mock what you could really construct.
- No tautological asserts (asserting what the mock returns).
- Test runs: lightweight CPU tests may be executed locally — report only real observed output. Lightweight = runs in seconds-to-minutes on CPU, no GPU/network/large downloads; if dependencies are missing, note that and fall back to listing remote commands — don't install heavy stacks locally. GPU/heavy tests run on remote machines: list exact commands + expected evidence, and never claim a test ran unless its output was actually seen.

### Docs are part of the diff
- README/docs updated in the same PR, dates aligned.
- Claims need plausible evidence — don't attach numbers or curves that look wrong.

### Prune relentlessly
- Finish renames completely: delete emptied packages, files, and dead logging in the same PR that obsoletes them.
- Constants: module-level `SCREAMING_CASE` tuples/frozensets, not scattered literals.
- Logging: module-level `logger = logging.getLogger(__name__)`, lazy `%-style` args.

## Commit messages

- Follow the repo's own commit convention when it defines one. Otherwise: `[modules] type: subject (#PR)` — modules comma-listed, type in `feat|fix|chore|refactor|test`. Prepend `[BREAKING]` when APIs change.
- Body = root-cause narrative with numbers and issue links, not a diff restatement.
- Review fixes: title `address review` + bullet list of changed areas.
- Trailers: AI-assistance disclosure + `Co-authored-by: <tool>` + `Signed-off-by:`.

## Git actions & PRs — approval-gated

- Never commit, push, or create a PR without the user's explicit approval for that action. Silence is not approval; work being finished is not approval.
- With explicit approval, commits and pushes are allowed — to the user's fork remote only. Before the first push in a repo, identify the fork remote explicitly (`git remote -v`, `gh repo view --json parent`); if the setup is ambiguous or there is no fork, ask which remote to target. Never push to an upstream remote, even if it is `origin`.
- Branches on the fork use a short kebab-case slug with a type prefix: `feat/async-rollout-lifecycle`, `fix/fa3-fail-fast`.
- Before drafting the PR file, run a self-review pass on the final diff: use the repo's own review skill/rubric when it exists (e.g., a `self-review` skill), otherwise apply the personal `code-review` skill. Fix findings (or list what remains open) first.
- PRs are always submitted by the user — never by the agent, even with approval. When the work is ready, write `pr_<branch-slug>.md` in the project root (the kebab-case slug of the branch, e.g., `pr_async-rollout-lifecycle.md` for `feat/async-rollout-lifecycle`) and stop.
- The PR file must follow the repo's PR template if one exists (`.github/PULL_REQUEST_TEMPLATE.md` or similar) and be paste-ready as-is: what/why, root-cause narrative, test commands run + results (real output only), issue cross-links, and any disclosures the repo requires (AI-assistance statements, duplicate-work checks, etc.).

## Design posture

- Iterate on a verified working example over perfect upfront design; state Goals / Non-Goals for big changes, phase them.
- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
- Make things general: solve the class of problem, not one instance; reuse existing infra instead of building parallel new paths.
- Fix formally at the source (ideally upstream) instead of patching around it locally.
