---
name: spike
description: "MUST load before building anything unproven — new feature, POC, prototype, tricky change, any code whose shape is still being learned — proved only by an observed run or an executing test of the claimed behavior. Make it work first and demonstrate it with a real run; polish, generality, and docs are deferred until it does. Not for the finishing pass of a demonstrated change, nor for drafting a non-trivial design — new interface, subsystem, refactor, migration, multi-step series — until accepted."
---

# Spike

**Load this before writing code whose approach isn't settled.**

## Scope — unproven builds only

New features, POCs, prototypes, tricky changes — code written to learn what the solution is. The approach is settled when this slice has an observed run or an executing test of its claimed behavior; until then, a tricky change to working code still loads this skill. The finishing pass — polish, shipped tests, docs — is out of scope.

## Build to learn

- A messy example that demonstrates beats clean code that might: speed over polish while the approach is unproven.
- Iterate on a verified working example over perfect upfront design.
  - State Goals / Non-Goals for the spike's one question, never a design: one line of goal, one line of non-goal.
- Add no hook, protection, or abstraction the working example doesn't yet demand.
- Fix the root cause, not the symptom: reproduce, understand, then change.
- Fail loudly while building: raise on the unexpected.
  - Never bake a silent fallback into what you build.
- Report only real observed output, never a run not seen.
  - Missing dependencies get named, not silently installed.

## Stay on the core

- The spike answers one question; everything else is out of its path.
- Prove with the narrowest check that answers it: a targeted run, a scratch script, one executed test.
  - No test-suite sweeps per edit; the change's full verification waits for the demonstrated build.
- An unrelated failure the spike trips over gets one line in the report, not a detour.
  - Pre-existing red, broken env, flaky sibling: note it, route around, move on.
- The same failure twice ends the attempt: report both results. Another try needs a new hypothesis, stated in one line, before any further edit.

## Done — demonstrated, not vibes

- The build is done when the change is demonstrated working: a real observed run or an executing test of the claimed behavior.
- A demonstrated change is not yet a finished one; polish, shipped tests, and docs come after, on the demonstrated base.

## Precedence

Built-in skills, project-specific skills, and repo conventions (`AGENTS.md`, contributing guides) win — this skill is baseline personal taste, carried across repos.

## Wind-down handoff

Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
