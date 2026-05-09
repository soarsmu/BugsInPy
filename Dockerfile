FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl build-essential dos2unix vim \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    wget llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:/home/bugsinpy/framework/bin:$PATH"

RUN curl -fsSL https://pyenv.run | bash && \
    mkdir -p "$PYENV_ROOT/versions" "$PYENV_ROOT/cache" && \
    pyenv rehash

ENV BUGSINPY_HOME=/home/bugsinpy

WORKDIR /home

CMD ["bash"]
