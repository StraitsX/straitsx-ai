# Callback Payload Reference

> Load this file when the user asks "what does the callback payload look like?" or needs field-level details for a specific event type.
>
> See also: [Callback Samples (public docs)](https://docs.straitsx.com/docs/callback-samples) for additional examples including USD-specific fields and variant payloads.

## Available Callback Events

| Event | Description |
|-------|-------------|
| [`paymentStatusUpdated`](#paymentstatusupdated) | Fires when a VBA or PayNow payment status changes |
| [`payoutStatusUpdated`](#payoutstatusupdated) | Fires when a bank transfer payout or FX payout status changes |
| [`cpVerificationStatusUpdated`](#cpverificationstatusupdated) | Fires when a customer profile verification status changes |
| [`cpbaVerificationStatusUpdated`](#cpbaverificationstatusupdated) | Fires when a customer profile bank account verification status changes |
| [`cpbaCreated`](#cpbacreated) | Fires when a new customer profile bank account is created |
| [`virtualAccountStatusUpdated`](#virtualaccountstatusupdated) | Fires when a virtual bank account is enabled or disabled |
| [`userWithdrawalStatusUpdated`](#userwithdrawalstatusupdated) | Fires when a user withdrawal status changes |
| [`userDepositStatusUpdated`](#userdepositstatusupdated) | Fires when a user deposit status changes |
| [`stablecoinWithdrawalStatusUpdated`](#stablecoinwithdrawalstatusupdated) | Fires when a blockchain/stablecoin withdrawal status changes |
| [`stablecoinDepositStatusUpdated`](#stabledepositstatusupdated) | Fires when a blockchain/stablecoin deposit status changes |
| [`swapUpdated`](#swapupdated) | Fires when a swap transaction status changes |
| [`cpTxnLimitsUpdated`](#cptxnlimitsupdated) | Fires when a customer profile's transaction limits change (CP+ only) |
| [`cpTxnLimitsUpdateRequestStatusUpdated`](#cptxnlimitsupdaterequeststatusupdated) | Fires when a transaction limits update request status changes (CP+ only) |
| [`cpRfiStatusUpdated`](#cprfistatusupdated) | Fires when a Request for Information (RFI) status changes |
| [`ubaCreated`](#ubacreated) | Fires when a new user bank account is created |
| [`ubaVerificationStatusUpdated`](#ubaverificationstatusupdated) | Fires when a user bank account verification status changes |

---

## `paymentStatusUpdated`

Fires when a VBA or PayNow payment status changes (e.g., `pending` → `completed`).


### Example Payload (SGD/XSGD Bank Transfer)

```json
{
  "id": "contract_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "type": "Direct bank transfer",
  "idempotency_id": "a4e709611640500d5b1c66241850c3b6",
  "amount": "1000.0",
  "fees": "0.0",
  "status": "completed",
  "bank_account_no": "3225445900001",
  "merchant_ref": "merchant-va-ref-001",
  "blocked_reasons": [],
  "currency": "xsgd",
  "end_to_end_ref": "Acme Fintech 0514023018201",
  "transaction_remarks": null,
  "payment_method": {
    "id": "StraitsX-175932-fc1783e5-7854-4388-8111-035385ff9220",
    "reference_id": "merchant-va-ref-001",
    "account_no": "3225445900001",
    "bank_short_code": "FAZZ",
    "recipient_name": "Xfers Pte Ltd"
  },
  "sender_information": {
    "account_holder_name": "ACME FINTECH PTE. LTD.",
    "account_number": "0721100001",
    "bank_short_code": "DBS",
    "bank_name": "DBS Bank Ltd",
    "end_to_end_ref": "Acme Fintech 0514023018201",
    "swift_bic": "DBSSSGSGXXX",
    "transaction_remarks": null
  },
  "sender_bank": "DBS Bank Ltd",
  "sender_bank_account_no": "0721100001",
  "sender_bank_account_holder_name": "ACME FINTECH PTE. LTD.",
  "sender_bank_swift_bic": "DBSSSGSGXXX",
  "customer_profile_id": "customer_profile_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "created_at": "2026-05-14T02:30:22.492Z",
  "updated_at": "2026-05-14T02:30:22.850Z"
}
```

### Example Payload (USD/XUSD Bank Transfer)

```json
{
  "id": "contract_b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "type": "Direct bank transfer",
  "idempotency_id": "0ded43ab-3f06-498d-a776-8fa8fd8ddf35",
  "amount": "10000.0",
  "fees": "0.0",
  "status": "completed",
  "bank_account_no": "885381014328374",
  "merchant_ref": "100012345",
  "blocked_reasons": [],
  "currency": "xusd",
  "end_to_end_ref": "S0661340E3B601",
  "transaction_remarks": "Payment for services rendered",
  "payment_method": {
    "id": "virtual_account_c3d4e5f6-a7b8-9012-cdef-123456789012",
    "reference_id": "100012345",
    "account_no": "885381014328374",
    "bank_short_code": "DBS",
    "bank_name": "DBS Bank",
    "bank_address": "12 MARINA BOULEVARD, MBFC TOWER 3, SINGAPORE 018982",
    "bank_country": "Singapore",
    "swift_bic": "DBSSSGSGXXX",
    "recipient_name": "ACME FINTECH PTE LTD"
  },
  "sender_information": {
    "account_holder_name": "GLOBEX CORP PTE. LTD.",
    "account_number": "SA 832-011076-001",
    "bank_short_code": null,
    "bank_name": null,
    "end_to_end_ref": "S0661340E3B601",
    "swift_bic": "SABBSARIXXX",
    "transaction_remarks": "Payment for services rendered"
  },
  "sender_bank": null,
  "sender_bank_account_no": "SA 832-011076-001",
  "sender_bank_account_holder_name": "GLOBEX CORP PTE. LTD.",
  "sender_bank_swift_bic": "SABBSARIXXX",
  "customer_profile_id": "customer_profile_d4e5f6a7-b8c9-0123-def0-234567890123",
  "created_at": "2026-05-14T05:37:27.759Z",
  "updated_at": "2026-05-14T05:37:28.672Z"
}
```

### Example Payload (PayNow)

```json
{
  "id": "contract_a1b2c3d4e5f6789012345678abcdef01",
  "type": "paynowTransaction",
  "idempotency_id": "2026051400001234",
  "amount": "50.0",
  "fees": "0.0",
  "status": "completed",
  "bank_account_no": null,
  "merchant_ref": "2026051400001234",
  "blocked_reasons": [],
  "currency": "xsgd",
  "end_to_end_ref": "paynow1a2b3c4d5e6f789012",
  "transaction_remarks": null,
  "payment_method": {
    "id": "paynow_b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "reference_id": "2026051400001234",
    "base64_encoded_image": "<base64 QR code image>",
    "qr_code_data": "00020101021226650009SG.PAYNOW...",
    "expires_at": "2026-05-14T14:25:32.000Z"
  },
  "sender_information": {
    "account_holder_name": "Jane Smith",
    "account_number": "1234567890",
    "bank_short_code": "UOB",
    "bank_name": "United Overseas Bank Ltd",
    "end_to_end_ref": "paynow1a2b3c4d5e6f789012",
    "swift_bic": "UOVBSGSGXXX",
    "transaction_remarks": null
  },
  "sender_bank": "United Overseas Bank Ltd",
  "sender_bank_account_no": "1234567890",
  "sender_bank_account_holder_name": "Jane Smith",
  "sender_bank_swift_bic": "UOVBSGSGXXX",
  "customer_profile_id": "customer_profile_c3d4e5f6-a7b8-9012-cdef-123456789012",
  "created_at": "2026-05-14T14:19:33.483Z",
  "updated_at": "2026-05-14T14:19:58.509Z"
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique contract ID. Use for deduplication. |
| `type` | string | `"Direct bank transfer"` for bank transfers, `"paynowTransaction"` for PayNow |
| `idempotency_id` | string | Your external reference ID (if provided during VBA creation) |
| `amount` | string | Payment amount received |
| `fees` | string | Fees charged |
| `status` | string | `"pending"`, `"completed"`, or `"refunded"` |
| `bank_account_no` | string | VBA account number that received the payment |
| `merchant_ref` | string | Your merchant reference |
| `blocked_reasons` | array | Reasons the payment is held (empty if not blocked). See blocked codes in transaction-safety docs. |
| `currency` | string | Currency code (lowercase, e.g., `"sgd"`, `"usd"`) |
| `end_to_end_ref` | string | Bank end-to-end reference |
| `transaction_remarks` | string | Sender's transaction remarks/notes |
| `payment_method` | object | Details of the payment method. Structure differs by currency and payment type (see examples above). |
| `payment_method.id` | string | Payment method ID |
| `payment_method.reference_id` | string | Your reference ID |
| `payment_method.account_no` | string | (Bank transfer) VBA account number |
| `payment_method.bank_short_code` | string | (Bank transfer) Bank short code |
| `payment_method.bank_name` | string | (USD/XUSD bank transfer) Bank full name |
| `payment_method.bank_address` | string | (USD/XUSD bank transfer) Bank address |
| `payment_method.bank_country` | string | (USD/XUSD bank transfer) Bank country |
| `payment_method.swift_bic` | string | (USD/XUSD bank transfer) SWIFT/BIC code |
| `payment_method.recipient_name` | string | (Bank transfer) Registered recipient name |
| `payment_method.virtual_payment_address` | string | (PayNow) Virtual payment address |
| `payment_method.base64_encoded_image` | string | (PayNow) Base64-encoded QR code image |
| `payment_method.qr_code_data` | string | (PayNow) QR code data string |
| `payment_method.expires_at` | string | (PayNow) Payment expiry timestamp |
| `sender_information` | object | Details about who sent the payment |
| `sender_information.account_holder_name` | string | Sender's name |
| `sender_information.account_number` | string | Sender's bank account number |
| `sender_information.bank_short_code` | string | Sender's bank short code |
| `sender_information.bank_name` | string | Sender's bank full name |
| `sender_information.swift_bic` | string | Sender's SWIFT/BIC code |
| `sender_information.end_to_end_ref` | string | End-to-end reference from sender's bank |
| `sender_information.transaction_remarks` | string | Remarks from sender |
| `customer_profile_id` | string | Customer profile this payment belongs to (if applicable) |
| `created_at` | string | ISO 8601 timestamp when the transaction was created |
| `updated_at` | string | ISO 8601 timestamp when the status last changed |

---

## `payoutStatusUpdated`

Fires when a payout or withdrawal status changes (e.g., `pending` → `completed` or `failed`).

This event covers two payout types with different payload structures:
- **Bank transfer payout** — regular SGD/USD payouts to bank accounts. Payload uses flat JSON with `type: "Withdrawal on behalf"`.
- **FX payout** — cross-currency payouts (e.g., XUSD → IDR). Payload uses JSON:API format with `data.type: "fxPayout"`.

Distinguish between them by checking the response structure: FX payouts are wrapped in `data.attributes`, while bank transfer payouts are flat JSON.


### Example Payload (SGD Payout)

```json
{
  "id": "contract_b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "type": "Withdrawal on behalf",
  "idempotency_id": "payout-unique-key-456",
  "amount": "500.0",
  "fees": "0.0",
  "status": "completed",
  "account_no": "1234567890",
  "bank_abbrev": "OCBC",
  "failure_reason": "",
  "arrival": "13 May 2026 - 10:51 PM",
  "currency": "sgd",
  "payout_invoice_id": "payout-unique-key-456",
  "wallet_name": "Digital Goods",
  "external_reference": "payout-unique-key-456",
  "created_at": "2026-05-13T14:51:07.967Z",
  "updated_at": "2026-05-13T14:51:09.814Z",
  "express": "FAST"
}
```

### Example Payload (USD Payout)

```json
{
  "id": "contract_c3d4e5f6-a7b8-9012-cdef-123456789012",
  "type": "Withdrawal on behalf",
  "idempotency_id": "payout-usd-unique-key-789",
  "amount": "10000.0",
  "fees": "0.0",
  "status": "completed",
  "account_no": "068760057173",
  "bank_abbrev": "",
  "failure_reason": "",
  "arrival": "14 May 2026 -  9:11 AM",
  "currency": "usd",
  "payout_invoice_id": "payout-usd-unique-key-789",
  "wallet_name": "Digital Goods",
  "bank_account_holder_name": "Acme Corp Pte. Ltd.",
  "swift_bic": "TSIBTWTP",
  "beneficiary_address": "123 Main Street, Singapore, SG, 018982",
  "routing_code": "",
  "intermediary_swift_bic": "",
  "description": null,
  "external_reference": "payout-ext-ref-789",
  "charge_option": "OUR",
  "created_at": "2026-05-14T01:11:03.800Z",
  "updated_at": "2026-05-14T01:11:27.946Z"
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique contract ID. Use for deduplication. |
| `type` | string | Always `"Withdrawal on behalf"` |
| `idempotency_id` | string | Your idempotency key from the payout request |
| `amount` | string | Payout amount |
| `fees` | string | Fees charged |
| `status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `account_no` | string | Recipient bank account number |
| `bank_abbrev` | string | Recipient bank short code (may be empty for USD/international payouts) |
| `failure_reason` | string | Reason for failure (empty string if not failed) |
| `arrival` | string | Formatted arrival time (populated when completed) |
| `currency` | string | Currency code (lowercase) |
| `payout_invoice_id` | string | Your payout invoice/reference ID |
| `wallet_name` | string | Wallet name associated with the payout |
| `bank_account_holder_name` | string | (USD only) Recipient account holder name |
| `swift_bic` | string | (USD only) Recipient SWIFT/BIC code |
| `beneficiary_address` | string | (USD only) Recipient address |
| `routing_code` | string | (USD only) Bank routing code |
| `intermediary_swift_bic` | string | (USD only) Intermediary bank SWIFT code |
| `description` | string/null | (USD only) Payment description |
| `external_reference` | string | Your external reference |
| `charge_option` | string | (USD only) Charge option (`"SHA"` or `"OUR"`) |
| `created_at` | string | ISO 8601 timestamp when the transaction was created |
| `updated_at` | string | ISO 8601 timestamp when the status last changed |
| `express` | string | (SGD only) `"FAST"` if sent via FAST network |

### Example Payload (FX Payout — Direct)

FX payouts also fire `payoutStatusUpdated`. Distinguish them from regular payouts by checking `data.type` = `"fxPayout"`.

```json
{
  "data": {
    "id": "contract_a7b8c9d0-e1f2-3456-0123-567890123456",
    "type": "fxPayout",
    "attributes": {
      "status": "completed",
      "quoteId": "fx_quote_6ac94cb6-d36a-4ed6-866b-eea25dca2d3b",
      "recipientId": "payout_recipient_654ad8a5-474b-4a0f-a4ea-170fe6a39de4",
      "rate": "16388.30689414",
      "from": { "currency": "XUSD", "amount": "91.53" },
      "to": { "currency": "IDR", "amount": "1500000.0" },
      "fee": { "currency": "XUSD", "amount": "0.0" },
      "initiator": null,
      "references": {
        "externalReference": null,
        "internalReference": "INV-2026-001"
      },
      "createdAt": "2026-05-11T10:00:00+08:00",
      "updatedAt": "2026-05-11T10:05:00+08:00"
    }
  }
}
```

### Example Payload (FX Payout — onBehalfOf)

```json
{
  "data": {
    "id": "contract_b8c9d0e1-f2a3-4567-1234-678901234567",
    "type": "fxPayout",
    "attributes": {
      "status": "completed",
      "quoteId": "fx_quote_7bd05dc7-e47b-5fe7-977c-ffb36eca3e4c",
      "recipientId": "payout_recipient_38bb768d-37f5-4e85-a782-223db6961d4f",
      "rate": "16388.30689414",
      "from": { "currency": "XUSD", "amount": "91.53" },
      "to": { "currency": "IDR", "amount": "1500000.0" },
      "fee": { "currency": "XUSD", "amount": "0.0" },
      "initiator": {
        "mode": "onBehalfOf",
        "customerProfileId": "customer_profile_8e1ebc55-ec98-4b09-a0c8-21dc5df2cf44"
      },
      "references": {
        "externalReference": null,
        "internalReference": "INV-2026-002"
      },
      "createdAt": "2026-05-11T11:00:00+08:00",
      "updatedAt": "2026-05-11T11:05:00+08:00"
    }
  }
}
```

### FX Payout Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique payout contract ID. Use for deduplication. |
| `data.type` | string | `"fxPayout"` (distinguishes from regular payouts) |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.quoteId` | string | The FX quote ID used for this payout |
| `data.attributes.recipientId` | string | The payout recipient ID |
| `data.attributes.rate` | string | FX rate applied |
| `data.attributes.from` | object | Source currency and amount |
| `data.attributes.to` | object | Target currency and amount |
| `data.attributes.fee` | object | Fee details |
| `data.attributes.initiator` | object/null | `null` for direct payouts, populated for onBehalfOf |
| `data.attributes.references` | object | Your reference IDs |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |
| `data.attributes.updatedAt` | string | ISO 8601 timestamp |

---

## `cpVerificationStatusUpdated`

Fires when a customer profile verification status changes (e.g., `pending` → `verified` or `rejected`).


### Example Payload (Personal CP)

```json
{
  "data": {
    "id": "customer_profile_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "customer_profile",
    "attributes": {
      "customerName": "Jane Doe",
      "registrationType": "personal",
      "registrationId": "S1234567A",
      "verificationStatus": "verified",
      "dateOfBirth": "1990-01-15",
      "gender": "FEMALE",
      "nationality": "SG",
      "email": "jane.doe@example.com",
      "address": {
        "street": "123 Orchard Road",
        "city": "Singapore",
        "country": "SG",
        "postalCode": "238888"
      },
      "registrationIdCountry": "SG",
      "registrationIdType": "identity_card",
      "createdAt": "2026-05-14T08:16:53Z",
      "updatedAt": "2026-05-14T08:17:55Z"
    }
  }
}
```

### Example Payload (Business CP)

```json
{
  "data": {
    "id": "customer_profile_b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "type": "customer_profile",
    "attributes": {
      "customerName": "Acme Fintech Pte Ltd",
      "registrationType": "business",
      "registrationId": "202012345R",
      "verificationStatus": "verified",
      "address": {
        "street": "10 Albert Street",
        "city": "Singapore",
        "postalCode": "000000",
        "state": null,
        "country": "SG"
      },
      "registrationIdCountry": "SG",
      "placeOfBiz": "10 Albert Street, 000000 Singapore",
      "placeOfBizCountry": "SG",
      "countryOfIncorporation": "SG",
      "dateOfIncorporation": "2020-11-14",
      "registrationIdType": "business_reg_no",
      "createdAt": "2026-05-14T08:04:08Z",
      "updatedAt": "2026-05-14T08:04:55Z"
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique customer profile ID. Use for deduplication. |
| `data.type` | string | Always `"customer_profile"` |
| `data.attributes.customerName` | string | Customer's full name |
| `data.attributes.registrationType` | string | `"personal"` or `"business"` |
| `data.attributes.registrationId` | string | Registration/identity number |
| `data.attributes.verificationStatus` | string | `"pending"`, `"verified"`, or `"rejected"` |
| `data.attributes.isRetryable` | boolean | (Only when rejected) Whether the profile can be resubmitted |
| `data.attributes.verificationRejectionSummary` | string | (Only when rejected) Summary of rejection reasons |
| `data.attributes.riskRating` | object | (If applicable) Risk rating details with status and rejections |
| `data.attributes.dateOfBirth` | string | Date of birth (personal profiles only) |
| `data.attributes.nationality` | string | ISO alpha-2 country code |
| `data.attributes.email` | string | Customer email (personal profiles only) |
| `data.attributes.address` | object | Customer address (if provided) |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |
| `data.attributes.updatedAt` | string | ISO 8601 timestamp |

> **Note:** The examples above show commonly returned fields. Optional fields that were not provided during profile creation may be omitted from the payload or returned as `null`. Customer Profile+ (CP+) callbacks use the same structure but include additional fields when provided during onboarding. Personal CP+ may include: `occupation`, `businessIndustry`, `expectedAnnualTransactionAmount`, `expectedTransactionSize`, `expectedTransactionFrequency`, `annualIncome`, `totalWealth`, `sourceOfWealth`, `identityDocuments`. Business CP+ may include: `tradingName`, `directors`, `beneficialOwners`, `trader`, `natureOfBusiness`, `entityLegalForm`, `monthlyTransactionVolume`, `sourceOfFunds`, `documents`.

---

## `cpbaVerificationStatusUpdated`

Fires when a customer profile bank account verification status changes.


### Example Payload

```json
{
  "id": 12345,
  "account_no": "LT073250064800012345",
  "account_holder_name": "John Doe",
  "bank_abbrev": "SWIFT",
  "disabled": false,
  "verification_status": "verified",
  "bank_account_proof": "https://example.com/proof.png",
  "updated_at": "2026-05-12T01:05:09.931Z",
  "swift_bic": "REVOLT21XXX"
}
```

> **Note:** The payload structure is the same for all status transitions (`pending`, `verified`, `rejected`). Only the `verification_status` value changes.

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Bank account record ID |
| `account_no` | string | Bank account number |
| `account_holder_name` | string | Name of the account holder |
| `bank_abbrev` | string | Bank short code (e.g., `"DBS"`, `"OCBC"`) |
| `disabled` | boolean | Whether the bank account has been deleted/disabled |
| `verification_status` | string | `"pending"`, `"verified"`, or `"rejected"` |
| `bank_account_proof` | string | URL of the uploaded bank account proof document |
| `swift_bic` | string | (If applicable) SWIFT/BIC code |
| `intermediary_swift_bic` | string | (If applicable) Intermediary bank SWIFT code |
| `routing_code` | string | (If applicable) Bank routing code |
| `payment_reason` | string | (If applicable) Purpose of payment |
| `updated_at` | string | ISO 8601 timestamp when the status last changed |

---

## `virtualAccountStatusUpdated`

Fires when a virtual bank account is enabled or disabled.


### Example Payload

```json
{
  "data": {
    "id": "virtual_account_b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "type": "virtual_bank_account",
    "attributes": {
      "referenceId": "your-reference-id-456",
      "currency": "USD",
      "status": "enabled",
      "instructions": {
        "recipientName": "ACME FINTECH PTE LTD",
        "bankName": "DBS Bank",
        "bankAddress": "12 MARINA BOULEVARD, MBFC TOWER 3, SINGAPORE 018982",
        "bankCountry": "Singapore",
        "swiftBic": "DBSSSGSGXXX",
        "accountNo": "885375012470001"
      },
      "createdAt": "2026-05-14T08:04:56.973Z"
    }
  }
}
```

> **Note:** This callback is primarily relevant for USD virtual accounts, which go through an activation/rejection flow. SGD virtual accounts are auto-enabled on creation and typically do not trigger this callback.

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique virtual bank account ID |
| `data.type` | string | Always `"virtual_bank_account"` |
| `data.attributes.referenceId` | string | Your reference ID for this VBA |
| `data.attributes.currency` | string | Currency code (e.g., `"USD"`) |
| `data.attributes.status` | string | `"enabled"` or `"disabled"` |
| `data.attributes.instructions` | object | Bank account details for receiving payments. Only included when the VBA is enabled. |
| `data.attributes.instructions.recipientName` | string | Recipient name |
| `data.attributes.instructions.bankName` | string | Bank full name |
| `data.attributes.instructions.bankAddress` | string | Bank address |
| `data.attributes.instructions.bankCountry` | string | Bank country |
| `data.attributes.instructions.swiftBic` | string | SWIFT/BIC code |
| `data.attributes.instructions.accountNo` | string | Virtual bank account number |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |

---

## `userWithdrawalStatusUpdated`

Fires when a user withdrawal (bank transfer out from your business account) status changes.


### Example Payload

```json
{
  "data": {
    "id": "contract_c3d4e5f6-a7b8-9012-cdef-123456789012",
    "type": "withdrawal",
    "attributes": {
      "amount": "500.0",
      "fees": "0.0",
      "transactionRemarks": "Monthly supplier payment",
      "idempotencyId": "withdrawal-unique-key-789",
      "currency": "sgd",
      "bankAccount": {
        "account_no": "1234567890",
        "account_holder_name": "Acme Pte Ltd",
        "bank": "SCB",
        "swift_bic": "SCBLSG22XXX",
        "routing_code": null,
        "intermediary_swift_bic": null
      },
      "status": "completed",
      "netAmount": "500.0",
      "createdAt": "2026-05-11T10:00:00+08:00",
      "updatedAt": "2026-05-11T10:15:00+08:00"
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique withdrawal contract ID. Use for deduplication. |
| `data.type` | string | Always `"withdrawal"` |
| `data.attributes.amount` | string | Withdrawal amount |
| `data.attributes.fees` | string | Fees charged |
| `data.attributes.transactionRemarks` | string | Your transaction remarks/notes |
| `data.attributes.idempotencyId` | string | Your idempotency key from the withdrawal request |
| `data.attributes.currency` | string | Currency code (lowercase, e.g., `"sgd"`, `"usd"`) |
| `data.attributes.bankAccount` | object | Recipient bank account details |
| `data.attributes.bankAccount.account_no` | string | Bank account number |
| `data.attributes.bankAccount.account_holder_name` | string | Account holder name |
| `data.attributes.bankAccount.bank` | string | Bank short code |
| `data.attributes.bankAccount.swift_bic` | string/null | SWIFT/BIC code (if applicable) |
| `data.attributes.bankAccount.routing_code` | string/null | Routing code (if applicable) |
| `data.attributes.bankAccount.intermediary_swift_bic` | string/null | Intermediary bank SWIFT code (if applicable) |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.netAmount` | string | Total amount (amount + fees) |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |
| `data.attributes.updatedAt` | string | ISO 8601 timestamp |

---

## `userDepositStatusUpdated`

Fires when a user deposit (bank transfer in to your business account) status changes.


### Example Payload

```json
{
  "data": {
    "id": "contract_d4e5f6a7-b8c9-0123-def0-234567890123",
    "type": "bankTransfer",
    "attributes": {
      "idempotencyId": "deposit-external-ref-001",
      "currency": "sgd",
      "amount": "2500.0",
      "fees": "0.0",
      "status": "completed",
      "createdAt": "2026-05-11T09:00:00+08:00",
      "senderInformation": {
        "accountHolderName": "John Doe",
        "accountNumber": "9876543210",
        "swiftBic": "OCBCSGSG",
        "transactionRemarks": "Invoice payment #1234",
        "endToEndRef": "20260511OCBCSGSGXXXX0002"
      },
      "blockedReasons": []
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique deposit contract ID. Use for deduplication. |
| `data.type` | string | Always `"bankTransfer"` |
| `data.attributes.idempotencyId` | string | External reference ID |
| `data.attributes.currency` | string | Currency code (lowercase) |
| `data.attributes.amount` | string | Deposit amount received |
| `data.attributes.fees` | string | Fees charged |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.senderInformation` | object | Details about who sent the deposit |
| `data.attributes.senderInformation.accountHolderName` | string | Sender's name |
| `data.attributes.senderInformation.accountNumber` | string | Sender's bank account number |
| `data.attributes.senderInformation.swiftBic` | string | Sender's SWIFT/BIC code |
| `data.attributes.senderInformation.transactionRemarks` | string | Sender's transaction remarks |
| `data.attributes.senderInformation.endToEndRef` | string | Bank end-to-end reference |
| `data.attributes.blockedReasons` | array | Reasons the deposit is held (empty if not blocked) |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |

---

## `stablecoinWithdrawalStatusUpdated`

Fires when a blockchain/stablecoin withdrawal status changes.


### Example Payload

```json
{
  "data": {
    "id": "contract_e5f6a7b8-c9d0-1234-ef01-345678901234",
    "type": "stablecoin_withdraw_contract",
    "attributes": {
      "transaction_hash": "0x4ee49a7f2b9648bb25c431c2fba0298488f1d6a32eed0d6495cf57d5fef85a68",
      "amount": "30.0",
      "network_fees": "0.01",
      "total_amount": "30.01",
      "transaction_source": "0x742d35Cc6634C0532925a3b844Bc9e7595f2bD28",
      "status": "completed",
      "idempotency_id": "blockchain-withdrawal-001",
      "network": "Ethereum",
      "token": "xsgd",
      "blockchain": "XSGD_ERC20",
      "created_at": "2026-05-07T12:08:22.269Z"
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique withdrawal contract ID. Use for deduplication. |
| `data.type` | string | Always `"stablecoin_withdraw_contract"` |
| `data.attributes.transaction_hash` | string | Blockchain transaction hash (or `"pending"` if not yet confirmed) |
| `data.attributes.amount` | string | Withdrawal amount |
| `data.attributes.network_fees` | string | Network/gas fees charged |
| `data.attributes.total_amount` | string | Total amount (amount + network fees) |
| `data.attributes.transaction_source` | string | Source blockchain address |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.idempotency_id` | string | Your idempotency key |
| `data.attributes.network` | string | Blockchain network name (e.g., `"Ethereum"`, `"Polygon"`, `"Avalanche"`) |
| `data.attributes.token` | string | Token/currency (e.g., `"xsgd"`, `"xusd"`) |
| `data.attributes.blockchain` | string | Token standard (e.g., `"XSGD_ERC20"`, `"XSGD_AVAX"`) |
| `data.attributes.created_at` | string | ISO 8601 timestamp |

---

## `stablecoinDepositStatusUpdated`

Fires when a blockchain/stablecoin deposit status changes.

### Example Payload

```json
{
  "data": {
    "id": "contract_f6a7b8c9-d0e1-2345-f012-456789012345",
    "type": "stablecoin_deposit_contract",
    "attributes": {
      "transaction_hash": "0x9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8",
      "amount": "500.0",
      "network_fees": "0.0",
      "total_amount": "500.0",
      "transaction_source": "0x9876543210abcdef9876543210abcdef98765432",
      "status": "completed",
      "idempotency_id": "e8b7c6d5a4f3e2d1c0b9a8f7e6d5c4b3",
      "network": "Ethereum",
      "token": "xsgd",
      "blockchain": "XSGD_ERC20",
      "created_at": "2026-05-11T10:00:00.000+08:00",
      "blocked_reasons": []
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique deposit contract ID. Use for deduplication. |
| `data.type` | string | Always `"stablecoin_deposit_contract"` |
| `data.attributes.transaction_hash` | string | Blockchain transaction hash |
| `data.attributes.amount` | string | Deposit amount received |
| `data.attributes.network_fees` | string | Network/gas fees (typically `"0.0"` for deposits) |
| `data.attributes.total_amount` | string | Total amount (amount + network fees) |
| `data.attributes.transaction_source` | string | Source blockchain address that sent the deposit |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.idempotency_id` | string | External reference ID |
| `data.attributes.network` | string | Blockchain network name (e.g., `"Ethereum"`, `"Polygon"`, `"Avalanche"`) |
| `data.attributes.token` | string | Token/currency received (e.g., `"xsgd"`, `"xusd"`) |
| `data.attributes.blockchain` | string | Token standard (e.g., `"XSGD_ERC20"`, `"XUSD_ERC20"`) |
| `data.attributes.created_at` | string | ISO 8601 timestamp |
| `data.attributes.blocked_reasons` | array | Reasons the deposit is held (empty if not blocked) |

---

## `swapUpdated`

Fires when a swap transaction status changes (e.g., XSGD ↔ XUSD conversion).


### Example Payload

```json
{
  "data": {
    "id": "contract_f6a7b8c9-d0e1-2345-f012-456789012345",
    "type": "swapTransaction",
    "attributes": {
      "idempotencyId": "swap-unique-key-001",
      "quoteId": "quote-uuid-abc123",
      "status": "completed",
      "swapPair": "XSGDXUSD",
      "sourceCurrency": "XSGD",
      "targetCurrency": "XUSD",
      "fixedSide": "source",
      "totalSourceCurrencyAmount": "1350.0",
      "sourceCurrencyAmount": "1350.0",
      "targetCurrencyAmount": "1000.0",
      "rate": "0.7407",
      "fees": [
        {
          "type": "TransactionFee",
          "amount": "0.0",
          "currency": "XSGD"
        }
      ],
      "createdAt": "2026-05-11T10:00:00+08:00",
      "updatedAt": "2026-05-11T10:00:05+08:00",
      "customerProfileId": null
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Unique swap contract ID. Use for deduplication. |
| `data.type` | string | Always `"swapTransaction"` |
| `data.attributes.idempotencyId` | string | Your idempotency key from the swap execution request |
| `data.attributes.quoteId` | string | The quote ID that was executed |
| `data.attributes.status` | string | `"pending"`, `"completed"`, or `"failed"` |
| `data.attributes.swapPair` | string | Currency pair (e.g., `"XSGDXUSD"`, `"XUSDXSGD"`) |
| `data.attributes.sourceCurrency` | string | Source currency code |
| `data.attributes.targetCurrency` | string | Target currency code |
| `data.attributes.fixedSide` | string | Which side was fixed: `"source"` or `"target"` |
| `data.attributes.totalSourceCurrencyAmount` | string | Total source amount (including fees) |
| `data.attributes.sourceCurrencyAmount` | string | Source amount (excluding fees) |
| `data.attributes.targetCurrencyAmount` | string | Target amount received |
| `data.attributes.rate` | string | Exchange rate applied |
| `data.attributes.fees` | array | Fee breakdown (empty array `[]` if no fees) |
| `data.attributes.fees[].type` | string | Fee type (e.g., `"TransactionFee"`) |
| `data.attributes.fees[].amount` | string | Fee amount |
| `data.attributes.fees[].currency` | string | Fee currency |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |
| `data.attributes.updatedAt` | string | ISO 8601 timestamp |
| `data.attributes.customerProfileId` | string/null | Customer profile ID (if swap was on behalf of a CP) |

---

## `cpTxnLimitsUpdated`

Fires when a customer profile's transaction limits change (e.g., after verification tier upgrade). Applicable to Customer Profile+ (CP+) only.


### Example Payload (Personal CP+)

```json
{
  "data": {
    "id": "customer_profile_transaction_limit_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "attributes": {
      "customerProfileId": "customer_profile_b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "totalAnnualPaymentLimit": "50000.0",
      "availableAnnualPaymentLimit": "48500.0",
      "totalAnnualPayoutLimit": "50000.0",
      "availableAnnualPayoutLimit": "49000.0",
      "transactionSizeLimit": "10000.0"
    }
  }
}
```

### Example Payload (Business CP+)

```json
{
  "data": {
    "id": "customer_profile_transaction_limit_c3d4e5f6-a7b8-9012-cdef-123456789012",
    "attributes": {
      "customerProfileId": "customer_profile_d4e5f6a7-b8c9-0123-def0-234567890123",
      "totalDailyPaymentLimit": "300000.0",
      "availableDailyPaymentLimit": "300000.0",
      "totalDailyPayoutLimit": "300000.0",
      "availableDailyPayoutLimit": "300000.0",
      "transactionSizeLimit": "50000.0"
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Transaction limits record ID |
| `data.attributes.customerProfileId` | string | Customer profile this limit belongs to |
| `data.attributes.totalAnnualPaymentLimit` | string | (Personal CP+) Total annual payment limit in USD |
| `data.attributes.availableAnnualPaymentLimit` | string | (Personal CP+) Remaining annual payment limit |
| `data.attributes.totalAnnualPayoutLimit` | string | (Personal CP+) Total annual payout limit in USD |
| `data.attributes.availableAnnualPayoutLimit` | string | (Personal CP+) Remaining annual payout limit |
| `data.attributes.totalDailyPaymentLimit` | string | (Business CP+) Total daily payment limit in USD |
| `data.attributes.availableDailyPaymentLimit` | string | (Business CP+) Remaining daily payment limit |
| `data.attributes.totalDailyPayoutLimit` | string | (Business CP+) Total daily payout limit in USD |
| `data.attributes.availableDailyPayoutLimit` | string | (Business CP+) Remaining daily payout limit |
| `data.attributes.transactionSizeLimit` | string/null | Maximum single transaction size in USD |

> **Note:** Personal CP+ profiles include annual limits only. Business CP+ profiles include daily limits only. The `transactionSizeLimit` field appears for both.

---

## `cpTxnLimitsUpdateRequestStatusUpdated`

Fires when a transaction limits update request status changes (e.g., `pending` → `approved` or `rejected`). Applicable to Customer Profile+ (CP+) only.


### Example Payload

```json
{
  "data": {
    "id": "transaction_limits_update_request_b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "type": "transactionLimitsUpdateRequest",
    "attributes": {
      "status": "approved",
      "customerProfileId": "customer_profile_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "updatedAt": "2026-05-03T14:30:00+08:00",
      "createdAt": "2026-05-01T10:00:00+08:00"
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | Update request ID |
| `data.type` | string | Always `"transactionLimitsUpdateRequest"` |
| `data.attributes.status` | string | `"pending"`, `"approved"`, or `"rejected"` |
| `data.attributes.customerProfileId` | string | Customer profile this request belongs to |
| `data.attributes.createdAt` | string | ISO 8601 timestamp |
| `data.attributes.updatedAt` | string | ISO 8601 timestamp |

---

## `cpRfiStatusUpdated`

Fires when a Request for Information (RFI) status changes during customer profile onboarding.


### Example Payload

```json
{
  "data": {
    "id": "rfi_request_0b3k17mmb63gcx55",
    "type": "rfiRequest",
    "attributes": {
      "customerProfileId": "customer_profile_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "activeRfiRequest": {
        "createdAt": "2026-05-14T03:11:13Z",
        "status": "sent",
        "rfiQuestions": [
          {
            "id": 1001,
            "question": "Please provide an indication of your estimated total wealth",
            "optional": false,
            "replyType": "CHECKBOX",
            "questionStatus": "pending",
            "requiresAction": true,
            "checkboxOptions": ["<S$100,000", "S$100,000 - S$250,000", "S$250,001 - S$500,000", "S$500,000 - S$1,000,000", ">S$1,000,000"]
          },
          {
            "id": 1002,
            "question": "Please declare your source(s) of wealth",
            "optional": false,
            "replyType": "TEXT",
            "questionStatus": "pending",
            "requiresAction": true
          },
          {
            "id": 1003,
            "question": "Please upload relevant supporting documents to substantiate your source(s) of wealth",
            "optional": false,
            "replyType": "DOC",
            "questionStatus": "pending",
            "requiresAction": true
          }
        ]
      },
      "rfiProgressSummary": {
        "expiryDate": "2026-05-28T16:59:59Z",
        "daysUntilExpiry": 14,
        "daysExpired": 0,
        "completionPercentage": 0,
        "totalQuestions": 3,
        "acceptedQuestions": 0,
        "pendingQuestions": 3,
        "rejectedQuestions": 0
      }
    }
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `data.id` | string | RFI request ID (format: `rfi_request_<id>`) |
| `data.type` | string | Always `"rfiRequest"` |
| `data.attributes.customerProfileId` | string | Customer profile this RFI belongs to |
| `data.attributes.activeRfiRequest` | object | Current RFI details |
| `data.attributes.activeRfiRequest.status` | string | Overall RFI status |
| `data.attributes.activeRfiRequest.rfiQuestions` | array | List of questions to answer |
| `data.attributes.activeRfiRequest.rfiQuestions[].id` | integer | Question ID |
| `data.attributes.activeRfiRequest.rfiQuestions[].question` | string | Question text |
| `data.attributes.activeRfiRequest.rfiQuestions[].replyType` | string | Expected reply type (e.g., `"DOC"`, `"TEXT"`) |
| `data.attributes.activeRfiRequest.rfiQuestions[].userReply` | object/null | User's submitted reply (omitted if not yet replied) |
| `data.attributes.activeRfiRequest.rfiQuestions[].questionStatus` | string | `"pending"`, `"submitted"`, `"accepted"`, `"rejected"` |
| `data.attributes.activeRfiRequest.rfiQuestions[].rejectionReason` | string | Reason for rejection (omitted if not rejected) |
| `data.attributes.activeRfiRequest.rfiQuestions[].requiresAction` | boolean | Whether the user needs to take action |
| `data.attributes.rfiProgressSummary` | object | Progress overview |
| `data.attributes.rfiProgressSummary.expiryDate` | string | ISO 8601 deadline for RFI completion |
| `data.attributes.rfiProgressSummary.daysUntilExpiry` | integer | Days remaining before expiry |
| `data.attributes.rfiProgressSummary.completionPercentage` | integer | Percentage of questions accepted (0–100) |
| `data.attributes.rfiProgressSummary.totalQuestions` | integer | Total number of questions |
| `data.attributes.rfiProgressSummary.acceptedQuestions` | integer | Questions accepted |
| `data.attributes.rfiProgressSummary.pendingQuestions` | integer | Questions awaiting response |
| `data.attributes.rfiProgressSummary.rejectedQuestions` | integer | Questions rejected (need resubmission) |

---

## `cpbaCreated`

Fires when a new customer profile bank account is created.


### Example Payload

Same structure as `cpbaVerificationStatusUpdated`:

```json
{
  "id": 12346,
  "account_no": "9876543210",
  "account_holder_name": "Acme Pte Ltd",
  "bank_abbrev": "OCBC",
  "disabled": false,
  "verification_status": "pending",
  "bank_account_proof": "https://example.com/proof.png",
  "swift_bic": "OCBCSGSG",
  "updated_at": "2026-05-11T10:00:00.000+08:00"
}
```

### Field Descriptions

Same fields as `cpbaVerificationStatusUpdated`. The `verification_status` will typically be `"pending"` at creation time.

---

## `ubaCreated`

Fires when a new user bank account is created.


### Example Payload

```json
{
  "id": 67890,
  "account_no": "1234567890",
  "account_holder_name": "John Doe",
  "bank_abbrev": "DBS",
  "disabled": false,
  "verification_status": "pending",
  "bank_account_proof": "https://example.com/bank-proof.png",
  "swift_bic": "DBSSSGSG",
  "updated_at": "2026-05-11T10:00:00.000+08:00"
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Bank account record ID |
| `account_no` | string | Bank account number |
| `account_holder_name` | string | Account holder name |
| `bank_abbrev` | string | Bank short code (e.g., `"DBS"`, `"OCBC"`) |
| `disabled` | boolean | Whether the bank account has been deleted/disabled |
| `verification_status` | string | `"pending"`, `"verified"`, or `"rejected"` |
| `bank_account_proof` | string | URL of the uploaded bank account proof document |
| `swift_bic` | string | (If applicable) SWIFT/BIC code |
| `intermediary_swift_bic` | string | (If applicable) Intermediary bank SWIFT code |
| `routing_code` | string | (If applicable) Bank routing code |
| `updated_at` | string | ISO 8601 timestamp |

---

## `ubaVerificationStatusUpdated`

Fires when a user bank account verification status changes.


### Example Payload

Same structure as `ubaCreated`:

```json
{
  "id": 67890,
  "account_no": "1234567890",
  "account_holder_name": "John Doe",
  "bank_abbrev": "DBS",
  "disabled": false,
  "verification_status": "verified",
  "bank_account_proof": "https://example.com/bank-proof.png",
  "swift_bic": "DBSSSGSG",
  "updated_at": "2026-05-11T14:30:00.000+08:00"
}
```

### Field Descriptions

Same fields as `ubaCreated`. The key difference is `verification_status` will reflect the new status (`"verified"` or `"rejected"`).

---

## Common Fields Across All Events

These fields appear in all callback payloads:

| Field | Description |
|-------|-------------|
| `id` | Unique contract/resource ID — use as deduplication key |
| `status` | Current status — compare against your local state |
| `created_at` / `createdAt` | When the resource was created |
| `updated_at` / `updatedAt` | When the status last changed |

> **Note:** Some callbacks use snake_case field names (e.g., `paymentStatusUpdated`, `cpbaVerificationStatusUpdated`, `ubaCreated`) while others use camelCase (e.g., `userWithdrawalStatusUpdated`, `swapUpdated`, `cpVerificationStatusUpdated`). This depends on the serialization format used for each event type. Always parse based on the actual field names in the payload.
