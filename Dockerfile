# 1. Base Image: We use RunPod's official PyTorch image with CUDA support
FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04

# 2. Set the working directory inside the container
WORKDIR /workspace

# 3. Install necessary system dependencies (ffmpeg and libgl1 are needed for image/video processing)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. Clone the main ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI

# 5. Install ComfyUI's core Python requirements
# 5. Upgrade PyTorch to 2.4+ before installing ComfyUI
RUN pip install --upgrade torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
RUN pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt

# 6. Copy your builder folder (containing setup.sh) into the container
COPY builder /workspace/builder

# 7. Make setup.sh executable and run it to download the Qwen Rapid nodes and models
RUN sed -i 's/\r$//' /workspace/builder/setup.sh && chmod +x /workspace/builder/setup.sh && /workspace/builder/setup.sh

# 8. Install Python packages needed for the RunPod API handler
RUN pip install --no-cache-dir runpod requests websocket-client

# 9. Copy your handler script and the exported ComfyUI workflow
COPY handler.py /workspace/handler.py
COPY workflow_api.json /workspace/workflow_api.json

# 10. Tell RunPod what to run when the container starts
CMD ["python", "/workspace/handler.py"]
