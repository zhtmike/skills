---
name: survey
description: "MUST load before any intensive, broad investigation — a question spanning too many sources, subsystems, or papers for a single context. Many focused, independent lanes dispatched concurrently through the harness's native sub-agent/dispatch mechanism; one report per lane, synthesized into one answer. Not for single-context questions."
---

# Survey

**Load this before any multi-source or multi-subsystem investigation.**

## Scope — one context is the boundary

A question that fits a single session's focus needs no survey — answer it directly. A question spanning sources, subsystems, or papers gets decomposed into lanes and dispatched. Show the lane plan and launch without waiting — ask first only if genuinely ambiguous.

## Decompose for breadth

- One focused, non-overlapping lane per source, subsystem, or sub-question — typically 3–6, more when the question is genuinely wide; never merge two questions into one lane.
- Prefer more narrow lanes over fewer broad ones — focus makes findings deep, and cheap lanes keep breadth affordable.

## Lane briefs

- Goal, known context (repo, versions, constraints), scope, expected deliverable: findings with sources (`file:line`, URLs, paper IDs), conclusions, open questions.
- Each lane is independent: own context, read-only, answers exactly its brief and nothing else.
- Where the harness dispatches via files, briefs are files in the session's work directory; where it dispatches native sub-agents, the brief is the sub-agent's prompt.

## Dispatch and failure handling

- Run all lanes concurrently through the harness's native sub-agent/dispatch mechanism — cheap/fast model per lane where the harness allows.
- A failed or empty lane: rerun it alone. Rate-limited provider: run lanes sequentially.

## Synthesis

- One answer, conflicts between lanes called out explicitly; report the conclusions.
- Where artifacts are files, clean up briefs and lane outputs once the work they informed is done.

## Precedence

Project-specific investigation guidance wins; this skill covers the rest.
