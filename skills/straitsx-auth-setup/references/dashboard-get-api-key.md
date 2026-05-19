# Get API Key

## Overview

This guide explains how to find, reveal, and copy your StraitsX API key from the Dashboard.

## Navigation Path

**Platform Tools → API Keys and IP Whitelisting → API Keys section → eye icon (Show)**

## Step-by-Step

### 1. Navigate to the API Keys Page

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **Developer Tools**, click **API Keys and IP Whitelisting**.
3. You'll land on the "API Keys, Public Key and IP Whitelisting" page.

### 2. Locate Your API Keys

The **API Keys** section is at the top of the page. Each key entry shows:

- **Key name** (label)
- **Created** date
- **Expires** date (if applicable, with a warning if expiring within 30 days)
- A grey box displaying the **masked API key value**
- An **eye icon** to reveal the full key
- A **⋮ (more)** menu with options: "Regenerate Key", "Delete"

### 3. Reveal the Full API Key

1. Click the **eye icon** next to the masked key value.
2. An OTP verification modal appears:
   - Title: "Enter Code"
   - Click **"Send"** to receive a 6-digit OTP at your registered email.
   - Enter the OTP and click **"Verify"**.
3. On success, the full API key is displayed and can be copied.

> **Sandbox mode:** OTP verification may be skipped.

### 4. Create a New API Key

1. At the bottom of the API Keys list, click **"Create New Key"**.
2. A confirmation modal appears.
3. Complete OTP verification.
4. The new key is created and appears in the list.

### 5. Regenerate or Delete a Key

**Regenerate:**
1. Click the **⋮ (more)** menu on the key you want to regenerate.
2. Select **"Regenerate Key"**.
3. Complete OTP verification.
4. A new key value is generated (the old value is invalidated immediately).

**Delete:**
1. Click the **⋮ (more)** menu.
2. Select **"Delete"** (shown in red).
3. Confirm deletion.
4. The key is permanently removed.

## Important Notes

- The API key header name is **`X-XFERS-APP-API-KEY`** — use this in your API request headers.
- Keys have an **enabled/disabled** status. Only enabled keys can authenticate API requests.
- Keys may have an **expiration date**. Monitor the "Expires" field and regenerate before expiry.
- Revealing the full key always requires **email OTP verification** in production.
- Store your API key securely. Do not expose it in client-side code or public repositories.
- You can have multiple API keys active simultaneously.
