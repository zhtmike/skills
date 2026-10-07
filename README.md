# zhtmike/skills

Personal agent skills — harness-agnostic (pi, OpenCode, Claude Code), self-contained, one concern per skill. Installed as symlinks so this repo stays the single source of truth.

## Skills

| Skill | Load when | Scope |
|---|---|---|
| `coding-style` | before touching any code — any edit, any language, any framework, any repo | edit conventions: minimal diffs, fail-fast, comment hygiene, tests with the change |
| `commit-gate` | before any git action (commit / amend / push / PR) | approval-gated actions on the fork, commit-message conventions, fresh-review commit gate |
| `code-review` | before reviewing a PR or a review branch | deep, comprehensive review; may span multiple dispatched agents; drafted to a `review_*.md` file, never posted |
| `survey` | before any intensive, broad investigation | typed decomposition, budgets, claim-based findings, optional evidence audit, synthesis schema |
| `h800-env-setup` | before creating or repairing a Python/GPU env on the H800 cluster | conda + cuda-compat, uv vs pip, flashinfer JIT toolkit |
| `h800-run-jobs` | before launching any long-running GPU job | ssh-detach launch pattern, compat exports, GPU selection |
| `h800-monitor-jobs` | while any long-running GPU job is in flight | polling cadence, failure signatures, cleanup checklist |

The `h800-*` skills apply only on H800 cluster nodes (driver 535 / CUDA 12.2) — install them there, not on every machine.

## Install

skills CLI (installs as symlinks; `skills update` propagates):

```bash
npx skills add zhtmike/skills --global -a <agent> --skill coding-style --skill commit-gate --skill code-review --skill survey
```

Or manually:

```bash
git clone https://github.com/zhtmike/skills ~/gitlocal/skills
mkdir -p ~/.agents/skills
ln -sfn ~/gitlocal/skills/coding-style ~/.agents/skills/coding-style   # repeat per skill
```

`~/.agents/skills/` is the cross-agent standard directory (pi reads it natively; Claude Code and OpenCode use their own — symlink accordingly). Reload after any change (`/reload` on pi).

## Authoring

See [CONTRIBUTING.md](CONTRIBUTING.md) — trigger-first descriptions, sections by concern, self-containment, harness-agnostic wording. Every skill change goes through the fresh-review commit gate (`commit-gate`).
