#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo Starting ComfyUI custom node and model setup...

# ==============================================================================
# 1. INSTALL CUSTOM NODES
# ==============================================================================
echo Cloning custom nodes...
cd workspaceComfyUIcustom_nodes

# Clone the specific Qwen Edit Utils repository for your TextEncode nodes
git clone httpsgithub.comlrzjasonComfyui-QwenEditUtils

# ==============================================================================
# 2. INSTALL NODE DEPENDENCIES
# ==============================================================================
echo Installing custom node requirements...

# Install dependencies if the repository includes a requirements.txt
if [ -f workspaceComfyUIcustom_nodesComfyui-QwenEditUtilsrequirements.txt ]; then
    pip install -r workspaceComfyUIcustom_nodesComfyui-QwenEditUtilsrequirements.txt
fi

# ==============================================================================
# 3. DOWNLOAD MODELS & CHECKPOINTS
# ==============================================================================
echo Downloading models...
mkdir -p workspaceComfyUImodelscheckpoints
cd workspaceComfyUImodelscheckpoints

echo Downloading Qwen-Rapid-AIO-NSFW-v23 checkpoint (28.4 GB)...
# Download directly from HuggingFace to the checkpoints folder
wget -O Qwen-Rapid-AIO-NSFW-v23.safetensors httpshuggingface.coPhr00tQwen-Image-Edit-Rapid-AIOresolvemainv23Qwen-Rapid-AIO-NSFW-v23.safetensors

echo Setup complete! All nodes and models are downloaded.
