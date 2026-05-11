# FX Payout (IDR) — Merchant Integration Guide

## Overview

FX Payout allows you to send Indonesian Rupiah (IDR) to bank accounts in Indonesia using your XUSD or USD balance. The system handles the foreign exchange conversion automatically — you lock in a rate via a quote, then execute the payout at that guaranteed rate.

**Use cases:**
- Pay suppliers or partners in Indonesia in their local currency
- Disburse funds to Indonesian bank accounts on behalf of your customers
- Settle cross-border obligations without managing FX manually

### Payout Modes

FX Payout supports two modes depending on who the payout is initiated for:

| Mode | When to Use | How |
|------|-------------|-----|
| **Direct (self mode)** | Payout from your own account | Omit the `initiator` object in API requests |
| **On behalf of a Customer Profile** | Payout on behalf of your end customer | Include `initiator` with `mode: "onBehalfOf"` and `customerProfileId` |

**On behalf of (Customer Profile) mode:**
- Requires a Customer Profile to be created first via the Customer Profile API
- The Customer Profile must be in `verified` status
- Recipients and payouts are scoped to the specified Customer Profile
- Webhook callbacks are sent to the `cpFxPayoutStatusUpdated` URL

**Direct (self) mode:**
- No Customer Profile needed — payouts are executed directly under your merchant account
- Recipients and payouts are scoped to your account
- Webhook callbacks are sent to the `userFxPayoutStatusUpdated` URL

---

## 1. End-to-End Flow

```
Step 1                Step 2                Step 3             Step 4              Step 5
  │                     │                     │                  │                   │
  ▼                     ▼                     ▼                  ▼                   ▼
┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
│Get Recip.│      │ Create   │      │ Create   │      │ Create   │      │ Monitor  │
│Requirem. │─────▶│Recipient │─────▶│ FX Quote │─────▶│ FX Payout│─────▶│  Status  │
└──────────┘      └──────────┘      └──────────┘      └──────────┘      └──────────┘
GET /v1/fx/       POST /v1/fx/      POST /v1/fx/      POST /v1/fx/      GET /v1/fx/
payout-recipients payout-recipients quotes            payouts           payouts/:id
/requirements
```

**Step-by-step:**

1. **Get Payout Recipient Requirements** — discover required fields and validation rules for IDR bank transfer
2. **Create Payout Recipient** — register an IDR bank account (bank verification happens automatically)
3. **Create FX Quote** — lock a rate for ~1 minute (do this after recipient is verified)
4. **Create FX Payout** — submit payout linking the quote and recipient
5. **Monitor Status** — poll `GET /v1/fx/payouts/:id` or receive webhook callback

> **Important:** Create the recipient first (steps 1–2) since bank verification takes time. Only create the quote (step 3) when you're ready to execute the payout, as quotes expire in ~1 minute.

**Prerequisites:**
- Merchant account with FX payout feature enabled. If you receive a 403 error with code `XFE6` ("Access to this endpoint is denied"), contact the StraitsX team to enable FX payout access for your account.
- Sufficient balance in source currency wallet (XUSD or USD)
- Recipient bank account verification must complete before creating a payout (verification is triggered automatically when you create a recipient — poll the recipient's `verificationStatus` until it becomes `verified` or `not_required`)

---

## 2. API Endpoints

### 2.1 Get Recipient Requirements

```
GET /v1/fx/payout-recipients/requirements?filter[recipientCountry]=ID&filter[currency]=IDR&filter[disbursementMethod]=bankTransfer&filter[entityType]=individual
```

Returns required fields and validation patterns for creating an IDR bank transfer recipient.

**Required query parameters:**
- `filter[recipientCountry]` — ISO 3166 alpha-2 code (e.g., `ID`)
- `filter[currency]` — `IDR`
- `filter[disbursementMethod]` — `bankTransfer`
- `filter[entityType]` — `individual` or `business`

---

### 2.2 Create Payout Recipient

```
POST /v1/fx/payout-recipients
```

**Request:**
```json
{
  "data": {
    "attributes": {
      "recipientCountry": "ID",
      "recipientInformation": {
        "disbursementMethod": "bankTransfer",
        "entityType": "individual",
        "recipientName": "John Doe",
        "currency": "IDR",
        "bankAccountNo": "1234567890",
        "swiftBic": "CENAIDJA",
        "bankAccountProofUrl": "https://example.com/proof.jpg"
      }
    }
  }
}
```

**With Customer Profile (onBehalfOf):**
```json
{
  "data": {
    "attributes": {
      "initiator": {
        "mode": "onBehalfOf",
        "customerProfileId": "customer_profile_<uuid>"
      },
      "recipientCountry": "ID",
      "recipientInformation": { ... }
    }
  }
}
```

**Required fields for IDR bankTransfer:**

| Field | Description |
|-------|-------------|
| `recipientCountry` | ISO 3166 alpha-2 (e.g., `ID`) |
| `recipientInformation.disbursementMethod` | Must be `bankTransfer` |
| `recipientInformation.entityType` | `individual` or `business` |
| `recipientInformation.recipientName` | Max 255 characters |
| `recipientInformation.currency` | `IDR` |
| `recipientInformation.bankAccountNo` | 5–34 alphanumeric characters |
| `recipientInformation.swiftBic` | Valid SWIFT BIC from supported bank list |
| `recipientInformation.bankAccountProofUrl` | Valid HTTP URL (proof of bank account) |

**Response:**
```json
{
  "data": {
    "id": "payout_recipient_<uuid>",
    "type": "fxPayoutRecipient",
    "attributes": {
      "verificationStatus": "pending",
      "recipientCountry": "ID",
      "recipientInformation": {
        "disbursementMethod": "bankTransfer",
        "entityType": "individual",
        "recipientName": "John Doe",
        "currency": "IDR",
        "bankAccountNo": "1234567890",
        "bankShortCode": "014",
        "swiftBic": "CENAIDJA",
        "bankName": "Bank Central Asia"
      },
      "createdAt": "...",
      "updatedAt": "..."
    }
  }
}
```

**Verification statuses:**

| Status | Meaning |
|--------|---------|
| `pending` | Verification in progress (triggered automatically on recipient creation) |
| `verified` | Bank account confirmed valid — ready for payouts |
| `rejected` | Bank account invalid — create a new recipient with correct details |
| `not_required` | Verification skipped (depends on merchant account configuration) |

> **Note:** Verification is triggered automatically when you create a recipient. It typically completes within a few seconds to a minute. Poll `GET /v1/fx/payout-recipients/:id` to check `verificationStatus` before creating a payout.

---

### 2.3 Create FX Quote

```
POST /v1/fx/quotes
```

**Request:**
```json
{
  "data": {
    "attributes": {
      "from": { "currency": "XUSD" },
      "to": { "currency": "IDR", "amount": "1500000" },
      "tenor": "instant"
    }
  }
}
```

**Rules:**
- Provide EITHER `from.amount` OR `to.amount`, not both
- IDR amounts must be whole numbers (no decimals)
- USD/XUSD allow up to 2 decimal places
- Amount must be positive

**Response:**
```json
{
  "data": {
    "id": "fx_quote_<uuid>",
    "type": "fxQuote",
    "attributes": {
      "rate": "16234.50000000",
      "from": { "currency": "XUSD", "amount": "92.40" },
      "to": { "currency": "IDR", "amount": "1500000" },
      "tenor": "instant",
      "createdAt": "2026-05-08T10:00:00+08:00",
      "expiresAt": "2026-05-08T10:02:00+08:00"
    }
  }
}
```

**Supported currency pairs:**

| Source | Target | Status |
|--------|--------|--------|
| XUSD | IDR | Available |
| USD | IDR | Available |
| XSGD | IDR | Coming soon |
| SGD | IDR | Coming soon |

**Tenor:** `instant` only

**Quote validity:** ~1 minute from creation (determined by the FX rate provider). After expiry, a new quote must be requested.

---

### 2.4 Create FX Payout

```
POST /v1/fx/payouts
```

**Request:**
```json
{
  "data": {
    "attributes": {
      "payoutDetails": {
        "idempotencyId": "payout-unique-key-123",
        "payoutType": "fxPayout",
        "recipientId": "payout_recipient_<uuid>",
        "fxQuoteId": "fx_quote_<uuid>",
        "reference": {
          "internalReference": "INV-2026-001",
          "externalReference": "optional-external-ref"
        }
      }
    }
  }
}
```

**With Customer Profile:**
```json
{
  "data": {
    "attributes": {
      "initiator": {
        "mode": "onBehalfOf",
        "customerProfileId": "customer_profile_<uuid>"
      },
      "payoutDetails": { ... }
    }
  }
}
```

**Required fields:**

| Field | Description |
|-------|-------------|
| `payoutDetails.payoutType` | Must be `"fxPayout"` |
| `payoutDetails.recipientId` | ID of a verified recipient |
| `payoutDetails.fxQuoteId` | ID of an unexpired, unused quote |
| `payoutDetails.idempotencyId` | Unique key to prevent duplicate payouts |

**Optional fields:**

| Field | Description |
|-------|-------------|
| `payoutDetails.reference.internalReference` | Your internal reference (e.g., invoice number) |
| `payoutDetails.reference.externalReference` | Additional external reference |

**Response:**
```json
{
  "data": {
    "id": "contract_<uuid>",
    "type": "fxPayout",
    "attributes": {
      "status": "pending",
      "quoteId": "fx_quote_<uuid>",
      "recipientId": "payout_recipient_<uuid>",
      "rate": "16234.50000000",
      "from": { "currency": "XUSD", "amount": "92.40" },
      "to": { "currency": "IDR", "amount": "1500000" },
      "fee": { "currency": "XUSD", "amount": "0.00" },
      "references": {
        "externalReference": null,
        "internalReference": "INV-2026-001"
      },
      "createdAt": "...",
      "updatedAt": "..."
    }
  }
}
```

---

### 2.5 Get Payout Status

```
GET /v1/fx/payouts/:id
GET /v1/fx/payouts              (list with filters)
```

**List query parameters:**

| Parameter | Description |
|-----------|-------------|
| `page[number]` | Page number |
| `page[size]` | Results per page |
| `status` | Filter by status: `pending`, `completed`, `failed` |
| `sort` | e.g., `createdAt:desc` |
| `from` | Start date (ISO 8601) |
| `to` | End date (ISO 8601) |
| `payoutId` | Filter by specific payout ID |
| `initiator[mode]` | `onBehalfOf` |
| `initiator[customerProfileId]` | Filter by customer profile |

---

## 3. Payout Statuses

| Status | Description |
|--------|-------------|
| `pending` | Payout is being processed (FX conversion, compliance checks, disbursement) |
| `completed` | Funds successfully disbursed to recipient bank account |
| `failed` | Payout cancelled — funds returned to source wallet |

Payouts are terminal once `completed` or `failed`. No further status changes occur.

---

## 4. Reversal & Rejection Handling

When a payout that was already in `pending` status gets rejected or reversed (e.g., bank rejection, compliance review failure, or disbursement failure), the following happens:

**What the merchant sees:**
- Payout status transitions from `pending` → `failed`
- A webhook is sent with the full payout payload showing `"status": "failed"`

**Fund return:**
- Funds are always returned to your source wallet in the **original source currency** (XUSD or USD)
- You will never receive an IDR deposit — the reversal is always in the currency you originally debited

**Failure reason:**
- The webhook payload does not include a specific `failureReason` field. The payout simply transitions to `failed` status.
- From the merchant's perspective, there is no distinction between an initial rejection and a later reversal — both result in `"status": "failed"` with funds returned.
- If you need details on why a specific payout failed, contact the StraitsX team with the payout ID.

**How to retry:**
- The original recipient can be reused (no need to create a new one), as long as its `verificationStatus` is still `verified`
- You must create a **new quote** (the original quote was already consumed)
- Submit a new payout with a **new `idempotencyId`**, the existing `recipientId`, and the new `fxQuoteId`

---

## 5. Response Format & Types

### `data.type` Values

Each endpoint returns a specific `data.type` value in the JSON:API response:

| Endpoint | `data.type` | `data.id` format |
|----------|-------------|------------------|
| `GET /v1/fx/payout-recipients/requirements` | _(no type — returns raw JSON object)_ | _(no id)_ |
| `POST /v1/fx/payout-recipients` | `fxPayoutRecipient` | `payout_recipient_<uuid>` |
| `GET /v1/fx/payout-recipients/:id` | `fxPayoutRecipient` | `payout_recipient_<uuid>` |
| `POST /v1/fx/quotes` | `fxQuote` | `fx_quote_<uuid>` |
| `GET /v1/fx/quotes/:id` | `fxQuote` | `fx_quote_<uuid>` |
| `POST /v1/fx/payouts` | `fxPayout` | `contract_<uuid>` |
| `GET /v1/fx/payouts/:id` | `fxPayout` | `contract_<uuid>` |
| `GET /v1/fx/payouts` (list) | `fxPayout` (array) | `contract_<uuid>` |

> **Note:** The requirements endpoint returns a plain `{ "data": { ... } }` object without `type` or `id` fields — it's not a JSON:API resource, just a schema description.

---

## 6. Response Chain Map

The following diagram shows how IDs from each step feed into the next:

```
Step 1: Get Requirements
  └── Returns: field validation rules (no IDs to chain)

Step 2: Create Recipient
  └── Returns: data.id = "payout_recipient_<uuid>"
                    │
                    ▼
Step 3: Create Quote
  └── Returns: data.id = "fx_quote_<uuid>"
                    │
                    ▼
Step 4: Create Payout
  └── Uses:
        • data.attributes.payoutDetails.recipientId  ← data.id from Step 2
        • data.attributes.payoutDetails.fxQuoteId    ← data.id from Step 3
        • data.attributes.payoutDetails.idempotencyId ← your unique key
```

**Field mapping detail:**

| Source Step | Source Field | Target Step | Target Field |
|------------|-------------|-------------|--------------|
| Create Recipient | `response.data.id` | Create Payout | `request.data.attributes.payoutDetails.recipientId` |
| Create Quote | `response.data.id` | Create Payout | `request.data.attributes.payoutDetails.fxQuoteId` |
| _(your system)_ | unique key | Create Payout | `request.data.attributes.payoutDetails.idempotencyId` |
| _(optional)_ Create Customer Profile | `response.data.id` | Create Recipient / Create Payout | `request.data.attributes.initiator.customerProfileId` |

**Notes:**
- The requirements endpoint (Step 1) does not return any IDs — it only provides field validation rules to help you construct the recipient creation request correctly
- The `recipientId` and `fxQuoteId` must be passed as the full string including the prefix (e.g., `payout_recipient_<uuid>`, `fx_quote_<uuid>`)
- If using Customer Profile mode, the same `customerProfileId` should be passed consistently across recipient creation and payout creation

---

## 7. IDR-Specific Requirements

### Supported Indonesian Banks

IDR payouts support 130+ Indonesian banks identified by SWIFT BIC code. Common banks:

| SWIFT BIC | Bank Name |
|-----------|-----------|
| CENAIDJA | Bank Central Asia (BCA) |
| BMRIIDJA | Bank Mandiri |
| BRINIDJA | Bank Rakyat Indonesia (BRI) |
| BNINIDJA | BNI (Bank Negara Indonesia) |
| BSMDIDJA | BSI (Bank Syariah Indonesia) |
| DBSBIDJA | DBS Indonesia |
| BNIAIDJA | CIMB Niaga |
| NISPIDJA | Bank OCBC NISP |
| BBIJIDJA | TMRW/UOB |
| BBBAIDJA | Permata |
| BTANIDJA | BTN |
| BDINIDJA | Bank Danamon |
| IBBKIDJA | Maybank Indonesia |
| MEGAIDJA | Bank Mega |
| SSPIIDJA | Seabank |
| BBLUIDJA | Blu/BCA Digital |
| PDJBIDJA | BJB |
| BBUKIDJA | Bank Bukopin |
| SCBLIDJX | Standard Chartered |
| HSBCIDJA | HSBC Indonesia |

Use the table above as a reference for common banks. An unsupported SWIFT BIC will return an error when creating the recipient.

### Amount Rules

- IDR amounts: **whole numbers only** (no decimal places)
- USD/XUSD amounts: up to 2 decimal places

### Bank Account Validation

- Account number: 5–34 alphanumeric characters
- Bank account proof URL required (image/document proving account ownership)
- Automatic verification confirms account exists and returns the registered account holder name

---

## 8. Error Scenarios

### Common Errors

| Error | HTTP | Description | Resolution |
|-------|------|-------------|------------|
| Unsupported currency pair | 400 | Invalid source or target currency | Use supported pairs (XUSD/USD → IDR) |
| Invalid amount | 400 | Zero, negative, or wrong decimal places | IDR must be whole numbers; USD/XUSD up to 2 decimals |
| Must provide one amount | 400 | Both or neither from/to amount specified | Provide exactly one of `from.amount` or `to.amount` |
| Quote expired | 400 | Quote has expired (~1 minute window) | Create a new quote |
| Quote already executed | 400 | Quote already used for a payout | Create a new quote |
| Recipient not found | 404 | Invalid recipient ID | Check recipient ID is correct |
| Bank account pending | 400 | Recipient verification not yet complete | Wait for verification to complete, then retry |
| Bank account rejected | 400 | Bank account verification failed | Create a new recipient with valid details |
| Invalid SWIFT BIC | 400 | SWIFT BIC not in supported bank list | Use a supported Indonesian bank SWIFT BIC |
| Insufficient balance | 400 | Wallet balance too low | Top up source currency wallet |
| Idempotency key repeated | 422 | Duplicate `idempotencyId` | Use a unique idempotency key per payout |
| FX service unavailable | 424 | Temporary service issue | Retry after a short delay |

### Rate Expiry During Processing

If the FX rate cannot be executed (e.g., service temporarily unavailable), the payout automatically transitions to `failed` and all funds are returned to your wallet. You'll receive a webhook notification and can retry with a new quote.

### Idempotency Behavior

- Each payout requires a unique `idempotencyId`
- Submitting the same `idempotencyId` twice returns a 422 error (not a duplicate payout)
- Safe to retry on network timeouts — if the first request succeeded, you'll get the 422 indicating no duplicate was created

---

## 9. Sandbox Testing

### Simulating Payout Status

In sandbox, use this endpoint to simulate payout completion or failure:

```
PUT /v1/sandbox/fx/payouts/:id
```

**Simulate success:**
```json
{
  "data": {
    "attributes": {
      "status": "completed"
    }
  }
}
```

**Simulate failure:**
```json
{
  "data": {
    "attributes": {
      "status": "cancelled"
    }
  }
}
```

### Sandbox Merchant Topup

Fund your sandbox wallet for testing:

```
POST /v1/sandbox/merchant/topup
```

```json
{
  "data": {
    "attributes": {
      "currency": "USD",
      "amount": "10000.00"
    }
  }
}
```

Supported currencies for topup: `SGD`, `USD`. Amount must be a positive number with up to 2 decimal places.

> **Note:** For FX Payout testing with XUSD as source currency, top up USD first, then swap to XUSD if needed. See the [Sandbox Top up account balance](https://docs.straitsx.com/reference/topup-merchant-account-sandbox) API reference for full details.

### Testing Checklist

- ✅ Create quotes with different source currencies (XUSD, USD)
- ✅ Create recipients with various Indonesian banks
- ✅ Verify recipient verification status transitions (pending → verified)
- ✅ Create payouts and simulate completion/failure
- ✅ Test webhook delivery for status changes
- ✅ Test idempotency by submitting duplicate `idempotencyId`
- ✅ Test error cases (expired quote, unverified recipient, insufficient balance)

---

## 10. Webhook Events

### Configuring Webhooks

Set your callback URLs via:

```
PUT /v1/webhooks
```

Relevant fields:
- `userFxPayoutStatusUpdated` — receives callbacks for direct user payouts
- `cpFxPayoutStatusUpdated` — receives callbacks for customer profile (onBehalfOf) payouts

### Event Types

Webhooks are sent when a payout status changes. The merchant receives the full payout object (same as `GET /v1/fx/payouts/:id` response) at the configured URL.

You can determine the event type by checking the `status` field in the payload:
- `"status": "pending"` — payout created and processing started
- `"status": "completed"` — payout successfully disbursed
- `"status": "failed"` — payout cancelled, funds returned

### Webhook Payload

Same structure as `GET /v1/fx/payouts/:id` response:

```json
{
  "data": {
    "id": "contract_<uuid>",
    "type": "fxPayout",
    "attributes": {
      "status": "completed",
      "quoteId": "fx_quote_<uuid>",
      "recipientId": "payout_recipient_<uuid>",
      "rate": "16234.50000000",
      "from": { "currency": "XUSD", "amount": "92.40" },
      "to": { "currency": "IDR", "amount": "1500000" },
      "fee": { "currency": "XUSD", "amount": "0.00" },
      "initiator": {
        "mode": "onBehalfOf",
        "customerProfileId": "customer_profile_<uuid>"
      },
      "references": {
        "externalReference": null,
        "internalReference": "INV-2026-001"
      },
      "createdAt": "2026-05-08T10:00:00+08:00",
      "updatedAt": "2026-05-08T10:05:00+08:00"
    }
  }
}
```

### When Webhooks Fire

- Payout enters `pending` (processing started)
- Payout reaches `completed` (disbursement confirmed)
- Payout reaches `failed` (cancelled for any reason — funds returned)

---

## 11. Troubleshooting

| Symptom | Cause | What You See | Resolution |
|---------|-------|--------------|------------|
| **Quote expired error on payout creation** | Quote was created too early or took too long to submit payout | HTTP 400: "The quote has expired. Please request a new quote." | Create a new quote immediately before calling Create Payout. Quotes are valid for ~1 minute only. |
| **Insufficient balance error on payout creation** | Source wallet (XUSD/USD) doesn't have enough funds to cover the payout amount + fees | HTTP 400: "Insufficient balance" | Top up your source currency wallet. The required balance = quote source amount + any applicable fees. Use `POST /v1/sandbox/merchant/topup` in sandbox. |
| **Payout stuck in `pending` for extended time** | Compliance review triggered — the payout is under manual review by the StraitsX compliance team | Payout status remains `pending` in GET response and no webhook received | No action required from your side. The payout will either complete or fail once the review is done. If it remains pending for more than 24 hours, contact the StraitsX team. |
| **Payout transitions to `failed` after being `pending`** | Disbursement rejected by the receiving bank or payment provider (e.g., invalid account, bank maintenance, compliance rejection) | Webhook received with `"status": "failed"`. Funds returned to your source wallet. | Check the recipient's bank account details are correct. Create a new recipient if needed, then retry with a new quote and payout. |
| **FX service unavailable (424)** | Temporary issue with the FX rate provider | HTTP 424 at payout creation, or payout transitions to `failed` shortly after creation | Retry after a short delay (30–60 seconds). If persistent, contact the StraitsX team. |
| **Bank account verification stays `pending`** | The bank inquiry service is temporarily unavailable or the account details couldn't be verified automatically | Recipient `verificationStatus` remains `pending` | Wait a few minutes and poll again. If still pending after 10 minutes, the account may require manual review — contact the StraitsX team. |
| **Bank account verification `rejected`** | The bank account number doesn't exist or doesn't match the provided SWIFT BIC | Recipient `verificationStatus` = `rejected` | Create a new recipient with the correct bank account number and SWIFT BIC. Verify the account details with the beneficiary. |

### When to Contact StraitsX Support

- Payout stuck in `pending` for more than 24 hours
- Repeated `failed` payouts with no clear cause
- Bank account verification stuck in `pending` for more than 10 minutes
- 403 errors (`XFE6`) indicating your account doesn't have FX payout access
- Any 5xx errors that persist after retrying

---

## 12. Quick Reference

### Authentication

All endpoints require the `X-XFERS-APP-API-KEY` header.

### Base URLs

| Environment | URL |
|-------------|-----|
| Sandbox | `https://api-sandbox.straitsx.com` |
| Production | `https://api.straitsx.com` |

### Error Response Format

All FX Payout API errors follow this JSON structure:

```json
{
  "errors": [
    {
      "error": "The quote has expired. Please request a new quote.",
      "error_code": "XFE_CONDITIONS_NOT_MET",
      "error_handling": "The quote has expired. Please request a new quote."
    }
  ]
}
```

| Field | Description |
|-------|-------------|
| `error` | Human-readable error message describing what went wrong |
| `error_code` | Machine-readable error code for programmatic handling |
| `error_handling` | Suggested resolution or next step for the user |

**HTTP status codes used:**

| HTTP Status | Meaning |
|-------------|---------|
| 400 | Bad request — invalid parameters, validation failure, or business rule violation |
| 401 | Unauthorized — missing or invalid API key |
| 403 | Forbidden — account not authorized for this endpoint (e.g., `XFE6`) |
| 404 | Not found — resource doesn't exist |
| 422 | Unprocessable — duplicate record (e.g., repeated idempotency key) |
| 424 | Failed dependency — external service temporarily unavailable |

### Polling & Retry Guidance

Use webhooks as the primary notification mechanism for payout status changes. Use polling (`GET /v1/fx/payouts/:id`) as a fallback for missed webhooks.

For recipient verification, poll `GET /v1/fx/payout-recipients/:id` until `verificationStatus` transitions to `verified`, `rejected`, or `not_required`.

### Concurrent Quotes

You can have multiple active (unexpired) quotes at the same time. Creating a new quote does not invalidate previous ones. Each quote is independent and can be used for a separate payout as long as it hasn't expired or been executed.

### Webhook Signature Verification

Each webhook request includes an `Xfers-Signature` header containing an HMAC-SHA256 signature of the request body. To verify:

1. Get your webhook signing secret from the StraitsX dashboard
2. Compute HMAC-SHA256 of the raw request body using your signing secret
3. Compare the computed signature with the `Xfers-Signature` header value

```python
# Python example
import hmac
import hashlib

def verify_webhook(payload_body, signature_header, signing_secret):
    computed = hmac.new(
        signing_secret.encode(),
        payload_body.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(computed, signature_header)
```

```javascript
// Node.js example
const crypto = require('crypto');

function verifyWebhook(payloadBody, signatureHeader, signingSecret) {
  const computed = crypto
    .createHmac('sha256', signingSecret)
    .update(payloadBody)
    .digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(computed),
    Buffer.from(signatureHeader)
  );
}
```

For more details, see [Securing Your Callback](https://docs.straitsx.com/v1.5.0/docs/securing-your-callback).

### Rate Limits

Standard API rate limits apply. See general API documentation for details.

### Typical Integration Timeline

1. **Day 1:** Set up sandbox credentials, configure webhook URLs
2. **Day 1–2:** Implement recipient requirements → create recipient → create quote → create payout flow
3. **Day 2–3:** Handle webhook callbacks, implement status polling as fallback
4. **Day 3–4:** Test error scenarios, idempotency, edge cases
5. **Day 5:** Production readiness review
