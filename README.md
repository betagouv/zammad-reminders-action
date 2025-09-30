# Zammad Reminders Action

A GitHub Action that sends reminders to Mattermost about pending Zammad tickets.

<img width="778" height="425" alt="image" src="https://github.com/user-attachments/assets/25aeeb4e-da09-4bc4-a4bc-f7811d5d8e52" />


## Features

- 📊 Counts new unassigned tickets in Zammad
- 📈 Counts open tickets by agent
- 💬 Sends formatted summary to Mattermost channel
- 🔄 Runs on schedule or manual trigger

## Usage

Create a workflow file (e.g., `.github/workflows/zammad-reminders.yml`) in your repository:

```yaml
name: Zammad Daily Reminders
on:
  schedule:
    - cron: "0 8 * * 1-5"  # 8 AM, Monday to Friday
  workflow_dispatch:       # Allow manual trigger

jobs:
  zammad-reminders:
    runs-on: ubuntu-latest
    steps:
      - name: Send Zammad reminders
        uses: betagouv/zammad-reminders-action@main
        with:
          zammad-api-url: ${{ secrets.ZAMMAD_API_URL }}
          zammad-api-token: ${{ secrets.ZAMMAD_API_TOKEN }}
          mattermost-webhook-url: ${{ secrets.MATTERMOST_WEBHOOK_URL }}
          mattermost-channel: "your-channel-name"
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `zammad-api-url` | The URL of your Zammad API (e.g., `https://your-zammad.com`) | ✅ |
| `zammad-api-token` | API token for Zammad authentication | ✅ |
| `mattermost-webhook-url` | Mattermost incoming webhook URL | ✅ |
| `mattermost-channel` | Mattermost channel name to send messages to | ✅ |

## Required Secrets

You'll need to set these secrets in your repository settings:

1. **`ZAMMAD_API_URL`**: Your Zammad instance URL
2. **`ZAMMAD_API_TOKEN`**: A Zammad API token with permission to read tickets
3. **`MATTERMOST_WEBHOOK_URL`**: Mattermost incoming webhook URL

### Creating a Zammad API Token

1. Log into your Zammad instance as an admin
2. Go to Admin → Channels → API
3. Create a new token with read permissions for tickets

### Creating a Mattermost Webhook

1. In Mattermost, go to your team settings
2. Navigate to Integrations → Incoming Webhooks
3. Create a new webhook and copy the URL

## Example Output

The action sends a message like this to your Mattermost channel:

```
Rappel Zammad quotidien

5 nouveaux tickets non-assignés

et 12 tickets assignés et ouverts (en attente de réponse) :

- agent1@example.com: 3 ticket(s) ouvert(s)
- agent2@example.com: 7 ticket(s) ouvert(s)
- agent3@example.com: 2 ticket(s) ouvert(s)
```

## Development

This action is built with Ruby and uses Docker. The main components are:

- `run.rb` - Main script that orchestrates the workflow
- `zammad_api_client.rb` - Handles Zammad API interactions
- `mattermost_api_client.rb` - Handles Mattermost webhook posting
- `Dockerfile` - Containerizes the Ruby application
- `action.yml` - Defines the GitHub Action interface

## License

MIT License. See [LICENSE](LICENSE) for details.
