# StraitsX AI Integration Kit

AI-powered integration assistant for the StraitsX Public API. This kit provides [agent skills](https://skills.sh) that AI coding assistants (Claude Code, Cursor, Codex, Kiro, and others) load to help you generate code, understand API documentation, and integrate with the StraitsX platform.

## Quick Start

### Install with the Skills CLI (recommended)

```bash
# Install all StraitsX skills
npx skills add StraitsX/straitsx-ai

# Or install a specific skill
npx skills add StraitsX/straitsx-ai --skill straitsx-request-signing
```

This works with any client that supports the [Agent Skills](https://skills.sh) spec — Claude Code, Codex, Cursor, Copilot, AmpCode, and more.

### Manual Install

Clone the repo and copy skills into your client's skill directory:

```bash
git clone https://github.com/StraitsX/straitsx-ai.git
```

| Client | Project-Level Install | User-Level Install (all projects) |
|---|---|---|
| Claude Code | `cp -r straitsx-ai/skills/* .claude/skills/` | `cp -r straitsx-ai/skills/* ~/.claude/skills/` |
| Codex | `cp -r straitsx-ai/skills/* .codex/skills/` | `cp -r straitsx-ai/skills/* ~/.codex/skills/` |
| Cursor | `cp -r straitsx-ai/skills/* .cursor/skills/` | `cp -r straitsx-ai/skills/* ~/.cursor/skills/` |
| Copilot | `cp -r straitsx-ai/skills/* .github/skills/` | `cp -r straitsx-ai/skills/* ~/.copilot/skills/` |
| AmpCode | `cp -r straitsx-ai/skills/* .agents/skills/` | `cp -r straitsx-ai/skills/* ~/.config/agents/skills/` |

### Kiro

Open the `straitsx-ai` folder as a workspace. The `.kiro/steering/` directory auto-loads context. You can also reference `SKILL_TREE.md` directly in chat.

## Set Up Your Environment

```bash
cp .env.example .env
```

Edit `.env` with your credentials — see the `straitsx-auth-setup` skill for details.

| Variable | Purpose |
|---|---|
| `X_XFERS_APP_API_KEY` | Your StraitsX API key (from the [StraitsX Dashboard](https://biz.straitsx.com)) |
| `PRIVATE_KEY_PATH` | Path to Ed25519 private key PEM (only for request signing) |
| `PUBLIC_KEY_ID` | Key ID from [StraitsX Dashboard](https://biz.straitsx.com) (only for request signing) |

### Generate Ed25519 key pair (optional, for request signing)

```bash
openssl genpkey -algorithm Ed25519 -out private_key.pem
openssl pkey -in private_key.pem -pubout -out public_key.pem
```

Upload `public_key.pem` to the [StraitsX Dashboard](https://biz.straitsx.com).

## Skills

| Skill | Purpose |
|---|---|
| `straitsx-api-overview` | Endpoint lookups, code generation from the OpenAPI spec, error codes, rate limiting, common pitfalls |
| `straitsx-auth-setup` | Credential configuration — API key only or API key + signing |
| `straitsx-request-signing` | Ed25519 request signing — golden code, canonical string format, test vectors |
| `straitsx-webhook-verification` | Webhook integration — delivery mechanics, retry behavior, signature verification, callback payloads |
| `straitsx-fx-payout-idr` | IDR FX Payout — send USD/XUSD to Indonesian bank accounts with automatic FX conversion |
| `straitsx-sandbox-testing` | End-to-end sandbox walkthrough — generates runnable code for first-party, third-party, or regular integration flows |

Once installed, just ask your AI assistant naturally:

| What to say | Skill used |
|---|---|
| "What endpoints are available?" | `straitsx-api-overview` |
| "What are common pitfalls?" | `straitsx-api-overview` |
| "What are the rate limits?" | `straitsx-api-overview` |
| "How do I authenticate?" | `straitsx-auth-setup` |
| "How do I sign requests?" | `straitsx-request-signing` |
| "How do I verify webhooks?" | `straitsx-webhook-verification` |
| "How do webhook retries work?" | `straitsx-webhook-verification` |
| "How do I send IDR to Indonesia?" | `straitsx-fx-payout-idr` |
| "Walk me through sandbox testing" | `straitsx-sandbox-testing` |

## Project Structure

```
straitsx-ai/
├── SKILL_TREE.md                          # Skill index (for agents consuming the repo directly)
├── skills/
│   ├── straitsx-api-overview/
│   │   ├── SKILL.md
│   │   └── references/                    # Includes bundled openapi-spec.json
│   ├── straitsx-auth-setup/
│   │   └── SKILL.md
│   ├── straitsx-fx-payout-idr/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── straitsx-request-signing/
│   │   ├── SKILL.md
│   │   └── references/                    # Includes bundled signing-vectors.json
│   ├── straitsx-sandbox-testing/
│   │   ├── SKILL.md
│   │   └── references/                    # Includes bundled openapi-spec.json
│   └── straitsx-webhook-verification/
│       ├── SKILL.md
│       └── references/
├── shared-references/
│   └── openapi-spec.json                  # Canonical source — synced into skills via sync-shared-refs.sh
├── test-vectors/
│   └── signing_vectors.json               # Canonical source — synced into skills via sync-shared-refs.sh
├── sync-shared-refs.sh                    # Copies shared files into skill bundles
├── .env.example
├── CHANGELOG.md
├── validate-spec.sh                       # Validates the shared OpenAPI spec
└── README.md
```

## Credential Types

| Credential | Purpose |
|---|---|
| `X_XFERS_APP_API_KEY` | Authenticating StraitsX API requests |
| `X_XFERS_APP_API_KEY` + `PRIVATE_KEY_PATH` | Signing StraitsX API requests (enhanced security) |