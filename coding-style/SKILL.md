---
name: coding-style
description: "MUST load before any edit to code that already works (not unproven builds) and before a demonstrated change is declared done — any language, any framework, any repo. The finishing pass: minimal diffs, fail-fast over silent fallbacks, comment hygiene, tests and docs shipped with the change."
---

# Personal Coding Style

**Load this before editing working code, and before a demonstrated change is declared done.**

## Scope — the finishing pass

Edits to already-working code, and the pass that takes a demonstrated change to done — any language, any framework, any repo.

- Taking a change to done starts from a change that demonstrably works — a real observed run or an executing test, never "should work".

## Core Principle

Write code that fails fast, carries its own explanation, and ships with proof. No silent fallbacks, no dead code. Prefer explicit and linear over clever and compact.

## Keep the diff minimal
- Touch only what the task needs.
  - No drive-by reformat or rename of untouched lines.
- A refactor or any big change starts from an agreed design — none agreed means stop and agree one before starting.
- A prose change is a delta from the old text: existing sentences anchor rewrites, and a removed mechanism's mentions are deleted outright — never rewritten as "there is no X": unmentioned means unactioned.
  - New behavior gets statements, not exposition — the full mechanics live in the owning reference docs — and the commit message carries the same old-first balance.
- The same failure twice stops the work: report both results and the wrong hypothesis.
- Another try needs a new hypothesis, stated in one line, before any further edit.

## Fix the class, not just the instance
- After fixing a bug, check whether the same pattern or risk exists elsewhere — same root cause means the fix applies there too.
- A behavior change sweeps its consumers: callers outside the diff still hold, or are retargeted in the same PR.
- Sibling fixes for the same defect class are in scope, not drive-by.
  - If the sweep turns up many sites or grows into a refactor, report and ask instead of expanding the diff.

## Fail fast, never silently fall back
- Raise with actionable messages — name the invalid value and valid choices.
- Validate at the declaration, not the use site.
  - A use-site check of the same invariant is duplication.
- Chain exceptions so the original cause survives the re-raise.
- A silent downgrade — catch-and-continue, default substitution — hides broken setups.
- A genuinely temporary fallback carries a tracked `TODO(owner)` plus a real tracking issue. No permanent workarounds.

## Be explicit
- Modern idiomatic typing on code you write or modify — the language's current union/generic spellings — and annotated non-obvious locals.
- On code you write or modify, a module with a public surface declares it up front (`__all__` or equivalent) and keeps helpers below the public API.
- A provisional name freezes in this pass once a run exercises the behavior it names.
- Inline helpers, globals, and configs that are used exactly once.
- Unused interface parameters are fine — the signature is the contract.
  - No code exists to appease a linter: no scrub statements for unused names; drop any your change takes over.
- Scripts get env-overridable defaults; a deprecated path names its replacement.

## Comments & docstrings
- Self-documenting code first: intent-revealing names, clear structure, named constants over magic numbers.
- The artifact is written for a reader who never saw its design document — vocabulary, document links, and design narrative stay in the document.
- No shipped file cites a design doc or narrates its own history ("accepted", "slice N", "replaces X") — each states what it is.
  - Links to shipped intra-repo artifacts are fine.
- Write docstrings as API reference — usage examples fine, design narrative not; motivation lives in the design doc.
- Comments stay rare; each earns its line — code that says it plainly gets none.
- Comment only the non-trivial; WHY means an invariant, never provenance.
  - No comment cites a PR, issue, or commit number; the sole exception is a tracked `TODO(owner)` with a real issue.
  - Cross-reference the invariant or upstream behavior instead.
  - Status declarations of the artifact itself (frozen, superseded, slated for migration) are provenance's one shipping exception — one per artifact, at the artifact, never its schedule.
- One line per comment; two lines is the hard ceiling — anything longer belongs in a docstring.
  - A comment that narrates what the next lines do gets deleted, not written.
- Comments describe the resulting code, never the edit that produced it.
  - Patch-time justification lives in the commit/PR description or the reply, not the code.
- Docstrings only on non-obvious or public functions; state the invariant or contract they pin.
  - Public/open APIs (exported names, package entry points, HTTP/RPC/CLI handlers): document every parameter and return, plus error conditions when real — a caller never needs the body.
  - A config-constructed plugin class carries its config surface on `__init__` — those parameters are the API.
- Update or delete comments a behavior change invalidates, in the same PR.
  - Version-dated comments ("as of X…") die with X; an inaccurate comment is worse than none.

## Tests ship with the change
- Every behavior change gets its fewest tests in the same PR, guarding its distinct failure modes: a new behavior's observable signature, a fixed bug (regression), an uncovered boundary/error path.
  - Where the repo's CI runs tests, ship each test matched to its collection's naming and path pattern.
  - The finishing pass drops or merges the rest.
- Keep tests real and distinct.
  - Never fake import systems or mock what you could really construct.
  - Merge near-identical tests into one parameterized test.
  - No tautological asserts — a test asserting what the mock returns guards nothing.
  - A review-suggested test is a proposal; naming the covering test answers it.
- Prefer a lightweight CPU test (no GPU/network/downloads) over heavy e2e — cheap is weight, never count.
- Fail-silent defects (no crash, plausible output) need the test to assert the observable signature of correct behavior.
- Test runs: lightweight CPU tests may run locally, on the user's clock.
  - An explicit checkpoint ("until commit") moves verification there; between checkpoints, state the last verified result.
  - Report only real observed output; if deps are missing, say so and list remote commands — don't install heavy stacks.
  - GPU/heavy tests run remotely: give commands + expected evidence; never claim a run you didn't see.

## Docs are part of the diff
- README/docs updated in the same PR, dates aligned.
- Public docs never route into machine-instruction layers — the machine layer points at the human docs.

## Prune relentlessly
- Finish renames completely: delete emptied packages, files, and dead logging in the same PR.
- No legacy code — place interim patches on the earliest, narrowest hook that runs before the failing mechanism.
  - Post-init hooks cannot fix compile-time failures.
  - When the upstream fix lands or the floor moves (dependency or pin bump, a dropped platform or version): delete the workaround, its dead callers, and its tests in the same change.
  - Until that change, the workaround's end-user surface (examples, launchers, config recipes) keeps serving the legacy path — retargets ship with the closing change.
  - Code kept past its fix, or a workaround rewritten instead of dropped, is new debt, not safety.
- No duplicated functions — two copies of the same logic breed bugs (test-fixture copies excepted).
  - When a diff touches one copy: extract the shared helper or delete the duplicate.
- Consolidate the constants your diff touches into one module-level collection, not scattered literals.
  - Single-use constants inline their literal at the consumer.
  - Shared ones join the file's constant block at the top — a constant never parks mid-file beside one call site.
- Log through the language's idiomatic logger.

## Design posture

- Every new hook, protection, or abstraction must justify its existence — default to not adding it.
  - Decoupling is a dependency property, not a file count — a split pays only when the module is a unit someone loads, replaces, or tests alone.
  - A review finding re-opens the question: verify the claim, check what the system already guarantees, prefer deletion when the justification fails.
  - Before designing a new module's public surface or reshaping a module's structure, read the closest existing analog — repo or pinned dependency — and align-or-diverge; a registry checks the dependency's registries.
  - A wider surface than the analog needs justification.
- Make things general: solve the class of problem; reuse infra over parallel new paths.
  - A helper with no domain words lives in the utils layer, not the domain module.
  - An upstream dependency may already ship it — search before writing a copy.
- Fix at the source (ideally upstream), not around it locally.

## Self-check before done

- Verify the artifact, not the tool's success message: a direction-sensitive edit gets its region re-read.
- Rescan your own diff once before declaring done, against the rules it can trip — diff size, fallbacks, comments, self-containment, tests, docs, public surface, pruning — not every rule.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) win — this skill is baseline personal taste.

One exception: the comment rules — no PR/issue/commit citations, the comment length cap — hold even where repo conventions say otherwise.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt? A mid-session human correction is re-examined here: agreeing it exposed a defect — not taste — answers yes.

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
