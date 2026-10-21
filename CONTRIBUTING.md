# Authoring skills for this repo

## Principles

1. **One skill, one concern** — a single clean trigger; everything else is out of scope, and the skill says so explicitly.
2. **Self-contained** — no references to other skills, by name or by concept; a skill loads alone and must make sense alone. Never "see the X skill" — inline the needed fact or drop it. Sole exception: the standard wind-down handoff (canonical block under Structure) closing every body but `self-learn`'s — the repo's one sanctioned cross-reference, funnelling wind-down lessons through the loop so no skill gets a hand edit.
3. **Harness-agnostic** — no pi/OpenCode/Claude-specific paths, flags, or mechanics. Delegation is referenced as "whatever agent-dispatch mechanism your harness provides"; harness specifics live in the harness's own setup, never here.
4. **Framework-agnostic where it costs nothing** — state mechanisms without naming the framework (engine init timeouts, supervisor-respawned workers, not vllm/ray specifics); skills bound to that environment (see Incident-agnostic) keep their framework names, pins, and signatures — the rest stay mechanism-level, with exact log signatures and cluster-bound commands concrete as grep handles.
5. **Incident-agnostic** — body and commit message both state the generic rule: the message carries the incident's shape (what failed, which rule changed), never repo, project, or PR/issue identifiers. Environment-specific facts are reserved to skills whose trigger is that environment (`h800-*`).
6. **Compact** — rules, not scripts; every line earns its place. Deep process lives in harness mechanics, not skill prose.
7. **Capacity is priced where it's spent** — a fan-out, a model tier, a retry loop, and a rule that will load again are costs; the skill that performs the action states the cap — never a new skill for it, never a pasted cost section.

## Structure (house style)

- Frontmatter: `name` (kebab-case, ≤64 chars, matching the directory) and `description` (≤512 chars — the description rides in every routing context; earn every char) shaped as: *"MUST load before/while/when `<trigger>`. `<nature of the work>`. Not for `<carve-out>`."* — or an equivalent closing boundary (`Defers to …`, `For general tasks …`). The description is the only routing surface; trigger words belong in its first sentence.
- Body: a bold load line under the H1 (usual, not universal), then `##` sections by concern — numbered procedures only where the order or the priority is itself the rule, never as a style choice. Standard shape: `## Scope — <boundary>` stating the carve-out, the concern sections, `## Precedence` (near the end — the precedence rule itself is not optional, the heading placement is).
- Rules and entry conditions are general conditions: concrete scenarios (a PR open, an environment set up, a job stable) appear only as examples, never as the definition — a rule that needs its example list to apply is miswritten.
- A rule states a behavior, not a spelling — which comment marker, formatter idiom, or logger incantation a project uses is its taste, pinned there and never here; spellings appear as examples at most (environment-bound skills keep their exact commands).
- One line, one rule: a bullet states a single rule, readable at a glance.
  - Conditions and exceptions nest one sub-level beneath their rule — never chain onto the line with em-dashes or semicolons.
  - A line carrying its rule, its exception, and its spelling holds three rules — split it.
- Backstop for rule lines: no more than ~40 words each.
  - `awk 'NF>40' <body>` — every hit must be an exempt line: prose paragraph, table row, code fence, frontmatter, or the frozen handoff.
- One body file per skill: obligations must be pushed whole, not pulled on demand.
  - Subfiles suit reference-shaped skills — lookup material, read when the question is known — never rule lists.
  - Decomposition follows triggers (Growth), never topics.
- Closing block: every body but `self-learn`'s ends with the standard wind-down handoff, verbatim, as its last section (the block itself gates wind-down-only and states the skip where `self-learn` is absent; structural, so it never counts against the Growth trade):

  ```markdown
  ## Wind-down handoff

  Only at the task's wind-down — never earlier — and only where `self-learn` is installed; otherwise skip this section. One question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

  - **No — end here.** One line per skill this session actually loaded — fired and helped / fired and hurt / never fired, each with one session quote or the words 'no quote'. A wind-down alone never loads `self-learn`.
  - **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
  ```
- Mirror the sibling skills (`code-review`, `survey`) for tone and density.

## Growth — compress, then split

- Ceiling: 130 lines / 1600 words per body, both hard — the frozen wind-down handoff is structural: excluded from both counts, and it never pays for an addition. Calibrated to density: content lines average ~13 words, so 130 lines ≈ 1600 words.
  - From ~105 lines or ~1300 words, an addition pays for itself by pruning weaker content (Compact as a discipline, not an aspiration).
  - Preferred payment: extract the general rule — sibling rules sharing a principle merge into it, their specifics surviving as examples at most.
  - Evict outright only what no general rule covers.
  - Never pay by merging rules onto one line.
- Every body-line deletion is on record: a commit whose diff removes SKILL.md lines carries a `Growth-Payment:` trailer naming what left and why — merged, evicted, moved with a split, retired, or reworded with no rule lost; `scripts/commit-msg.sh` floors the marker (commit-msg stage and push-side audit). Detailed accounting (net counts, checker numbers) may ride the message body above the trailer.
- Split when a section serves a different trigger than the frontmatter — a reader loading the skill for X should not carry half a body about Y. Precedent: coding-style was split into coding-style + commit-gate once commit gating accreted its own trigger.
- A split is a new skill: own directory and trigger (Principle 1), README row added, both bodies self-contained (Principle 2); name the install step in the commit message — new directories neither break existing symlinks nor propagate to installed machines. Name it at reference level (the README carries the literal commands) — local paths and per-node sync state stay out of history.

## Paired bodies — coding-style ↔ code-review

The rubric lives twice: `coding-style` states it for the writer, `code-review` checks it for the reviewer — self-containment forbids either body naming the other, so the pairing is maintained here. Paired = what a reviewer would flag as a finding in a foreign PR (necessity, fallback bans, analog shape, comment and public-surface behavior, tests-as-evidence, workaround/deadline hygiene); the writer-only remainder — spelling-level taste and local mechanics — is enforced where the writer is: the commit gate's fresh review receives the writer body itself. An edit that adds or changes a paired rule lands in both bodies — one change when hand-made, two when one side rides the incident loop (its one-file rule holds).

## Post-task updates — the incident loop

Most bodies here grew from session incidents, encoded after the fact. The retrospective half of that loop is bounded by the `self-learn` skill: it opens on one of two doors — the wind-down handoff surfacing a misfire at a settled task, or the user calling for it ("update the skills if necessary") — and a wind-down alone never opens it. Behind either door: a real-defect bar, the edit proposed to the user before it lands — and the edit is one file, the owning skill's body from this repo only (skills bundled elsewhere — a working repo's own, harness defaults, third-party collections — are reported, never edited), never a guide or scaffolding here. Fully user-specified edits follow this guide directly; those bars don't bind them. Loop commits carry a `Learned-By: self-learn` trailer, so history distinguishes the loop's edits from fully user-specified ones (which carry no marker). Retirement is human: a periodic, human-initiated prune — `git blame` shows each line's landing — retires lines whose firing reports (the handoff's report lines included) never showed a fire.

## Invariants — check before committing

- `scripts/check.sh` is the mechanical floor (menu, scoping, wiring: `scripts/README.md`) — run it before proposing a change; every commit is gated by it.
- Commit messages carry the attribution trailers the commit gate drafts — `Co-authored-by:` always, `AI-assistance:` where the session can verify it — and a `Growth-Payment:` trailer whenever the diff deletes skill-body lines (Growth); `scripts/commit-msg.sh` enforces this floor at commit-msg stage, and its `--audit <rev-range>` re-checks a landed range.
- The tools' verdicts need no fresh-review adjudication — judgment goes to the remainder (routing disjointness, paired-body sync, whether a recorded Growth payment was the right one, commit messages) and the documented blind spots (`scripts/README.md`). A false alarm is fixed in the tool, never routed around; an invariant changes only through this guide.
- grep the skill body for other skills' names **and their concepts** — zero hits outside the canonical wind-down handoff, which appears verbatim, exactly once, as the last section (the repo's only permitted cross-reference).
- grep for harness specifics (CLI flags, harness paths, exit-code semantics) — zero hits.
- grep the changed skill body for incident specifics — repo names, PR/issue numbers, symbols from the motivating codebase — zero hits outside environment-bound skills (`h800-*`).
- The description routes exactly one concern, disjoint from every other skill's trigger, within ≤512 chars — several entry doors may serve that one concern, but they all lead to the same work.
- A change that adds or changes a paired rule (Paired bodies) updates both bodies, or the commit message states why not.
- Commit messages carry the incident, not the person or the machine: no quoted user instructions, session-habit narratives, node-state (what was linked where, when), or local paths beyond what the repo's own files already state.
  - Nor the place: no repo, project, PR/issue, or commit-SHA identifiers naming where the work happened.
- No body over the ceiling (130 lines / 1600 words, the frozen handoff excluded from both counts); from ~105 lines / ~1300 words, additions pay per Growth.
- No rule line over ~40 words in a changed body — every `awk 'NF>40'` hit must be exempt (prose, table row, code fence, frontmatter, frozen handoff).
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
