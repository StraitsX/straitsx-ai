# StraitsX API Error Codes

> Reference for AI clients generating error handling code. Source: [Error Responses](https://docs.straitsx.com/docs/errors)

## Response Format

All error responses return JSON in this structure:

```json
{
  "errors": [
    {
      "error": "string",
      "error_code": "string",
      "error_handling": "string"
    }
  ]
}
```

- `error` — error message specific to the request
- `error_code` — unique STX error code
- `error_handling` — instruction on how to resolve

## Error Code Reference

| HTTP Status | STX Code | Category | Common Messages | Handling |
|---|---|---|---|---|
| 401 | STXE-1000 | Authentication | Missing API Key in Header, Invalid API Key, Invalid IP Address | Check API key is present and correct. Verify IP whitelist. |
| 403 | STXE-2000 | Authorization | Restricted API Access | Account may be locked or lacks permission. Contact support. |
| 400 | STXE-3000 | Validation | Custom message (varies) | Check request parameters against the OpenAPI spec. |
| 422 | STXE-4000 | Business Logic | Resource Not Verified, Insufficient Balance, Amount Exceed Limit, Invalid State Transition, Invalid OTP | Context-dependent — see detailed table below. |
| 404 | STXE-5000 | Not Found | Record Not Found, Configuration Not Found | Verify resource IDs and parameters. |
| 403 | STXE-6000 | Environment | Restricted Endpoints Access in Live Mode | Endpoint is sandbox-only. Switch to sandbox mode. |
| 409 | STXE-7000 | Conflict | Duplicated Idempotency Key, Record Existed | Use a different idempotency key or check existing records. |
| 500 | STXE-8XXX | Server Error | Required operation failed | Retry with backoff. If persistent, contact support. |
| 429 | STXE-9000 | Rate Limit | Rate Limit reached for requests | Back off and retry after a delay. |

## STXE-4000 Detail (Business Logic Errors)

These share the same error code but have different messages and handling:

| Message | Handling |
|---|---|
| Resource Object Not Verified | Verify accounts first. |
| Feature Unavailable For Your Region | Check region access for this feature. |
| Feature Unavailable For This Request | Validate parameters for this feature. |
| Threshold Exceeded | Check available limits. |
| Invalid State Transition | Retry later — resource is in a transitional state. |
| Invalid OTP | Provide correct OTP. |
| Insufficient Balance | Ensure account has sufficient balance. |
| Customer Profile Is Not Verified | Verify the customer profile first. |
| Customer Profile Has Insufficient Info | Provide additional customer profile information. |
| Amount Exceed Limit / Daily Limit / Annual Limit | Reduce amount or request limit increase. |
| Resubmission of Verification Info Not Allowed | Cannot re-verify — StraitsX policy restriction. |
| Failure in a contract processing | Contact support. |

## Legacy Error Codes

These older codes are still returned by some endpoints:

| Code | Message | Notes |
|---|---|---|
| XFE5 | Api token is invalid | Same as STXE-1000 |
| XFE6 | Access to this endpoint is denied | Same as STXE-2000 |
| XFE12 | Invalid parameter | Same as STXE-3000 |
| XFE13 | Record not found | Same as STXE-5000 |
| XFE15 | Required parameter empty | Same as STXE-3000 |
| XFE16 | Invalid request / Duplicated request | Same as STXE-1000 |
| XFE21 | Insufficient account balance | Same as STXE-4000 |
| XFE503 | Failed name check | Bank account name mismatch |
| XFE504 | Maximum number of bank accounts | Delete existing accounts |
| XFE505 | Bank abbrev provided invalid | Use GET /api/v3/banks for valid values |
| XFE506 | Required bank data are empty | Provide bank_abbrev, account_no, account_name |
| XFE601 | Conditions to withdraw not met | Adjust amount per response instructions |
| XFE602 | Exceeds limit | Wait or verify account for higher limits |
| XFE603 | Not allowed to carry out request | Call another API or contact support |
| XFE604 | Maximum Limit Merchant Withdrawal | Daily withdrawal limit reached — retry tomorrow |

## Code Generation Guidance

When generating error handling code:

1. Always check for the `errors` array in non-2xx responses.
2. Match on `error_code` (not HTTP status) for specific handling — multiple error types share the same HTTP status.
3. For STXE-4000, parse the `error` message to determine the specific business logic failure.
4. For STXE-8XXX, implement retry with exponential backoff.
5. For STXE-9000, implement rate limiting / backoff.
6. Handle both new (STXE-*) and legacy (XFE*) codes if the integration needs backward compatibility.
