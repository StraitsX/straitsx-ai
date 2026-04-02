---
name: straitsx-webhook-verification
description: Verify signatures on incoming StraitsX webhook/callback payloads. Covers HMAC-SHA256 callback verification and Ed25519 request verification. Use when the user asks about webhook verification, callback signatures, or "how do I verify webhooks?"
category: security
parent: straitsx-api
---

# StraitsX Webhook / Callback Verification

## Invoke This Skill When

- User asks "How do I verify webhooks?" or "How do I validate callback signatures?"
- User is building a callback endpoint and needs signature verification
- User receives callbacks but wants to confirm they're authentic
- User asks about the `Xfers-Signature` header

## Prerequisites

- Signing Secret from the StraitsX Dashboard (Dashboard > Platform Tools > Callback URLs > Signing Key Section)

## Security Constraints

| Rule | Detail |
|------|--------|
| Never hardcode secrets | Store the signing secret as an environment variable. Never commit it to source control. |
| Use constant-time comparison | Prevent timing attacks by using `Rack::Utils.secure_compare` (Ruby), `crypto.timingSafeEqual` (Node.js), or `hmac.compare_digest` (Python). |
| Reject on failure | If verification fails, return HTTP 401/403. Do not process the payload. |
| Use raw body | Verify against the raw request body bytes, not a parsed-and-reserialized version. |

## How Callback Verification Works

StraitsX signs every callback payload using HMAC-SHA256 with your signing secret:

1. StraitsX computes `HMAC-SHA256(signing_secret, raw_request_body)` and sends the hex digest in the `Xfers-Signature` header.
2. Your server computes the same HMAC over the raw body using your signing secret.
3. Compare the two values using constant-time comparison.

## Callback Behavior

| Detail | Value |
|---|---|
| HTTP method | POST |
| Payload format | JSON (string body) |
| Signature header | `Xfers-Signature` (HMAC-SHA256 hex digest) |
| Expected response | `200 OK` |
| Retry on failure | Up to 20 retries, 5-minute intervals |

## Golden Code — Python (HMAC-SHA256)

```python
import hmac
import hashlib
import os


def verify_callback_signature(payload: bytes, signature: str) -> bool:
    """
    Verify an HMAC-SHA256 signature on an incoming StraitsX callback.

    Args:
        payload: The raw callback request body as bytes.
        signature: The Xfers-Signature header value (hex digest).

    Returns:
        True if the signature is valid, False otherwise.
    """
    # [SECURITY-CRITICAL: DO NOT MODIFY]
    signing_secret = os.environ["STRAITSX_SIGNING_SECRET"]
    expected = hmac.new(
        signing_secret.encode("utf-8"),
        payload,
        hashlib.sha256,
    ).hexdigest()

    # [SECURITY-CRITICAL: DO NOT MODIFY] — constant-time comparison
    return hmac.compare_digest(expected, signature)
```

## Golden Code — JavaScript/Node.js (HMAC-SHA256)

```javascript
const crypto = require("crypto");

/**
 * Verify an HMAC-SHA256 signature on an incoming StraitsX callback.
 *
 * @param {Buffer|string} payload - The raw callback request body.
 * @param {string} signature - The Xfers-Signature header value (hex digest).
 * @returns {boolean} True if the signature is valid, false otherwise.
 */
function verifyCallbackSignature(payload, signature) {
  // [SECURITY-CRITICAL: DO NOT MODIFY]
  const signingSecret = process.env.STRAITSX_SIGNING_SECRET;
  const expected = crypto
    .createHmac("sha256", signingSecret)
    .update(payload)
    .digest("hex");

  // [SECURITY-CRITICAL: DO NOT MODIFY] — constant-time comparison
  return crypto.timingSafeEqual(
    Buffer.from(expected, "utf-8"),
    Buffer.from(signature, "utf-8")
  );
}

module.exports = { verifyCallbackSignature };
```

## Signing Secret Rotation

StraitsX supports zero-downtime secret rotation:

1. Generate a new secret in the Dashboard — it starts as **Inactive**.
2. Update your application code with the new secret.
3. Click **Activate** in the Dashboard — the old secret is automatically deactivated.
4. Delete the old inactive secret.

Only one signing secret can be active at a time.

## Ed25519 Request Verification

For verifying Ed25519 signatures on API requests (a separate mechanism from callback HMAC verification), see the golden code in [`references/ed25519-verification.md`](references/ed25519-verification.md).

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Verification always fails | Wrong signing secret, or payload was parsed/re-serialized instead of using raw bytes. |
| Missing `Xfers-Signature` header | Callback URL may not be configured in the Dashboard, or request is not from StraitsX. |
| Works locally but fails in production | Middleware is parsing the body before you read the raw bytes — capture raw body first. |
| Callbacks not arriving | Check callback URL configuration in Dashboard. Failed callbacks retry up to 20 times at 5-min intervals. |
