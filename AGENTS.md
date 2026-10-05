# Working in this repo

Personal agent skills — one `<name>/SKILL.md` per skill. Before adding or editing a skill, read CONTRIBUTING.md (house style + invariants); its greps must pass before a change is proposed.

- One concern, one trigger: a new skill must not overlap an existing skill's trigger (README table); prefer editing the owning skill.
- h800-* carry H800-cluster facts (driver 535 / CUDA 12.2) — verify against the cluster, not general CUDA docs.
- Nothing else lives here: no scripts, no harness config — install wiring (symlinks, dispatch mechanics) belongs to each harness's setup, not this repo.
- Installs are symlinks: renaming or deleting a skill directory breaks installed machines — call it out in the commit message.
- Commits go through the fresh-review gate (the global commit-gate skill); draft the full message first.
