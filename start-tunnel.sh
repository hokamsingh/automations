#!/bin/bash
# Starts a cloudflared quick tunnel pointing at n8n.
# After getting the URL, re-registers the Fathom webhook so it always points
# at the live tunnel (quick-tunnel URL changes on every restart).
#
# Usage: ./start-tunnel.sh
# Requires: cloudflared, curl, FATHOM_API_KEY env var or hardcoded below.

FATHOM_API_KEY="${FATHOM_API_KEY:-j1ggppfgpY_-eLCB12u3fw.erDNkYF7Lr29Yn2YzexBxvlsEq1mQZYrcXR6wo_FDMQ}"
LOG="/tmp/cloudflared.log"

# Kill any existing tunnel
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 1

# Start tunnel in background, capture output
cloudflared tunnel --url http://localhost:5678 > "$LOG" 2>&1 &
TUNNEL_PID=$!
echo "cloudflared PID: $TUNNEL_PID"

# Wait for URL to appear (up to 30s)
TUNNEL_URL=""
for i in $(seq 1 30); do
  TUNNEL_URL=$(grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" | head -1)
  [ -n "$TUNNEL_URL" ] && break
  sleep 1
done

if [ -z "$TUNNEL_URL" ]; then
  echo "ERROR: tunnel URL not found after 30s. Check $LOG"
  exit 1
fi

echo "Tunnel URL: $TUNNEL_URL"

# Delete all existing Fathom webhooks then re-register
EXISTING=$(curl -s https://api.fathom.ai/external/v1/webhooks \
  -H "X-Api-Key: $FATHOM_API_KEY" 2>/dev/null || echo "")

# Extract IDs with python (no jq dependency)
IDS=$(python3 -c "
import json, sys
try:
  data = json.loads('''$EXISTING''')
  items = data if isinstance(data, list) else data.get('items', [])
  for item in items:
    print(item['id'])
except:
  pass
" 2>/dev/null)

for id in $IDS; do
  curl -s -X DELETE "https://api.fathom.ai/external/v1/webhooks/$id" \
    -H "X-Api-Key: $FATHOM_API_KEY" > /dev/null
  echo "Deleted old webhook: $id"
done

# Register new webhook
RESULT=$(curl -s -X POST https://api.fathom.ai/external/v1/webhooks \
  -H "X-Api-Key: $FATHOM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"destination_url\": \"${TUNNEL_URL}/webhook/fathom\",
    \"include_transcript\": true,
    \"include_summary\": true,
    \"include_action_items\": true,
    \"triggered_for\": [\"my_recordings\"]
  }")

WEBHOOK_ID=$(python3 -c "import json,sys; d=json.loads('$RESULT'); print(d.get('id','ERROR'))" 2>/dev/null)
echo "Fathom webhook registered: $WEBHOOK_ID"
echo "Webhook URL: ${TUNNEL_URL}/webhook/fathom"
echo ""
echo "All set. Tunnel running (PID $TUNNEL_PID). Logs: $LOG"
