# Payment & Payout Lifecycle Reference

> Merchant-facing reference for payment and payout status transitions, refund/reversal scenarios, and reconciliation guidance.

---

## 1. Payment Lifecycle (Incoming Funds)

Payments represent incoming funds via Virtual Bank Account (VBA) or PayNow.

### Status Transitions

```
pending → completed          (normal flow — funds received and credited)
pending → completed          (blocked → RFI resolved → compliance passed → completed)
pending → refunded           (blocked → RFI failed / screening rejected → refunded)
pending → expired            (PayNow QR code expired without payment)
```

> **Note on `blocked_reasons`**: When a payment is blocked (e.g., name mismatch), the status remains `"pending"` but the callback includes a `blocked_reasons` array with the relevant code. The payment can still proceed to `completed` if the block is resolved.

> **Note on `failed` status**: If you poll the API between a compliance block and the refund being processed, you may briefly observe `"status": "failed"`. This is a transient state — the payment will subsequently move to `refunded` once the bank return is completed. The webhook callback fires when the final `refunded` status is reached.

### Terminal States

| Status | Terminal? | Description |
|--------|-----------|-------------|
| `completed` | Yes | Funds credited to your balance. Terminal state. |
| `refunded` | Yes | Funds returned to sender. No further transitions. |
| `failed` | Transient | Payment was cancelled. Typically transitions to `refunded` once bank return completes. |
| `expired` | Yes | PayNow payment window expired. No funds received. |

### Key Behaviors

- **`completed` IS terminal** — once a payment reaches `completed`, it does not transition to another status via the API. If a post-completion return is required (e.g., bank recall), it is handled operationally and may appear as a balance adjustment rather than a status change on the original payment.
- **Refund triggers**: name mismatch with bank records, compliance/AML block, bank-initiated recall. These block the payment (status remains `pending` with `blocked_reasons`). If the block cannot be resolved via RFI, the payment is refunded.
- **Fund return**: when refunded, funds are returned to the sender's originating bank account automatically. Merchants do not need to take action for the bank transfer itself.
- **Balance impact**: the refunded amount is deducted from your account balance. If you already credited a customer on your side, you must reverse that credit.

> **Note**: In rare cases where a bank-initiated recall occurs after completion, StraitsX operations will contact you directly. The handling of post-completion returns is managed on a case-by-case basis.

### Webhook Event

Event: **`paymentStatusUpdated`**

Fires on every externally-visible status change (`pending`, `completed`, `failed`, `refunded`).

Payload fields:

```json
{
  "id": "<unique_id>",
  "type": "Direct bank transfer",
  "idempotency_id": "<external_id>",
  "amount": "1000.00",
  "fees": "0.00",
  "status": "refunded",
  "currency": "sgd",
  "payment_method": { ... },
  "sender_information": {
    "account_holder_name": "...",
    "account_number": "...",
    "bank_short_code": "...",
    "bank_name": "...",
    "end_to_end_ref": "...",
    "swift_bic": "...",
    "transaction_remarks": "..."
  },
  "created_at": "2024-01-15T10:30:00.000+08:00",
  "updated_at": "2024-01-16T14:00:00.000+08:00"
}
```

### Refund Time Window

Refunds apply to payments that were blocked before completion (i.e., moved to `failed` status). There is no fixed time limit — the refund is processed once the operations team initiates the bank return. For post-completion bank recalls, these are handled operationally on a case-by-case basis.

---

## 2. Payout Lifecycle (Outgoing Funds)

Payouts represent outgoing bank transfers to beneficiary accounts (first-party withdrawals and third-party payouts).

### Status Transitions

```
pending → completed          (normal flow — funds disbursed successfully)
pending → failed             (compliance block, bank rejection, or disbursement error)
```

### Terminal States

| Status | Terminal? | Description |
|--------|-----------|-------------|
| `completed` | Yes | Funds successfully delivered to beneficiary. |
| `failed` | Yes | Disbursement rejected. Funds returned to your balance. |

### Key Behaviors

- **`completed` IS terminal** for payouts — once a payout is marked completed, it does not revert. Bank-level reversals after completion are handled as separate incoming deposits (see Scenario B below).
- **Automatic fund return**: when a payout fails, funds are automatically returned to your source wallet in the original currency. No action needed to recover funds.
- **Retry**: you must create a new payout with a **new `idempotencyId`**. The original idempotency key cannot be reused.

### Webhook Event

Event: **`payoutStatusUpdated`**

Payload fields:

```json
{
  "id": "<unique_id>",
  "type": "Withdrawal on behalf",
  "idempotency_id": "<external_id>",
  "amount": "500.00",
  "fees": "0.00",
  "status": "failed",
  "account_no": "1234567890",
  "bank_abbrev": "DBS",
  "failure_reason": "The account number is invalid.",
  "currency": "sgd",
  "created_at": "2024-01-15T10:30:00.000+08:00",
  "updated_at": "2024-01-15T10:35:00.000+08:00"
}
```

### Common Failure Reasons

The `failure_reason` field contains a human-readable description prefixed with "Disbursement failed: ". Common values:

| Category | Example `failure_reason` |
|----------|--------------------------|
| Invalid account | "Disbursement failed: The account number is invalid." |
| Closed/blocked account | "Disbursement failed: Issue with beneficiary account. Please check with beneficiary bank." |
| Beneficiary bank issue | "Disbursement failed: Issue with the beneficiary bank. Please try again or contact the beneficiary bank." |
| Bank unavailable | "Disbursement failed: Receiving Bank is down." |
| PayNow not enabled | "Disbursement failed: The recipient does not have PayNow enabled." |
| System error | "Disbursement failed: Please contact us for more information." |

> **Note**: Do not use `failure_reason` for programmatic branching — the text may change. Use it for logging and display only.

---

## 3. Refund & Reversal Scenarios

### Scenario A: Payment Blocked Due to Name Mismatch (RFI Flow)

**Trigger**: the sender's bank account name does not match the expected recipient name (e.g., payment sent via Wise or another intermediary, causing a third-party name to appear).

**What you observe**:
1. `paymentStatusUpdated` webhook fires with `"status": "pending"` and a `blocked_reasons` array containing the block code (e.g., `"code": "NM-001"` for name mismatch)
2. StraitsX initiates a Request for Information (RFI) with the merchant/user to provide transfer proof
3. **If RFI is resolved successfully** → `paymentStatusUpdated` fires with `"status": "completed"` (funds credited)
4. **If RFI fails or screening is rejected** → `paymentStatusUpdated` fires with `"status": "refunded"` (funds returned to sender)

**Example callback payload (blocked state)**:
```json
{
  "id": "contract_257487fd...",
  "status": "pending",
  "blocked_reasons": [
    { "code": "NM-001" }
  ],
  "sender_information": {
    "account_holder_name": "WISE ASIA-PACIFIC PTE. LTD.",
    ...
  },
  ...
}
```

**What to do**:
1. Check `blocked_reasons` in the callback — if present, the payment is under review
2. Respond to any RFI requests from StraitsX (provide transfer proof if requested)
3. Wait for the next `paymentStatusUpdated` callback with either `completed` or `refunded`
4. If `refunded`: no balance impact (funds were never credited). Inform your customer the payment was returned.

**Known block codes**:

| Code | Description |
|------|-------------|
| `NM-001` | Name mismatch — sender name does not match expected recipient |

### Scenario B: Payout Completed, Then Rejected by Beneficiary Bank (T+1 Return)

**Trigger**: beneficiary bank returns funds after the payout was already marked completed (rare, but possible with SWIFT/MEPS payments).

**What you observe**:
1. The original payout status **remains `completed`** — it does not change
2. The returned funds appear as a **new incoming payment** credited to your balance
3. You receive a `paymentStatusUpdated` callback for the incoming credit
4. The `transaction_remarks` field in the payment callback contains `RTN <original_idempotency_id>` — this links the return to the original payout

**How to identify a payout return**:

The payment callback's `sender_information.transaction_remarks` field contains the keyword `RTN` followed by the original payout's `idempotency_id`. Use this to programmatically match the return to the original payout.

**Example callback payload (payout return as incoming payment)**:
```json
{
  "id": "contract_abc123...",
  "type": "Direct bank transfer",
  "idempotency_id": "<new_payment_idempotency_id>",
  "amount": "500.00",
  "fees": "0.00",
  "status": "completed",
  "currency": "usd",
  "sender_information": {
    "account_holder_name": "...",
    "swift_bic": "...",
    "transaction_remarks": "RTN <original_payout_idempotency_id>"
  },
  "created_at": "2024-01-16T09:00:00.000+08:00",
  "updated_at": "2024-01-16T09:05:00.000+08:00"
}
```

**What to do**:
1. Check `transaction_remarks` for the `RTN` prefix in incoming payment callbacks
2. Extract the original payout `idempotency_id` from the remarks to match back to your original payout record
3. Decide whether to retry the payout (with corrected details) or take other action

> **Note**: The `sender_information.account_holder_name` and `swift_bic` fields may vary depending on the banking rail used for the original payout. Do not rely on these fields for matching — use `transaction_remarks` as the authoritative identifier for payout returns.

### Scenario C: Merchant Wants to Refund a Customer (Voluntary Refund)

**Is there a refund API?** No. There is no self-service refund endpoint.

**Recommended approach**:
1. Contact StraitsX support at https://support.straitsx.com/hc/en-us/requests/new
2. Provide: payment ID, reason for refund, amount (full or partial)
3. The operations team will process the refund and return funds to the sender's bank account

**Alternative** (if you have the sender's bank details):
- Create a payout to the customer's bank account as a separate transaction
- This is treated as a new outgoing payout, not linked to the original payment

---

## 4. Reconciliation Guidance

### Matching Refunds to Original Payments

When a payment is refunded:
- The **same contract ID** (`id` field) is used — the status changes to `refunded`
- Use the `id` or `idempotency_id` from the webhook payload to match back to your original record
- No separate refund transaction ID is exposed via the API

### Matching Payout Returns (T+1 Rejections)

When a completed payout is returned by the beneficiary bank:
- The return appears as a **separate incoming payment** with its own `id` and `idempotency_id`
- **Identify returns via `transaction_remarks`**: the field contains `RTN <original_payout_idempotency_id>` — use this to link the return to the original payout
- The original payout remains in `completed` status
- Sender details (`account_holder_name`, `swift_bic`) may vary depending on the banking rail — do not rely on these for matching

### Best Practices

1. **Store the `id` and `idempotency_id`** for every transaction — these are your primary reconciliation keys
2. **Deduplicate callbacks** by `id` — you may receive multiple webhooks for the same status change
3. **Track timestamps** — `updated_at` in the payload indicates when the status change occurred
4. **Check `transaction_remarks` for payout returns** — incoming payments with `RTN <idempotency_id>` in `transaction_remarks` are returned payouts; extract the original payout's `idempotency_id` to reconcile

---

## 5. Status Transition Diagrams

### Payments (Incoming via API — `paymentStatusUpdated`)

```
created
  │
  ▼
pending ─── (blocked: NM-001 etc.) ──┬──► completed (RFI resolved)
  │                                  │
  │                                  └──► refunded (RFI failed / screening rejected)
  ▼
completed (terminal)
```

Additionally: `created → expired` (PayNow QR timeout, no funds received)

Merchant-visible statuses: `pending`, `completed`, `refunded`, `failed` (transient), `expired`

### Payouts (Outgoing via API — `payoutStatusUpdated`)

```
created
  │
  ▼
pending ──────────────────────► failed (bank rejection / compliance block)
  │
  ▼
completed (terminal)
```

Merchant-visible statuses: `pending`, `completed`, `failed`

### Deposits (Incoming — Dashboard Users — `userDepositStatusUpdated`)

```
created
  │
  ▼
pending ─── (blocked) ───────┬──► completed (block resolved)
  │                          │
  │                          └──► refunded (screening rejected)
  ▼
completed (terminal)
```

Merchant-visible statuses: `pending`, `completed`, `refunded`, `failed` (transient)

### Withdrawals (Outgoing — Dashboard Users — `userWithdrawalStatusUpdated`)

```
created
  │
  ▼
pending ──────────────────────► failed (bank rejection / compliance block)
  │
  ▼
completed (terminal)
```

Merchant-visible statuses: `pending`, `completed`, `failed`

---

## 6. Best Practices Summary

| Practice | Why |
|----------|-----|
| Always handle `refunded` and `failed` statuses | Transactions don't only move forward |
| Don't branch on `failure_reason` text | Values may change without notice |
| Deduplicate by `id` | Multiple callbacks possible for same event |
| Use new `idempotencyId` for retries | Original key is consumed even on failure |
| Check `transaction_remarks` for `RTN` prefix | Identifies payout returns in incoming payment callbacks |
| Contact support for payment refunds | No self-service refund API exists |
| Store `id` + `idempotency_id` | Primary keys for reconciliation |
