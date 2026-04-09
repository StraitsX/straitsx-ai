# StraitsX API Concept Map

> Maps business concepts and common terminology to API endpoints. Load this file when the user asks about a feature by name (e.g., "first-party payout") and you need to find the right endpoint.

## Integration Models

StraitsX supports three integration models. The model determines which endpoints to use for payments and payouts.

| Model | What it means | Payment endpoints | Payout endpoints |
|---|---|---|---|
| First-Party | You collect payments from your end users and pay out to the same bank account that sent the payment. Requires customer profiles. | Virtual Bank Accounts, PayNow (under `/payment_methods/`) | `POST /customer_profile/{id}/withdrawals` |
| Third-Party | You collect payments from your end users and pay out to a different bank account (e.g., a merchant). Requires customer profiles + payout recipients. | Virtual Bank Accounts, PayNow (under `/payment_methods/`) | `POST /customer_profile/{id}/payouts` |
| Regular | You send payouts from your StraitsX business account to any recipient. No customer profiles needed. | Virtual Bank Accounts, PayNow (under `/payment_methods/`) | `POST /payouts` |

## Customer Profiles

| Concept | What it means | Endpoints |
|---|---|---|
| Customer Profile (CP) | Basic end-user identity — no KYC/KYB verification. Used for first-party and third-party flows. | `POST /kyc/customer_profiles` (personal), `POST /kyc/customer_profiles` (business) |
| Customer Profile+ (CP+) | Enhanced end-user identity with full KYC/KYB verification. Required for higher limits and USD transactions. | `POST /kyc/customer_profiles` (personal CP+), `POST /kyc/customer_profiles` (business CP+) |
| CP Verification | StraitsX reviews the submitted profile. Status goes `pending` → `verified` or `rejected`. | `GET /kyc/customer_profiles/{id}` (check `verificationStatus`) |
| CP Bank Account | A bank account linked to a customer profile. Must be verified before use in payouts. | `POST /customer_profile/{id}/bank_accounts`, `GET /customer_profile/{id}/bank_accounts` |
| RFI (Request for Information) | StraitsX requests additional documents during CP+ verification. | `GET /customer_profile/{id}/rfi-requests`, `PUT /customer_profile/{id}/rfi-requests/{rfi_id}` |

## Payments (Collecting Money)

| Concept | What it means | Endpoints |
|---|---|---|
| Virtual Bank Account (VBA) | A unique bank account number assigned to a customer profile. When the customer transfers money to this account, StraitsX credits your business account. | `POST /payment_methods/virtual_bank_accounts`, `GET /payment_methods/virtual_bank_accounts/{id}` |
| Persistent PayNow | A reusable PayNow QR code linked to a customer profile. Never expires, multi-use. SGD only. | `POST /payment_methods/paynow`, `GET /payment_methods/paynow/{id}` |
| Dynamic PayNow | A one-time PayNow QR code with a fixed amount and expiry. SGD only. | `POST /payments/paynow`, `GET /payments/paynow/{id}` |
| Payment | An incoming fiat transaction. Created automatically when a customer sends money to a VBA or pays via PayNow. | `GET /payments/{contract_id}`, `GET /payments` |
| Payment Methods | The collection of VBAs and PayNow codes for a customer profile. | `GET /customer_profile/{id}/payment_methods`, `GET /payment_methods` |

## Payouts (Sending Money)

| Concept | What it means | Endpoints |
|---|---|---|
| First-Party Payout | Send money back to the same bank account that made the original payment. Requires a verified customer profile with a verified bank account. | `POST /customer_profile/{id}/withdrawals`, `GET /customer_profile/{id}/withdrawals`, `GET /customer_profile/{id}/withdrawals/{id}` |
| Third-Party Payout | Send money to a different recipient's bank account on behalf of a customer profile. Requires a payout recipient. | `POST /customer_profile/{id}/payouts`, `GET /customer_profile/{id}/payouts`, `GET /customer_profile/{id}/payouts/{id}` |
| Regular Payout | Send money from your business account to any recipient. No customer profile needed. | `POST /payouts`, `GET /payouts`, `GET /payouts/{id}` |
| Payout Recipient (CP) | A bank account registered as a payout destination for a customer profile. Used in third-party payouts. | `POST /customer_profile/{id}/payout-recipients`, `GET /customer_profile/{id}/payout-recipients` |
| Payout Recipient (Regular) | A bank account registered as a payout destination for your business account. Used in regular payouts. | `POST /payout-recipients`, `GET /payout-recipients` |
| Recipient Requirements | The required fields for creating a payout recipient, which vary by currency and destination country. | `GET /payout-recipients/requirements` |
| Refund | No dedicated refund API. To refund a customer, use the appropriate payout endpoint to send funds back. | Use first-party, third-party, or regular payout endpoints |

## Swaps

| Concept | What it means | Endpoints |
|---|---|---|
| Swap | Exchange one currency/stablecoin for another within your StraitsX account. Available 24/7. | See flow below |
| Swap Quote | A price quote for a swap. Has a validity window (1 min to 1 hour depending on pair). Must be executed before expiry. | `POST /swap/quotes`, `GET /swap/quotes/{id}` |
| Swap Execution | Confirm and execute a previously requested quote. Irreversible once executed. | `POST /swap/transactions` |
| Swap Transaction | The record of an executed swap. | `GET /swap/transactions/{id}`, `GET /swap/transactions` |
| Supported Pairs | The currency pairs available for swapping (e.g., XSGD↔SGD, XSGD↔USDC). | `GET /swap/pairs` |

**Swap flow:** Request quote → Execute quote → Check transaction status.

## FX (Foreign Exchange)

| Concept | What it means | Endpoints |
|---|---|---|
| FX Quote | A foreign exchange rate quote for cross-currency payouts. | `POST /fx/quotes`, `GET /fx/quotes/{id}` |
| FX Payout | A payout that includes currency conversion. | `POST /fx/payouts`, `GET /fx/payouts`, `GET /fx/payouts/{id}` |

**FX flow:** Create FX quote → Execute (create payout with FX) → Check transaction status.

## Blockchain

| Concept | What it means | Endpoints |
|---|---|---|
| Blockchain Address | A whitelisted wallet address for receiving stablecoin withdrawals. Must be verified. | `GET /blockchain_transfer/addresses/`, `GET /blockchain_transfer/deposit_addresses` |
| Blockchain Withdrawal | Send stablecoins (XSGD, XUSD, USDC, USDT) from your StraitsX account to an external wallet. | `POST /blockchain_transfer/withdrawals/`, `GET /blockchain_transfer/withdrawals/{id}`, `GET /blockchain_transfer/withdrawals` |
| Network Fee Estimate | Estimate the blockchain network fee before creating a withdrawal. | `POST /blockchain_transfer/withdrawals/{blockchain}/estimate_network_fee` |
| Supported Blockchains | The blockchain networks available for withdrawals (e.g., Ethereum, Solana). | `GET /blockchain_transfer/blockchains` |

## Transaction Limits

| Concept | What it means | Endpoints |
|---|---|---|
| Transaction Limit | Per-customer-profile limits on transaction amounts (daily, per-transaction). | `GET /customer_profile/{id}/transaction-limits` |
| Limit Update Request | Request to increase a customer profile's transaction limits. Requires StraitsX approval. | `POST /customer_profile/{id}/transaction-limits-update-requests`, `GET /customer_profile/{id}/transaction-limits-update-requests/{id}` |

## Webhooks & Callbacks

| Concept | What it means | Endpoints |
|---|---|---|
| Webhook Configuration | Configure which URLs receive callback notifications. | `GET /webhooks`, `PATCH /webhooks` |
| Callback | A POST request StraitsX sends to your server when a transaction status changes. Signed with HMAC-SHA256 (`Xfers-Signature` header). | Incoming — your server receives these |
| Resend Callback | Manually trigger a callback resend for a specific contract or batch of contracts. | `POST /webhooks/{contractId}/resend`, `POST /webhooks/resend` |
| Callback Retry | Failed callbacks are retried every 5 minutes, up to 20 times. | Automatic — no endpoint needed |

## Account & Reporting

| Concept | What it means | Endpoints |
|---|---|---|
| Account Balance | Your StraitsX business account balance across all currencies. | `GET /merchant/account-balance` (v2), `GET /merchant/balance` (v1) |
| Account Statement | Transaction history for your business account with filtering and pagination. | `GET /merchant/statements/account-statement` |
| Supported Banks | List of banks supported for payouts and virtual bank accounts. | `GET /banks` |

## User Withdrawals (Dashboard)

| Concept | What it means | Endpoints |
|---|---|---|
| User Withdrawal | A withdrawal initiated from the StraitsX dashboard (not via API). Can also be created via API for dashboard-style flows. | `POST /withdrawals`, `GET /withdrawals/{id}` |
| User Bank Account | Bank accounts linked to your StraitsX business account (not customer profiles). | `GET /withdrawals/bank-accounts`, `POST /withdrawals/bank-accounts`, `PUT /withdrawals/bank-accounts/{id}` |
