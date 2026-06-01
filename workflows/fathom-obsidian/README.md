# Fathom → Obsidian Import (n8n Workflow)

Automated n8n workflow that polls Fathom for new meeting transcripts every 30 minutes and saves structured markdown notes to an Obsidian vault.

## What it does

- Polls `https://api.fathom.ai/external/v1/meetings` every 30 minutes
- Deduplicates by `recording_id` — never imports the same meeting twice
- Fetches AI summary and full transcript per meeting
- Generates compact markdown note and saves to `/vault/Meetings/`
- Files named `YYYY-MM-DD-meeting-title.md`
- Detects Fathom API auth failures with a clear error (visible in n8n execution history)

## Note format

```
# Meeting Title
Date: YYYY-MM-DD
Fathom: https://fathom.video/share/...

## Summary
<AI summary, Fathom links stripped>

## Action Items
- [ ] ...

## Raw Transcript
<first 1200 chars of transcript>
```

## Setup

### Prerequisites

- Docker
- n8n running locally (see below)
- Fathom API key (`app.fathom.video` → Settings → API)

### 1. Start n8n

```bash
docker run -d --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -e TZ=Asia/Kolkata \
  -e N8N_RESTRICT_FILE_ACCESS_TO=/vault \
  -v n8n_data:/home/node/.n8n \
  -v /path/to/ObsidianVault:/vault \
  n8nio/n8n
```

Replace `/path/to/ObsidianVault` with your actual vault path. n8n will be at `http://localhost:5678`.

### 2. Create Fathom credential in n8n

1. Go to `http://localhost:5678` → Credentials → New
2. Search **"Header Auth"**
3. Name: `Fathom API Key`
4. Header Name: `X-Api-Key`
5. Header Value: your Fathom API key
6. Save

### 3. Import the workflow

1. Go to Workflows → Import
2. Upload `workflow.json` from this repo
3. Open the workflow, re-link the Fathom credential on all HTTP Request nodes
4. Click **Publish**

### 4. Vault permissions

Ensure n8n can write to `/vault/Meetings`:

```bash
docker exec --user root n8n chown -R node:node /vault
```

### 5. Auto-cleanup (optional)

Add to crontab to delete notes older than 7 days:

```
0 2 * * * find /path/to/ObsidianVault/Meetings -name '*.md' -mtime +7 -delete
```

## API keys

| Key | Where stored | Expires |
|-----|-------------|---------|
| Fathom API key | n8n Credentials | Never (permanent) |
| n8n API key | n8n Settings → API | Set per key (workflow does not use this) |

The workflow only uses the Fathom API key stored in n8n Credentials. It will never expire unless you revoke it in Fathom settings.

## Troubleshooting

- **"not writable" error**: Run `docker exec --user root n8n chown -R node:node /vault`
- **DNS / API error**: Check n8n execution log — the Deduplicate node will throw a descriptive error if Fathom returns 401/403
- **Container stopped**: Run `~/start-n8n.sh` or the docker run command above (data persists in `n8n_data` volume)
