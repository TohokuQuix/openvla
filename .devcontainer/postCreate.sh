#!/usr/bin/env bash
set -euo pipefail

source /opt/conda/etc/profile.d/conda.sh
ENV_NAME="openvla"

echo "[postCreate] create conda env: ${ENV_NAME}"
if ! conda env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  conda create -n "${ENV_NAME}" python=3.10 -y
fi

echo "[postCreate] install pytorch (cuda 12.4)"
conda run -n "${ENV_NAME}" conda install -y \
  pytorch torchvision torchaudio pytorch-cuda=12.4 \
  -c pytorch -c nvidia

echo "[postCreate] install openvla editable"
conda run -n "${ENV_NAME}" pip install -U pip
conda run -n "${ENV_NAME}" pip install -e .

echo "[postCreate] install flash-attn deps + flash-attn"
conda run -n "${ENV_NAME}" pip install packaging ninja
conda run -n "${ENV_NAME}" ninja --version
conda run -n "${ENV_NAME}" pip install "flash-attn==2.5.5" --no-build-isolation || \
  echo "[WARN] flash-attn install failed. You can still run without flash-attn."

echo "[postCreate] auto-activate conda env in bashrc"
BASHRC="$HOME/.bashrc"
if ! grep -q "conda activate ${ENV_NAME}" "${BASHRC}"; then
  cat >> "${BASHRC}" <<EOF
# >>> openvla devcontainer auto-activate >>>
source /opt/conda/etc/profile.d/conda.sh
conda activate ${ENV_NAME}
# <<< openvla devcontainer auto-activate <<<
EOF
fi

echo "[postCreate] done"
