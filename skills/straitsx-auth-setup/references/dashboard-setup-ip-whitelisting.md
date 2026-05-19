# Set Up IP Whitelisting

## Overview

This guide explains how to enable IP whitelisting in the StraitsX Dashboard to restrict API access to specific IP addresses, and how to add or remove IPs from the whitelist.

## Navigation Path

**Platform Tools → API Keys and IP Whitelisting → IP Whitelisting section**

## Step-by-Step

### 1. Navigate to the API Keys Page

1. In the Dashboard sidebar, click **Platform Tools**.
2. Under **Developer Tools**, click **API Keys and IP Whitelisting**.
3. You'll land on the "API Keys, Public Key and IP Whitelisting" page.
4. Scroll down to the **IP Whitelisting** section.

### 2. Enable IP Whitelisting

The IP Whitelisting section has a **toggle switch** at the top:

1. Flip the toggle to **"Enabled"**.
2. Once enabled, the list of whitelisted IP addresses appears below.
3. When disabled, the IP list is hidden and all IPs are allowed.

> When IP whitelisting is enabled, only requests from whitelisted IP addresses will be accepted. All other requests will be blocked.

### 3. Add an IP Address

1. Click **"Add IP Address"** at the bottom of the IP list.
2. The "Add an IP Address" modal opens with these fields:

   | Field | Description |
   |-------|-------------|
   | **IP Address Name** | A label for this IP (e.g., "Production Server"). Max 100 characters. Optional but recommended. |
   | **IP Address** | The IP address to whitelist (e.g., `123.456.789.0`). Required. |

3. Click **"Add Address"** to save.
4. On success, the modal closes and the new IP appears in the list.

### 4. View Whitelisted IPs

Each whitelisted IP entry shows:

- **Name** (the label you provided, or "IP Address" if none was set)
- **Added** date
- The **IP address** in a copyable field (click the copy icon to copy)
- A **⋮ (more)** menu with a "Delete" option

### 5. Delete an IP Address

1. Click the **⋮ (more)** menu on the IP you want to remove.
2. Select **"Delete"** (shown in red).
3. A confirmation modal appears:
   - Message: _"The IP address will be removed immediately, and connected integrations will be blocked."_
   - Buttons: **Cancel** | **Delete**
4. Click **Delete** to confirm.
5. The IP is removed immediately.

## Important Notes

- When IP whitelisting is **enabled**, only requests from listed IPs will be accepted. Ensure your server IPs are added **before** enabling the toggle, or your API calls will be blocked.
- Deleting an IP takes effect **immediately** — any active integrations from that IP will lose access.
- There is no OTP verification required for adding or deleting IPs.
- The toggle can be turned off at any time to disable IP restrictions without deleting your saved IPs.
- Give each IP a descriptive name (e.g., "Production API Server", "Staging Environment") so your team can easily identify them later.
