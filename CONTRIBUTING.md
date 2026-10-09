# Authoring skills for this repo

## Principles

1. **One skill, one concern** — a single clean trigger; everything else is out of scope, and the skill says so explicitly.
2. **Self-contained** — no references to other skills, by name or by concept; a skill loads alone and must make sense alone. Never "see the X skill" — inline the needed fact or drop it. Sole exception: the standard wind-down handoff (canonical block under Structure) closing every body but `self-learn`'s — the repo's one sanctioned cross-reference, funnelling wind-down lessons through the loop so no skill gets a hand edit.
3. **Harness-agnostic** — no pi/OpenCode/Claude-specific paths, flags, or mechanics. Delegation is referenced as "whatever agent-dispatch mechanism your harness provides"; harness specifics live in the harness's own setup, never here.
4. **Framework-agnostic where it costs nothing** — state mechanisms without naming the framework (engine init timeouts, supervisor-respawned workers, not vllm/ray specifics); exact log signatures and cluster-bound commands stay concrete as grep handles.
5. **Incident-agnostic** — the skill body states the generic rule; the incident that motivated it (repo, PR/issue numbers, codebase symbols) lives in the commit message only. Environment-specific facts are reserved to skills whose trigger is that environment (`h800-*`).
6. **Compact** — rules, not scripts; every line earns its place. Deep process lives in harness mechanics, not skill prose.

## Structure (house style)

- Frontmatter: `name` (kebab-case, ≤64 chars, matching the directory) and `description` (≤512 chars — the description rides in every routing context; earn every char) shaped as: *"MUST load before/while `<trigger>`. `<nature of the work>`. Not for `<carve-out>`."* — or an equivalent closing boundary (`Defers to …`, `For general tasks …`). The description is the only routing surface; trigger words belong in its first sentence.
- Body: a bold load line under the H1 (usual, not universal), then `##` sections by concern — never numbered procedures. Standard shape: `## Scope — <boundary>` stating the carve-out, the concern sections, `## Precedence` (near the end — the precedence rule itself is not optional, the heading placement is).
- Rules and entry conditions are general conditions: concrete scenarios (a PR open, an environment set up, a job stable) appear only as examples, never as the definition — a rule that needs its example list to apply is miswritten.
- Closing block: every body but `self-learn`'s ends with the standard wind-down handoff, verbatim, as its last section (the block itself gates wind-down-only and states the skip where `self-learn` is absent; structural, so it never counts against the Growth trade):

  ```markdown
  ## Wind-down handoff

  Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

  - **No — end here.** A wind-down alone never loads `self-learn`.
  - **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
  ```
- Mirror the sibling skills (`code-review`, `survey`) for tone and density.

## Growth — compress, then split

- Ceiling: 100 lines / 1600 words per body. From ~80 lines or ~1300 words, additions pay for themselves — tighten or replace existing lines instead of appending (Compact as a discipline, not an aspiration).
- Split when a section serves a different trigger than the frontmatter — a reader loading the skill for X should not carry half a body about Y. Precedent: coding-style was split into coding-style + commit-gate once commit gating accreted its own trigger.
- A split is a new skill: own directory and trigger (Principle 1), README row added, both bodies self-contained (Principle 2); name the install step in the commit message — new directories neither break existing symlinks nor propagate to installed machines. Name it at reference level (the README carries the literal commands) — local paths and per-node sync state stay out of history.

## Post-task updates — the incident loop

Most bodies here grew from session incidents, encoded after the fact. The retrospective half of that loop is bounded by the `self-learn` skill: a wind-down checkpoint — task settled, not to be redone soon, or the user calling for it ("update the skills if necessary") — a real-defect bar, the edit proposed to the user before it lands — and the edit is one file, the owning skill's body from this repo only (skills bundled elsewhere — a working repo's own, harness defaults, third-party collections — are reported, never edited), never a guide or scaffolding here. Fully user-specified edits follow this guide directly; those bars don't bind them. Loop commits carry a `Learned-By: self-learn` trailer, so history distinguishes the loop's edits from fully user-specified ones (which carry no marker). Retirement is human: a periodic, human-initiated prune — `git blame` shows each auto-added line's landing — retires lines whose firing reports never showed a fire.

## Invariants — check before committing

- grep the skill body for other skills' names **and their concepts** — zero hits outside the canonical wind-down handoff, which appears verbatim, exactly once, as the last section (the repo's only permitted cross-reference).
- grep for harness specifics (CLI flags, harness paths, exit-code semantics) — zero hits.
- grep the changed skill body for incident specifics — repo names, PR/issue numbers, symbols from the motivating codebase — zero hits outside environment-bound skills (`h800-*`).
- The description routes exactly one concern, disjoint from every other skill's trigger, within ≤512 chars — several entry doors may serve that one concern, but they all lead to the same work.
- Commit messages carry the incident, not the person or the machine: no quoted user instructions, session-habit narratives, node-state (what was linked where, when), or local paths beyond what the repo's own files already state.
- No body over the ceiling (100 lines / 1600 words); from ~80 lines or ~1300 words, additions must tighten what is there — and split when a section serves a different trigger, per Growth.
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

## Wind-down handoff

<the standard closing block, verbatim — see Closing block under Structure>
```
