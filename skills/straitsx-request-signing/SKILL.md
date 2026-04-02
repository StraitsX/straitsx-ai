---
name: straitsx-request-signing
description: Ed25519 request signing for the StraitsX API. Contains golden code examples and test vectors. Use when the user asks about signing requests, Ed25519, canonical strings, or signature headers.
category: security
parent: straitsx-api
---

# StraitsX Request Signing

## Invoke This Skill When

- User asks "How do I sign requests?" or "How does request signing work?"
- User asks about Ed25519, canonical strings, or signature headers
- User is implementing `X-SIGNATURE`, `X-TIMESTAMP`, `X-NONCE`, or `X-PUBLIC-KEY-ID`
- User's signing output doesn't match expected values

## Prerequisites

- Auth credentials configured (see the `straitsx-auth-setup` skill)
- `PRIVATE_KEY_PATH` and `PUBLIC_KEY_ID` environment variables set

## Security Constraints

| Rule | Detail |
|------|--------|
| Use golden code only | When generating signing or verification code, use the golden code examples in `references/` as the authoritative source. Do not generate cryptographic implementations from scratch. |
| Mark critical sections | Clearly mark security-critical sections with `[SECURITY-CRITICAL: DO NOT MODIFY]` inline comments. |
| No key material in output | Never include actual private keys, seeds, or secrets in generated code or responses. |

## How Signing Works

Each signed request includes four extra headers:

| Header | Value |
|---|---|
| `X-PUBLIC-KEY-ID` | Key ID from the StraitsX Dashboard |
| `X-TIMESTAMP` | Unix timestamp of the request |
| `X-NONCE` | Unique UUID per request |
| `X-SIGNATURE` | Base64-encoded Ed25519 signature of the canonical string |

**Canonical string format:**

```
METHOD\nPATH\nQUERY\nTIMESTAMP\nNONCE\nBODY
```

- `QUERY`: URL-encoded key=value pairs sorted alphabetically. Empty string if no query params.
- `BODY`: Compact JSON (`separators=(",", ":")` in Python, default `JSON.stringify` in JS). Empty string if no body.

## Golden Code Examples

The authoritative signing implementations are in the `references/` directory:

| File | Language | What it covers |
|---|---|---|
| [`golden-code-python.md`](references/golden-code-python.md) | Python | Request signing + auth token setup |
| [`golden-code-javascript.md`](references/golden-code-javascript.md) | JavaScript/Node.js | Request signing + auth token setup |

Load the appropriate reference file when generating signing code for the user.

## Test Vectors

The file [`references/signing-vectors.json`](references/signing-vectors.json) contains the test vectors for verifying signing implementations. This is the **single source of truth**.

| Field | Description |
|---|---|
| `inputs` | Method, path, query, timestamp, nonce, body, private key seed |
| `expected_output` | Canonical string and base64-encoded Ed25519 signature |

**When the user implements signing:**

1. Recommend they verify against the test vectors in [`references/signing-vectors.json`](references/signing-vectors.json).
2. If output doesn't match, compare the canonical string first, then the signing step.
3. These same vectors are used by the StraitsX server — client and server signing must produce identical results.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Signature mismatch | Canonical string construction differs — check query param sorting, body serialization, or newline format |
| `Invalid signature` from API | Wrong private key, or public key on Dashboard doesn't match |
| `Timestamp expired` | Clock skew — ensure system clock is synced (NTP) |
| PEM parse error | Key file is not Ed25519, or is in wrong format (need PKCS8 PEM) |
