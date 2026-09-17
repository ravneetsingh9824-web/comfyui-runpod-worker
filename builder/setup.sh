#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting ComfyUI custom node and model setup..."

# ==============================================================================
# 1. INSTALL CUSTOM NODES
# ==============================================================================
echo "Cloning custom nodes..."
cd /workspace/ComfyUI/custom_nodes

# Clone the specific Qwen Edit Utils repository for your TextEncode nodes
git clone https://github.com/lrzjason/Comfyui-QwenEditUtils

# ==============================================================================
# 2. INSTALL NODE DEPENDENCIES
# ==============================================================================
echo "Installing custom node requirements..."

# Install dependencies if the repository includes a requirements.txt
if [ -f /workspace/ComfyUI/custom_nodes/Comfyui-QwenEditUtils/requirements.txt ]; then
    pip install -r /workspace/ComfyUI/custom_nodes/Comfyui-QwenEditUtils/requirements.txt
fi

# ==============================================================================
# 3. DOWNLOAD MODELS & CHECKPOINTS
# ==============================================================================
echo "Downloading models..."
mkdir -p /workspace/ComfyUI/models/checkpoints
cd /workspace/ComfyUI/models/checkpoints

echo "Downloading Qwen-Rapid-AIO-NSFW-v23 checkpoint (28.4 GB)..."
# Download directly from HuggingFace to the checkpoints folder
wget -O Qwen-Rapid-AIO-NSFW-v23.safetensors "https://huggingface.co/Phr00t/Qwen-Image-Edit-Rapid-AIO/resolve/main/v23/Qwen-Rapid-AIO-NSFW-v23.safetensors"

echo "Setup complete! All nodes and models are downloaded."
