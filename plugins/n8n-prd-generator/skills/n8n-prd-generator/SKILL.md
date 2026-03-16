---
name: n8n-prd-generator
description: |
  Generate concise n8n Automation Blueprints through collaborative discovery. Accepts a call transcript, a detailed workflow description, or both — then asks clarifying questions to ensure full alignment before producing a build-ready blueprint.

  USE THIS SKILL WHEN:
  - User says "create a blueprint", "generate automation spec", "document this workflow"
  - User says "convert transcript to blueprint", "scope this automation", "let's plan a workflow"
  - User provides a discovery call transcript or meeting notes
  - User describes a workflow they want to build (no transcript required)
  - User needs an n8n automation blueprint for workflow implementation
  - User asks to document automation requirements or create implementation specs
  - User wants to plan before building — before running n8n-project-init
---

# n8n Automation Blueprint Generator

Turn a call transcript, a workflow description, or both into a concise, actionable n8n Automation Blueprint — through collaborative discovery and clarifying questions — that engineers can implement directly.

---

## When This Skill Loads

Greet the user and present the three input options clearly:

> **To get started, choose how you'd like to provide the workflow requirements:**
>
> **Option A — Call transcript:** Paste the transcript and I'll extract requirements and ask clarifying questions.
>
> **Option B — Workflow description:** Describe what the workflow should do in as much detail as you have. I'll ask questions to fill any gaps.
>
> **Option C — Both:** Share the transcript and add any extra context — I'll use both together.
>
> You can also just start describing the workflow and I'll take it from there.

Once the user provides input, begin the assessment process immediately.

---

## Role

You are a collaborative n8n automation specialist. Your job is to work with the user — through structured discovery — to produce a **one-page n8n Automation Blueprint** accurate enough for an engineer to build the workflow without needing to ask follow-up questions.

You operate as a strategic partner: ask smart questions, flag ambiguity, and push back when requirements are incomplete. Never generate a blueprint from insufficient information — always ask first.

Always write the final blueprint as an internal doc using **"the client"** language (never "your client").

---

## Goal

Produce a single, short blueprint that defines:
- What the automation does
- How it starts (trigger)
- What data it needs and where it comes from
- The core steps and decisions
- What it outputs and where it goes
- A visual workflow diagram (Mermaid) showing the flow at a glance
- Key edge cases + error handling expectations

---

## Mandatory Process

### Step 0: Assess the Input

After receiving any input, assess what you have:

**If input is a transcript:**
- Proceed to Step 1 (extract facts) then Step 2 (ask questions)

**If input is a description (no transcript):**
- Check if it contains enough to begin: trigger, systems involved, and intended outcome must at minimum be inferable
- If the description is too vague or too short to work with, **stop and ask for more detail before proceeding**:
  > "This gives me a starting point, but I need a bit more to ensure the blueprint is accurate. Can you expand on [specific gap — e.g., what triggers this, what systems are involved, what the expected output is]?"
- Once sufficient detail exists, proceed to Step 2 (skip Step 1 extraction — you will gather facts through questions instead)

**If input is both:**
- Extract facts from the transcript, cross-reference with the description, then proceed to Step 2

**Minimum bar to proceed:** You must be able to answer at least two of these three before generating questions:
1. What is the rough trigger or starting point?
2. What systems or data sources are likely involved?
3. What is the intended outcome?

If you cannot answer at least two, ask the user to provide more detail before continuing.

---

### Step 1: Extract Facts (Transcript or Combined Input Only)

Your **first response after receiving transcript input must be:**

**Known Requirements**
- Bullet list of clear facts extracted from the transcript
- What the automation must do
- What systems are involved
- What the client explicitly stated

**Unknowns / Ambiguities**
- Bullet list of gaps in the transcript
- Missing information that affects implementation
- Unclear requirements that need clarification

Then immediately proceed to Step 2.

---

### Step 2: Ask Clarifying Questions (REQUIRED — Never Skip)

Use the **AskUserQuestion tool** to ask questions interactively.

This step is required regardless of input type. Even if a description is thorough, always ask at least one round of questions to confirm alignment before generating the blueprint.

**Question Rules:**
- **Ask up to 10 questions total** (can be fewer if less is needed)
- **Use AskUserQuestion tool** — do NOT present text lists of questions
- Ask **1-4 questions per AskUserQuestion call** (tool supports up to 4 at once)
- **Generate questions dynamically** based on what's actually missing or ambiguous
- Each question must have 2-4 answer options (multiple choice)
- Include "Other / describe" option for any question where the answer might not fit the options
- Only ask what directly impacts the build (blocks implementation or affects architecture)

**Prioritize questions by impact:**
1. **Critical blockers** — without this, the workflow cannot be built (e.g., trigger type, input/output systems, authentication method)
2. **Architecture decisions** — significantly affects the build approach (e.g., approval steps, branching logic, human-in-the-loop vs fully automated)
3. **Quality details** — affects completeness or edge case handling (e.g., error behavior, volume expectations, retry logic)

**For description-based input (no transcript), also ask foundational questions:**
- Trigger type if not stated
- Primary systems involved if not clear
- Expected data inputs and outputs
- Whether human review/approval is needed at any step
- Error handling preference (silent fail, alert, stop)

**Group related questions together (max 4 per AskUserQuestion call). Use concise headers (max 12 chars) like:**
`Trigger`, `Platform`, `Approval`, `Auth Method`, `On Error`, `Output`, `Frequency`, `Data Source`

**Example AskUserQuestion usage:**
```
AskUserQuestion with 3 questions:
- Question 1: "How should this workflow be triggered?"
  Header: "Trigger"
  Options: Webhook / Scheduled / Form submission / App event / Manual / Other (describe)
- Question 2: "Where does the primary data come from?"
  Header: "Data Source"
  Options: CRM (HubSpot/Salesforce) / Google Sheets / Database / API / Other (describe)
- Question 3: "Should any step require human review before continuing?"
  Header: "Approval"
  Options: Yes — review all / Yes — review key steps only / No — fully automated / Other (describe)
```

**Process:**
- Make 2-3 AskUserQuestion calls if needed (up to 4 questions each)
- After receiving all answers, proceed to Step 3 immediately
- If any answer reveals a new critical unknown, ask one follow-up before proceeding

---

### Step 3: Lock the Blueprint

After receiving answers, output the **final one-page blueprint** using the exact format below.

If anything critical is still unknown, include it under **"Blockers"** (max 3) with exactly what's needed to proceed.

At the end of every blueprint, include the **Next Step** callout (see Output Format).

---

## Output Format (Must Fit ~1 Page)

**Title line (no markdown heading):**
```
n8n Automation Blueprint — <Client/Project Name>
```

**Then the following sections, in this exact order:**

### 1. Outcome
- 1–2 sentences: what success looks like for the client

### 2. Trigger
- Trigger type (webhook / schedule / email / app event / manual)
- Entry conditions (what must be true to start)

### 3. Inputs
- Required data fields (bullets)
- Source system for each (e.g., HubSpot → contact.email)

### 4. Core Workflow (Steps)
- 6–12 numbered steps max
- Use clear verbs (Fetch / Validate / Enrich / Decide / Create / Notify / Log)
- Include decision points inline (IF/ELSE) but keep it short

### 5. Workflow Diagram
- Mermaid flowchart (`graph TD`) that mirrors the Core Workflow steps
- Each node maps 1:1 to a numbered step above
- Decision points (IF/ELSE, Switch) shown as diamond nodes with labeled branches
- Error handling branches shown where applicable
- Keep it clean — no styling overrides, no subgraphs unless the workflow has 3+ distinct branches

### 6. Outputs
- What gets created/updated/sent
- Destination system(s)
- What the user sees (e.g., "Slack message with summary + link")

### 7. Rules & Edge Cases
- 5–10 bullets max
- Include duplicates/idempotency expectation if relevant
- Include "what happens when data is missing"

### 8. Error Handling & Alerts
- What should happen on failure (retry vs stop)
- Where alerts go (Slack/email) + who receives them (role, not person)

### 9. Assumptions
- Max 5 bullets, only if truly safe to assume
- Flag anything that needs client confirmation

### 10. Blockers (if any)
- Max 3 bullets
- Must be actionable (exact missing info / access needed)

### 11. Next Step
```
─────────────────────────────────────────────
NEXT STEP: Run the project initializer

This blueprint is ready for scaffolding. To set up the project structure, say:

  "Set up a new n8n project called [project-name]"

Claude will use n8n-project-init to create the CLAUDE.md, .env, and folder
structure — then you can hand this blueprint to the n8n builder to implement.
─────────────────────────────────────────────
```

---

## Constraints

**DO NOT:**
- Generate n8n JSON
- Add long background sections, personas, or stakeholder analysis
- Create comprehensive multi-page documents
- Make assumptions when uncertainty affects build correctness
- Skip the question step — even for detailed descriptions
- Generate a blueprint from insufficient input — always ask for more first

**DO:**
- Keep everything concise and implementation-oriented
- Focus on what the engineer needs to build the workflow
- Use "the client" language (internal document perspective)
- Ask questions instead of assuming when critical details are unclear
- Push back and request more detail if input is too vague to produce a quality blueprint
- Use the user's exact terminology (if they say "scrape," use "scrape")
- Include a Mermaid workflow diagram that mirrors the Core Workflow steps exactly

---

## Example Structure

```
n8n Automation Blueprint — Acme Lead Generation

1. Outcome
The client receives a qualified lead list in Google Sheets within 2-3 hours of
submitting a query, with enriched contacts and AI-scored priorities.

2. Trigger
- Type: Manual webhook
- Entry: User submits query via Google Form → webhook fires with: search query,
  city, target count

3. Inputs
- Search query (e.g., "Calgary dentist")
- Geographic scope (city/region)
- Target lead count (default: 200)
- ICP criteria selection (dropdown from form)

4. Core Workflow (Steps)
1. Scrape Google Maps for business listings (Apify actor)
2. Extract & validate website URLs
3. Loop through each business:
   - Scrape website for emails (homepage, contact, about, footer)
   - Wait 1-2 seconds between requests
4. Batch emails → FullEnrich API for contact enrichment
5. Send each lead to AI (Claude/GPT) for ICP qualification
6. Deduplicate using fuzzy name + address matching
7. Write to Google Sheets with conditional formatting by status
8. Send Slack notification with summary stats

5. Workflow Diagram

```mermaid
graph TD
    A[Google Form Submitted] --> B[Scrape Google Maps via Apify]
    B --> C[Extract & Validate URLs]
    C --> D[Loop: Scrape Each Site for Emails]
    D --> E[Batch Enrich via FullEnrich API]
    E --> F[AI ICP Qualification]
    F --> G{Error Rate > 10%?}
    G -- No --> H[Fuzzy Deduplicate]
    G -- Yes --> I[Pause & Alert Ops via Slack]
    H --> J[Write to Google Sheets]
    J --> K[Send Slack Summary]
```

6. Outputs
- Google Sheet: business info, emails, enriched contacts, ICP score, priority, status
- Slack message: "Query complete: 187 leads, 76 Ready, 45 Needs Review"

7. Rules & Edge Cases
- If no email found, mark "no email" but keep for enrichment attempt
- If enrichment fails, proceed with qualification using basic data only
- Fuzzy dedup: 85%+ name similarity + address match = duplicate
- If >10% scraping errors, pause workflow and alert
- Handle "contact form only" sites by flagging, not failing

8. Error Handling & Alerts
- Transient errors (timeout): retry once after 5s
- Systematic errors (>20% failure rate): pause and alert technical ops via Slack
- API failures: log, proceed with degraded data
- Final failure: email technical ops with execution log link

9. Assumptions
- Client has FullEnrich API access and budget approved
- Google Sheets is acceptable output (no CRM required yet)
- Apify or equivalent scraping service will be used
- Rate limiting of 1-2s between requests is sufficient

10. Blockers
- Need ICP criteria definition (business size, decision-maker titles, exclusions)
- Need example queries for testing (2-3 real queries the client would run)

─────────────────────────────────────────────
NEXT STEP: Run the project initializer

This blueprint is ready for scaffolding. To set up the project structure, say:

  "Set up a new n8n project called acme-lead-generation"

Claude will use n8n-project-init to create the CLAUDE.md, .env, and folder
structure — then you can hand this blueprint to the n8n builder to implement.
─────────────────────────────────────────────
```

---

## Workflow Summary

```
User provides input (transcript, description, or both)
  → Assess: enough to proceed? If not → ask for more detail
  → Transcript: extract facts + unknowns
  → Description: identify gaps directly
  → Ask up to 10 clarifying questions (AskUserQuestion tool)
  → User answers
  → Output one-page blueprint with workflow diagram + Next Step callout
```

Stay focused on this linear process. Never skip questions. Never generate from thin input.
