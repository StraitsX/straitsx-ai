---
name: straitsx-api-overview
description: Look up StraitsX API endpoints, generate code from the OpenAPI spec, and answer documentation questions. Use when the user asks about available endpoints, request/response schemas, or API capabilities.
category: reference
parent: straitsx-api
---

# StraitsX API Overview

## Invoke This Skill When

- User asks "What endpoints are available?" or "What can I do with this API?"
- User asks about a specific endpoint (e.g., "How do I create a payment?")
- User asks about request/response schemas, parameters, or field types
- User asks you to generate code for an API call

## Spec Reference

- **OpenAPI Spec**: [`references/openapi-spec.json`](references/openapi-spec.json) — the StraitsX OpenAPI spec (v1.4.0, OpenAPI 3.1.0, JSON format). Load this file when you need to look up endpoints, schemas, or parameters.
- **API Version**: 1.4.0
- **Servers**: Sandbox (`https://api-sandbox.straitsx.com/v1`), Production (`https://api.straitsx.com/v1`)

## How to Answer Questions

| Question type | What to do |
|---|---|
| Endpoint questions ("How do I create a payment?") | Look up the endpoint in the OpenAPI spec. Return path, HTTP method, description, parameters, request body schema, and response schema. Include example payloads where available. |
| Parameter questions ("What params does transfer accept?") | Return the full parameter list with names, types, locations (path/query/header/body), required/optional status, and descriptions. |
| Schema questions ("What does the payment response look like?") | Return the response schema with field names, types, and descriptions. |
| Authentication questions | Redirect to the `straitsx-auth-setup` skill. |
| No match found | Suggest related endpoints or topics. For example, if they ask about "refunds" and there is no refund endpoint, suggest the payments or transactions endpoints. |

**Important**: Always consult the spec. Do not guess or hallucinate endpoint details.

## Code Generation Rules

When generating code for an API endpoint:

1. **Always look up the endpoint** in the OpenAPI spec first. Use the correct path, HTTP method, parameters, and schemas.
2. **Supported languages**: Python, JavaScript/TypeScript, Go, cURL.
3. **Required headers** — always include:
   - `X-XFERS-APP-API-KEY` — loaded from the `X_XFERS_APP_API_KEY` environment variable.
   - `Content-Type: application/json` — for requests with a JSON body.
4. **Optional signing headers** — include only when the user has chosen HTTP Request Signing (see the `straitsx-request-signing` skill):
   - `X-PUBLIC-KEY-ID`, `X-TIMESTAMP`, `X-NONCE`, `X-SIGNATURE`
5. **Request body**: Structure according to the OpenAPI spec schema.
6. **Error handling**: Always include error handling that checks HTTP status and parses error response bodies.
7. **Security-critical code**: For request signing or webhook verification, defer to the `straitsx-request-signing` or `straitsx-webhook-verification` skills. Do not generate cryptographic code from scratch.

## References

Load these on demand when the user's question requires deeper detail:

| File | When to load |
|---|---|
| [`references/openapi-spec.json`](references/openapi-spec.json) | User asks about endpoints, parameters, schemas, or you need to generate code for an API call |
| [`references/error-codes.md`](references/error-codes.md) | User asks about error handling, error codes, or debugging API responses |
| [`references/transaction-safety.md`](references/transaction-safety.md) | User asks about idempotency, transaction status, retries, or safe payout handling |
| [`references/faqs.md`](references/faqs.md) | User asks about capabilities, limits, supported currencies, swap pairs, customer profiles, bank accounts, or domain-specific behavior |
