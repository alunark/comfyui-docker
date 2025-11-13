FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu24.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl python3 python3-venv libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Using Pythron Virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update && apt-get install -y python3-pip

# Create working directory
WORKDIR /app

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130

# Clone ComfyUI and install its requirements
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# Change working directory
WORKDIR /app/ComfyUI

# Install ComfyUI dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Clean up pip cache to reduce image size
RUN pip cache purge

# Copy file configuration
COPY extra_model_paths.yaml .

# Return to root app directory
WORKDIR /app

# Add entrypoint and inference script
COPY entrypoint.sh .

# Make entrypoint executable and fix permissions for OVHcloud user
RUN chmod +x entrypoint.sh
RUN chown -R 42420:42420 /app
ENV HOME=/app

# Start ComfyUI via the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]