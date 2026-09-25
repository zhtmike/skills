---
name: h800-run-jobs
description: "MUST load before launching any long-running GPU job (training, rollout, smoke tests) on the H800 cluster (driver 535 / CUDA 12.2). Covers the ssh-detach launch pattern (local background jobs get reaped), the cuda-compat exports every launcher needs, GPU selection on the shared box, and job script hygiene. For general tasks — the constraints are the cluster's, not any repo's."
---

# H800 Running Jobs

**Load this before launching training runs, smoke tests, or any long-lived GPU process.**

Context: the interactive session happens to live inside tmux → Slurm — that is incidental. Do NOT launch jobs via tmux (no `tmux new-window`/`send-keys`); the ssh-detach pattern below is the launch mechanism, full stop. tmux only explains why the session survives network drops.

## The ssh-detach pattern (the cluster's #1 operational rule)

Agent/tool shells reap locally-detached children — `setsid`, `nohup`, and `&` from the tool shell all die with it. Long-running jobs MUST be launched via ssh so sshd owns them:

```bash
timeout 20 ssh -o BatchMode=yes localhost \
  'cd <workdir> && nohup bash runner.sh > runner.log 2>&1 < /dev/null & echo launched'
```

Do not mix the launch with sleeps/polls in the same tool call — launch-only commands survive; compound ones get reaped with the shell.

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
- Some test harnesses compute GPU-role counts arithmetically from `NUM_GPUS` (e.g. `num_gpus - fixed_overhead`) — running a many-GPU-default test on fewer GPUs can produce nonsense configs (negative counts, empty data files). Check the script's assumptions before adapting GPU counts.

## Job script hygiene

- `set -u` scripts must export `NVCC_PREPEND_FLAGS="${NVCC_PREPEND_FLAGS:-}"` before `conda activate` (hook crashes otherwise).
- Stop shared cluster services (e.g. ray) between sequential jobs; skip only for parallel groups on disjoint devices, via the harness's own opt-out if it has one.
- Capture exit codes per job and print a final `=== done (job=$RC) ===` line — the monitor greps for it.

## Precedence

Cluster physics override repo docs; repo-specific job semantics belong to the repo's own guides.
