# StraitsX API FAQs

> Consolidated FAQ reference for AI clients. Load when the user asks domain-specific questions about StraitsX capabilities, limits, or behavior. Sources: [General](https://docs.straitsx.com/docs/common-faqs), [Payment](https://docs.straitsx.com/docs/payment-faqs), [Payout](https://docs.straitsx.com/docs/payout-faqs), [Swap](https://docs.straitsx.com/docs/swap-faqs), [Customer Profile](https://docs.straitsx.com/docs/customer-profile-faqs), [Bank Account](https://docs.straitsx.com/docs/bank-account-faqs)

---

## General

| Question | Answer |
|---|---|
| Supported currencies | SGD and USD |
| Supported payment methods | Bank transfer (virtual bank account) and PayNow (SGD only) |
| Can I mix integration models? | Yes — APIs are modular. E.g., First-Party Payment + Third-Party Payout. Contact sales if unsure. |
| API key validity | 6 months. Dashboard shows expiry date. Email reminders sent 14 and 30 days before expiry. |
| Rate limiting | 5 requests per second (TPS) per API key. Applies to all HTTP methods equally (GET, POST, PUT, PATCH). Same limit for sandbox and production. No `Retry-After` header in 429 responses — implement your own backoff. |
| Failed callback retry | Every 5 minutes, up to 20 retries. |
| Supported file uploads | PNG, JPG, PDF — max 10 MB per request. |
| Fees on failed transactions | No penalties, but frequent failures from incorrect inputs may trigger fraud prevention checks. |
| Restricted countries/businesses | Yes — refer to StraitsX restricted lists on the docs site. |

### Contract Types

| Type | Description |
|---|---|
| FiatPaymentContract | Incoming fiat transactions via API |
| FiatPayoutContract | Outgoing fiat transactions via API |
| FiatDepositContract | Incoming fiat transactions via dashboard |
| FiatWithdrawContract | Outgoing fiat transactions via dashboard |
| FiatRefundContract | SGD/USD refunds triggered by internal ops |
| StablecoinDepositContract | Incoming blockchain transfers |
| StablecoinWithdrawContract | Outgoing blockchain transfers |
| SwapContract | Swap transactions |
| OtcContract | OTC transactions |
| AdminContract | Transfers triggered by internal ops |
| TransferContract | Credit/debit of transfer balance after compliance approval |

### Dashboard Roles

| Permission | Owner | Admin | Developer | Viewer |
|---|---|---|---|---|
| Generate Key | ✅ | ✅ | ✅ | ❌ |
| Add Member | ✅ | ✅ | ❌ | ❌ |
| Initiate Transactions | ✅ | ✅ | ❌ | ❌ |

---

## Payments

| Question | Answer |
|---|---|
| Are virtual bank accounts unique per customer? | Yes — identified by the account number returned by the Create Virtual Bank Account API. |
| Does StraitsX maintain per-user ledgers? | No. Successful payments credit stablecoin (XSGD/XUSD) to the partner's StraitsX business account. |
| Settlement currencies | SGD→SGD, USD→USD, SGD→XSGD, or USD→XUSD (depends on agreed use case). |
| PayNow QR expiry | Persistent: never expires, multi-use, one per user. Dynamic: configurable 5 min to 30 days, one-time use. |
| PayNow transaction limit | S$200,000 (FAST limit for SGD local transfers). |

### Payment Transaction Types

| Type | Description |
|---|---|
| `bankTransferTransaction` / `Direct bank transfer` | Bank-to-bank payments |
| `paynowTransaction` | PayNow payments |

---

## Payouts & Refunds

| Question | Answer |
|---|---|
| Can I add bank accounts for end users anytime? | Yes — use the Create Customer Profile Bank Account API. |
| Scheduled payouts? | Not supported via API. Set up a recurring job in your backend. |
| Are payouts instant? | Processed instantly via API, but actual receipt depends on currency, amount, and banking network. May be held for fraud/compliance review. |
| Can I recall a payout? | No — cannot be recalled once processed. Double-check details before execution. |
| Refund API? | No dedicated refund API. Use Payout API to send funds back. |
| What if a withdrawal is rejected by beneficiary bank? | Status remains `completed` on StraitsX side. The refund is treated as a separate deposit. |

### Payout Transaction Types

| Type | Description |
|---|---|
| `Withdrawal on behalf` | First-party payouts (SGD) |
| `bankTransferTransaction` | Third-party and regular payouts (SGD) |
| `paynowTransaction` | PayNow transactions (SGD) |
| `swiftTransaction` | USD payouts |

### Payout Recipient Requirements

| Integration Model | Recipient Rules |
|---|---|
| First-Party | Payout only to the same bank account that made the payment. |
| Third-Party | See [Create Customer Profile Payout Recipient](https://docs.straitsx.com/reference/create-a-customer-profile-payout-recipient). |
| Regular Transfer | See [Create Payout Recipient](https://docs.straitsx.com/reference/create-a-payout-recipient). |

---

## Swaps

| Question | Answer |
|---|---|
| Amount range | 10 to 100,000 per swap. Error returned if outside range. |
| Can swaps be reversed? | No — settled immediately. |
| Expired quote? | Request a new quote before executing. |
| Availability | 24/7, regardless of banking hours. |
| Does requesting a quote freeze funds? | No. |
| Processing time | Near-instant. Callback sent on completion. |
| Transaction fee | Typically no fee — spread is built into the rate. `totalSourceCurrencyAmount` equals `sourceCurrencyAmount` unless a fee is imposed. |
| Possible statuses | `completed`, `failed`, `pending` |

### Swap Pairs & Quote Validity

| Pair | Quote Validity |
|---|---|
| XSGD↔USDC | 5 min |
| XSGD↔XUSD | 5 min |
| USDC↔USDT | 1 min |
| XUSD↔USDC | 5 min |
| XUSD↔USDT | 1 min |
| XSGD↔USDT | 1 min |
| XSGD↔SGD | 1 hour |
| XSGD↔USD | 1 min |
| XUSD↔SGD | 1 min |
| XUSD↔USD | 1 min |
| USDC↔SGD | 5 min |
| USDC↔USD | 5 min |
| USDT↔SGD | 1 min |
| USDT↔USD | 1 min |
| SGD↔USD | 1 min |

### Swap API Flow

| Step | Endpoint | Purpose |
|---|---|---|
| 1 | Request a Swap Quote | Get current exchange rate |
| 2 | Get a Swap Quote | Retrieve existing quote by ID |
| 3 | Execute a Swap Quote | Confirm and execute the swap |

---

## Customer Profiles

| Question | Answer |
|---|---|
| CP vs CP+ | CP requires basic info (no KYC/KYB). CP+ requires extensive info with full KYC/KYB verification. CP+ has transaction limits per profile and additional compliance requirements. CP+ transactions are currently USD only. |
| Verification processing time | Typically under 30 minutes. |
| Can I retry after rejection? | Depends on rejection reason. Document quality issues: yes, with better documents. Policy rejections (e.g., sanctioned user): no. |
| Are IP addresses verified? | No — for record purposes only. Provide the IP addresses you have on file. |

### Required Fields — Personal

| Field | CP+ | CP |
|---|---|---|
| customerName | Optional | Required |
| customerFirstName | Required | N/A |
| customerLastName | Required | N/A |
| registrationType | Required | Required |
| registrationId | Required | Required |
| registrationIdCountry | Required | Required |
| registrationIdType | Required | Required |
| dateOfBirth | Required | Required |
| nationality | Required | Required |
| address | Required | Required |
| countryOfResidence | Required | N/A |
| gender | Required | Optional |
| email | Required | Optional |
| businessIndustry | Required | N/A |
| occupation | Required | N/A |
| annualIncome | Required | N/A |
| identityDocuments | Required | N/A |
| ipAddresses | Required | N/A |

### Required Fields — Business

| Field | CP+ | CP |
|---|---|---|
| customerName | Required | Required |
| registrationType | Required | Required |
| registrationId | Required | Required |
| registrationIdType | Required | Optional |
| countryOfIncorporation | Required | Optional |
| dateOfIncorporation | Required | Optional |
| address | Required | Optional |
| entityLegalForm | Required | N/A |
| businessContact | Required | N/A |
| natureOfBusiness | Required | N/A |
| usOwnership | Required | N/A |
| sourceOfFunds | Required | N/A |
| directors | Required | N/A |
| beneficialOwners | Required | N/A |
| trader | Required | N/A |
| documents | Required | N/A |

---

## Bank Accounts

| Question | Answer |
|---|---|
| Verification statuses | `pending` (awaiting review), `verified` (approved), `rejected` |
| Callback on status change? | Yes — via `cpbaVerificationStatusUpdated` webhook event. |
| How long does verification take? | Depends on document clarity. |
| Is there a reason given for rejection? | No explicit reason — status is just `rejected`. |
| Can I resubmit after rejection? | Yes — submit a new application with correct details. |
| How fast is verification for first deposit? | Near-instant once the first deposit completes. |
