# Changelog

## [0.2.0] - 2026-04-08

### Changed
- Updated OpenAPI spec to cover all public API endpoints (91 paths, 113 endpoints)
- Added production server URL alongside sandbox

### Added
- First Party Payouts — create, get, list
- Third Party Payouts — create, get, list + payout recipients (CRUD)
- Regular Payouts — create, get, list + payout recipients (CRUD)
- CP/CP+ Bank Accounts — create, update, delete, list
- Customer Profile Payments — get payment, list payments (v1 & v2)
- Transaction Limits — get, update, get update requests
- Webhooks — get, update, resend callback (single + batch)
- RFI APIs — get list, get single, submit
- Blockchain — get supported blockchains, deposit addresses (get list, create)
- Virtual Account deletion endpoints
- User Bank Accounts — create, get, update, delete
- FX endpoints — create/get/execute FX quotes, list/get FX transactions
- Personal Customer Profile (non-plus) — create, update
- Outbound transfers — list
- Additional sandbox mock/simulation endpoints

## [0.1.0] - 2026-04-02

### Added
- Multi-skill architecture with 4 standalone skills following the [Agent Skills](https://skills.sh) open spec
  - `straitsx-api-overview` — endpoint lookups, code generation from bundled OpenAPI spec
  - `straitsx-auth-setup` — credential configuration (API key only or API key + Ed25519 signing)
  - `straitsx-request-signing` — Ed25519 signing golden code (Python, JavaScript), canonical string format, bundled test vectors
  - `straitsx-webhook-verification` — HMAC-SHA256 callback verification and Ed25519 request verification golden code
- OpenAPI spec v1.4.0 bundled into `straitsx-api-overview/references/openapi-spec.json` for portable skill installs
- Signing test vectors bundled into `straitsx-request-signing/references/signing-vectors.json`
- Per-client install instructions for Claude Code, Codex, Cursor, Copilot, and AmpCode
- `npx skills add StraitsX/straitsx-ai` one-command install support
- Ed25519 signing test vectors (`test-vectors/signing_vectors.json`) — 5 vectors covering POST, GET, DELETE, special characters, and URL-encoded query params
- StraitsX sandbox OpenAPI spec v1.4.0 (`straitsx-sandbox-base-url.json`)
- Environment variable template (`.env.example`)
- SKILL_TREE.md as skill index for agents consuming the repo directly

### Changed
- Repository renamed from `api-integration-kit` to `straitsx-ai`
- Skills use name-based cross-references instead of relative file paths for portability
- Removed sandbox testing skill and MCP server references (deferred until MCP server is deployed)
- Removed remote OpenAPI spec URL references — spec is bundled locally
