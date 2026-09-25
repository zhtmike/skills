---
name: h800-monitor-jobs
description: "MUST load before monitoring or debugging long-running GPU jobs on the H800 cluster (driver 535 / CUDA 12.2). Covers progress polling without flooding, root-cause extraction from job/ray/vllm logs, the known failure signatures (flashinfer JIT, EADDRINUSE, OOM races), and the cleanup checklist. For general tasks — the constraints are the cluster's, not any repo's."
---

# H800 Monitoring Jobs

**Load this while any job launched per h800-run-jobs is in flight.**

Context: the session lives inside tmux → Slurm; both are incidental to job mechanics — jobs are ssh-detached with their own logs (per h800-run-jobs). Two recovery uses: `tmux capture-pane -p` retrieves the tool shell's own scrollback (a foreground command whose output redirect was lost), and Slurm persistence means a "disappeared" job is usually still running (`squeue`, `pgrep -f` before assuming death).

## Delegate the monitoring

Long monitoring loops burn orchestrator context — dispatch a fixer sub-agent to poll and report instead of checking yourself:

- Give it: the runner log path, the done-marker line, the poll cadence (adaptive 30s→10m, below), the known-failure table below, and a one-retry-max rule.
- It returns a final report (PASS/FAIL tally, durations, root causes) — you read the verdict, not the stream.
- Reuse the same fixer session for follow-up rounds; it retains the log layouts.

## Polling cadence (for the sub-agent, or quick manual checks)

**Adaptive interval — poll tight early, back off when stable:**

- Start at 15–30s during engine startup (the ramp phase where JIT builds, port binds, and import errors surface). A failure caught in the first minute saves the whole run.
- Each check where the log grows and no error appears: increase the interval (30s → 1m → 2m → 5m → 10m), capped at 10 minutes. Any error, stall (log frozen but process alive), or GPU-memory anomaly: drop back to 30s to track the failure as it develops.
- The sub-agent should state its current interval when reporting, so the orchestrator can see the stability trend.
- Watch: the runner log's size/freshness (`stat -c %Y`), `nvidia-smi` memory+util, and process liveness (`pgrep -f`). A frozen log + idle GPU + live process = investigate; a growing log = healthy.
- GPUs climbing 0 → 3 MiB → 1.3 GB → 20+ GB is the normal engine-startup ramp; 0% util during it is expected (minutes, not hours).

## Root-cause extraction

Grep the per-test logs (not the interleaved console) for the actual error:

```bash
grep -aE "Traceback|raise |Error|assert|Exception|FAILED" <test.log> | grep -avE "UserWarning|warnings.warn" | tail -10
```

Known signatures on this cluster:

| Signature | Meaning | Action |
|---|---|---|
| `Could not find nvcc` / `cuda_home doesn't exist` | flashinfer JIT without toolkit | Install per h800-env-setup, set CUDA_HOME |
| `_Float128/_Float32x ... invalid combination of type specifiers` | nvcc EDG vs system glibc on cold JIT build | Pre-warm the build from an activated shell once |
| `DistNetworkError ... EADDRINUSE` | torch.distributed ephemeral port collision (parallel smoke groups) | Rerun; a flake, not a code bug |
| `out of memory at cumem_allocator.cpp` | sleep/wake engine race at tight memory budgets | Check utilization settings; CI-proportional slack differs on 79 GiB cards |
| `the NVIDIA driver on your system is too old` | compat exports missing from that shell | Add the LD_LIBRARY_PATH cuda-compat prefix |

## Precedence

Cluster physics override repo docs; repo-specific test semantics belong to the repo's own guides.

## Cleanup checklist after every run

1. `pgrep -f ray::` → 0 (or `ray stop --force`).
2. Free the GPUs you used back to 0 MiB (`nvidia-smi`).
3. Confirm the runner's final `=== done` line exists (run-jobs prints `=== done (job=$RC) ===`) — its absence means the script died mid-way.
