# Set Up Public Key for HTTP Request Signing

## Overview

This guide explains how to upload an Ed25519 public key to the StraitsX Dashboard for HTTP request signing, enable the feature, and retrieve the Key ID.

## Navigation Path

**Platform Tools → API Keys and IP Whitelisting → Public Key section → Add Public Key**

## Step-by-Step

### 1. Navigate to the API Keys Page

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **Developer Tools**, click **API Keys and IP Whitelisting**.
3. You'll land on the "API Keys, Public Key and IP Whitelisting" page.
4. Scroll down to the **Public Key** section.

### 2. Add a Public Key

1. At the bottom of the Public Key section, click **"Add Public Key"**.
2. The "Add Public Key" modal opens with these fields:

   | Field | Description |
   |-------|-------------|
   | **Public Key Name** | A label for this key (e.g., "Production Signing Key"). Max 100 characters. |
   | **Ed25519 Public Key** | Paste your Ed25519 SSH public key. Supports ssh-ed25519, base64, or hex formats. |

   - Placeholder for key: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@example.com`
   - Tooltip: _"Paste your Ed25519 SSH public key. Supports multiple formats including ssh-ed25519, base64, or hex."_

3. **Important warning displayed:** _"Only upload your Public Key. StraitsX will never ask for your Private Key. Sharing your Private Key puts your account at risk."_

4. A link is provided: **"Learn how to generate a compatible key pair"** → [docs.straitsx.com/docs/http-request-signing#5-how-do-i-generate-my-key-pair](https://docs.straitsx.com/docs/http-request-signing#5-how-do-i-generate-my-key-pair)

5. Click **"Generate Key"** to submit.
6. On success, the modal closes and the new key appears in the list.

### 3. Retrieve the Key ID

After adding a public key, it appears in the Public Key section with:

- **Key name** (the label you provided)
- **Created** date
- **Last used** date
- **Status badge** — "Enabled" (green) or "Disabled" (grey)
- **Key ID** — displayed in a copyable field with a copy button

**To copy the Key ID:**
1. Locate your key in the list.
2. Find the **"Key ID"** row below the key name.
3. Click the **copy icon** to copy the Key ID to your clipboard.

> The Key ID is what you include in your HTTP request signature headers. It tells StraitsX which public key to use for verification.

### 4. View the Full Public Key

1. Click **"Show Public Key"** (toggle link below the Key ID).
2. The full public key text expands below.
3. Click **"Hide Public Key"** to collapse it.

### 5. Enable HTTP Request Signing

The Public Key section has a **toggle switch** at the top:

1. Ensure you have **at least one enabled public key** before turning on the toggle.
2. Flip the toggle to **"Enabled"**.
3. If no keys are enabled, you'll see an error: _"Please enable at least 1 public key before turning on the toggle."_

Once enabled, all API requests must include a valid HTTP signature using your private key.

### 6. Manage Public Keys

**Enable/Disable a key:**
1. Click the **⋮ (more)** menu on the key.
2. Select **"Disable"** or **"Enable"**.
3. A confirmation modal appears.
4. Confirm the action.

**Delete a key:**
1. Click the **⋮ (more)** menu.
2. Select **"Delete"** (shown in red).
3. Confirm deletion.

## Important Notes

- **Maximum 5 public keys** can be stored. When the limit is reached, the "Add Public Key" button is hidden.
- Only **Ed25519** keys are supported. RSA or other key types will be rejected.
- The **Key ID** is what you use in your HTTP signature header — not the public key itself.
- You can have multiple keys enabled simultaneously (useful for key rotation).
- Disabling all keys while the toggle is on will not automatically turn off signing enforcement — ensure at least one key remains enabled.
- The toggle controls whether StraitsX **enforces** signature verification on incoming API requests from your account.
- Keep your **private key** secure and never share it. Only the public key is uploaded to the Dashboard.
