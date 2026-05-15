# StraitsX AI Skill Authoring Guide

**Audience:** Skill maintainers and contributors to this repository. This guide is NOT for merchants consuming the skills — it's for anyone creating or updating skills in `straitsx-ai`.

This document defines the mandatory quality standards for every skill in the `straitsx-ai` repository. All existing and new skills must comply with these conventions.

**Why this exists:** This guide ensures consistent, complete skills that produce working code on the first attempt.

---

## 1. SKILL.md Structure

Every `SKILL.md` must include these sections in order:

```
---
(frontmatter: name, description, category, parent)
---

# Skill Title

## Invoke This Skill When
## Prerequisites
## (Main Content — flow steps, instructions, golden code, etc.)
## Troubleshooting
```

### 1.1 Frontmatter (Required)

```yaml
---
name: straitsx-<skill-name>
description: <One-line description. End with trigger phrases: "Use when the user asks about X, Y, or Z.">
category: <setup | security | testing | payments | reference>
parent: straitsx-api
---
```

- `name`: Lowercase, hyphenated. Must match the folder name.
- `description`: Used for skill routing. Include common trigger phrases so the AI knows when to load this skill.
- `category`: Choose the most appropriate from the list above.

### 1.2 Invoke This Skill When (Required)

A bullet list of trigger conditions. Be specific — include exact phrases users might say:

```markdown
## Invoke This Skill When

- User asks "How do I ...?" or "Walk me through ..."
- User wants to ...
- User is confused about ...
```

### 1.3 Prerequisites (Required)

List what the user needs before this skill is useful:

```markdown
## Prerequisites

- Sandbox API key configured (see the `straitsx-auth-setup` skill)
- `X_XFERS_APP_API_KEY` environment variable set
```

Always cross-reference other skills when there's a dependency.

---

## 2. API Call Steps — Response Documentation

**This is the most critical section.** Every step that makes an API call MUST include:

### 2.1 Response Format Tag (Required)

Immediately after the endpoint description, state the response format:

```
→ Response format: JSON:API (data.id)
```

or

```
→ Response format: flat (id)
```

or

```
→ Response format: array ([0].id)
```

### 2.2 Response Annotation (Required)

Show the key fields to extract, with exact JSON paths:

```
→ Response: ID at `data.id`, account number at `data.attributes.instructions.accountNo`
```

### 2.3 Full Example

```markdown
5. Create a virtual bank account (VBA) for the customer profile
   POST /payment_methods/virtual_bank_accounts
   Body uses data.attributes + data.relationships (nested format).
   → Response format: JSON:API (data.id)
   → Response: VBA ID at `data.id`, account number at `data.attributes.instructions.accountNo`

6. [Sandbox] Simulate a bank transfer payment to the VBA
   POST /sandbox/customer_profile/{customer_profile_id}/bank_transfer_simulations
   Body is FLAT. Required fields: destination_bank_account_no, amount, source_bank_account_holder_name.
   → Response format: flat (id)
   → Response: contract ID at `id` (not `data.id`)
```

---

## 3. Chain Map (Required for Multi-Step Flows)

Any skill with sequential API calls where one step's output feeds into the next MUST include a chain map section. Place it after the flow steps.

### Format

```markdown
### Response Chain Map

| Step | Response Field | Feeds Into |
|------|---------------|------------|
| Step 1 (Create CP) | `data.id` | Step 2 path param `customer_profile_id` |
| Step 3 (Create bank account) | `[0].id` | Step 4 path param `bank_account_id` |
| Step 5 (Create VBA) | `data.attributes.instructions.accountNo` | Step 6 body `destination_bank_account_no` |
| Step 6 (Simulate payment) | `id` | Step 7 path param `contract_id` |
```

### Why This Matters

Different endpoints return IDs in different formats:
- JSON:API style: `response.data.id`
- Flat style: `response.id`
- Array style: `response[0].id`

Without explicit chain maps, AI code generators assume a consistent format and produce `undefined` errors.

---

## 4. Troubleshooting Table (Required)

Every skill MUST include a troubleshooting table. At minimum, cover these categories:

| Category | Example |
|----------|---------|
| **Auth errors** | Missing/invalid API key (`STXE-1000`) |
| **Permission errors** | Missing scopes (`XFE6` / 403) |
| **Validation errors** | Wrong body format, missing required fields |
| **State errors** | Resource not in expected status |
| **Rate limiting** | 429 / `STXE-9000` |
| **Idempotency conflicts** | Duplicate idempotency key (`STXE-7000`) |
| **Sandbox quirks** | Auto-completion, environment-specific behavior |

### Format

```markdown
## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `STXE-1000` on any request | Invalid or missing API key. Check `X_XFERS_APP_API_KEY` is set and is a sandbox key. |
| `XFE6` (403 Access Denied) | Your API key is missing required scopes. Contact StraitsX support. |
| ... | ... |
```

Include the actual error code/message the user would see, not just a description.

---

## 5. OpenAPI Spec Coverage

Before publishing or updating a skill:

- [ ] Every endpoint referenced in the skill exists in `references/openapi-spec.json`
- [ ] Each endpoint in the spec has a complete request body schema (required fields, types, validation rules)
- [ ] Each endpoint in the spec has a response schema with examples
- [ ] The spec is pretty-printed (not minified)

If an endpoint is missing from the spec, add it before publishing the skill. If you don't have the schema details, flag it as a known gap in the skill with a `<!-- TODO: -->` comment.

---

## 6. Cross-Skill Routing

When a skill's flow overlaps with or depends on another skill, add explicit routing:

```markdown
> **Note:** For general sandbox setup (customer profile creation, bank account linking),
> follow the `straitsx-sandbox-testing` skill. This skill covers FX-specific steps only.
```

Rules:
- Route TO other skills for prerequisite steps (don't duplicate content).
- Route FROM other skills when your skill covers a specialized sub-flow.
- Use the exact skill name in backticks so the AI can load it.

---

## 7. Code Generation Rules

If your skill generates runnable code, include a "Code Generation Rules" section. At minimum:

1. **Specify the base URL** (sandbox vs production)
2. **Specify required headers** (API key, content-type, signing headers if applicable)
3. **Chain responses** — reference the chain map for which fields to extract
4. **Error handling** — check HTTP status after each call, stop on errors
5. **Rate limiting** — include delays between calls if applicable
6. **Idempotency** — generate unique IDs where required
7. **Re-run safety** — check-before-create pattern for non-deletable resources

---

## 8. References Directory

Skills that reference external data (OpenAPI specs, golden code, test vectors) should store them in a `references/` subdirectory:

```
skills/straitsx-<skill-name>/
├── SKILL.md
└── references/
    ├── openapi-spec.json      (if skill-specific endpoints needed)
    ├── golden-code-python.md  (if golden code provided)
    └── ...
```

Rules:
- Reference files are loaded on-demand, not always included in context.
- Use relative links in SKILL.md: `[references/openapi-spec.json](references/openapi-spec.json)`
- Keep individual reference files under 100KB where possible for AI tool compatibility.

---

## 9. Quality Checklist

Before submitting a skill PR, verify:

- [ ] Frontmatter is complete (name, description, category, parent)
- [ ] "Invoke This Skill When" section has specific trigger phrases
- [ ] Prerequisites list all dependencies with cross-skill references
- [ ] Every API call step has a `→ Response format:` tag
- [ ] Every API call step has a `→ Response:` annotation with field paths
- [ ] Chain map is present (if multi-step flow)
- [ ] Troubleshooting table covers all required categories
- [ ] All referenced endpoints exist in the OpenAPI spec
- [ ] Code examples use environment variables for secrets (never hardcoded)
- [ ] Cross-skill routing is explicit where flows overlap
- [ ] Reference files are under 100KB each

---

## 10. Updating Existing Skills

When updating a skill that predates this guide:

1. Add response format tags and annotations to all API call steps
2. Add a chain map if the skill has sequential API calls
3. Verify troubleshooting table covers all required categories
4. Check OpenAPI spec coverage for all referenced endpoints
5. Add cross-skill routing where applicable

Prioritize the changes that prevent runtime bugs (response annotations > chain map > troubleshooting).
