---
name: code-review
description: The user's (zhtmike's) personal way to review code and PRs — necessity-first, scope-disciplined, zero tolerance for fallback shims, evidence-backed claims. Use when asked to review a diff or PR on the user's behalf. Lower priority than built-in and project-specific skills.
---

# Personal Code Review

> "zhtmike" always means the user — the human running the agent.

## Precedence

Project-specific review skills and repo rubrics (e.g., a repo's `self-review` skill, review templates in `AGENTS.md`) always take priority — run those as the primary review and apply this skill only to what they don't cover.

## Output contract — never post reviews

- Write the complete review to `review_<pr-number>.md` in the project root (e.g., `review_428.md` when reviewing PR #428); for a pre-PR or local-diff review — including the self-review pass before drafting `pr_<branch-slug>.md` — use `review_<branch-slug>.md` (e.g., `review_async-rollout-lifecycle.md`). Re-reviews overwrite the same file.
- NEVER post, submit, or push the review anywhere — no GitHub comments, no review submission, no `gh pr review` / `gh pr comment` / API calls, and no committing or pushing the review file itself. You only draft the local file; zhtmike reads it and copy-pastes it personally, or discards it and reviews by hand.
- Format the file so it can be pasted as-is: per-finding sections with `file:line` references, severity conveyed by verb phrasing, short code snippets for concrete fixes, and issue/PR cross-links.
- Disclose automation: end the review file with a one-line disclosure in the same style as the repo's commit/PR AI-assistance convention, e.g. "AI assistance (<tool name>) was used for this review."

## Philosophy

Minimal, general, honest diffs: no hook or fallback without justification, no scope creep, no permanent workarounds — and behavioral claims proven with data.

## Review Order — flag in this priority

1. **Necessity** — For every addition ask: why does this exist? Hooks, protections, abstractions, and defensive checks must justify themselves. Default answer: delete it.
2. **Scope** — Anything unrelated to the PR's purpose: drop it. Change too huge? Split it — interface/RFC first PR, implementation second.
3. **Fallback / compat shims** — catch-and-continue, version-compat branches, silent downgrades: drop them and fix formally. Never wave through "fallback plan" code.
4. **Generality & reuse** — Does this solve only one model/case? Prefer extending existing infra over introducing parallel mechanisms. Check duplication against already-landed work.
5. **Single-use indirection** — globals/helpers/configs used once: make it inline.
6. **Tests & evidence** — New behavior needs a test; prefer cheap CPU tests over heavy ones, and flag tests that materially increase CI cost. You may run lightweight CPU tests (seconds-to-minutes, no GPU/network) locally to verify behavior — report only real observed output; GPU claims are checked by plausibility, not asserted as run. Behavioral or performance claims need plausible evidence (curves, counts) — sanity-check the data itself, not just its presence.
7. **Readability** — "What is this code doing?" If it needs re-reading, rewrite it. Flag names that hide intent.
8. **Workaround hygiene** — Temporary code must carry `TODO(owner)` + a tracking issue (+ upstream link if applicable).
9. **Docs sync** — README/docs updated in the same PR, dates aligned.

**Skip / low priority:** formatting, typing style, docstring aesthetics, naming bikeshedding, commit hygiene, micro-performance.

## Comment style (inside the review file)

- Short, imperative, direct. One finding = one section.
- Severity by verb choice, not labels:
  - Blocking: "Drop X", "Fix it", "Non-readable. Fix it."
  - Suggestion: "consider…", "Better to…", "I think…"
- Socratic when demanding justification ("why do we need this?"); imperative with a concrete recipe when you know the answer — name the exact functions/APIs to use.
- Cross-link issues/PRs for context; assign a concrete owner for follow-ups.
- Re-flag feedback that was ignored on earlier rounds.
- Concede fast when convinced: "Good point", "Agree" — then move on.

## Verdict heuristic

A PR is approvable when nothing in it is unnecessary, nothing is temporary-without-a-tracker, and every behavioral claim has evidence. Violations of these block; everything else — formatting, style nits — doesn't.
