# zhtmike/skills

Personal agent skills — harness-agnostic (pi, OpenCode, Claude Code), self-contained, one concern per skill. Installed as symlinks so this repo stays the single source of truth.

## Skills

| Skill | Load when | Scope |
|---|---|---|
| `spike` | before building anything unproven — new feature, POC, prototype, tricky change, any code whose shape is still being learned | exploration license: make it work, demonstrate with a real run of the claimed behavior (that run is what settles the approach), defer polish and abstraction |
| `propose` | before drafting or materially revising the design for a non-trivial change — interface, subsystem, refactor or migration, multi-PR series | smallest behavior contract: pin what must hold, leave names provisional until a first exercise, verify claims, review weight as hard as correctness; ends at the anchored, accepted text |
| `coding-style` | before any edit to code that already works, and before a demonstrated change is declared done | the finishing pass: minimal diffs, fail-fast, comment hygiene, tests and docs with the change |
| `commit-gate` | before any git write action (commit / amend / rebase / push) | approval-gated actions on the fork, commit-message conventions, fresh-review commit gate |
| `pr-gate` | before any PR operation (create / merge / close / reopen / delete / label / text update / comment / reply) | approval-gated PR lifecycle: fresh-ask rules, never-bundle destructives, bot-reply exemption, agent PR-text conventions (template, `pr_<branch-slug>.md`, AI marker) |
| `code-review` | before reviewing a PR or a review branch on the user's behalf | deep, necessity-first review — every claim and cited link verified, every hunk held to scope; may span multiple dispatched agents; drafted to a `review_*.md` file, posted only on the user's explicit go |
| `survey` | before any intensive, broad investigation | typed decomposition, budgets, claim-based findings, verification lane only when the answer gates a risky decision, synthesis schema |
| `self-learn` | when a task's lessons are to be encoded into an owning skill — the wind-down pass (task settled, an owning skill misfired; its closing handoff surfaces this, never wind-down alone) or the user's explicit request, whatever the wording; zhtmike's setups only | proposes a one-file edit to a skill owned by this repo only (repo-bundled, harness-default, third-party skills are reported, never edited): scar verbatim, falsifier, firing report, full gates — never new skills, not for fully user-specified edits |
| `h800-env-setup` | before creating or repairing a Python/GPU env on the H800 cluster | conda + cuda-compat, uv vs pip, flashinfer JIT toolkit |
| `h800-run-jobs` | before launching any long-running GPU job — or diagnosing a launch that left no job running | ssh-detach launch pattern, compat exports, GPU selection |
| `h800-monitor-jobs` | while any long-running GPU job is in flight | polling cadence, failure signatures, cleanup checklist |

The `h800-*` skills apply only on H800 cluster nodes (driver 535 / CUDA 12.2) — install them there, not on every machine.

## Install

skills CLI (installs as symlinks; `skills update` propagates):

```bash
npx skills add zhtmike/skills --global -a <agent> --skill spike --skill propose --skill coding-style --skill commit-gate --skill pr-gate --skill code-review --skill survey --skill self-learn
```

Or manually:

```bash
git clone https://github.com/zhtmike/skills ~/gitlocal/skills
mkdir -p ~/.agents/skills
ln -sfn ~/gitlocal/skills/coding-style ~/.agents/skills/coding-style   # repeat per skill
```

`~/.agents/skills/` is the cross-agent standard directory (pi reads it natively; Claude Code and OpenCode use their own — symlink accordingly). Reload after any change (`/reload` on pi).

## Authoring

See [CONTRIBUTING.md](CONTRIBUTING.md) — trigger-first descriptions, sections by concern, self-containment (one exception: the standard wind-down handoff to `self-learn` closing every body but its own), harness-agnostic wording, rules that state behavior rather than spelling, atomic one-rule lines. Every skill change passes `scripts/check.sh` (wired via pre-commit; see CONTRIBUTING) and the fresh-review commit gate (`commit-gate`).
