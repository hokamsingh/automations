# Telegram n8n Commander (n8n Workflow)

Remotely manage your n8n instance from Telegram via chat commands. Control workflows, view executions, run backups, and get error alerts — all from your phone.

## Commands

| Command | Description |
|---------|-------------|
| `help` | List all commands |
| `workflows` | List all workflows with active/inactive status |
| `execute <name>` | Execute a workflow by name |
| `activate <name>` | Activate a workflow |
| `deactivate <name>` | Deactivate a workflow |
| `executions <name>` | List last 50 executions for a workflow |
| `cleanup` | Permanently delete all archived workflows |
| `backup` | Export and send a `.tar.gz` of all workflows + credentials |

## Automatic alerts

- **Workflow failure** — sends error details when any workflow fails (configure this as the Error Workflow in other workflow settings)
- **Instance start** — notifies when n8n restarts

## Notes

- `execute` requires the target workflow to have a **"When Executed by Another Workflow"** trigger node
- `activate` requires a trigger node that supports activation (webhook, schedule, etc.)
- `backup` only works on self-hosted n8n (runs shell commands inside the container)
- Backup file contains **decrypted credentials** — treat it as sensitive

## Setup

### 1. Get your Telegram Chat ID

Message [@userinfobot](https://t.me/userinfobot) on Telegram — it will reply with your user ID.

### 2. Create n8n API key

1. Go to `http://localhost:5678/settings/api`
2. Click **Create an API Key**, name it, copy the key
3. In n8n credentials, create an **n8n API** credential:
   - API Key: the key you just copied
   - Base URL: `http://localhost:5678` (or your public URL)

### 3. Import the workflow

1. Go to `http://localhost:5678` → Workflows → Create Workflow
2. Top-right menu → **Import from file**
3. Upload `workflow.json`

### 4. Replace all placeholders

Search and replace in the imported workflow:

| Placeholder | Replace with |
|-------------|-------------|
| `YOUR_TELEGRAM_CHAT_ID` | Your Telegram user/chat ID |
| `YOUR_TELEGRAM_USER_ID` | Your Telegram user ID (same as chat ID for DMs) |
| `YOUR_TELEGRAM_CREDENTIAL_ID` | Your n8n Telegram credential |
| `YOUR_N8N_API_CREDENTIAL_ID` | Your n8n API credential |

### 5. Set as Error Workflow (optional)

To receive failure alerts from other workflows:
1. Open any other workflow → Settings
2. Set **Error Workflow** to `Telegram-n8n-Commander`

### 6. Activate

Click **Publish** in the workflow editor.

## Troubleshooting

- **No response from bot**: Check Telegram credential and that workflow is published
- **"Workflow name not found"**: Command matching is case-sensitive and exact — use the exact workflow name as shown by `workflows` command
- **Backup fails**: Ensure n8n has write access to `/home/node/` inside the container
- **execute fails**: Target workflow must have a "When Executed by Another Workflow" trigger node
