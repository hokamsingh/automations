# automations

Personal n8n workflow library.

## Workflows

| Workflow | Description | Trigger |
|----------|-------------|---------|
| [fathom-obsidian](workflows/fathom-obsidian/README.md) | Fathom transcripts → Obsidian notes | Every 30 min (polling) |
| [fathom-webhook](workflows/fathom-webhook/README.md) | Fathom transcripts → Obsidian notes | Instant (webhook) |

## Adding a workflow

1. Export from n8n: workflow → ⋮ → Download
2. `workflows/<name>/workflow.json`
3. `workflows/<name>/README.md` with setup notes
4. Commit and push
