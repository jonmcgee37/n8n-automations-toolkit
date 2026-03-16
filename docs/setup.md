# n8n Automations Toolkit — Setup Guide

Follow these steps exactly. The whole process takes about 10 minutes.

---

## What You Need Before Starting

- [ ] A Mac with Terminal access
- [ ] Claude Code installed (if not, ask Jon)
- [ ] Access to this GitHub repository (ask Jon to add you as a collaborator)
- [ ] The n8n credentials (Jon will send these to you via the password manager)

You will receive three values from Jon:

| Value | What It Is | Example |
|-------|-----------|---------|
| **N8N_API_URL** | The URL of our n8n instance | `https://pattern.app.n8n.cloud` |
| **N8N_API_KEY** | The API key to authenticate | (a long string of characters) |
| **N8N_CREDENTIALS_TEMPLATE_URL** | A workflow in n8n with pre-configured service credentials | `https://pattern.app.n8n.cloud/workflow/abc123` |

---

## Step 1: Create the Credentials File

Open **Terminal** on your Mac and run this command:

```bash
cat > ~/.n8n.env << 'EOF'
N8N_API_URL=PASTE_THE_URL_HERE
N8N_API_KEY=PASTE_THE_API_KEY_HERE
N8N_CREDENTIALS_TEMPLATE_URL=PASTE_THE_TEMPLATE_URL_HERE
EOF
```

**Replace the three placeholder values** with the actual values Jon sent you. Make sure there are no extra spaces before or after the values.

To verify it saved correctly:

```bash
cat ~/.n8n.env
```

You should see your three values printed out. If it looks right, move on.

**Important:** This file stays on YOUR computer only. It is never uploaded to GitHub. It contains your API key, so treat it like a password.

---

## Step 2: Open Claude Code

In your Terminal, type:

```bash
claude
```

This opens Claude Code. You will see a different-looking prompt -- you are now inside Claude Code, not your regular terminal.

**All commands from here on out are typed inside Claude Code, not in your regular terminal.**

---

## Step 3: Add the Plugin Marketplace

Type this command in Claude Code:

```
/plugin marketplace add jonmcgee37/n8n-automations-toolkit
```

This tells Claude Code where to find our team's plugins. It will connect to the private GitHub repository and download the plugin catalog.

If it asks for GitHub authentication, use:
- **Username:** your GitHub username
- **Password:** your GitHub Personal Access Token (not your GitHub password -- see Appendix A if you need to create one)

---

## Step 4: Install the Three Plugins

Run these three commands one at a time:

```
/plugin install n8n@n8n-toolkit
```

A screen will appear asking where to install. **Select "Install for you (user scope)"** and press Enter.

```
/plugin install n8n-prd-generator@n8n-toolkit
```

Select "Install for you (user scope)" again.

```
/plugin install n8n-project-init@n8n-toolkit
```

Select "Install for you (user scope)" one more time.

---

## Step 5: Verify the Install

Type:

```
/plugin
```

Use the arrow keys to go to the **Installed** tab. You should see all three plugins listed:

- `n8n` -- builds and tests workflows
- `n8n-prd-generator` -- creates blueprints from stakeholder conversations
- `n8n-project-init` -- scaffolds new project directories

If all three appear, you are done with installation.

---

## Step 6: Test It

Type this in Claude Code:

```
Set up a new n8n project called test-verification
```

Claude should:
1. Find your credentials from `~/.n8n.env`
2. Ask you for project details (name, description, stakeholder)
3. Create a folder with CLAUDE.md, .env, and .gitignore
4. Verify the API connection to the n8n instance

If it successfully connects to n8n, everything is working. Clean up the test:

```bash
rm -rf test-verification
```

**You are done. You are ready to build automations.**

---

## How to Start a New Project

### 1. Create your automations folder (one-time)

In your regular terminal:

```bash
mkdir -p ~/n8n-automations
```

### 2. Open it and launch Claude Code

```bash
cd ~/n8n-automations
claude
```

Or open `~/n8n-automations` in VS Code / Windsurf and use the Claude Code panel.

### 3. Generate a blueprint (after a stakeholder meeting)

Paste your meeting notes or transcript into Claude Code:

```
Here is the transcript from my call with [stakeholder name] on the [team] team.
They need an automation that [brief description].
Generate an automation blueprint.
```

Claude will extract requirements, ask you clarifying questions, and produce a one-page blueprint.

### 4. Scaffold the project

```
Set up a new n8n project called [project-name]
```

Use kebab-case for the name (e.g., `lead-enrichment-workflow`, `slack-approval-bot`).

### 5. Build the workflow

Open the project subfolder in a new VS Code window (or `cd` into it in terminal and run `claude`), then describe what you want to build or paste the blueprint.

Claude will build the workflow node by node, testing after each step.

---

## How to Update the Plugins

When Jon announces an update, open Claude Code and run:

```
/plugin marketplace update n8n-toolkit
```

Then uninstall and reinstall any plugins that changed:

```
/plugin uninstall n8n-project-init@n8n-toolkit
/plugin install n8n-project-init@n8n-toolkit
```

Select "user scope" again. This ensures the updated version replaces the cached copy.

---

## Troubleshooting

### "No such file or directory: /plugin"

You are running the command in your regular terminal, not inside Claude Code. Type `claude` first to enter Claude Code, then run the `/plugin` command.

### Claude Code asks for n8n credentials even though you set them up

Check that your credentials file exists and has values:

```bash
cat ~/.n8n.env
```

If it is empty or missing, go back to Step 1.

### API connection fails

Ask Jon to verify:
- The API key has not been rotated
- The n8n instance URL is correct
- Your IP is not blocked

### GitHub authentication fails when adding the marketplace

You need a GitHub Personal Access Token, not your password. See Appendix A.

### Plugins do not show in the Installed tab

Make sure you ran `/plugin install`, not just `/plugin marketplace add`. The marketplace add only registers the catalog. You still need to install each plugin individually.

---

## Conventions

- **Project naming:** kebab-case, descriptive (e.g., `hubspot-lead-scoring`, `slack-approval-workflow`)
- **Always start with a blueprint** from a stakeholder conversation before building
- **Update CLAUDE.md as you build** -- document decisions, issues, and architecture changes
- **Never commit .env files** -- the .gitignore handles this, but double check
- **Test before activating** -- the n8n plugin enforces this, but verify edge cases manually
- **Document webhook URLs and payloads** -- the next person to maintain this needs the contract

---

## Appendix A: Creating a GitHub Personal Access Token

If GitHub rejects your password when adding the marketplace:

1. Go to **github.com** and log in
2. Click your **profile picture** (top right) then **Settings**
3. Scroll down the left sidebar and click **Developer settings**
4. Click **Personal access tokens** then **Tokens (classic)**
5. Click **Generate new token** then **Generate new token (classic)**
6. Name it something like `claude-plugins`
7. Set expiration to 90 days
8. Check the **repo** checkbox (this gives access to private repos)
9. Click **Generate token**
10. **Copy the token immediately** -- GitHub only shows it once

Use this token as your "password" when Claude Code or git asks for authentication.

To save it so you do not have to enter it every time:

```bash
git config --global credential.helper osxkeychain
```

