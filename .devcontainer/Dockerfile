FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

# 基本ツール + flash-attn ビルドに必要なもの
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl ca-certificates wget \
  build-essential pkg-config \
  ninja-build \
  sudo \
  # OpenCV系が必要になった時の定番（headlessでもハマりにくくする）
  libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
  && rm -rf /var/lib/apt/lists/*

# vscode ユーザ作成
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

# Miniconda
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh -o /tmp/miniconda.sh \
  && bash /tmp/miniconda.sh -b -p ${CONDA_DIR} \
  && rm -f /tmp/miniconda.sh \
  && ${CONDA_DIR}/bin/conda clean -afy

ENV PATH=${CONDA_DIR}/bin:$PATH

# conda の初期化（bash起動時に conda が使えるように）
RUN conda init bash

USER ${USERNAME}
WORKDIR /workspaces/openvla
