# scripts/ — this repo's check tooling

The mechanical floor for [CONTRIBUTING.md](../CONTRIBUTING.md)'s invariants:
what these tools settle needs no fresh-review adjudication. A false alarm is
fixed in the tool, never routed around; an invariant changes only through
CONTRIBUTING.

| Pick | When | Usage |
|---|---|---|
| `check.sh` | the whole gate — also the pre-commit entry | `scripts/check.sh [skill]` |
| `structure.sh` | frontmatter shape, size ceiling, registry (stray entries, README rows, scripts/ whitelist) | `scripts/structure.sh [skill]` |
| `content.sh` | cross-references, harness/incident vocabulary, long rule lines | `scripts/content.sh [skill]` |
| `handoff.sh` | the frozen wind-down handoff — prints a diff on mismatch | `scripts/handoff.sh [skill]` |
| `handoff.sh --fix` | a body's handoff missing or diverged at the tail (ambiguous cases refused) | `scripts/handoff.sh --fix <skill>` |
| `report.sh` | size budgets before adding to a near-ceiling body | `scripts/report.sh [skill]` |
| `common.sh` | never picked — the shared harness (limits, patterns, diagnostics) | sourced only |

A `[skill]` argument scopes a tool to one skill; repo-wide sub-checks then
stay silent. Diagnostics name their concern (`frontmatter`, `ceiling`,
`registry`, `crossrefs`, `harness`, `incident`, `rule-lines`, `handoff`) —
FAIL blocks; WARN advises, and `report.sh` is the WARN home. `-h` on the
runnable tools prints their usage.

## What the gate settles — and what it doesn't

Treat a FAIL as signal, never noise: it is either a real violation or one
of the documented false-positive triggers below — in which case the fix
lands in the tool, not the body (AGENTS.md's false-alarm rule). Treat PASS
as floor, not innocence: the semantic remainder (routing disjointness,
paired-body sync, whether prose holds three rules) stays with the fresh
review. Per concern — false negatives (wrongly passes) are what the review
still owns; false positives (wrongly fails) are the triggers to check
before rewording a correct body:

| Concern | False negatives | False positives |
|---|---|---|
| `frontmatter` | a description routing multiple concerns (semantic); duplicate `name:`/`description:` lines beyond the first | an opener other than "MUST load" only warns, though CONTRIBUTING allows equivalent boundaries |
| `ceiling` | none — exact count, terminal newline included | none |
| `registry` | a README row's content beyond the name cell; duplicate rows for one skill; stray top-level directories (deliberately unflagged — local untracked dirs would collide) | none |
| `crossrefs` | concept references without the name ("see the reviewing skill") — the invariant bans concepts too; capitalized mentions (the match is case-sensitive — a case-insensitive one false-positives on verbs like a "Propose, then edit" heading) | hyphenated prose collisions: "a code-review pass" (adjective) reads as a skill reference |
| `harness` | vocabulary beyond the list — new harness names, paraphrases ("the print flag") | "exit code N" describing a non-harness tool's semantics (h800 bodies discuss cluster commands) |
| `incident` | repo/project names without numbers; short SHAs (deliberately — hex-word collisions); paths outside `~/gitlocal` and `/Users/`; anything inside `h800-*` bodies, which the invariant exempts | a PR/issue number in legitimate prose outside backticks (rare) |
| `rule-lines` | rules miswritten as prose paragraphs (no bullet marker) escape the 40-word cap | a bullet that is legitimately one long unfenced example can exceed 40 words without holding three rules |
| `handoff` | `--fix` trusts everything above the heading — deletions above the tail repair silently | none — byte-exact against canonical; a reformatted CONTRIBUTING fence fails loudly |

## Wiring

One path — the pre-commit framework running this repo's own gate:

```sh
pre-commit install
```

The root `.pre-commit-config.yaml` defines a single local hook running
`check.sh` (no third-party linters; skill bodies are never auto-formatted).
If a previous hook occupies the slot, `pre-commit install -f` replaces it.
