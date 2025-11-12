#!/bin/bash

set -e

# Required env vars
BUCKET_MOUNT_PATH=${BUCKET_MOUNT_PATH:-/workspace/flux-model}
FLUX_VARIANT=${FLUX_VARIANT:-base}  # options are base | kontext

UNET_FILE=${UNET_FILE:-flux1-schnell.safetensors}
DIFFUSION_MODEL_FILE=${DIFFUSION_MODEL_FILE:-flux1-kontext-dev.safetensors}
VAE_FILE=${VAE_FILE:-ae.safetensors}
CLIP_FILE_1=${CLIP_FILE_1:-clip_l.safetensors}
CLIP_FILE_2=${CLIP_FILE_2:-t5xxl_fp16.safetensors}

# symlinks
if [[ "$FLUX_VARIANT" == "kontext" ]]; then
    echo "→ Deploying Flux Kontext variant"
    ln -sf "${BUCKET_MOUNT_PATH}/${DIFFUSION_MODEL_FILE}" "/app/ComfyUI/models/diffusion_models/${DIFFUSION_MODEL_FILE}"
else
    echo "→ Deploying base (Schnell or DEV) FLUX variant"
    ln -sf "${BUCKET_MOUNT_PATH}/${UNET_FILE}" "/app/ComfyUI/models/unet/${UNET_FILE}"
fi

ln -sf "${BUCKET_MOUNT_PATH}/${VAE_FILE}" "/app/ComfyUI/models/vae/${VAE_FILE}"
ln -sf "${BUCKET_MOUNT_PATH}/comfyanonymous/clip/${CLIP_FILE_1}" "/app/ComfyUI/models/clip/${CLIP_FILE_1}"
ln -sf "${BUCKET_MOUNT_PATH}/comfyanonymous/clip/${CLIP_FILE_2}" "/app/ComfyUI/models/clip/${CLIP_FILE_2}"

# Start ComfyUI
exec python3 /app/ComfyUI/main.py --listen 0.0.0.0 --port 8188