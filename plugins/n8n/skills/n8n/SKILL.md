---
name: n8n
description: |
  Build, test, and deploy n8n workflows via REST API with incremental testing. Expert automation for n8n.
  This is Step 3 of 3 in the Pattern AI Automations build pipeline.

  USE THIS SKILL WHEN:
  - User says "create workflow", "build automation", "deploy to n8n", "activate workflow", "build the workflow"
  - User needs to list, update, delete, or test workflows
  - User mentions webhook execution, checking executions, debugging workflow runs
  - User asks about n8n nodes, expressions, credentials, or Code nodes
  - User needs JavaScript or Python code for n8n Code nodes
  - User mentions {{ }} expressions, $json, $input, or $node references
  - User asks about AI Agent, OpenAI, Anthropic, Google Sheets, Airtable, Slack, or other n8n nodes
  - User has completed n8n-project-init and is ready to build
---

# n8n Automation Builder

Build, test, and deploy n8n workflows via REST API with incremental testing.

This is **Step 3 of 3** in the build pipeline:

```
[Step 1] PRD Generator  →  [Step 2] Project Init  →  [Step 3] n8n Builder  ← YOU ARE HERE
```

---

## When This Skill Loads (DO THIS IMMEDIATELY — IN ORDER)

### Step 1: Read Reference Files
```
Use the Read tool to read these files NOW:
1. Read references/pitfalls.md (critical command format rules)
2. Read references/build-process.md (step-by-step build workflow)
```

### Step 2: Load Project Context

Read the project's `CLAUDE.md` file in the current working directory:

```
Read CLAUDE.md
```

Extract and hold in context:
- **Project name and description**
- **Stakeholder** — who this is for
- **n8n instance URL** — confirm it matches `.env`
- **Blueprint Reference section** — this is the build spec. If a blueprint is present, it defines the trigger, inputs, core steps, outputs, rules, and error handling requirements. Use it as the primary guide for the entire build.
- **Planned Workflow Steps** — use the node sequence if defined
- **Node-Specific Credentials table** — use to pre-select credential types

If `CLAUDE.md` is missing:
> "I don't see a CLAUDE.md in this directory. This project may not have been initialized. Run `Set up a new n8n project` first, then come back to build."

If `CLAUDE.md` exists but the Blueprint Reference section is empty:
> "There's no blueprint in CLAUDE.md. You can paste your blueprint now and I'll use it as the build spec, or describe the workflow and I'll proceed from your description."

### Step 3: Check .env Configuration
```
Read the .env file in the working directory to verify:
- N8N_API_URL is set
- N8N_API_KEY is set
- N8N_CREDENTIALS_TEMPLATE_URL is set
```

If any values are missing, stop and tell the user to run the project initializer first.

### Step 4: Confirm Build Spec and Create Todo List

Briefly confirm what you're about to build based on the blueprint:

> "Ready to build: **[Project Name]**
> Trigger: [trigger type]
> Steps: [count] nodes
> Output: [destination]
>
> Building node by node with testing after each step. Starting now."

Then create a todo list with one item per node/major step from the blueprint.

```
SKILL LOADS -> READ REFS -> READ CLAUDE.md -> CHECK .env -> CONFIRM SPEC -> BUILD
```

---

## Critical Rules

### 1. USE THE TOOLS THE USER SPECIFIES

**If the user mentions specific tools, nodes, or services - YOU MUST USE THEM.**

```
User says "use Apify" -> You use Apify node
User says "use OpenAI" -> You use OpenAI Chat Model
```

Never substitute, skip, or defer user-requested tools.

### 2. NEVER Simplify When Hitting Errors - FIX THE ISSUE

```
Loop node has error -> Debug why -> Fix the loop configuration
```

Don't switch to "simpler" approaches. Keep the correct architecture.

### 3. Only Use Nodes From Credentials Template

Never add nodes requiring authentication unless:
1. The node exists in the user's credentials template, OR
2. The user explicitly asks to use that specific tool/service

### 4. Only Use Node Types/Versions That Are INSTALLED

Always copy `type` AND `typeVersion` from the credentials template.

### 5. One Node at a Time

```
ADD NODE -> TEST -> ADD NEXT NODE -> TEST -> REPEAT
```

**NEVER add 2+ nodes without testing between them.**

### 6. NEVER Delete or Deactivate Workflows - UPDATE Instead

```
Node fails -> Debug the error -> Update the same workflow (PUT)
```

One workflow ID for the entire build process.

### 7. Use Native Nodes First

| Priority | Use When |
|----------|----------|
| 1. Native node | Built-in exists (Slack, Sheets, etc.) |
| 2. AI Agent node | For ANY AI/LLM task |
| 3. Loop node | For processing multiple items |
| 4. HTTP Request | Native has issues OR no node exists |
| 5. Code node | Complex logic only |

### 8. No Mock Data

Never use placeholder URLs, fake IDs, or "REPLACE_ME" values.

### 9. Test with 2 Items

Always set `limit=2` on data-fetching nodes for fast testing.

### 10. Only Work With User-Specified Workflows

Never check, run, or modify workflows the user didn't mention.

---

## Build Process

### Step 0: Fetch Schema (If Database Involved)
```
1. Create temp workflow: Webhook + getSchema/getAll node
2. Execute to fetch actual field names
3. Use exact field names in main workflow
```

### Step 1: Create Workflow with Trigger
```
1. Read references/triggers.md
2. Create workflow with trigger only
3. Test trigger
```

### Step 2: Add Each Node
```
1. Read relevant reference file for this node type
2. Add ONE node to workflow
3. Test workflow
4. If ERROR -> fix -> retry
5. If SUCCESS -> move to next node
```

### Step 3: Final Verification
```
1. All nodes added and tested
2. Workflow activated
3. Report success to user
```

---

## API Methods Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create | POST | `/api/v1/workflows` |
| Update | **PUT** | `/api/v1/workflows/{id}` |
| Activate | **POST** | `/api/v1/workflows/{id}/activate` |
| Deactivate | **POST** | `/api/v1/workflows/{id}/deactivate` |
| Delete | DELETE | `/api/v1/workflows/{id}` |
| Execute | POST | `/webhook/{path}` |

---

## API Call Format

**CRITICAL RULES:**
1. **NEVER write JSON files to disk** - Always use API directly
2. **NEVER use `\` line continuations** - Causes errors
3. **Always single-line commands** - Or heredoc for large JSON

**GET:**
```bash
export $(cat .env | grep -v '^#' | xargs) && curl -s "${N8N_API_URL}/api/v1/ENDPOINT" -H "X-N8N-API-KEY: ${N8N_API_KEY}" | jq .
```

**POST/PUT (large JSON):**
```bash
export $(cat .env | grep -v '^#' | xargs) && curl -s -X POST "${N8N_API_URL}/api/v1/workflows" -H "X-N8N-API-KEY: ${N8N_API_KEY}" -H "Content-Type: application/json" -d "$(cat <<'EOF'
{
  "name": "My Workflow",
  "nodes": [...],
  "connections": {},
  "settings": {"executionOrder": "v1"}
}
EOF
)"
```

---

## Workflow JSON Structure

```json
{
  "name": "Workflow Name",
  "nodes": [
    {
      "id": "unique-node-id",
      "name": "Node Display Name",
      "type": "n8n-nodes-base.nodeName",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {},
      "credentials": {}
    }
  ],
  "connections": {
    "Source Node Name": {
      "main": [[{"node": "Target Node Name", "type": "main", "index": 0}]]
    }
  },
  "settings": {"executionOrder": "v1"}
}
```

---

## Reference Files

Read these files as needed using the Read tool:

### Core API & Build Process
| File | Contents |
|------|----------|
| [references/api-reference.md](references/api-reference.md) | All API commands (CRUD, executions, tags, variables) |
| [references/build-process.md](references/build-process.md) | Step-by-step build-test workflow |
| [references/pitfalls.md](references/pitfalls.md) | **CRITICAL**: Command format rules, common mistakes |

### Node Reference
| File | Contents |
|------|----------|
| [references/triggers.md](references/triggers.md) | Webhook, Schedule, Form, Chat, and service triggers |
| [references/ai-nodes.md](references/ai-nodes.md) | AI Agent, OpenAI/Anthropic Chat Models, Memory, Vector Store |
| [references/data-nodes.md](references/data-nodes.md) | Google Sheets, Airtable, Notion, Postgres, Slack, Gmail, etc. |
| [references/transform-nodes.md](references/transform-nodes.md) | Set, If, Switch, Filter, Merge, Code, HTTP Request, Loops |

### Code & Expressions
| File | Contents |
|------|----------|
| [references/javascript.md](references/javascript.md) | JavaScript patterns for Code nodes |
| [references/python.md](references/python.md) | Python patterns for Code nodes |
| [references/node-config.md](references/node-config.md) | Node configurations and workflow patterns |
| [references/expressions.md](references/expressions.md) | Expression syntax (`{{ $json.field }}`) |
| [references/credentials.md](references/credentials.md) | Credential template usage |

---

## Node Selection Flow

**Before adding ANY node:**

```
1. Read the relevant reference file (triggers.md, ai-nodes.md, etc.)
2. Check if node is in credentials template
3. Get correct typeVersion and parameters
4. If DATABASE node -> FETCH SCHEMA first
5. Add node with correct config
```

---

## Expression Quick Reference

```javascript
// Webhook body (CRITICAL - data is under .body!)
{{ $json.body.fieldName }}

// Other node reference
{{ $('Node Name').item.json.field }}

// Default value
{{ $json.field ?? 'default' }}

// Safe access
{{ $json.obj?.nested?.field }}

// Current date
{{ $now.toFormat('yyyy-MM-dd') }}
```

**In Code nodes, use plain JavaScript - NOT `{{ }}`:**
```javascript
const data = $input.first().json.body;
return [{ json: { result: data.fieldName } }];
```

---

## Code Node Quick Reference

### JavaScript
```javascript
// Input access
const items = $input.all();
const first = $input.first().json;

// Other nodes
const data = $('Node Name').first().json;

// Return (MUST be array with json key)
return [{ json: { result: 'value' } }];
```

### Python
```python
# Input access
items = _input.all()
first = _input.first().json

# Return (MUST be list)
return [{"json": {"result": "value"}}]
```

---

## Testing After Each Node

```bash
# 1. Activate
curl -X POST "${N8N_API_URL}/api/v1/workflows/{id}/activate"

# 2. Execute
curl -X POST "${N8N_API_URL}/webhook/{path}" -d '{}'

# 3. Check status
curl "${N8N_API_URL}/api/v1/executions?limit=1" | jq '.data[0].status'

# 4. Verify node ran
curl "${N8N_API_URL}/api/v1/executions/{id}?includeData=true" | jq '.data.resultData.runData | keys'
```

**Do NOT proceed until status = "success" and new node appears in runData.**

---

## Build Complete: What to Report

**After all nodes are built and tested, output a structured summary:**

```
─────────────────────────────────────────────
BUILD COMPLETE — <Project Name>
─────────────────────────────────────────────
Workflow:  <workflow name>
Status:    Active
URL:       https://pattern.app.n8n.cloud/workflow/<id>

Nodes built and tested:
  ✓ [Trigger type] — working
  ✓ [Node 2 name] — working (N results)
  ✓ [Node 3 name] — working
  ...

Output: <what was created/sent/updated>
─────────────────────────────────────────────
```

**If any node requires manual configuration in the UI:**
```
Manual setup required:
  • [Node name]: [exactly what the user needs to do in the UI]
```

---

## Error Handling Setup (Ask After Every Build)

After reporting build complete, always ask about error handling using AskUserQuestion:

**First question:**
```
Question: "Do you want to add error handling to this workflow?"
Header: "Error Handling"
Options:
  - "Yes — attach an existing error workflow"
  - "Yes — create a new error workflow for this project"
  - "No — skip for now"
```

**If "attach an existing error workflow":**
- Ask: "What is the name or workflow ID of the error handling workflow?"
- Fetch the workflow by name/ID to confirm it exists
- Set it as the error workflow on the current workflow using the n8n API:
  ```bash
  # Update workflow settings to attach error workflow
  PUT /api/v1/workflows/{id}
  # Set settings.errorWorkflow to the error workflow ID
  ```
- Confirm: "Error workflow `<name>` attached."

**If "create a new error workflow":**
- Ask using AskUserQuestion:
  ```
  Question: "How should the error alert be sent?"
  Header: "Alert Channel"
  Options:
    - "Slack"
    - "Gmail"
    - "Both Slack and Gmail"
  ```
- Then ask for the destination:
  - Slack: "Which Slack channel? (e.g., #automation-alerts)"
  - Gmail: "Which email address should receive error alerts?"
- Build a minimal error handling workflow:
  1. **Error Trigger** node (`n8n-nodes-base.errorTrigger`)
  2. **Notification node** (Slack and/or Gmail) with this message format:
     ```
     ❌ Workflow Error: {{ $json.workflow.name }}
     Error: {{ $json.execution.error.message }}
     Execution: https://pattern.app.n8n.cloud/execution/{{ $json.execution.id }}
     ```
  3. Activate the error workflow
  4. Attach it to the main workflow via API
- Report: "Error workflow created and attached. Alerts will go to [destination]."

**If "skip for now":**
- Acknowledge and move on. Do not ask again.

---

## Final Wrap-Up

After build complete and error handling decision, output:

```
─────────────────────────────────────────────
DONE — <Project Name> is live on Pattern n8n

Update your CLAUDE.md status checklist:
  ✓ Workflow built and tested
  ✓ Error handling: <added / skipped>
  □ Stakeholder review
  □ Activated in production (if not already)
  □ Documentation complete
─────────────────────────────────────────────
```
