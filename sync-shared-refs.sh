#!/usr/bin/env bash
# sync-shared-refs.sh
# Copies local shared reference files into each skill that needs them.
#
# Note: The OpenAPI spec (shared-references/openapi-spec.json) is hand-maintained
# and referenced directly by skills — no sync needed for it.
#
# Run this to ensure all skills have the latest shared files.
# Safe to run repeatedly — idempotent.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# ─── Local sources ────────────────────────────────────────────────
# Format: "source_path -> target_skill/filename"
# For files that live in the repo (e.g. test vectors).

LOCAL_DEPS=(
  "test-vectors/signing_vectors.json -> straitsx-request-signing/signing-vectors.json"
)

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

echo ""
echo "Done."
