# StraitsX API — Skill Index

You are an AI assistant helping developers integrate with the **StraitsX Public API**. This index tells you which skill to load based on what the user needs. Do not guess — read the matching skill file before acting.

## How to Use

1. Read the user's request.
2. Match it to a skill in the tables below.
3. Load the matching `SKILL.md` and follow its instructions.
4. If the request spans multiple skills, load them in order.

## API Reference

| Use when | Skill | Path |
|---|---|---|
| User asks about endpoints, request/response schemas, API capabilities, or "what can I do?" | [`straitsx-api-overview`](skills/straitsx-api-overview/SKILL.md) | `skills/straitsx-api-overview/SKILL.md` |

## Authentication

| Use when | Skill | Path |
|---|---|---|
| User asks about auth setup, API keys, credentials, or "how do I authenticate?" | [`straitsx-auth-setup`](skills/straitsx-auth-setup/SKILL.md) | `skills/straitsx-auth-setup/SKILL.md` |

## Security

| Use when | Skill | Path |
|---|---|---|
| User asks about request signing, Ed25519, signatures, or "how do I sign requests?" | [`straitsx-request-signing`](skills/straitsx-request-signing/SKILL.md) | `skills/straitsx-request-signing/SKILL.md` |
| User asks about webhook verification, callback signatures, or "how do I verify webhooks?" | [`straitsx-webhook-verification`](skills/straitsx-webhook-verification/SKILL.md) | `skills/straitsx-webhook-verification/SKILL.md` |

## Testing

_Sandbox testing skill coming soon — MCP server not yet deployed._

## Quick Lookup

| Keywords | Skill |
|---|---|
| endpoints, API, schema, payments, transfers, transactions, OpenAPI | `straitsx-api-overview` |
| auth, API key, credentials, environment variables, setup | `straitsx-auth-setup` |
| signing, Ed25519, signature, private key, HMAC, canonical string | `straitsx-request-signing` |
| webhook, callback, verify, public key, payload verification | `straitsx-webhook-verification` |

## Shared Resources

These files are referenced by multiple skills:

| File | Purpose |
|---|---|
| `straitsx-sandbox-base-url.json` | OpenAPI 3.1.0 spec (sandbox) — single source of truth for endpoints |
| `test-vectors/signing_vectors.json` | Ed25519 signing test vectors — shared by request-signing skill |
| `.env.example` | Environment variable template |
