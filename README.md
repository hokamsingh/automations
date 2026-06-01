# automations

Personal n8n workflow library. All workflows import directly into any n8n instance.

## Infrastructure

Start n8n (data persists in `n8n_data` Docker volume):

```bash
./start-n8n.sh [/path/to/ObsidianVault]
```

n8n runs at `http://localhost:5678`.

## Workflows

| Folder | Description | Trigger |
|--------|-------------|---------|
| [fathom-obsidian](workflows/fathom-obsidian/) | Fathom meeting transcripts → Obsidian vault markdown notes | Every 30 min |

## Adding a new workflow

1. Export from n8n: workflow → ⋮ → Download
2. Drop JSON into `workflows/<name>/workflow.json`
3. Add a `workflows/<name>/README.md` with setup notes
4. Commit and push
