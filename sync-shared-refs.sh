#!/usr/bin/env bash
# sync-shared-refs.sh
# Fetches shared reference files from their canonical online sources
# and copies them into each skill that needs them.
# Also patches SKILL.md cross-skill paths to local references.
#
# Run this to ensure all skills have the latest shared files.
# Safe to run repeatedly — idempotent.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# ─── Remote sources ───────────────────────────────────────────────
# Format: "url -> target_skill/filename"
# Add new entries here when a skill needs a remote file.

REMOTE_DEPS=(
  "https://docs.straitsx.com/openapi/straitsx-sandbox-base-url.json -> straitsx-api-overview/openapi-spec.json"
  "https://docs.straitsx.com/openapi/straitsx-sandbox-base-url.json -> straitsx-sandbox-testing/openapi-spec.json"
)

# ─── Local sources ────────────────────────────────────────────────
# Format: "source_path -> target_skill/filename"
# For files that live in the repo (e.g. test vectors).

LOCAL_DEPS=(
  "test-vectors/signing_vectors.json -> straitsx-request-signing/signing-vectors.json"
)

# ─── SKILL.md path rewrites ──────────────────────────────────────
# When a file is copied locally, update the SKILL.md reference too.
# Format: "target_skill|old_text|new_text"

REWRITES=(
  'straitsx-sandbox-testing|`references/openapi-spec.json` in the `straitsx-api-overview` skill|[`references/openapi-spec.json`](references/openapi-spec.json)'
)

# ─── Fetch remote files ──────────────────────────────────────────

echo "Fetching remote shared references..."
echo ""

for dep in "${REMOTE_DEPS[@]}"; do
  url="${dep%% -> *}"
  target="${dep##* -> }"
  skill="${target%%/*}"
  filename="${target##*/}"

  dest_dir="$REPO_ROOT/skills/$skill/references"
  dest="$dest_dir/$filename"

  mkdir -p "$dest_dir"

  if curl -sSfL "$url" -o "$dest"; then
    echo "  ✓ $url → skills/$skill/references/$filename"
  else
    echo "  ✗ Failed to fetch: $url"
  fi
done

# ─── Copy local files ────────────────────────────────────────────

echo ""
echo "Syncing local shared references..."
echo ""

for dep in "${LOCAL_DEPS[@]}"; do
  src_rel="${dep%% -> *}"
  target="${dep##* -> }"
  skill="${target%%/*}"
  filename="${target##*/}"

  src="$REPO_ROOT/$src_rel"
  dest_dir="$REPO_ROOT/skills/$skill/references"
  dest="$dest_dir/$filename"

  if [ ! -f "$src" ]; then
    echo "  ✗ Source not found: $src_rel"
    continue
  fi

  mkdir -p "$dest_dir"
  cp "$src" "$dest"
  echo "  ✓ $src_rel → skills/$skill/references/$filename"
done

# ─── Patch SKILL.md references ────────────────────────────────────

echo ""
echo "Patching SKILL.md cross-skill references..."
echo ""

for rewrite in "${REWRITES[@]}"; do
  IFS='|' read -r skill old_text new_text <<< "$rewrite"
  skill_md="$REPO_ROOT/skills/$skill/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "  ✗ SKILL.md not found: skills/$skill/SKILL.md"
    continue
  fi

  if grep -qF "$old_text" "$skill_md"; then
    sed -i '' "s|$old_text|$new_text|g" "$skill_md"
    echo "  ✓ skills/$skill/SKILL.md — updated reference to local path"
  else
    echo "  · skills/$skill/SKILL.md — already up to date"
  fi
done

echo ""
echo "Done."
