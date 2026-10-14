---
name: propose
description: "MUST load before drafting or materially revising the design for a non-trivial change — interface, subsystem, migration, multi-PR series. Pin the smallest behavior contract others code against, keep machinery minimal behind it, verify claims against the code, and review scope for weight as hard as for correctness. Not for trivial edits, not for executing an already-agreed design, not for the proving build of that design."
---

# Propose

**Load this before designing a non-trivial change — and again before materially revising that design.**

## Scope — the design gate before code

Fires when a change is big enough to need agreement first: a new interface or subsystem, a refactor or migration plan, a multi-step series.

Out of scope: trivial edits; executing an already-agreed design; interrogating a person's plan at their request (a different concern); the proving build of an agreed approach.

## Situate the design

- Check the parent or upstream project's precedent before inventing a convention — its habits are the ecosystem's default.
- Read the higher-level charter and sibling efforts for boundaries already drawn; compose with them, never re-own their scope.
- Name new generations by identity, not version ordinals — ordinals collide with neighbors and expire.
- Migration follows the neighboring code: add alongside, warn while the old path still works, delete only after a window.
  - The old path stays callable through that window. Renaming it belongs to the delete, not the add.

## Author the minimal contract

- The boundary's behavior is the deliverable: it outlives the machinery, so design effort lands there.
- Machinery behind the boundary may land minimal and harden later, provided the observable contract holds.
- Design for the problem the code has today: a mode for a case not yet landed or an enum for a single caller is over-engineering even when internally consistent.
- State goal and non-goals, constraints with evidence, the contract surface, the smallest first slice, and a testable done-when per slice.
- Pin behaviors, not vocabulary: freeze what must hold — ordering, error and shutdown semantics; signatures, enums, and schemas stay provisional until a first implementation exercises them.
- Every frozen surface names its payer — the concrete near-term exercise that types it. No payer, no freeze.
- If an existing switch already expresses a behavior, extend it; never mint parallel vocabulary that then needs reconciling with the old.
- Find the module that already owns the problem before designing a second owner for it.
- State each contract exactly once — a second statement of the same contract drifts into contradiction.
- A series names its first slice (the smallest) and the contents of every later slice.

## Make it checkable

- Every factual claim is checked against the tree before review: line anchors, counts, method names.
- A claim that an existing symbol, config key, or call site exists fails when the tree lacks it.
  - A name the design introduces is marked as a proposal.
- Every constraint is checkable — a rule you cannot test, or a validator you cannot write, is not a constraint.
- Every non-obvious inherited mechanism carries its why, where it is cited — unexplained plumbing trips every reviewer the way it tripped the author.
- The document is standing and self-contained: no revision narration; history lives in the discussion thread and commits.

## Review for weight, not only correctness

- Correctness reviews (consistency, implementability) always reward more specification — weight needs its own axis, asked out loud.
- The weight question, verbatim in every review brief: should this be specified now — has a first exercise paid for freezing it?
- Whatever agent-dispatch mechanism your harness provides, dispatched reviewers get that question in the brief.
- Each round re-verifies the previous round's fixes and stops when the weight pass's unresolved findings are empty.
- A finding that asks to freeze a surface with no payer is resolved by cutting that surface.
- A design that passes correctness while freezing unexercised surface is over-engineered: cut inside the accepted direction rather than restart.

## Converged, then code

- The behavior pins and the named first slice are enough to start that slice's code.
- Freeze names in the first implementation's review, not in the design.
- Anchor the design where the project anchors designs (its issue, RFC, or doc convention) before the first code lands.

## Precedence

Project-specific design guidance wins; this skill covers the rest.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
