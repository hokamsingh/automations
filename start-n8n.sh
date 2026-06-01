#!/bin/bash
# Start n8n — run this if the container is ever removed
# Data persists in the 'n8n_data' Docker volume

VAULT_PATH="${1:-/home/developer/ObsidianVault}"

docker run -d --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -e TZ=Asia/Kolkata \
  -e N8N_RESTRICT_FILE_ACCESS_TO=/vault \
  -v n8n_data:/home/node/.n8n \
  -v "$VAULT_PATH:/vault" \
  n8nio/n8n

echo "n8n started at http://localhost:5678"
echo "Vault mounted from: $VAULT_PATH"
