# TARS — AI Personal Assistant (n8n Workflow)

Telegram-based personal AI assistant. Handles voice and text messages. Manages Gmail, Google Calendar, and Google Tasks.

## What it does

- Receives text or voice messages via Telegram
- Transcribes voice messages using OpenAI Whisper
- Routes messages to TARS agent (LLM via OpenRouter)
- Maintains per-user conversation memory (window buffer)
- Tools available to the agent:
  - **Gmail** — read unread emails, send emails
  - **Google Calendar** — fetch events by date range
  - **Google Tasks** — create and list tasks

## Example commands

- "What emails do I have today?"
- "Show my calendar for tomorrow"
- "Create a task: review pull requests"
- Send a voice note for hands-free interaction

## Setup

### Prerequisites

- n8n running locally (`./start-n8n.sh`)
- Telegram bot (create via [@BotFather](https://t.me/BotFather))
- OpenRouter API key ([openrouter.ai/settings/keys](https://openrouter.ai/settings/keys))
- OpenAI API key ([platform.openai.com/api-keys](https://platform.openai.com/api-keys)) — for voice transcription only
- Google account with Calendar, Gmail, and Tasks access

### 1. Import the workflow

1. Go to `http://localhost:5678` → Workflows → Create Workflow
2. Top-right menu → **Import from file**
3. Upload `workflow.json`

### 2. Wire up credentials

| Node | Credential type | Where to get |
|------|----------------|--------------|
| Telegram Trigger + Telegram | Telegram API | [@BotFather](https://t.me/BotFather) → `/newbot` |
| OpenRouter | OpenRouter API | [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys) |
| Transcribe a recording | OpenAI API | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| Get Email + Send Email | Gmail OAuth2 | Google Cloud Console → OAuth2 |
| Google Calendar | Google Calendar OAuth2 | Google Cloud Console → OAuth2 |
| Create/Get tasks | Google Tasks OAuth2 | Google Cloud Console → OAuth2 |

### 3. Set your calendar

In the **Google Calendar** node, set the calendar to your Google account email.

### 4. Activate

Click **Publish** in the workflow editor.

## Customization

Edit the **System Message** in the `TARS 🤖` agent node to change behavior, tone, or add new instructions.

## Troubleshooting

- **Voice messages not transcribing**: Check OpenAI credential and account credits
- **No Telegram response**: Verify bot token and that workflow is published
- **Calendar returns nothing**: Confirm Google Calendar OAuth2 scope includes read access
- **Tasks not creating**: Confirm Google Tasks list ID in the task nodes matches your actual list
