---
name: n8n-project-init
description: |
  Initialize a new n8n automation project for the Pattern AI Automations team.

  USE THIS SKILL WHEN:
  - User says "/n8n-init", "/init-n8n", or "/new-project"
  - User says "start a new n8n project", "set up a new automation", "new project"
  - User wants to scaffold a new n8n build directory with team standards
  - User asks to create the CLAUDE.md or .env for an n8n project
---

# n8n Project Initializer

Scaffold a new automation project for the Pattern AI Automations team with standardized configuration, shared credentials, and project context.

## Trigger

Use this skill when:
- User says `/n8n-init`, `/init-n8n`, or `/new-project`
- User says "start a new n8n project", "set up a new automation"
- User wants to create a new project directory for an n8n workflow build

---

## Step 1: Locate the Plugin Root

The project template files live in this plugin's repository. Find them:

```bash
# The template files are at the plugin root under project-template/
# Use CLAUDE_PLUGIN_ROOT if available, otherwise search for them
TOOLKIT_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find ~/claude-plugins -name 'CLAUDE.md.template' -path '*/project-template/*' 2>/dev/null | head -1 | xargs dirname)}"

# If not found locally, check if they exist in the marketplace path
# The key files we need:
# - project-template/CLAUDE.md.template
# - project-template/.env.template
# - project-template/.gitignore
```

If the template files cannot be found, generate them inline using the formats documented in Step 4 below.

---

## Step 2: Gather Project Info

Ask the user for the following (collect everything in one prompt using the AskUserQuestion tool where possible):

**Required:**
1. **Project name** — Used for the directory name. Should be kebab-case (e.g., `lead-enrichment-workflow`, `slack-alert-automation`)
2. **Brief description** — One sentence: what does this automation do?
3. **Your name** — Who is building this? (team member name)
4. **Stakeholder** — Who requested this? (name and team, e.g., "Sarah Chen, RevOps")

**Credentials (check for existing config first):**

Before asking for credentials, check these locations in order:

```bash
# 1. Shared team credentials file
cat ~/.n8n-team.env 2>/dev/null

# 2. Existing .env in a sibling project directory
find .. -maxdepth 2 -name '.env' -path '*n8n*' 2>/dev/null | head -1 | xargs cat 2>/dev/null

# 3. Environment variables already set
echo $N8N_API_URL
```

If credentials are found, confirm with the user: "I found your n8n instance at [URL] — want to use the same credentials for this project?"

If no credentials are found, ask for:
- **n8n instance URL** (e.g., `https://pattern.app.n8n.cloud`)
- **n8n API key**
- **Credentials template workflow URL**

**Optional (ask only if relevant):**
- **Blueprint** — Has a blueprint already been generated? If so, ask them to paste it.
- **Specific nodes/services** — Any services they already know they'll need (Slack, Google Sheets, Supabase, etc.)

---

## Step 3: Create Project Directory

```bash
mkdir -p <project-name>
cd <project-name>
```

---

## Step 4: Copy and Populate Template Files

### 4a: .gitignore

Copy directly from the template — no modifications needed:

```bash
cp "$TOOLKIT_ROOT/project-template/.gitignore" .gitignore
```

Or create inline:

```bash
cat > .gitignore << 'EOF'
.env
.env.*
!.env.template
.DS_Store
Thumbs.db
.vscode/settings.json
.idea/
node_modules/
.next/
dist/
build/
*.log
npm-debug.log*
tmp/
temp/
EOF
```

### 4b: .env

Start from the template and fill in the actual values:

```bash
cat > .env << EOF
# ============================================
# Pattern AI Automations — n8n Configuration
# ============================================
# NEVER commit this file to git
# ============================================

# n8n Instance
N8N_API_URL=${N8N_API_URL}
N8N_API_KEY=${N8N_API_KEY}

# Credentials Template
N8N_CREDENTIALS_TEMPLATE_URL=${N8N_CREDENTIALS_TEMPLATE_URL}

# ============================================
# Project-Specific Variables
# ============================================
# Add as needed during the build:
# WEBHOOK_PATH=
# SLACK_CHANNEL=
# GOOGLE_SHEET_ID=
EOF
```

Also keep a copy of .env.template (without real values) for reference:

```bash
cp "$TOOLKIT_ROOT/project-template/.env.template" .env.template 2>/dev/null
```

### 4c: CLAUDE.md

Copy the template and replace all `{{PLACEHOLDER}}` values with actual project info:

| Placeholder | Replace With |
|-------------|-------------|
| `{{PROJECT_NAME}}` | Project name from Step 2 |
| `{{PROJECT_DESCRIPTION}}` | Brief description from Step 2 |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |
| `{{TEAM_MEMBER_NAME}}` | Builder's name from Step 2 |
| `{{STAKEHOLDER_NAME}}` | Stakeholder name from Step 2 |
| `{{STAKEHOLDER_TEAM}}` | Stakeholder team from Step 2 |
| `{{N8N_API_URL}}` | n8n instance URL |
| `{{N8N_CREDENTIALS_TEMPLATE_URL}}` | Credentials template URL |

If a blueprint was provided, paste it into the "Blueprint Reference" section.

If specific nodes/services were mentioned, pre-populate the "Node-Specific Credentials" table.

---

## Step 5: Verify API Connection

```bash
export $(cat .env | grep -v '^#' | xargs) && curl -s "${N8N_API_URL}/api/v1/workflows?limit=1" -H "X-N8N-API-KEY: ${N8N_API_KEY}" | jq '.data | length'
```

- If it returns a number → connection is working
- If it fails → help troubleshoot (wrong URL, bad API key, network issue)

---

## Step 6: Report to User

```
✅ Project initialized: <project-name>/

Files created:
  - CLAUDE.md       (project context — update as you build)
  - .env            (n8n credentials — never commit)
  - .env.template   (credential reference — safe to commit)
  - .gitignore      (protects .env from git)

n8n API connection: ✅ verified

Next steps:
  1. Describe your workflow (or paste the blueprint)
  2. The n8n plugin will build incrementally: one node → test → next node → test
  3. Update CLAUDE.md as you go with architecture decisions and notes
```

---

## Important Notes

- **Never put real API keys in CLAUDE.md** — they go in `.env` only
- **Always verify the API connection** — catch auth issues before building starts
- **The CLAUDE.md tracks project state** — encourage the builder to update it as decisions are made and issues are resolved. This creates a knowledge trail for the team.
- **If the user already has a blueprint**, incorporate it into CLAUDE.md automatically
- **The .env.template is safe to commit** — it has placeholder values only and helps new team members understand what variables are needed
