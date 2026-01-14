#!/usr/bin/env bash
set -euo pipefail

# conda env
if ! conda env list | grep -qE '^openvla\s'; then
  conda create -n openvla python=3.10 -y
fi

# shellcheck disable=SC1091
source /opt/conda/etc/profile.d/conda.sh
conda activate openvla

python -V
pip -V

# ---------- PyTorch on DGX Spark ----------
# DGX Spark (GB10) は sm_121 / CUDA 13.0 が前提になりやすいので、
# まずは cu130 系の torch を入れるのが無難です。
#
# 1) まず PyTorch公式の cu130 index を試す（使える環境ならこれが一番楽）
set +e
pip install --upgrade pip wheel setuptools
pip install --index-url https://download.pytorch.org/whl/cu130 torch torchvision torchaudio
STATUS=$?
set -e

if [ $STATUS -ne 0 ]; then
  echo "[WARN] official cu130 wheels install failed. Fallback to known-working DGX Spark wheels repo."
  echo "       See: https://github.com/assix/pytorch-aarch64-cuda130-python310-wheels"
  # fallback: wheelを直接取得して入れる（ネットワークが必要）
  TMPDIR="$(mktemp -d)"
  git clone --depth 1 https://github.com/assix/pytorch-aarch64-cuda130-python310-wheels "$TMPDIR/wheels"
  pip install "$TMPDIR"/wheels/*.whl
  rm -rf "$TMPDIR"
fi

python - <<'PY'
import torch
print("torch:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
print("cuda version:", torch.version.cuda)
print("gpu:", torch.cuda.get_device_name(0) if torch.cuda.is_available() else None)
PY

# ---------- install openvla repo ----------
pip install -e .

# NOTE:
# flash-attn は DGX Spark / sm_121 で動かない・ビルドが重い事例が多いので
# まずは無しで動作確認→必要なら後で対応がおすすめ。
# See PyTorch forum / issues around GB10 + flash_attn.
echo "[INFO] postCreate done."
