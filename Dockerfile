# Use an appropriate micromamba base image
FROM mambaorg/micromamba:latest

# Run as root for installation
USER root

# Install necessary system dependencies and clean up in one layer to reduce image size
RUN apt-get update && \
    apt-get install --quiet --yes --no-install-recommends libgl1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a new user to avoid running as root and set the working directory
RUN useradd --create-home micromamba
USER micromamba
WORKDIR /home/micromamba

# Copy necessary files into the container
COPY environment.yml setup.py vsflow README.md ./
COPY vslib ./vslib

# Initialize micromamba, create environment, and clean up in one command
RUN micromamba shell init -s bash -p ~/micromamba && \
    echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    eval "$(micromamba shell hook --shell bash)" && \
    micromamba create -y -n vsflow --file environment.yml --platform linux-64 && \
    micromamba clean --all --yes && \
    micromamba activate vsflow && \
    pip install . && \
    micromamba deactivate

# Switch back to root to remove installation files
USER root
RUN rm -rf ./vslib environment.yml setup.py vsflow README.md

# Switch back to micromamba user and update .bashrc to activate the environment on login
USER micromamba
RUN echo "micromamba activate vsflow" >> ~/.bashrc
