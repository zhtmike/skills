---
name: code-review
description: "The user's (zhtmike's) personal way to review code and PRs — necessity-first, scope-disciplined, zero tolerance for fallback shims, evidence-backed claims. Use when asked to review a diff or PR on the user's behalf. Lower priority than built-in and project-specific skills."
---

# Personal Code Review

> "zhtmike" always means the user — the human running the agent.

## Precedence

Project-specific review skills and repo rubrics (a repo's `self-review` skill, templates in `AGENTS.md`) take priority — run those first; apply this skill only to what they don't cover.

## Output contract — never post reviews

- Write the review to `review_<pr-number>.md` in the project root (`review_428.md` for PR #428); for pre-PR/local diffs — including the self-review before `pr_<branch-slug>.md` — use `review_<branch-slug>.md`. Re-reviews overwrite the same file.
- NEVER post, submit, or push the review anywhere — no GitHub comments, `gh pr review` / `gh pr comment` / API calls, and no committing or pushing the file. You only draft it; zhtmike pastes it personally or reviews by hand.
- Keep it compact: ≤ 30 lines. One-line verdict, then a numbered list — each finding 1–3 lines: `file:line` + imperative ask + at most one fact or cross-link. No preamble, tables, praise/evidence sections, or `[verified]` tags; verify silently first, cite a run/artifact inline only when it carries the finding. Over ~7 findings: keep the top, one-line or drop the rest.
- Write as zhtmike talks, not as a report: terse imperatives ("Drop the fallback, fix it formally"), Socratic when demanding justification ("why do we need this?"). A one-line thanks opener is fine; no praise sections.
- Fix snippets inline, one-liners only, and only when the recipe is the point.
- End with: `AI assistance (<tool>) was used for this review.` — substitute the one tool actually running the review.

## Philosophy

Minimal, general, honest diffs: no hook or fallback without justification, no scope creep, no permanent workarounds — and behavioral claims proven with data.

## Review Order — flag in this priority

1. **Necessity** — For every addition ask: why does this exist? Hooks, protections, abstractions, and defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — Anything unrelated to the PR's purpose: drop it. Change too huge? Split it — interface/RFC first PR, implementation second.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code.
4. **Generality & reuse** — Does this solve only one model/case? Prefer extending existing infra over introducing parallel mechanisms. Check duplication against already-landed work.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — New behavior needs a test; prefer cheap CPU tests, and flag tests that materially increase CI cost. Lightweight CPU tests may run locally (real output only); GPU claims are checked by plausibility, never asserted as run. Evidence (curves, counts) must be plausible — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it. Flag names that hide intent.
8. **Workaround hygiene** — Temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.

**Skip / low priority:** formatting, typing style, docstring aesthetics, naming bikeshedding, commit hygiene, micro-performance.

## Comment style (inside the review file)

- Severity by verb choice, not labels — blocking: "Drop X", "Fix it", "Non-readable. Fix it."; suggestion: "consider…", "Better to…", "I think…".
- When you know the fix, give the concrete recipe — name the exact functions/APIs.
- Cross-link issues/PRs; assign an owner for follow-ups.
- Re-flag ignored feedback; concede fast when convinced ("Agree" — move on).

## Verdict heuristic

A PR is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.
