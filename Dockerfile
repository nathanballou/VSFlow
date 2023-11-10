# Use an appropriate micromamba base image
FROM mambaorg/micromamba:latest

USER root

RUN apt-get update && apt-get install --quiet --yes --no-install-recommends libgl1 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a new user to avoid running as root
RUN useradd --create-home micromamba
USER micromamba
WORKDIR /home/micromamba

# Copy necessary files into the container
COPY environment.yml setup.py vsflow README.md ./
COPY vslib ./vslib


# Initialize micromamba for bash shell and install the environment
RUN micromamba shell init -s bash -p ~/micromamba && \
    echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    eval "$(micromamba shell hook --shell bash)" && \
    micromamba create -y -n vsflow --file environment.yml --platform linux-64 && \
    micromamba clean --all --yes

# Activate the environment and install the package
RUN echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    eval "$(micromamba shell hook --shell bash)" && \
    micromamba activate vsflow && \
    pip install .
    
USER root
RUN rm -rf ./vslib environment.yml setup.py vsflow README.md
USER micromamba
# Update the .bashrc to activate the environment on login
RUN echo "micromamba activate vsflow" >> ~/.bashrc
