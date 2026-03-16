---
name: n8n-project-init
description: |
  Initialize a new n8n automation project for the Pattern AI Automations team.
  Scaffolds the project directory with CLAUDE.md, .env, and .gitignore — using
  Pattern instance credentials and an existing blueprint from the PRD generator.

  USE THIS SKILL WHEN:
  - User says "/n8n-init", "/init-n8n", or "/new-project"
  - User says "start a new n8n project", "set up a new automation", "initialize project"
  - User wants to scaffold a new n8n build directory with team standards
  - User asks to create the CLAUDE.md or .env for an n8n project
  - User has finished the PRD generator and is ready to scaffold before building
---

# n8n Project Initializer

Scaffold a new n8n automation project for the Pattern AI Automations team. This is **Step 2 of 3** in the build pipeline:

```
[Step 1] PRD Generator  →  [Step 2] Project Init  →  [Step 3] n8n Builder
```

---

## Step 1: Verify Pattern Credentials

Run this command to check for the team credentials file:

```bash
cat ~/.n8n.env 2>/dev/null
```

**If the file exists and contains values:**
- Confirm with the user: "Using Pattern n8n instance at `https://pattern.app.n8n.cloud` — correct?"
- Load `N8N_API_URL`, `N8N_API_KEY`, and `N8N_CREDENTIALS_TEMPLATE_URL` from the file
- Proceed to Step 2

**If the file is missing or empty:**
- Stop immediately and tell the user:

> "Your Pattern credentials file (`~/.n8n.env`) is missing or empty. Before initializing a project, you need to set this up.
>
> Ask Jon for the three credential values (N8N_API_URL, N8N_API_KEY, N8N_CREDENTIALS_TEMPLATE_URL), then run:
>
> ```bash
> cat > ~/.n8n.env << 'EOF'
> N8N_API_URL=https://pattern.app.n8n.cloud
> N8N_API_KEY=PASTE_YOUR_KEY_HERE
> N8N_CREDENTIALS_TEMPLATE_URL=PASTE_TEMPLATE_URL_HERE
> EOF
> ```
>
> Once that's done, come back and run the project initializer again."

Do not proceed until credentials are confirmed.

---

## Step 2: Check for Blueprint

Before collecting project details, check whether a blueprint was already generated.

Run:

```bash
ls *.md 2>/dev/null
```

**If a `.md` file is found in the current directory:**
- Ask: "I see a markdown file here — is this your PRD blueprint? If so, I'll pull it into the project automatically."
- If yes, read it and use it in Step 4c

**If no `.md` file is found:**
- Ask using AskUserQuestion:

```
Question: "Do you have a blueprint from the PRD generator?"
Header: "Blueprint"
Options:
  - "Yes — I'll paste it now"
  - "No — skip for now, I'll add it later"
  - "No — take me back to the PRD generator first"
```

- If they choose "take me back to PRD generator": stop and say "Run the PRD generator first (`Generate an automation blueprint`) and come back when your blueprint is ready."
- If they paste a blueprint: use it in Step 4c
- If they skip: proceed without it, leave the Blueprint Reference section blank in CLAUDE.md

---

## Step 3: Collect Project Details

Use AskUserQuestion tool to gather:

**First call (2 questions):**
- "What is the project name?" — kebab-case (e.g., `lead-enrichment-workflow`, `slack-approval-bot`)
  Header: "Project Name"
  Options: free text — remind them to use kebab-case
- "One sentence: what does this automation do?"
  Header: "Description"
  Options: free text

**Second call (2 questions):**
- "Who is building this?" (team member name)
  Header: "Builder"
  Options: free text
- "Who requested this, and what team are they on?" (e.g., "Sarah Chen, RevOps")
  Header: "Stakeholder"
  Options: free text

---

## Step 4: Create Project Files

### 4a: Create directory

```bash
mkdir -p <project-name>
```

### 4b: .gitignore

```bash
cat > <project-name>/.gitignore << 'EOF'
.env
.env.*
!.env.template
.DS_Store
Thumbs.db
.vscode/settings.json
.idea/
node_modules/
*.log
tmp/
temp/
EOF
```

### 4c: .env

Write the Pattern credentials into the project `.env`:

```
# ============================================
# Pattern AI Automations — n8n Configuration
# ============================================
# NEVER commit this file to git
# ============================================

N8N_API_URL=https://pattern.app.n8n.cloud
N8N_API_KEY=<value from ~/.n8n.env>
N8N_CREDENTIALS_TEMPLATE_URL=<value from ~/.n8n.env>

# ============================================
# Project-Specific Variables (add as needed)
# ============================================
# WEBHOOK_PATH=
# SLACK_CHANNEL=
# GOOGLE_SHEET_ID=
```

### 4d: CLAUDE.md

Create CLAUDE.md with all placeholders replaced:

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name from Step 3 |
| `{{PROJECT_DESCRIPTION}}` | Description from Step 3 |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |
| `{{TEAM_MEMBER_NAME}}` | Builder name from Step 3 |
| `{{STAKEHOLDER_NAME}}` | Stakeholder name from Step 3 |
| `{{STAKEHOLDER_TEAM}}` | Stakeholder team from Step 3 |
| `{{N8N_CREDENTIALS_TEMPLATE_URL}}` | From `~/.n8n.env` |

**If a blueprint was provided in Step 2:** paste it verbatim into the "Blueprint Reference" section.
**If not:** leave the section with the placeholder note.

---

## Step 5: Verify API Connection

```bash
export $(cat <project-name>/.env | grep -v '^#' | xargs) && \
curl -s "${N8N_API_URL}/api/v1/workflows?limit=1" \
  -H "X-N8N-API-KEY: ${N8N_API_KEY}" | jq '.data | length'
```

- Returns a number → connection confirmed
- Fails → help troubleshoot: confirm URL is `https://pattern.app.n8n.cloud`, verify API key matches `~/.n8n.env`, check network

---

## Step 6: Report and Hand Off to Builder

```
Project initialized: <project-name>/

Files created:
  ✓ CLAUDE.md       — project context (update as you build)
  ✓ .env            — Pattern credentials (never commit)
  ✓ .gitignore      — protects .env from git

n8n instance: Pattern (https://pattern.app.n8n.cloud)
API connection: verified
Blueprint: <included / not included>
```

Then output the next step callout:

```
─────────────────────────────────────────────
NEXT STEP: Build the workflow

Your project is scaffolded and ready. To start building, say:

  "Build the workflow for <project-name>"

The n8n builder will implement the workflow node by node using the
blueprint in CLAUDE.md, testing after each step before moving on.
─────────────────────────────────────────────
```

---

## Important Notes

- **Pattern instance only** — this plugin is configured for `pattern.app.n8n.cloud`. Do not modify for other instances.
- **Never put API keys in CLAUDE.md** — credentials live in `.env` only
- **Always run the PRD generator first** — a blueprint makes the build phase significantly faster and more accurate
- **Verify the API connection every time** — catch auth issues before building starts
- **CLAUDE.md is a living doc** — encourage the builder to update it with decisions, issues, and test notes as they build
