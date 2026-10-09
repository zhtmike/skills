---
name: h800-run-jobs
description: "MUST load before launching any long-running GPU job (training, rollout, smoke tests) on the H800 cluster (driver 535 / CUDA 12.2) — or diagnosing a launch that left no job running. Covers the ssh-detach launch pattern (local background jobs get reaped), the cuda-compat exports every launcher needs, GPU selection on the shared box, and job script hygiene. Not for other machines or clusters."
---

# H800 Running Jobs

**Load this before launching training runs, smoke tests, or any long-lived GPU process — and when a launch leaves no job running.**

## Scope — the launch mechanism, not tmux

The interactive session happens to live inside tmux → Slurm — that is incidental. Do NOT launch jobs via tmux (no `tmux new-window`/`send-keys`); the ssh-detach pattern below is the launch mechanism, full stop. tmux only explains why the session survives network drops.

## The ssh-detach pattern (the cluster's #1 operational rule)

Agent/tool shells reap locally-detached children — `setsid`, `nohup`, and `&` from the tool shell all die with it. Long-running jobs MUST be launched via ssh so sshd owns them:

```bash
timeout 20 ssh -o BatchMode=yes localhost \
  'cd <workdir> && nohup bash runner.sh > runner.log 2>&1 < /dev/null & echo launched'
```

Do not mix the launch with sleeps/polls in the same tool call — launch-only commands survive; compound ones get reaped with the shell. One detached job per ssh call: a second `nohup ... &` inside the same remote command does not reliably survive ssh exit.

## Every launcher needs the compat exports

Scripts that run CUDA 13 stacks on the 535 driver must set these inside the script (inherited environments are not reliable across ssh/ray workers):

```bash
source <conda>/etc/profile.d/conda.sh
conda activate <env>
export LD_LIBRARY_PATH=${CONDA_PREFIX}/cuda-compat:${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH:-}
export LIBRARY_PATH=${CONDA_PREFIX}/cuda-compat:${CONDA_PREFIX}/lib:${LIBRARY_PATH:-}
export CUDA_HOME=${CONDA_PREFIX}        # if flashinfer JIT is in play
export PYTHONUNBUFFERED=1 RAY_DEDUP_LOGS=0
```

## GPU selection on the shared box

- Check `nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader` first. If GPUs are held by processes outside this user's Slurm job, **report it to the user immediately** (foreign/leaked jobs should be raised with their owner, not routed around); otherwise take what's verified free.
- Pin free devices explicitly: `CUDA_VISIBLE_DEVICES=2,3` + match `NUM_GPUS=2`.
- Check the script's GPU-count assumptions before adapting them — many-GPU defaults can produce nonsense configs on fewer GPUs.

## Job script hygiene

- `set -u` scripts: `set +u` around `conda activate` (cuda hooks crash on unbound vars; pre-exporting them does not save it).
- Detached runners do not source `.bashrc`: credential env vars (e.g. `WANDB_API_KEY`) are absent and tools fall back to `~/.netrc` — keep it current or export the key in the runner.
- Stop shared cluster services (e.g. ray) between sequential jobs; skip only for parallel groups on disjoint devices, via the test suite's own opt-out if it has one.
- Capture exit codes per job and print a final `=== done (job=$RC) ===` line — polling greps for it.

## Precedence

Cluster physics override repo docs; repo-specific job semantics belong to the repo's own guides.

## Wind-down handoff

At the task's wind-down, one question: did a skill's guidance misfire — wrong, misleading, or silent where it hurt?

- **No — end here.** A wind-down alone never loads `self-learn`.
- **Yes — load `self-learn` and hand it the misfire.** Its bar and ownership boundary take it from there: this repo's skills may get a proposed edit; external ones (repo-bundled, harness-default, third-party) come back as a report — never an edit, and never by your own hand.
