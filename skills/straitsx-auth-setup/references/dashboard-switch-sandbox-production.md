# Switch Between Sandbox and Production Mode

## Overview

This guide explains how to switch between Sandbox and Production mode in the StraitsX Dashboard. Sandbox mode lets you test API integrations with simulated transactions before going live.

## Navigation Path

**Profile avatar (top-right) → "Switch to Sandbox Mode" / "Switch to Production Mode"**

## Step-by-Step

### 1. Open the Profile Menu

1. In the top-right corner of the Dashboard, click your **profile avatar / name**.
2. A dropdown menu appears.

### 2. Switch Mode

- If you're currently in **Production** mode, you'll see:
  **"Switch to Sandbox Mode"**

- If you're currently in **Sandbox** mode, you'll see:
  **"Switch to Production Mode"**

Click the option to switch. The Dashboard will reload in the selected mode.

### 3. Confirm You're in Sandbox Mode

When in Sandbox mode, a **banner** appears at the top of the page:

> **Sandbox mode**  |  All transactions made are simulated. [Learn more]

This banner is visible on every page while you're in Sandbox mode. It does not appear in Production mode.

## What Changes Between Modes

| Aspect | Production | Sandbox |
|--------|-----------|---------|
| Transactions | Real funds and assets | Simulated (no real money moves) |
| API Keys | Production keys | Sandbox-specific keys |
| Callback URLs | Production endpoints | Can be configured separately |
| Signing Secret | Production secret | Sandbox secret (OTP may be skipped) |
| OTP Verification | Required for sensitive actions | Often skipped for faster testing |

## Important Notes

- Sandbox mode is only available if your account has sandbox access enabled. If you don't see the "Switch to Sandbox Mode" option in the profile menu, contact StraitsX support.
- API keys, callback URLs, and signing secrets are **separate** between Sandbox and Production. Configuring one does not affect the other.
- The mode switch persists for your current browser session. Opening a new session defaults back to Production.
- Use Sandbox mode to test your integration end-to-end before switching to Production for live transactions.
