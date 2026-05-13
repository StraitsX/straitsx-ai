---
name: straitsx-fx-payout-idr
description: IDR FX Payout integration via the StraitsX API. Covers the full flow from recipient creation to FX quote to payout execution. Use when the user asks about sending IDR to Indonesia, FX payouts, cross-border payments to Indonesian bank accounts, or currency conversion payouts.
category: payout
parent: straitsx-api
---

# StraitsX IDR FX Payout

## Invoke This Skill When

- User asks "How do I send IDR to Indonesia?" or "How do I do an FX payout?"
- User asks about cross-border payouts, currency conversion payouts, or USD/XUSD → IDR
- User asks about FX quotes, FX rates, or locking exchange rates
- User asks about creating IDR payout recipients or Indonesian bank transfers
- User asks about the FX payout sandbox flow or testing FX payouts
- User mentions SWIFT BIC codes for Indonesian banks

## Prerequisites

- Auth credentials configured (see the `straitsx-auth-setup` skill)
- FX payout feature enabled on the merchant account (contact StraitsX team if you receive 403 `XFE6`)
- Sufficient balance in source currency wallet (XUSD or USD)

## How to Answer Questions

| Question type | What to do |
|---|---|
| Flow questions ("How does FX payout work?") | Load [`references/fx-payout-idr-reference.md`](references/fx-payout-idr-reference.md) and explain the 5-step flow: requirements → recipient → quote → payout → monitor. |
| Endpoint questions ("How do I create an FX quote?") | Load the reference file for exact endpoint paths, request/response schemas, and field requirements. |
| Recipient questions ("What banks are supported?") | Load the reference file for the supported Indonesian banks table and recipient field requirements. |
| Sandbox testing ("How do I test FX payouts?") | Load the reference file for sandbox simulation endpoints and testing checklist. |
| Error/troubleshooting questions | Load the reference file for the error scenarios and troubleshooting tables. |
| Webhook questions ("How do I get notified?") | Load the reference file for webhook configuration and payload structure. |
| Authentication questions | Redirect to the `straitsx-auth-setup` skill. |
| Webhook signature verification | Redirect to the `straitsx-webhook-verification` skill. |

**Important**: Always consult the reference file. Do not guess endpoint paths, field names, or response structures.

## Code Generation Rules

When generating FX payout code for the user:

1. **Always load the reference file** first for exact request/response schemas.
2. **Follow the 5-step flow** — always implement in order: requirements → recipient → quote → payout → status check.
3. **Handle quote expiry** — create the quote immediately before the payout call. Quotes expire in ~1 minute. Never cache quotes.
4. **Poll recipient verification** — after creating a recipient, poll `GET /v1/fx/payout-recipients/:id` until `verificationStatus` is `verified` or `not_required` before proceeding.
5. **Use sandbox base URL for testing**: `https://api-sandbox.straitsx.com/v1`
6. **Use production base URL for live**: `https://api.straitsx.com/v1`
7. **Include the API key header**: `X-XFERS-APP-API-KEY` from environment variable.
8. **Generate unique idempotency keys** — use UUID v4 for each payout.
9. **Add delays between requests** — 300ms minimum to respect rate limits.
10. **IDR amount validation** — ensure IDR amounts are integers with no decimal places.
11. **Security-critical code** — for request signing or webhook verification, defer to the `straitsx-request-signing` or `straitsx-webhook-verification` skills. Do not generate cryptographic code from scratch.

## Key Constraints

| Rule | Detail |
|------|--------|
| Quote validity | ~1 minute — create immediately before payout |
| IDR amounts | Whole numbers only (no decimals) |
| USD/XUSD amounts | Up to 2 decimal places |
| Specify one amount | Provide EITHER `from.amount` OR `to.amount` in the quote, not both |
| Idempotency | Each payout requires a unique `idempotencyId` |
| Recipient verification | Must be `verified` or `not_required` before creating a payout |
| Supported pairs | XUSD → IDR, USD → IDR (XSGD/SGD coming soon) |
| Tenor | `instant` only |

## References

Load on demand when the user's question requires detail:

| File | When to load |
|---|---|
| [`references/fx-payout-idr-reference.md`](references/fx-payout-idr-reference.md) | User asks about FX payout flow, endpoints, request/response schemas, recipient requirements, sandbox testing, webhooks, error handling, or troubleshooting |

For related skills:

| Skill | When to redirect |
|---|---|
| `straitsx-auth-setup` | User needs to configure API credentials |
| `straitsx-request-signing` | User needs to sign FX payout requests |
| `straitsx-webhook-verification` | User needs to verify FX payout webhook signatures |
| `straitsx-sandbox-testing` | User needs sandbox data setup (e.g., Customer Profile creation/verification, wallet topup) or a general sandbox walkthrough |
