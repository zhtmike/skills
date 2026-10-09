---
name: coding-style
description: "MUST load before touching any code — any edit, any language, any framework, any repo. The user's conventions for edits and change structure: minimal diffs, fail-fast over silent fallbacks, comment hygiene, tests shipped with the change."
---

# Personal Coding Style

**Load this before any code modification.** Nearly every rule here is diff-checkable — a reviewer can hold a change against them.

## Scope — how code is written

Any language, any framework, any repo.

## Core Principle

Write code that fails fast, carries its own explanation, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Rules

### Keep the diff minimal
- Touch only what the task needs — small, clean diffs make personal review fast. No drive-by reformat or rename of untouched lines.
- A refactor or any big change: ask first and get the user's go-ahead before starting.

### Fix the class, not just the instance
- After fixing a bug, check whether the same pattern or risk exists elsewhere — same root cause means the fix applies there too.
- Sibling fixes for the same defect class are in scope, not drive-by changes; if the sweep turns up many sites or grows into a refactor, report and ask instead of expanding the diff.

### Fail fast, never silently fall back
- Raise with actionable messages: `raise ValueError(f"Invalid backend: {x}. Must be one of {sorted(valid)}")`
- A silent downgrade (catch-and-continue, default substitution) hides broken setups.
- If a fallback is genuinely temporary: `# TODO(owner): drop this and raise instead — tracked in <issue>` plus a real tracking issue. No permanent workarounds.
- Chain exceptions: `raise ImportError(...) from e`.

### Be explicit
- Modern idiomatic typing on code you write or modify — the language's current union/generic spellings over legacy forms — and annotated non-obvious locals.
- A module with a public surface declares it up front (`__all__` or the language's equivalent) and keeps implementation helpers below the public API, on code you write or modify.
- Long linear functions are fine; dense code that needs a pause to parse is not.
- Inline helpers, globals, and configs that are used exactly once.
- Scripts: env-overridable defaults (`VAR=${VAR:-default}`); deprecated paths get a header naming the replacement.

### Comments & docstrings
- Self-documenting code first: intent-revealing names, clear structure, named constants over magic numbers — the code itself carries the explanation. Comments stay rare; each must earn its line (a tracked `TODO(owner)` counts). If the code says it plainly, no comment.
- Comment only the non-trivial. WHY, not WHAT — and WHY means an invariant, never provenance: no comment cites a PR, issue, or commit number (`# handle #1234`, `// see PR #567` are both wrong); the sole exception is `# TODO(owner): ... — tracked in <issue>` with a real issue. Cross-reference the invariant or upstream behavior instead: `# stride at 16kHz; keep in sync with the feature extractor's hop_length`
- One line per comment; two lines is the hard ceiling even for a non-obvious invariant — anything longer belongs in a docstring, never more comment. A comment that narrates what the next lines do gets deleted, not written.
- Comments describe the resulting code, never the edit that produced it — no `# now retries`, `# changed from sync to async`, `# fixed the race`. Patch-time justification lives in the commit/PR description or the reply, not the code; applying a patch earns no more comment allowance than writing the file fresh.
- Docstrings only on non-obvious or public functions; state the invariant or contract they pin, when there is one. Public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers) go further: document every parameter and return, plus error conditions when real — a caller should never need to read the body.
- Prevent comment erosion: update or delete the comments a behavior change invalidates, in the same PR — version-dated comments ("as of X…") die with X — an inaccurate comment is worse than none.
- Self-check before finishing: rescan your own diff against the comment rules above.

### Tests ship with the change
- Every behavior change gets a test in the same PR. Prefer cheap CPU tests (`importorskip`, `monkeypatch`) over heavy e2e; never fake import systems or mock what you could really construct.
- No tautological asserts (asserting what the mock returns).
- Defects that fail silently (no crash, plausible output) need the test to assert the observable signature of correct behavior — an exit-code-only smoke passes on the corrupted run.
- Test runs: lightweight CPU tests (seconds-to-minutes, no GPU/network/downloads) may run locally — report only real observed output; if deps are missing, say so and list remote commands instead — don't install heavy stacks. GPU/heavy tests run remotely: give commands + expected evidence; never claim a run you didn't see.

### Docs are part of the diff
- README/docs updated in the same PR, dates aligned.
- Claims need plausible evidence — don't attach numbers or curves that look wrong.

### Prune relentlessly
- Finish renames completely: delete emptied packages, files, and dead logging in the same PR that obsoletes them.
- No legacy code: place interim patches on the earliest, narrowest hook that runs before the failing mechanism (post-init hooks cannot fix compile-time failures), reusing existing hooks; when the upstream fix lands or the supported floor moves — dependency or pin bump, a dropped platform or version — delete the workaround/compat branch, its dead callers, and its tests in the same change. Code kept past its fix or floor, or a workaround rewritten instead of dropped, is new debt, not safety.
- No duplicated functions: two copies of the same logic is a bug factory (deliberate test-fixture copies excepted) — when a diff touches one copy, extract the shared helper or delete the duplicate; byte-identical helpers are the loudest smell.
- Constants: module-level `SCREAMING_CASE` tuples/frozensets over scattered literals — consolidate the ones your diff touches.
- Logging: module-level `logger = logging.getLogger(__name__)`, lazy `%-style` args.

## Design posture

- Iterate on a verified working example over perfect upfront design; state Goals / Non-Goals for big changes, phase them.
- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
- Make things general: solve the class of problem, not one instance; reuse existing infra instead of building parallel new paths.
- Fix formally at the source (ideally upstream) instead of patching around it locally.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) win. This skill covers only what they don't — baseline personal taste, carried across repos.

One exception: the comment rules above — no PR/issue/commit citations, the comment length cap — hold even when the repo's own code comments otherwise; don't imitate local comment style on these two points.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
