# Fathom Webhook → Obsidian (instant import)

Receives Fathom webhooks and immediately writes a structured markdown note to the Obsidian vault. No polling — notes appear within seconds of a meeting ending.

## What it does

- Fathom POSTs full meeting payload (transcript + AI summary + action items) to n8n
- Deduplicates by `recording_id` — never imports the same meeting twice
- Writes `YYYY-MM-DD-meeting-title.md` to `/vault/Meetings/`
- Responds `200 ok` to Fathom immediately

## Note format

```
# Meeting Title
Date: YYYY-MM-DD
Fathom: https://fathom.video/share/...

## Summary
<AI summary, Fathom timestamp links stripped>

## Action Items
- [ ] ...

## Raw Transcript
<first 1200 chars>
```

## Setup

### Prerequisites

- Docker + n8n running (see `../../start-n8n.sh`)
- cloudflared installed (`cloudflared --version`)
- Fathom API key

### 1. Start n8n

```bash
../../start-n8n.sh /path/to/ObsidianVault
```

### 2. Import workflow

1. n8n → Workflows → Import → upload `workflow.json`
2. Click **Publish**

No credentials to configure — the webhook node needs no auth.

### 3. Start tunnel + register Fathom webhook

```bash
../../start-tunnel.sh
```

This starts cloudflared, captures the public URL, deletes any stale Fathom webhooks, and registers a fresh one. Run this every time the tunnel restarts.

### 4. Auto-start on boot (optional)

```bash
sudo cp ../../cloudflared-tunnel.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloudflared-tunnel
```

## How deduplication works

`$getWorkflowStaticData('global')` stores imported `recording_id` values across executions. If Fathom retries a webhook (it does on non-2xx response), the second delivery is silently skipped.

## Tunnel URL changes on restart

Quick tunnels (trycloudflare.com) get a new random URL every time. `start-tunnel.sh` handles this: it re-registers the Fathom webhook automatically after starting the tunnel.

## API keys

| Key | Where | Expires |
|-----|-------|---------|
| Fathom API key | `start-tunnel.sh` env or hardcoded | Never |
| Fathom webhook secret | `whsec_Mks0aU8xHtdJqnRJ7nMdQWrvAt+0K9Hh` (for signature verification, not used currently) | Per webhook registration |
