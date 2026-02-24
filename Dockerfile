# Fetch ubuntu image
FROM ubuntu:22.04

# Comment this line to disable interactive prompts during package installation
# ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN \
    apt update && \
    apt install -y git python3 && \
    apt install -y cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy ./setup.sh at /app
WORKDIR /app
COPY setup.sh /app

# Run the setup script to install the tools
RUN ./setup.sh

# Command that will be invoked when the container starts
CMD ["bash"]