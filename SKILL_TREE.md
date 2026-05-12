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

## FX & Cross-Border Payouts

| Use when | Skill | Path |
|---|---|---|
| User asks about IDR payouts, FX conversion, sending money to Indonesia, USD/XUSD → IDR, or "how do I do an FX payout?" | [`straitsx-fx-payout-idr`](skills/straitsx-fx-payout-idr/SKILL.md) | `skills/straitsx-fx-payout-idr/SKILL.md` |

## Testing

| Use when | Skill | Path |
|---|---|---|
| User asks about sandbox testing, integration walkthroughs, or "how do I test the full flow?" | [`straitsx-sandbox-testing`](skills/straitsx-sandbox-testing/SKILL.md) | `skills/straitsx-sandbox-testing/SKILL.md` |

## Quick Lookup

| Keywords | Skill |
|---|---|
| endpoints, API, schema, payments, transfers, transactions, OpenAPI | `straitsx-api-overview` |
| auth, API key, credentials, environment variables, setup | `straitsx-auth-setup` |
| signing, Ed25519, signature, private key, HMAC, canonical string | `straitsx-request-signing` |
| webhook, callback, verify, public key, payload verification | `straitsx-webhook-verification` |
| FX, IDR, Indonesia, cross-border, currency conversion, XUSD, USD, payout, remittance, SWIFT BIC, bank transfer IDR | `straitsx-fx-payout-idr` |
| sandbox, testing, mock, simulate, walkthrough, integration test, end-to-end | `straitsx-sandbox-testing` |

## Shared Resources

These files are referenced by multiple skills:

| File | Purpose |
|---|---|
| `shared-references/openapi-spec.json` | OpenAPI 3.1.0 spec (v1.5.0) — single source of truth for endpoints, hand-maintained |
| `test-vectors/signing_vectors.json` | Ed25519 signing test vectors — shared by request-signing skill |
| `.env.example` | Environment variable template |
