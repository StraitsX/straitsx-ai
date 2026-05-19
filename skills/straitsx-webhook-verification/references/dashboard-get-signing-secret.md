# Get Signing Secret

## Overview

This guide explains how to navigate to the webhook signing secret (used for HMAC-SHA256 callback verification), reveal/copy it, and understand the active/inactive key states.

## Navigation Path

**Platform Tools → Callback URL → Signing Key card (right sidebar) → eye icon or Setting**

Alternatively: **Platform Tools → Signing Key** (also navigates to the same page)

## Step-by-Step

### 1. Navigate to the Callback URL Page

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **Developer Tools**, click either **Callback URL** or **Signing Key**.
3. You'll land on the Callback URLs page.

### 2. Locate the Signing Key Card

On the right sidebar of the Callback URLs page, you'll see the **Signing Key** card. It displays:

- Label: **"Signing Key"**
- A grey box showing the first 20 characters of your active signing key followed by `...`
- An **eye icon** to reveal the full key
- A **"Setting"** button to manage multiple keys
- Helper text: _"Use this key to verify that webhook requests are from StraitsX. Store it securely."_

### 3. Reveal the Full Signing Secret

1. Click the **eye icon** next to the masked key.
2. An OTP verification modal appears:
   - Title: "Enter Code"
   - Description: _"Enter OTP found in your email in order to access the signing secret."_
   - Click **"Send"** to receive a 6-digit OTP at your registered email address.
   - Enter the OTP in the input field.
   - Click **"Verify"**.
3. On success, a modal displays the **full signing secret** which you can copy.

> **Sandbox mode:** OTP verification is skipped — the secret is revealed immediately.

### 4. Manage Multiple Signing Keys (Setting)

Click the **"Setting"** button on the Signing Key card to open the Signing Key Settings modal.

The modal shows:

- A list of all your signing keys (up to 3 maximum)
- Each key shows the partial secret value
- The currently active key is labeled **(Active)**
- Radio buttons to select which key to activate
- A **delete icon** next to inactive keys
- A **"+ Generate a New Key"** button (if fewer than 3 keys exist)
- A **"Save"** button to confirm activation changes

**To generate a new key:**
1. Click **"+ Generate a New Key"**.
2. Complete OTP verification (6-digit email code).
3. The new key appears in the list (inactive by default).

**To activate a different key:**
1. Select the radio button next to the desired key.
2. Click **Save**.
3. Complete OTP verification.
4. The selected key becomes active.

**To delete a key:**
1. Click the delete icon next to an inactive key.
2. A confirmation modal appears: _"This action cannot be undone. The key will be deleted immediately, and any previously verified webhooks using this key will need an alternative."_
3. Click **Delete** and complete OTP verification.

## Important Notes

- **Only one signing key can be active at a time.** StraitsX uses the active key to sign webhook payloads sent to your endpoint. You use the same key to verify that incoming webhooks are genuinely from StraitsX.
- **Maximum 3 signing keys** can exist simultaneously. Generate new keys before revoking old ones for zero-downtime rotation.
- The signing secret is used for **HMAC-SHA256 verification** of webhook callbacks.
- Every sensitive action (reveal, create, activate, delete) requires **email OTP verification** in production. Sandbox mode skips OTP.
- The OTP has a **60-second cooldown** before you can request a new one.
- Store the signing secret securely — it is only fully visible during the reveal flow.
