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
TOOLKIT_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find ~/claude-plugins -name 'CLAUDE.md.template' -path '*/project-template/*' 2>/dev/null | head -1 | xargs dirname)}"
```

If the template files cannot be found, generate them inline using the formats documented in Step 4 below.

---

## Step 2: Gather Project Info and Credentials

### CRITICAL: Check for n8n credential profiles FIRST

**Before asking the user ANY questions, run this command:**

```bash
ls ~/.n8n-envs/*.env 2>/dev/null && echo "PROFILES_FOUND" || echo "NO_PROFILES"
```

**If output contains PROFILES_FOUND:**
1. List the available profile names:
   ```bash
   ls ~/.n8n-envs/*.env | xargs -I{} basename {} .env
   ```
2. Ask the user which n8n instance this project targets. Present the profile names as selectable options (e.g., "pattern", "behold", "sandbox").
3. Load the selected profile:
   ```bash
   cat ~/.n8n-envs/<selected-name>.env
   ```
4. **DO NOT ask the user for credentials. They are already in the profile. Move on to asking for project details.**

**If output contains NO_PROFILES:**
1. Check for a single team credentials file:
   ```bash
   cat ~/.n8n-team.env 2>/dev/null
   ```
2. If found with populated values, use those credentials. Confirm with the user: "Using n8n instance at [URL] -- correct?"
3. If not found or empty, ask the user to provide:
   - n8n instance URL (e.g., `https://pattern.app.n8n.cloud`)
   - n8n API key
   - Credentials template workflow URL
4. Offer to save: "Want me to save these as a profile at ~/.n8n-envs/<name>.env for future projects?"

### Then ask for project details

Collect the following (use AskUserQuestion tool where possible):

**Required:**
1. **Project name** -- kebab-case directory name (e.g., `lead-enrichment-workflow`)
2. **Brief description** -- One sentence: what does this automation do?
3. **Your name** -- Who is building this? (team member name)
4. **Stakeholder** -- Who requested this? (name and team, e.g., "Sarah Chen, RevOps")

**Optional (ask only if relevant):**
- **Blueprint** -- Has a blueprint already been generated? If so, ask them to paste it.
- **Specific nodes/services** -- Any services they already know they will need

---

## Step 3: Create Project Directory

```bash
mkdir -p <project-name>
cd <project-name>
```

---

## Step 4: Copy and Populate Template Files

### 4a: .gitignore

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

Use the credentials loaded from the profile (Step 2). Write them into the project .env:

```bash
cat > .env << EOF
# ============================================
# Pattern AI Automations -- n8n Configuration
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

### 4c: CLAUDE.md

Create the CLAUDE.md with all placeholder values replaced:

| Placeholder | Replace With |
|-------------|-------------|
| `{{PROJECT_NAME}}` | Project name from Step 2 |
| `{{PROJECT_DESCRIPTION}}` | Brief description from Step 2 |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |
| `{{TEAM_MEMBER_NAME}}` | Builder's name from Step 2 |
| `{{STAKEHOLDER_NAME}}` | Stakeholder name from Step 2 |
| `{{STAKEHOLDER_TEAM}}` | Stakeholder team from Step 2 |
| `{{N8N_API_URL}}` | n8n instance URL from loaded credentials |
| `{{N8N_CREDENTIALS_TEMPLATE_URL}}` | Credentials template URL from loaded credentials |

If a blueprint was provided, paste it into the "Blueprint Reference" section.
If specific nodes/services were mentioned, pre-populate the "Node-Specific Credentials" table.

---

## Step 5: Verify API Connection

```bash
export $(cat .env | grep -v '^#' | xargs) && curl -s "${N8N_API_URL}/api/v1/workflows?limit=1" -H "X-N8N-API-KEY: ${N8N_API_KEY}" | jq '.data | length'
```

- Returns a number: connection is working
- Fails: help troubleshoot (wrong URL, bad API key, network issue)

---

## Step 6: Report to User

```
Project initialized: <project-name>/

Files created:
  - CLAUDE.md       (project context -- update as you build)
  - .env            (n8n credentials -- never commit)
  - .gitignore      (protects .env from git)

n8n instance: <instance-name> (<N8N_API_URL>)
API connection: verified

Next steps:
  1. Describe your workflow (or paste the blueprint)
  2. The n8n plugin will build incrementally: one node, test, next node, test
  3. Update CLAUDE.md as you go with architecture decisions and notes
```

---

## Important Notes

- **Never put real API keys in CLAUDE.md** -- they go in `.env` only
- **Always verify the API connection** -- catch auth issues before building starts
- **The CLAUDE.md tracks project state** -- encourage the builder to update it as decisions are made
- **If the user already has a blueprint**, incorporate it into CLAUDE.md automatically
