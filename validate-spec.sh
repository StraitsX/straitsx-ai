#!/usr/bin/env bash
# validate-spec.sh
# Validates the shared OpenAPI spec passes OAS validation and is pretty-printed.
# Run this after any edit to shared-references/openapi-spec.json.

set -euo pipefail

SPEC="$(cd "$(dirname "$0")" && pwd)/shared-references/openapi-spec.json"

if [ ! -f "$SPEC" ]; then
  echo "✗ Spec not found: $SPEC"
  exit 1
fi

echo "Validating: $SPEC"
echo ""

# Check 1: Valid JSON
if ! python3 -c "import json; json.load(open('$SPEC'))" 2>/dev/null; then
  echo "✗ Invalid JSON"
  exit 1
fi
echo "✓ Valid JSON"

# Check 2: Pretty-printed (more than 1 line)
LINE_COUNT=$(wc -l < "$SPEC" | tr -d ' ')
if [ "$LINE_COUNT" -le 1 ]; then
  echo "✗ Not pretty-printed (file is $LINE_COUNT line(s) — should be multi-line with indentation)"
  exit 1
fi
echo "✓ Pretty-printed ($LINE_COUNT lines)"

# Check 3: OAS validation
if python3 -c "from openapi_spec_validator import validate; import json; validate(json.load(open('$SPEC')))" 2>/dev/null; then
  echo "✓ Passes OAS validation"
else
  echo ""
  echo "✗ OAS validation failed. Details:"
  python3 -c "
from openapi_spec_validator import validate
import json
try:
    validate(json.load(open('$SPEC')))
except Exception as e:
    print(f'  {e}')
" 2>/dev/null
  exit 1
fi

echo ""
echo "All checks passed."
