ARG BASE_IMAGE=nvidia/cuda:13.0.0-cudnn-devel-ubuntu24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

# 基本ツール（ビルド系）
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl ca-certificates wget \
  build-essential pkg-config \
  ninja-build \
  sudo \
  libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
  && rm -rf /var/lib/apt/lists/*

# vscode ユーザ
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

# Miniconda (aarch64)
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -o /tmp/miniconda.sh \
  && bash /tmp/miniconda.sh -b -p ${CONDA_DIR} \
  && rm -f /tmp/miniconda.sh \
  && ${CONDA_DIR}/bin/conda clean -afy

ENV PATH=${CONDA_DIR}/bin:$PATH
RUN conda init bash

USER ${USERNAME}
WORKDIR /workspaces/openvla
