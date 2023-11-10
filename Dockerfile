# Use an appropriate micromamba base image
FROM mambaorg/micromamba:latest

# Run as root for installation
USER root

# Install necessary system dependencies and clean up in one layer to reduce image size
RUN apt-get update && \
    apt-get install --quiet --yes --no-install-recommends libgl1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy necessary files into the container
COPY environment.yml setup.py vsflow README.md ./
COPY vslib ./vslib

ENV PATH /opt/conda/envs/vsflow/bin:$PATH

# Initialize micromamba, create environment, and clean up in one command
RUN micromamba shell init -s bash -p ~/micromamba && \
    echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    eval "$(micromamba shell hook --shell bash)" && \
    micromamba env create -y --file environment.yml --platform linux-64 && \
    micromamba clean --all --yes && \
    pip install .

# Activate the environment on login
RUN echo "micromamba activate vsflow" >> ~/.bashrc

# Remove unnecessary files
RUN rm -rf ./vslib environment.yml setup.py vsflow README.md
