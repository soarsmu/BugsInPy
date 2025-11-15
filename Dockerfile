FROM python:3.9-slim-trixie

# The installer requires curl (and certificates) to download the release archive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates git nano dos2unix bzip2 build-essential

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure uv installer is linked
ENV PATH="/root/.local/bin/:$PATH"

# micromamba for Legacy compilers --------------

ADD https://micro.mamba.pm/api/micromamba/linux-64/latest /micromamba.tar.bz2
RUN mkdir -p /opt/micromamba \
 && tar -xjf /micromamba.tar.bz2 -C /opt/micromamba bin/micromamba \
 && rm /micromamba.tar.bz2
ENV MAMBA_ROOT_PREFIX=/opt/micromamba
ENV PATH="/opt/micromamba/bin:${PATH}"

# Create separate envs with pinned Python + pip
RUN /opt/micromamba/bin/micromamba create -y -n py36 -c conda-forge python=3.6 pip && \
    /opt/micromamba/bin/micromamba create -y -n py37 -c conda-forge python=3.7 pip && \
    /opt/micromamba/bin/micromamba create -y -n py38 -c conda-forge python=3.8 pip && \
    /opt/micromamba/bin/micromamba clean -a -y

# Expose python3.X and pip3.X shims
RUN ln -sf /opt/micromamba/envs/py36/bin/python /usr/local/bin/python3.6 && \
    ln -sf /opt/micromamba/envs/py37/bin/python /usr/local/bin/python3.7 && \
    ln -sf /opt/micromamba/envs/py38/bin/python /usr/local/bin/python3.8 && \
    ln -sf /opt/micromamba/envs/py36/bin/pip    /usr/local/bin/pip3.6    && \
    ln -sf /opt/micromamba/envs/py37/bin/pip    /usr/local/bin/pip3.7    && \
    ln -sf /opt/micromamba/envs/py38/bin/pip    /usr/local/bin/pip3.8
# ---

# Ensure the installed binary is on the `PATH`
ENV BUGSINPY_HOME="/home/bugsinpy/"
ENV PATH="$BUGSINPY_HOME/framework/bin:$PATH"

# Set working directory
WORKDIR /home

# Default command
CMD ["/bin/bash"]