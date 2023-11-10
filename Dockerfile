# Use an appropriate micromamba base image
FROM mambaorg/micromamba:latest

# Set the working directory
WORKDIR /home/micromamba

# Copy necessary files into the container
COPY environment.yml setup.py vsflow README.md ./
COPY vslib ./vslib

# Create the conda environment using micromamba
RUN micromamba create --yes --file environment.yml --platform linux-64 && \
    micromamba clean --all --yes

# Activate the environment and install the package
RUN micromamba shell init -s bash -p ~/micromamba && \
    echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    bash -c "source ~/.bashrc && \
    micromamba activate vsflow && \
    pip install ."

# Clean up the installation files
RUN rm -rf ./vslib environment.yml setup.py vsflow README.md

# Update the .bashrc to activate the environment on login
RUN sed -ie 's/base/vsflow/' ~/.bashrc
