---
name: straitsx-webhook-verification
description: Build a reliable StraitsX webhook/callback handler. Covers delivery mechanics, retry behavior, payload formats, HMAC-SHA256 signature verification, and best practices. Use when the user asks about webhooks, callbacks, signature verification, retry behavior, or "how do I handle callbacks?"
category: security
parent: straitsx-api
---

# StraitsX Webhook / Callback Integration

## Invoke This Skill When

- User asks "How do I verify webhooks?" or "How do I validate callback signatures?"
- User asks "How do webhook retries work?" or "Are callbacks guaranteed?"
- User asks "What does a callback payload look like?"
- User is building a callback endpoint and needs signature verification
- User receives callbacks but wants to confirm they're authentic
- User asks about the `Xfers-Signature` header
- User asks about callback delivery, retry schedule, or missed webhooks
- User asks about deduplication, ordering, or idempotent webhook handling

## Prerequisites

- Webhook URL configured (via `PATCH /webhooks` API or Dashboard > Platform Tools > Callback URLs)
- Signing Secret from the StraitsX Dashboard (Dashboard > Platform Tools > Callback URLs > Signing Key Section)
- Store signing secret as environment variable: `STRAITSX_SIGNING_SECRET`

## Security Constraints

| Rule | Detail |
|------|--------|
| Never hardcode secrets | Store the signing secret as an environment variable. Never commit it to source control. |
| Use constant-time comparison | Prevent timing attacks by using `Rack::Utils.secure_compare` (Ruby), `crypto.timingSafeEqual` (Node.js), or `hmac.compare_digest` (Python). |
| Reject on failure | If verification fails, return HTTP 401/403. Do not process the payload. |
| Use raw body | Verify against the raw request body bytes, not a parsed-and-reserialized version. |

---

## Delivery Mechanics

### How Callbacks Work

When a transaction or resource status changes, StraitsX sends an HTTP POST request to your registered webhook URL with the event payload.

| Detail | Value |
|---|---|
| HTTP method | POST |
| Timeout | 15 seconds — your server must respond within this window |
| Success criteria | Any 2xx HTTP status code (200, 201, 202, 204, etc.) |
| Signature header | `Xfers-Signature` (HMAC-SHA256 hex digest) |
| Content-Type | `application/json` (default) or `application/x-www-form-urlencoded` (legacy `query_string` format) |

### Retry Behavior

If delivery fails (timeout, non-2xx response, network error):

| Detail | Value |
|---|---|
| Max attempts | 20 |
| Retry schedule | Polynomial backoff — starts at ~3s, grows to minutes, then hours |
| Total retry window | Approximately 24–48 hours |
| After exhaustion | Event marked as `failed` — use resend API to recover |

Approximate schedule: attempt 2 at ~3s, attempt 3 at ~18s, attempt 4 at ~83s, attempt 5 at ~258s, and so on.

### Delivery Guarantees

| Guarantee | Detail |
|---|---|
| Delivery semantics | **At-least-once** — the same event may be delivered more than once |
| Ordering | **Not guaranteed** — callbacks may arrive out of chronological order |

---

## Callback Events

| Event | Fires when |
|---|---|
| `paymentStatusUpdated` | VBA/PayNow payment status changes |
| `payoutStatusUpdated` | Payout/withdrawal status changes |
| `cpVerificationStatusUpdated` | Customer profile verification status changes |
| `cpbaVerificationStatusUpdated` | CP bank account verification status changes |
| `cpbaCreated` | New CP bank account created |
| `virtualAccountStatusUpdated` | VBA is enabled/disabled |
| `userWithdrawalStatusUpdated` | User withdrawal status changes |
| `userDepositStatusUpdated` | User deposit status changes |
| `stablecoinWithdrawalStatusUpdated` | Blockchain withdrawal status changes |
| `stablecoinDepositStatusUpdated` | Blockchain deposit status changes |
| `swapUpdated` | Swap transaction status changes |
| `userFxPayoutStatusUpdated` | Direct FX payout status changes |
| `cpFxPayoutStatusUpdated` | CP FX payout (onBehalfOf) status changes |
| `cpTxnLimitsUpdated` | CP+ transaction limits change |
| `cpTxnLimitsUpdateRequestStatusUpdated` | CP+ limits update request status changes |
| `cpRfiStatusUpdated` | Request for Information (RFI) status changes |
| `ubaCreated` | New user bank account created |
| `ubaVerificationStatusUpdated` | User bank account verification status changes |

For full payload schemas and field descriptions per event type, see [`references/callback-payloads.md`](references/callback-payloads.md).

---

## Signature Verification

> See also: [Securing Your Callback](https://docs.straitsx.com/docs/securing-your-callback) (official guide with Ruby examples)

StraitsX signs every callback payload using HMAC-SHA256 with your signing secret:

1. StraitsX computes `HMAC-SHA256(signing_secret, raw_request_body)` and sends the hex digest in the `Xfers-Signature` header.
2. Your server computes the same HMAC over the raw body using your signing secret.
3. Compare the two values using constant-time comparison.

### Golden Code — Python (HMAC-SHA256)

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

### Golden Code — JavaScript/Node.js (HMAC-SHA256)

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

---

## Signing Secret Rotation

StraitsX supports zero-downtime secret rotation:

1. Generate a new secret in the Dashboard — it starts as **Inactive**.
2. Update your application code with the new secret.
3. Click **Activate** in the Dashboard — the old secret is automatically deactivated.
4. Delete the old inactive secret.

Only one signing secret can be active at a time.

---

## Configuring Webhook URLs

Register your callback URLs per event type:

**Via API:** [`PATCH /webhooks`](https://docs.straitsx.com/reference/update-webhooks)
```
PATCH /webhooks
Body:
{
  "data": {
    "attributes": {
      "paymentStatusUpdated": "https://your-server.com/webhooks/payment",
      "payoutStatusUpdated": "https://your-server.com/webhooks/payout"
    }
  }
}
```

**Via Dashboard:** Platform Tools → Callback URL

---

## Resending Callbacks

If a callback was missed or your listener was down:

**Single contract:** [`POST /webhooks/{contractId}/resend`](https://docs.straitsx.com/reference/resend-callback-for-a-single-contract)
```
POST /webhooks/{contractId}/resend
```

**Multiple contracts:** [`POST /webhooks/resend`](https://docs.straitsx.com/reference/resend-callback-for-a-list-of-contracts)
```
POST /webhooks/resend
Body: { "data": { "attributes": { "contractIds": ["contract_...", "contract_..."] } } }
```

**By event type:** [`POST /webhook-events/{event_type}/resend/{triggerable_id}`](https://docs.straitsx.com/reference/resend-webhook-by-event-type)
```
POST /webhook-events/{event_type}/resend/{triggerable_id}
```

---

## Best Practices

1. **Return 2xx quickly** — Acknowledge receipt immediately, then process asynchronously in a background job. The 15-second timeout is generous but don't rely on it.

2. **Idempotent handling** — Use the `id` field in the payload to deduplicate. Store processed callback IDs and skip duplicates.

3. **Don't rely on ordering** — Always check the `status` field against your local state. Ignore callbacks that would move your state backwards (e.g., receiving `pending` after you've already processed `completed`).

4. **Verify signatures** — Always verify the `Xfers-Signature` header in production. Reject unsigned or incorrectly signed requests.

5. **Use webhooks + polling** — Use webhooks as the primary notification mechanism. Implement periodic polling as a fallback for missed callbacks.

6. **Monitor delivery** — Check the StraitsX Dashboard for failed webhook deliveries. Use the resend API to recover missed events.

---

## Ed25519 Request Verification

For verifying Ed25519 signatures on API requests (a separate mechanism from callback HMAC verification), see the golden code in [`references/ed25519-verification.md`](references/ed25519-verification.md).

---

## References

Load these on demand when the user needs deeper detail:

| File | When to load |
|---|---|
| [`references/callback-payloads.md`](references/callback-payloads.md) | User asks "what does the callback payload look like?" or needs field-level details for a specific event type |
| [`references/ed25519-verification.md`](references/ed25519-verification.md) | User needs Ed25519 signature verification (separate from HMAC callback verification) |
| [`references/dashboard-get-signing-secret.md`](references/dashboard-get-signing-secret.md) | User asks how to find/reveal the signing secret in the Dashboard |
| [`references/dashboard-register-callback-url.md`](references/dashboard-register-callback-url.md) | User asks how to configure webhook URLs in the Dashboard |
| [`references/dashboard-trigger-callback-resend.md`](references/dashboard-trigger-callback-resend.md) | User asks how to resend a callback or check delivery history in the Dashboard |

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Verification always fails | Wrong signing secret, or payload was parsed/re-serialized instead of using raw bytes. |
| Missing `Xfers-Signature` header | Callback URL may not be configured in the Dashboard, or request is not from StraitsX. |
| Works locally but fails in production | Middleware is parsing the body before you read the raw bytes — capture raw body first. |
| Callbacks not arriving | Check callback URL configuration in Dashboard. Ensure your endpoint is publicly accessible. If your server uses IP whitelisting, ensure StraitsX [source IP addresses](https://docs.straitsx.com/docs/source-ip-addresses) are whitelisted. |
| Receiving duplicate callbacks | Expected behavior (at-least-once delivery). Implement deduplication using the `id` field. |
| Callbacks arriving out of order | Expected behavior. Compare `status` in payload against your local state before processing. |
| `failed` webhook status in Dashboard | Your endpoint returned non-2xx or timed out (>15s). Check server logs. Use resend API to retry. |