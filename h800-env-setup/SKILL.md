---
name: h800-env-setup
description: "MUST load before creating or repairing any Python/GPU environment on the H800 cluster (driver 535 / CUDA 12.2, no /usr/local/cuda). Covers conda + cuda-compat forward compatibility, the CUDA toolkit for flashinfer JIT, uv vs pip resolution, and mirror-accelerated installs. For general tasks — the constraints are the cluster's, not any repo's."
---

# H800 Environment Setup

**Load this before creating or repairing any Python environment on this cluster.**

## Reuse first — env and package mutations need approval

The user typically has an existing, activated conda env for the task at hand. **Default to it.** Creating a new env (`conda create`), installing packages (`conda install`, `uv pip install`, `pip install`), or modifying existing ones (upgrade, remove, symlink into `$CONDA_PREFIX`) are all approval-gated actions — ask the user first unless they explicitly requested that change. Silent env mutation can break working setups that took hours to build.

## Cluster facts (verify with `nvidia-smi`, assume stale otherwise)

- The interactive session is typically a Slurm allocation (`srun --partition=<p> --gres=gpu:N --cpus-per-gpu=24 --mem-per-cpu=8G --pty bash`; check `squeue -u $(whoami)` for the job), usually reached through tmux — incidental context only; it explains session persistence across network drops, nothing else. `ssh localhost` works from inside it — that's what the run pattern relies on.
- NVIDIA H800 nodes (datacenter, compute cap 9.0), driver 535.161.08 → natively CUDA 12.2 only. GPU count per allocation varies (check `nvidia-smi` / `squeue`).
- No usable `/usr/local/cuda` (only a stubs-only `cuda-12.2` — headers/nvml, no nvcc, no `bin/`). Any CUDA 13 stack needs forward compatibility.
- PyPI via direct connection is slow/flaky — always route through the tuna mirror.
- GPUs are usually free, but foreign processes (another user's server) sometimes hold some. **If you see GPUs held by processes outside this user's Slurm job, tell the user immediately** — it may be a leaked or misbehaving job the user can raise with its owner; don't silently route around it.

## The CUDA 13 stack on the 535 driver (cuda-compat)

CUDA 13 builds (torch cu130, vllm cu130) fail on the 535 driver without the forward-compat package:

```bash
conda create -n <env> python=3.12 -c conda-forge   # tuna: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
conda install -c conda-forge cuda-compat            # approval-gated (see Reuse first); lands in $CONDA_PREFIX/cuda-compat (libcuda 610.x)
```

Every shell/launcher that touches CUDA must export (put in job scripts, not just interactive shells):

```bash
export LD_LIBRARY_PATH=${CONDA_PREFIX}/cuda-compat:${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH:-}
export LIBRARY_PATH=${CONDA_PREFIX}/cuda-compat:${CONDA_PREFIX}/lib:${LIBRARY_PATH:-}
```

Without these, `import torch` fails with "the NVIDIA driver on your system is too old".

## uv vs pip — the resolver split

Modern multi-pin repos (verl-omni et al.) carry git pins whose metadata conflicts (e.g. verl's `transformers<5.11` vs the repo's `>=5.13`). uv resolves these via `[tool.uv] override-dependencies` from the repo's pyproject; **plain pip cannot** — `pip install -e .` dies with `ResolutionImpossible`. Always use uv inside such repos:

```bash
export UV_DEFAULT_INDEX=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
uv pip install --python "$CONDA_PREFIX/bin/python" -e ".[extras]"
```

Pre-fetch big wheels (torch cu130 ~500MB) into a local wheelhouse and add `UV_FIND_LINKS=<dir>` when the network stalls — uv honors it.

## Toolkit for flashinfer JIT (reward/rollout servers)

vLLM's flashinfer sampling JIT-compiles on first non-greedy request — needs a complete toolkit:

```bash
conda install -c conda-forge cuda-nvcc=13.4.92 cuda-cudart-dev=13.4.92 libcurand-dev cuda-cccl   # approval-gated (see Reuse first); exact pins — unpinned solves pick nvcc 12.9
cd $CONDA_PREFIX/include && for f in ../targets/x86_64-linux/include/*; do [ -e "$(basename $f)" ] || ln -s "$f" .; done
ln -sfn targets/x86_64-linux/lib $CONDA_PREFIX/lib64   # NOT lib64/ — that target doesn't exist in conda-forge
export CUDA_HOME=$CONDA_PREFIX
```

Piecemeal toolkits fail on missing header families (`cuda_runtime.h`, then `curand.h`); nvcc alone is not enough. A cold `trtllm_mnnvl_comm` build may fail on system-glibc `_FloatN` guards — run the build once from an activated shell (conda's sysroot config rescues it); the cache then serves all later runs.

## Precedence

Cluster physics override repo docs; repo-specific install quirks belong to the repo's own guides.

## Guard against `set -u` in conda scripts

conda's cuda-nvcc activate hooks crash under `set -u` (`NVCC_PREPEND_FLAGS: unbound variable`). Export `NVCC_PREPEND_FLAGS="${NVCC_PREPEND_FLAGS:-}"` before `conda activate` in any strict-mode script.
