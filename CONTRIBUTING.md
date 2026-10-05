# Authoring skills for this repo

## Principles

1. **One skill, one concern** — a single clean trigger; everything else is out of scope, and the skill says so explicitly.
2. **Self-contained** — no references to other skills, by name or by concept; a skill loads alone and must make sense alone. Never "see the X skill" — inline the needed fact or drop it.
3. **Harness-agnostic** — no pi/OpenCode/Claude-specific paths, flags, or mechanics. Delegation is referenced as "whatever agent-dispatch mechanism your harness provides"; harness specifics live in the harness's own setup, never here.
4. **Compact** — rules, not scripts; every line earns its place. Deep process lives in harness mechanics, not skill prose.

## Structure (house style)

- Frontmatter: `name` (kebab-case, ≤64 chars, matching the directory) and `description` (≤1024 chars) shaped as: *"MUST load before/while `<trigger>`. `<nature of the work>`. Not for `<carve-out>`."* — or an equivalent closing boundary (`Defers to …`, `For general tasks …`). The description is the only routing surface; trigger words belong in its first sentence.
- Body: a bold load line under the H1 (usual, not universal), then `##` sections by concern — never numbered procedures. Standard shape: `## Scope — <boundary>` stating the carve-out, the concern sections, `## Precedence` (near the end — the precedence rule itself is not optional, the heading placement is).
- Mirror the sibling skills (`code-review`, `survey`) for tone and density.

## Invariants — check before committing

- grep the skill body for other skills' names **and their concepts** — zero hits.
- grep for harness specifics (CLI flags, harness paths, exit-code semantics) — zero hits.
- The description states exactly one trigger, disjoint from every other skill's trigger.
- The fresh-review commit gate (`commit-gate`) runs before any commit.

## Template

```markdown
---
name: my-skill
description: "MUST load before <trigger>. <what it does + how>. Not for <carve-out>."
---

# My Skill

**Load this before <trigger>.**

## Scope — <boundary>

<when it applies; the carve-out for what doesn't>

## <Concern sections>

<rules, by concern>

## Precedence

Project-specific <domain> guidance wins; this skill covers the rest.
```
