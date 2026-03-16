# Pattern AI Automations Toolkit

Plugin marketplace and project templates for the AI Automations team. This repo is the single source of truth for n8n build skills, project scaffolding, and team standards.

## What's Inside

### Plugins

| Plugin | Purpose | Slash Command |
|--------|---------|---------------|
| **n8n** | Build, test, and deploy n8n workflows via REST API with incremental testing | Auto-activates on n8n context |
| **n8n-prd-generator** | Convert stakeholder call transcripts into one-page automation blueprints | Auto-activates when transcripts are provided |
| **n8n-project-init** | Scaffold a new automation project with all config files | `/n8n-toolkit:n8n-project-init` |

### Project Template

The `project-template/` directory contains starter files that get copied into every new project by the init plugin:

- `CLAUDE.md` — Project context for Claude Code
- `.env.template` — n8n credentials (fill in values, rename to `.env`)
- `.gitignore` — Protects secrets from being committed

---

## Team Setup (One-Time)

Every team member runs these steps once to get the toolkit installed.

### Prerequisites

- Claude Code installed (via terminal or VS Code/Windsurf extension)
- Access to the Pattern n8n instance
- Access to this GitHub repository

### Step 1: Add the Marketplace

```bash
# In Claude Code (terminal or VS Code), run:
/plugin marketplace add jonmcgee37/n8n-automations-toolkit
```

If using a local clone instead of GitHub:

```bash
git clone git@github.com:jonmcgee37/n8n-automations-toolkit.git ~/claude-plugins/n8n-toolkit
/plugin marketplace add ~/claude-plugins/n8n-toolkit
```

### Step 2: Install the Plugins

```bash
/plugin install n8n@n8n-toolkit
/plugin install n8n-prd-generator@n8n-toolkit
/plugin install n8n-project-init@n8n-toolkit
```

### Step 3: Set Up n8n Credentials

Create a file at `~/.n8n.env` with the shared instance credentials:

```
N8N_API_URL=https://pattern.app.n8n.cloud
N8N_API_KEY=your-team-api-key
N8N_CREDENTIALS_TEMPLATE_URL=https://pattern.app.n8n.cloud/workflow/TEMPLATE_ID
```

### Step 4: Verify

```bash
# Check plugins are installed
/plugin
# → Go to "Installed" tab, confirm all 3 appear

# Start a new project to test
# Just tell Claude: "set up a new n8n project called test-workflow"
```

---

## Starting a New Project

### 1. Plan: Generate a Blueprint

After your stakeholder meeting, feed the transcript to Claude Code:

```
Here's the transcript from my call with [stakeholder]. Generate an automation blueprint.
```

The **n8n-prd-generator** plugin activates automatically. It will extract requirements, ask clarifying questions, and produce a one-page blueprint.

### 2. Scaffold: Initialize the Project

```
Set up a new n8n project called [project-name]
```

The **n8n-project-init** plugin will:
- Create the project directory
- Copy template files (CLAUDE.md, .env, .gitignore)
- Fill in your n8n credentials from the shared config
- Verify the API connection
- Set up the CLAUDE.md with your project-specific context

### 3. Build: Create the Workflow

Describe what you want to build (or paste the blueprint). The **n8n** plugin handles:
- Incremental node-by-node construction via REST API
- Automated testing after each node
- Credential template lookups
- Validation before activation

### 4. Ship: Commit and Document

When the workflow is working:
- Update CLAUDE.md with final architecture notes
- Commit to the team's GitHub org
- Document the webhook URL and payload structure

---

## Updating the Toolkit

When plugins are updated in this repo:

```bash
# If installed from GitHub:
/plugin marketplace update n8n-toolkit

# If installed from local clone:
cd ~/claude-plugins/n8n-toolkit
git pull
# Plugins update automatically on next Claude Code session
```

---

## Repository Structure

```
n8n-automations-toolkit/
├── .claude-plugin/
│   └── marketplace.json          ← Plugin registry
├── .gitignore                    ← Repo-level ignore rules
├── plugins/
│   ├── n8n/                      ← Core build & test skill
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/n8n/
│   │       ├── SKILL.md
│   │       └── references/       ← Node configs, expressions, pitfalls, etc.
│   ├── n8n-prd-generator/        ← Blueprint generator skill
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/n8n-prd-generator/
│   │       └── SKILL.md
│   └── n8n-project-init/         ← Project scaffolding skill
│       ├── .claude-plugin/plugin.json
│       └── skills/n8n-project-init/
│           └── SKILL.md
├── project-template/             ← Starter files for new projects
│   ├── CLAUDE.md.template
│   ├── .env.template
│   └── .gitignore
├── docs/
│   └── setup.md
├── CHANGELOG.md
└── README.md
```

---

## Contributing

To update a plugin or add a new one:

1. Clone this repo
2. Make your changes
3. Test locally: `claude --plugin-dir ./`
4. Push to main — team members pick up changes on next marketplace update

---

## Team

Maintained by the Pattern AI Automations team. Questions → reach out to Jon.
