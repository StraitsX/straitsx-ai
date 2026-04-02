# Transaction Safety & Idempotency

> Reference for AI clients generating transactional code. Source: [Transaction Safety](https://docs.straitsx.com/docs/transaction-safety), [Idempotent Requests](https://docs.straitsx.com/docs/idempotent-requests)

## Idempotency

All transactional POST requests accept an idempotency key (`referenceId` or `idempotency_id`). GET and DELETE requests are idempotent by definition.

**Key generation strategies:**
- Random token with sufficient entropy (e.g., UUID v4)
- Unique reference ID from your platform (e.g., `order_id`, `user_id`)

**Behavior:** Retrying a request with the same idempotency key returns the original result — it will not create a duplicate transaction.

## Transaction Safety Rules

1. **Always check status.** The `status` field in the API response or callback is the source of truth. Only consider a transaction successful when status is `completed`.

2. **Don't auto-fail on network errors.** If a payout request gets a timeout or HTTP 5xx, do not mark it as failed in your system. Instead, GET the transaction status to confirm the actual outcome.

3. **Reuse idempotency keys on retry.** When retrying a failed request, always reuse the same `idempotency_id` to prevent duplicate disbursements.

## Transaction Statuses

| Status | Meaning |
|---|---|
| `pending` | Request received, not yet processed. For payments: funds received but not credited. |
| `completed` | Transaction successful. For payouts: funds sent (bank crediting may take additional time). |
| `failed` | Transaction unsuccessful. Check `failure_reason` in the callback if available. |
| `refunded` | Funds returned to sender bank account. |

## Blocked Codes (Pending Payments)

Payments in `pending` state may include a blocked code explaining the hold:

| Code | Reason | Suggested Handling |
|---|---|---|
| FG-001 | Internal risk control measures | Inform user of possible delay. |
| NM-001 | Name mismatch (sender name vs user name) | Ask user to provide supplementary bank account info. First-party transfers only. |
| CR-001 | Compliance measures | Contact StraitsX for root cause. Inform user of delay. |

## Code Generation Guidance

When generating transactional code:

1. Always include an `idempotency_id` in POST requests that create transactions.
2. Implement a status-checking loop or callback handler — never assume success from a 2xx response alone.
3. On timeout or 5xx, retry with the same `idempotency_id` and verify status via GET.
4. Log the `idempotency_id` alongside your internal reference for reconciliation.
