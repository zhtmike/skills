---
name: coding-style
description: "MUST load before any edit to code that already works (not unproven builds) and before a demonstrated change is declared done — any language, any framework, any repo. The finishing pass: minimal diffs, fail-fast over silent fallbacks, comment hygiene, tests and docs shipped with the change."
---

# Personal Coding Style

**Load this before editing working code, and before a demonstrated change is declared done.**

## Scope — the finishing pass

Edits to already-working code, and the pass that takes a demonstrated change to done — any language, any framework, any repo.

- Taking a change to done starts from a change that demonstrably works: a real observed run or an executing test of the claimed behavior, never "should work".

## Core Principle

Write code that fails fast, carries its own explanation, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Rules

### Keep the diff minimal
- Touch only what the task needs — small diffs make personal review fast.
  - No drive-by reformat or rename of untouched lines.
- A refactor or any big change: ask first, get the go-ahead before starting.
- The same check failing twice stops the edit: report both results and the wrong hypothesis. A third try needs a new hypothesis, stated before the edit.

### Fix the class, not just the instance
- After fixing a bug, check whether the same pattern or risk exists elsewhere — same root cause means the fix applies there too.
- Sibling fixes for the same defect class are in scope, not drive-by.
  - If the sweep turns up many sites or grows into a refactor, report and ask instead of expanding the diff.

### Fail fast, never silently fall back
- Raise with actionable messages: `raise ValueError(f"Invalid backend: {x}. Must be one of {sorted(valid)}")`.
- A silent downgrade (catch-and-continue, default substitution) hides broken setups.
- Validate at the declaration — dataclass `__post_init__`, class-definition hooks; a use-site check of the same invariant is duplication.
- Chain exceptions: `raise ImportError(...) from e`.
- A genuinely temporary fallback carries `# TODO(owner): drop this and raise instead — tracked in <issue>` plus a real tracking issue. No permanent workarounds.

### Be explicit
- Modern idiomatic typing on code you write or modify — the language's current union/generic spellings — and annotated non-obvious locals.
- On code you write or modify, a module with a public surface declares it up front (`__all__` or the language's equivalent) and keeps helpers below the public API.
- A provisional name freezes in this pass once a run exercises the behavior it names.
- Inline helpers, globals, and configs that are used exactly once.
- Unused interface parameters are fine — the signature is the contract.
  - No code exists to appease a linter: no scrub statements for unused names; drop any your change takes over.
- Scripts: env-overridable defaults; a deprecated path names its replacement.

### Comments & docstrings
- Self-documenting code first: intent-revealing names, clear structure, named constants over magic numbers.
- The artifact is written for a reader who never saw its design document — vocabulary, document links, and design narrative stay in the document.
- Write docstrings as API reference — usage examples fine, design narrative not; guides guide, motivation lives in the design doc.
- Comments stay rare; each earns its line — code that says it plainly gets none.
  - A tracked `TODO(owner)` counts as earning its line.
- Comment only the non-trivial; WHY means an invariant, never provenance.
  - No comment cites a PR, issue, or commit number (`# handle #1234`, `// see PR #567` are both wrong); the sole exception is `# TODO(owner): … — tracked in <issue>` with a real issue.
  - Cross-reference the invariant or upstream behavior instead: `# stride at 16kHz; keep in sync with the feature extractor's hop_length`.
- One line per comment; two lines is the hard ceiling — anything longer belongs in a docstring.
  - A comment that narrates what the next lines do gets deleted, not written.
- Comments describe the resulting code, never the edit that produced it — no `# now retries`, `# changed from sync to async`, `# fixed the race`.
  - Patch-time justification lives in the commit/PR description or the reply, not the code.
  - Status declarations of the artifact itself (frozen, superseded, slated for migration) are provenance's one shipping exception — one per artifact, at the artifact, never its schedule.
  - Applying a patch earns no more comment allowance than writing the file fresh.
- Docstrings only on non-obvious or public functions; state the invariant or contract they pin.
  - Public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers): document every parameter and return, plus error conditions when real — a caller never needs the body.
  - One file, one field-documentation style — the project's form where it has one, never mixed across sibling classes.
- Prevent comment erosion: update or delete comments a behavior change invalidates, in the same PR.
  - Version-dated comments ("as of X…") die with X; an inaccurate comment is worse than none.

### Tests ship with the change
- Every behavior change gets a test in the same PR.
  - Where the repo's CI runs tests, ship each test matched to its collection — naming pattern, path filters.
  - Prefer cheap CPU tests (`importorskip`, `monkeypatch`) over heavy e2e; never fake import systems or mock what you could really construct.
- No tautological asserts — asserting what the mock returns.
- Fail-silent defects (no crash, plausible output) need the test to assert the observable signature of correct behavior.
  - An exit-code-only smoke passes on the corrupted run.
- Test runs: lightweight CPU tests (seconds-to-minutes, no GPU/network/downloads) may run locally, on the user's clock.
  - An explicit checkpoint ("until commit") moves verification there; between checkpoints, state the last verified result rather than re-running per edit.
  - Report only real observed output; if deps are missing, say so and list remote commands — don't install heavy stacks.
  - GPU/heavy tests run remotely: give commands + expected evidence; never claim a run you didn't see.

### Docs are part of the diff
- README/docs updated in the same PR, dates aligned.
- Public docs route to public docs — never into machine-instruction layers; the machine layer points at the human docs, not the reverse.

### Prune relentlessly
- Finish renames completely: delete emptied packages, files, and dead logging in the same PR that obsoletes them.
- No legacy code — place interim patches on the earliest, narrowest hook that runs before the failing mechanism, reusing existing hooks.
  - Post-init hooks cannot fix compile-time failures.
  - When the upstream fix lands or the floor moves (dependency or pin bump, a dropped platform or version): delete the workaround, its dead callers, and its tests in the same change.
    - Until the window closes, its end-user surface (examples, launchers, config recipes) keeps serving the legacy path — retargets ship with the closing change.
  - Code kept past its fix, or a workaround rewritten instead of dropped, is new debt, not safety.
- No duplicated functions — two copies of the same logic is a bug factory (deliberate test-fixture copies excepted).
  - When a diff touches one copy: extract the shared helper or delete the duplicate.
- Constants: module-level `SCREAMING_CASE` collections over scattered literals — consolidate the ones your diff touches.
  - Single-use constants inline their literal at the consumer.
  - Shared ones join the file's constant block at the top — a constant never parks mid-file beside one call site.
- Logging: the language's idiomatic module-level logger, lazy argument formatting.

## Design posture

- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
  - A review finding re-opens the question: verify the claim, check what the system already guarantees, and prefer deletion over patching when the justification fails.
  - Before designing a new module's public surface, read the closest existing analog — repo or pinned dependency — and align-or-diverge per shared rule; a registry checks the dependency's registries.
  - A wider surface than the analog needs justification.
- Make things general: solve the class of problem; reuse existing infra over parallel new paths.
  - A helper with no domain words lives in the repo's utils layer, not the domain module.
  - An upstream dependency may already ship it — search before writing a copy.
- Fix at the source (ideally upstream), not around it locally.

## Self-check before done

- Verify the artifact, not the tool's success message: a direction-sensitive edit (add vs remove) gets its region re-read.
- Rescan your own diff once before declaring done, against the rules it can trip — diff size, fallbacks, comments, tests, docs, public surface, pruning — not every rule.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) win — this skill is baseline personal taste, carried across repos.

One exception: the comment rules — no PR/issue/commit citations, the comment length cap — hold even where the repo's own code comments otherwise.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
