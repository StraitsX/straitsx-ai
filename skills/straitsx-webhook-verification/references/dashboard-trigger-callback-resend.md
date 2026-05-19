# Trigger Callback Resend and Check Response

## Overview

This guide explains how to find a specific transaction's callback history in the StraitsX Dashboard, trigger a resend, and view the delivery status/response.

## Navigation Path

**Platform Tools → Callback Request History → (select a callback) → Resend Callback**

## Step-by-Step

### 1. Navigate to Callback History

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **General Tools**, click **Callback Request History**.
3. You'll land on the Callback History page with the heading: _"Track and review the delivery status of all your callbacks in one place."_

### 2. Find the Specific Callback

The page displays a table with these columns:

| Column | Description |
|--------|-------------|
| Callback Type | e.g. Bank Transfer In, Stablecoin Withdrawal |
| Event Tag | e.g. `user.fiatdeposit.completed` |
| Last Attempt | Date/time of last delivery attempt |
| Client Response | HTTP response code from your server |
| Status Summary | Delivered, Not Delivered, Retrying, or Pending |

**To filter results:**

1. Click the **"Filter & Sort"** button (top-right).
2. A modal opens with these filter fields:
   - **Callback Type** — dropdown (Bank Transfer In, Bank Transfer Out, Stablecoin Withdrawal, Swap Status Update, Customer Profile Verification, Customer Profile Bank Account, User Bank Account, Virtual Account, Transaction Limits, Transaction Limits Update Request, RFI Request)
   - **Event Tag** — searchable dropdown (e.g. `cp.fiatpayment.completed`, `user.fiatwithdraw.failed`)
   - **Last Attempt Date** — date range picker (DD/MM/YYYY)
   - **Status Summary** — dropdown (Delivered, Not Delivered, Retrying, Pending)
3. Click **Apply** to filter. Click **Back** to cancel.

Results are paginated at 25 items per page.

### 3. View Callback Details

Click any row in the table to open the Callback Detail page.

The detail page shows:

- **Callback Details** section:
  - Callback Type
  - Event Tag
  - Callback URL (the endpoint that was called)
  - **Webhook Payload** — the full JSON request body sent to your server (with copy button)
  - **Client's Response** — the full response body your server returned (with copy button)
  - Status tag (shows `success` or `failed`; may also show `retrying` or `pending`)

- **Delivery Attempts** section:
  - Table columns: Attempt number, Attempt Time, Client Response
  - Tooltip: _"System will retry delivery automatically (up to 20 attempts)."_

- **Transaction Details** sidebar (if applicable):
  - Shows transaction status and key details
  - "View Full Transaction Details" button links to the full transaction page

### 4. Trigger a Resend

1. On the Callback Detail page, click the **"Resend Callback"** button (top-right).
2. A confirmation modal appears:
   - Message: _"This will reattempt delivery of the last callback payload to your registered endpoint. It won't affect the transaction status."_
   - Buttons: **Cancel** | **Resend**
3. Click **Resend** to trigger the resend.
4. On success, a notification appears: _"Webhook resend initiated successfully"_.
5. Click the refresh icon next to "Callback Details" to reload and see the new delivery attempt.

## Important Notes

- Resending does **not** affect the underlying transaction status.
- The system automatically retries failed callbacks up to **20 attempts** before marking as "Not Delivered".
