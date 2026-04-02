---
name: straitsx-auth-setup
description: Set up authentication for the StraitsX API. Covers API-key-only auth and API-key + Ed25519 request signing. Use when the user asks about credentials, environment variables, or "how do I authenticate?"
category: setup
parent: straitsx-api
---

# StraitsX Authentication Setup

## Invoke This Skill When

- User asks "How do I authenticate?" or "How do I set up credentials?"
- User asks about API keys, environment variables, or `.env` configuration
- User is starting a new integration and needs to get credentials working
- User is confused about which credentials go where

## Security Constraints

| Rule | Detail |
|------|--------|
| No hardcoded secrets | Never put API keys, private keys, or key IDs directly in source code. Always use environment variables. |
| Separate credentials | Keep production and sandbox API keys separate. Do not mix them. |

## Step 1: Choose Your Auth Method

Ask the user which method they want before proceeding:

| Method | When to use | What's needed |
|---|---|---|
| **API Key Only** | Getting started, simpler integrations | `X_XFERS_APP_API_KEY` only |
| **API Key + Request Signing** | Production, enhanced security | `X_XFERS_APP_API_KEY` + Ed25519 key pair |

## Option A: API Key Only

**Step 1:** Get your API key from the [StraitsX Dashboard](https://dashboard.straitsx.com) (API settings page).

**Step 2:** Configure your environment:

```bash
# StraitsX API key — the only credential needed for API-key-only auth
X_XFERS_APP_API_KEY=your_straitsx_api_key_here
```

**Step 3:** Include the API key header in requests:

```python
import os

headers = {
    "X-XFERS-APP-API-KEY": os.environ["X_XFERS_APP_API_KEY"],
    "Content-Type": "application/json",
}
```

```javascript
const headers = {
  "X-XFERS-APP-API-KEY": process.env.X_XFERS_APP_API_KEY,
  "Content-Type": "application/json",
};
```

## Option B: API Key + HTTP Request Signing

**Step 1:** Get your API key from the StraitsX Dashboard.

**Step 2:** Generate an Ed25519 key pair:

```bash
openssl genpkey -algorithm Ed25519 -out private_key.pem
openssl pkey -in private_key.pem -pubout -out public_key.pem
```

**Step 3:** Upload `public_key.pem` to the StraitsX Dashboard. You'll receive a **Key ID** — this is the `PUBLIC_KEY_ID`.

**Step 4:** Configure your environment:

```bash
X_XFERS_APP_API_KEY=your_straitsx_api_key_here
PRIVATE_KEY_PATH=./private_key.pem
PUBLIC_KEY_ID=your_key_id_from_dashboard
```

**Step 5:** For the signing implementation, load the `straitsx-request-signing` skill.

## Environment Variable Reference

| Variable | Required | Purpose |
|---|---|---|
| `X_XFERS_APP_API_KEY` | Always | Your StraitsX API key for authenticating API requests |
| `PRIVATE_KEY_PATH` | Only for signing | Path to your Ed25519 private key PEM file |
| `PUBLIC_KEY_ID` | Only for signing | The Key ID from the StraitsX Dashboard after uploading your public key |
| `STRAITSX_SIGNING_SECRET` | Only for callbacks | HMAC-SHA256 signing secret for verifying incoming callbacks (from Dashboard > Platform Tools > Callback URLs) |

## Pre-flight Check

Before the user makes an API call, verify at minimum:
- `X_XFERS_APP_API_KEY` is set

If the user has chosen HTTP Request Signing, also verify:
- `PRIVATE_KEY_PATH` is set and the file exists
- `PUBLIC_KEY_ID` is set
