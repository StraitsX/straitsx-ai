# Register Callback URL

## Overview

This guide explains how to configure webhook/callback URLs for different event types in the StraitsX Dashboard.

## Navigation Path

**Platform Tools → Callback URL → Edit URL → enter URLs → Save Changes**

## Step-by-Step

### 1. Navigate to the Callback URL Page

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **Developer Tools**, click **Callback URL**.
3. You'll land on the Callback URLs page.

### 2. Enter Edit Mode

1. In the main content area, you'll see the section header **"Callback URLs"** with an **"Edit URL"** button.
2. Click **"Edit URL"** to enter edit mode.
3. The button area changes to show **"Cancel"** and **"Save Changes"** buttons.

### 3. Configure URLs by Event Type

The page has two tabs:

#### Tab 1: Client Event

_"Events triggered by your own platform's activity on StraitsX (e.g., deposits, withdrawals, blockchain actions, bank account creation, verification updates)"_

**Payments & Transactions:**

| Field | Description |
|-------|-------------|
| User Deposit Status Update | Triggered when the status of an incoming bank transfer deposit is updated |
| User Withdrawal Status Update | Triggered when the status of a user withdrawal is updated |
| Blockchain Withdrawal Status Update | Triggered when the status of a blockchain withdrawal is updated |
| Blockchain Deposit Status Update | Triggered when the status of a blockchain deposit is updated |
| Swap Status Update | Triggered when the status of a swap transaction is updated |

**Accounts:**

| Field | Description |
|-------|-------------|
| User Bank Account Created | Triggered when your bank account is created |
| User Bank Account Verification Status Updated | Triggered when the verification status of your bank account is updated |
| Virtual Account Status Update | Triggered when the status of a virtual bank account is updated to enabled or disabled |

#### Tab 2: End Customer Event

_"Events triggered by your customers' deposits, withdrawals, and account changes (e.g., payouts, incoming payments, verification status, transaction limits, bank account creation)"_

**Payments & Payout:**

| Field | Description |
|-------|-------------|
| Bank / PayNow Payout Status Update | Triggered when the status of a First party / Third party / Regular payout is updated |
| Bank / PayNow Payment Status Update | Triggered when the status of an incoming bank payment / PayNow payment is updated |

**Accounts:**

| Field | Description |
|-------|-------------|
| Customer Profile Bank Account Created | Triggered when a customer profile bank account is created |
| Customer Profile Bank Account Verification Status Updated | Triggered when the verification status of a customer profile bank account is updated |

**Profile Verification & Limits:**

| Field | Description |
|-------|-------------|
| Customer Profile Verification Status Update | Triggered when the verification status of a customer profile is updated |
| Customer Profile Transaction Limit Update | Triggered when the transaction limit of a customer profile is updated |
| Customer Profile Transaction Limit Update Request Status Update | Triggered when the status of a transaction limit update request is updated |

**Request For Information (RFI):**

| Field | Description |
|-------|-------------|
| Request For Information (RFI) | Triggered when StraitsX requires more information during onboarding and transaction approval |

### 4. Enter Your Callback URLs

1. In edit mode, each event type shows a text input field.
2. Enter your HTTPS endpoint URL (e.g., `https://api.yourcompany.com/webhooks/straitsx`).
3. Fields without a URL show placeholder text: `(no callback)`.
4. Invalid URLs show an error: _"Please enter a valid URL"_.

### 5. Save Changes

1. After entering your URLs, click **"Save Changes"**.
2. The button is disabled if any URL has a validation error.
3. On success, the page exits edit mode and shows the saved URLs in read-only fields.

### 6. Configure Payload Format (Optional)

On the right sidebar, below the Signing Key card, there's a **Payload Format** card where you can select how callback data is sent to your endpoint.

**Available options:**

| Option | Description |
|--------|-------------|
| **JSON** (default) | Callback data is sent as a JSON body in the request |
| **Query** | Callback data is sent as query string parameters |

To change the format:
1. Select the desired option (JSON or Query).
2. The change is saved automatically — the backend will immediately apply the new format to all future callbacks.

> Choose the format that best matches how your server parses incoming webhook requests. Most integrations use JSON.

## Important Notes

- URLs must be valid HTTP/HTTPS endpoints.
- You can set **different URLs for each event type**, or use the same URL for multiple events.
- Leaving a field empty means no callback will be sent for that event type.
- Changes take effect immediately after saving.
- You can view the current URLs without entering edit mode — they're displayed in read-only fields.
- The Signing Key (sidebar) is used to verify that incoming webhooks are genuinely from StraitsX. See the "Get Signing Secret" guide.
