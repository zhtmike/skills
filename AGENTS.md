# Working in this repo

Personal agent skills — one `<name>/SKILL.md` per skill. Before adding or editing a skill, read CONTRIBUTING.md (house style + invariants); `scripts/check.sh` must pass before a change is proposed. A checker false alarm is fixed in the checker — its patterns and exemptions — never routed around; invariant changes go through CONTRIBUTING, not the checker.

- One concern, one trigger (CONTRIBUTING Principle 1); prefer editing the owning skill — the README table is the trigger roster.
- h800-* carry H800-cluster facts — verify against the cluster, not general CUDA docs.
- Nothing else lives here but `scripts/` — this repo's own check tooling (menu: `scripts/README.md`) — and `.pre-commit-config.yaml`, its commit-gate wiring, and `.github/workflows/gate.yml`, the push-side backstop that re-runs both. No harness config — install wiring (symlinks, dispatch mechanics) belongs to each harness's setup, not this repo.
- Installs are symlinks: renaming or deleting a skill directory breaks installed machines — call it out in the commit message.
- A change that adds, removes, renames, or splits a skill updates every harness guide's symlink step and skill checklist in the same change — the guides live in harness-setup.
- Post-task skill updates route through the global `self-learn` skill — its doors, real-defect bar, and one-file scope live in CONTRIBUTING's Post-task updates; a wind-down alone never opens it.
- Commits go through the fresh-review gate (the global `commit-gate` skill). The owner pre-approves commits and pushes to this repo's own remote for their own sessions — present the diff and message for the record, run the fresh review, and proceed without waiting for a per-commit go; every other remote keeps the per-commit approval.
