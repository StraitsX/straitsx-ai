# Common Integration Pitfalls

> Load this file when the user asks "what should I watch out for?", "what are common mistakes?", or is troubleshooting an issue that isn't a specific error code.

---

## 1. Webhook/Callback Not Received

| Cause | Resolution |
|-------|------------|
| Webhook URL not configured | Configure via [`PATCH /v1/webhooks`](https://docs.straitsx.com/reference/update-webhooks) or Dashboard (Platform Tools → Callback URL) |
| StraitsX IP not whitelisted | Whitelist StraitsX [source IP addresses](https://docs.straitsx.com/docs/source-ip-addresses) |
| Transaction still processing | Some transactions process on business days only — callbacks fire when status actually changes |
| Webhook URL returning non-2xx | Check your server logs — StraitsX retries up to 20 times with increasing delays |

> For full webhook delivery details, see the `straitsx-webhook-verification` skill.

---

## 2. Balance & Fee Errors

| Pitfall | Detail |
|---------|--------|
| Payout fails with "Insufficient Balance" | The required balance = payout amount + fees. Always check `amount + fees ≤ available balance` before submitting. |
| No balance in sandbox | Sandbox accounts start with zero balance. Collect a payment first (via VBA mock) or use `POST /v1/sandbox/merchant/topup`. |

---

## 3. Customer Profile Verification & Resubmission

| Pitfall | Detail |
|---------|--------|
| Duplicate registration ID | You cannot create a new CP with the same `registrationId`. Update the existing rejected CP instead via `PATCH`. |
| Not checking rejection details before resubmitting | Always check `verificationRejectionSummary` and `riskRating.rejections` in the callback/GET response. Resubmitting without addressing the specific rejection reason will result in another rejection. |
| Expecting instant verification | Regular CP: approved within ~2 minutes if no screening hits. CP+: typically under 30 minutes ([details](https://docs.straitsx.com/docs/customer-profile-faqs#5-how-long-does-it-take-to-review-a-cp-profile-if-its-rejected-will-a-reason-be-provided-and-would-you-recommend-retrying)). If there's a screening hit, processing time depends on case complexity. Any RFI raised may further extend the timeline. In sandbox, you manually set the status. |

---

## 4. Request Body Format

| Pitfall | Detail |
|---------|--------|
| Using `data.attributes` nesting for flat endpoints | Some endpoints (CP creation, bank accounts, payouts) use **flat** request bodies, not JSON:API `data.attributes` nesting. Always check the API reference for each endpoint. |
| Missing required fields for specific scenarios | Payout recipients require different fields depending on `disbursementMethod` (bankTransfer vs paynow vs swift). Use the requirements endpoint first. |

---

## 5. Wrong Base URL

| Pitfall | Detail |
|---------|--------|
| Calling mock server or wrong environment | Always verify you're calling the correct base URL: `https://api-sandbox.straitsx.com` (sandbox) or `https://api.straitsx.com` (production). Errors from a mock server won't match StraitsX error codes. |

---

## 6. API Key Issues

| Pitfall | Detail |
|---------|--------|
| API key expired | API keys have an expiry date (6 months). Monitor expiry and rotate before it lapses. |
| Missing endpoint scopes | Sandbox and production keys may need explicit scope grants. If you get `XFE6` (403), contact StraitsX support. |
| Using production key in sandbox (or vice versa) | Each environment has its own API key. They are not interchangeable. |

---

## 7. Sandbox vs Production Differences

| Area | Sandbox | Production |
|------|---------|------------|
| Verification (CP, bank account) | Status won't auto-transition — must be manually updated via sandbox mock endpoints | Handled by StraitsX compliance team |
| Payments | Simulated via mock endpoints | Real bank transfers |
| Payouts | Simulated via status update endpoints | Real disbursements with settlement times |
| Balance | Must be topped up manually or via mock payments | Real funds from actual payments received |
| Callbacks | Sent to your configured URL (real HTTP requests) | Same behavior |
| Rate limit | 5 TPS | 5 TPS (same) |

---

## 8. Bank Account Duplicates

| Pitfall | Detail |
|---------|--------|
| Creating duplicate bank accounts | Attempting to create a bank account with the same details (account number + bank) that already exists will return an error. Use the list endpoint to check if the account already exists before creating. |
| Bank account auto-created without merchant awareness | When a first-party payment is received, the sender's bank details are captured and a bank account record is auto-created and verified — this can be used for future payouts. If you haven't configured the `cpbaCreated` / `cpbaVerificationStatusUpdated` webhook, you won't be notified of these auto-created accounts. |

---

## 9. API Documentation vs Actual Response

| Pitfall | Detail |
|---------|--------|
| Relying on documentation field ordering | JSON key ordering is not guaranteed. Parse responses by field name, not position. |
| Assuming all fields are always present | Optional fields may be omitted entirely from the response (not returned as `null`). Always check for field existence before accessing. |
| Response format discrepancies | Some endpoints return flat JSON, others use JSON:API `data.attributes` nesting. Always verify against the actual API response, not assumptions. |

---

## 10. Non-Latin Characters

| Pitfall | Detail |
|---------|--------|
| Banks rejecting names/addresses with non-Latin characters | Banks may reject or delay processing when names or addresses contain non-Latin characters. Provide all details in English. Only native names may use non-Latin characters where required. |
| Chinese name screening false hits | English names of Chinese users may trigger false hits during name screening. Provide Chinese names as Native Names for faster and more accurate screening. |

---

## 11. First-Party Payment Name Mismatch & Wrong Currency

| Pitfall | Detail |
|---------|--------|
| Payment rejected due to sender name mismatch | In the first-party payment model, the sender's name must match the customer profile's name. If a payment is received from a different person's bank account, it will be rejected. Ensure your customers deposit only from their own bank accounts. |
| Wrong currency deposit | Deposits in unsupported currencies lead to delays or unintended conversions. Ensure users deposit in the correct supported currency. |

---

## 12. Fake Profiles in Production

| Pitfall | Detail |
|---------|--------|
| Submitting fake profiles | Submitting fake profiles in production triggers bank RFIs that cannot be answered, permanently blocking the profile. Never submit fake profiles — use sandbox for testing. |
