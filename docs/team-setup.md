# Team Setup Guide

Step-by-step instructions for getting a new AI Automations team member up and running with the n8n toolkit.

---

## Prerequisites

Before starting, ensure the team member has:

- [ ] Claude Pro or Team subscription
- [ ] Claude Code installed (check with `claude --version` in terminal)
- [ ] VS Code or Windsurf with Claude Code extension (optional — terminal works too)
- [ ] Access to the Pattern n8n instance (URL + API key)
- [ ] Access to this GitHub repository
- [ ] Git configured on their machine

---

## Installation Steps

### 1. Clone or Add the Marketplace

**Option A: From GitHub (recommended — auto-updates)**

```bash
/plugin marketplace add pattern-ai/n8n-automations-toolkit
```

This registers the repo as a marketplace. Claude Code pulls the latest version from GitHub each time.

**Option B: Local clone (works offline, manual updates)**

```bash
# Clone the repo
git clone git@github.com:pattern-ai/n8n-automations-toolkit.git ~/claude-plugins/n8n-toolkit

# Register as a local marketplace in Claude Code
/plugin marketplace add ~/claude-plugins/n8n-toolkit
```

To update later: `cd ~/claude-plugins/n8n-toolkit && git pull`

### 2. Install the Three Plugins

```bash
/plugin install n8n@n8n-toolkit
/plugin install n8n-prd-generator@n8n-toolkit
/plugin install n8n-project-init@n8n-toolkit
```

These install to **user scope** by default, meaning they're available in every Claude Code session — terminal, VS Code, Windsurf, any project directory.

### 3. Set Up Shared Credentials

Create the shared team credentials file:

```bash
cat > ~/.n8n-team.env << 'EOF'
N8N_API_URL=https://pattern.app.n8n.cloud
N8N_API_KEY=ask-jon-for-the-team-api-key
N8N_CREDENTIALS_TEMPLATE_URL=https://pattern.app.n8n.cloud/workflow/TEMPLATE_ID
EOF
```

Get the actual values from Jon or from the team's password manager.

This file lives in the home directory and gets reused by every project. The init plugin reads it automatically so you don't have to re-enter credentials each time.

### 4. Set Up the n8n MCP Server (Optional but Recommended)

The plugins tell Claude Code *how* to build workflows. The MCP server gives Claude Code *direct API access* to the n8n instance via structured tool calls (rather than curl commands).

If not already configured, add it to your Claude Code settings:

```bash
# This depends on how the MCP server is packaged
# Check with Jon for the current recommended setup
```

The MCP server and plugins are complementary — you can use both.

### 5. Verify Everything Works

```bash
# Open Claude Code
claude

# Check plugins are installed
/plugin
# → Go to "Installed" tab, confirm all 3 plugins appear

# Quick test — tell Claude:
"Set up a new n8n project called test-verification"
# It should scaffold the directory with CLAUDE.md, .env, .gitignore
# and verify the API connection

# Clean up the test
rm -rf test-verification
```

---

## Daily Workflow

### Starting a New Automation

**1. After stakeholder meeting → Generate blueprint**

Open Claude Code and provide the meeting transcript or notes:

```
Here's the transcript from my call with [name] on the RevOps team. 
They need an automation that [brief description]. Generate a blueprint.
```

The PRD generator plugin activates and walks you through:
- Extracting known requirements
- Asking clarifying questions (interactive)
- Producing a one-page blueprint

Save the blueprint — you'll paste it into the project.

**2. Scaffold the project**

```
Set up a new n8n project called [kebab-case-name]
```

The init plugin:
- Creates the directory
- Copies template files
- Fills in credentials from `~/.n8n-team.env`
- Verifies the API connection
- Asks for project details (your name, stakeholder, description)

**3. Build the workflow**

Open the project directory in Claude Code (or `cd` into it) and describe what you want to build. Paste the blueprint if you have one.

The n8n plugin handles:
- Node-by-node construction
- Testing after every node addition
- Credential template lookups
- Validation before activation

**4. Document and commit**

Update CLAUDE.md with:
- Final architecture (actual nodes and connections)
- Decisions made during the build
- Webhook URL and payload structure
- Any manual setup steps required

Commit to the team's GitHub org.

---

## Updating the Toolkit

When Jon pushes updates to the plugins or templates:

**If installed from GitHub:**
```bash
/plugin marketplace update n8n-toolkit
```

**If installed from local clone:**
```bash
cd ~/claude-plugins/n8n-toolkit
git pull
# Changes take effect on next Claude Code session
```

---

## Troubleshooting

### Plugins not showing in `/plugin`

- Make sure you installed with `/plugin install`, not just added the marketplace
- Check that the marketplace was added successfully: `/plugin` → Discover tab
- Try removing and re-adding: `/plugin marketplace remove n8n-toolkit` then re-add

### API connection fails during project init

- Check `.env` values are correct (no trailing spaces or quotes)
- Verify the API key hasn't been rotated — check with Jon
- Try the curl manually:
  ```bash
  export $(cat .env | grep -v '^#' | xargs) && curl -s "${N8N_API_URL}/api/v1/workflows?limit=1" -H "X-N8N-API-KEY: ${N8N_API_KEY}"
  ```

### Credentials template returns empty

- The template workflow may have been deleted or moved in n8n
- Check `N8N_CREDENTIALS_TEMPLATE_URL` in `.env`
- Ask Jon for the current template workflow ID

### Old n8n skills conflicting

If you previously had n8n skills installed from another source:
```bash
# Find and remove old skills
find ~/.claude/ -name "*.md" -path "*n8n*"
# Remove any that aren't from this toolkit

# Check for old plugins
/plugin
# Uninstall any duplicate n8n plugins
```

---

## Team Conventions

- **Project naming:** kebab-case, descriptive (e.g., `hubspot-lead-scoring`, `slack-approval-workflow`)
- **Always start with a blueprint** from a stakeholder conversation — don't build ad hoc
- **Update CLAUDE.md as you build** — this is the knowledge trail for the team
- **Never commit .env files** — credentials go in `.env`, templates go in `.env.template`
- **Test before activating** — the n8n plugin enforces this, but double-check edge cases manually
- **Document webhook URLs and payloads** — the next person to maintain this needs to know the contract
