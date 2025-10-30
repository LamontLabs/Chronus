#!/usr/bin/env bash
set -euo pipefail

OUT="provenance/legal"
mkdir -p "$OUT"

echo "== License Scan =="
echo "# Third-Party License Report" > "$OUT/LICENSE_REPORT.md"
date -u +"%Y-%m-%dT%H:%M:%SZ" >> "$OUT/LICENSE_REPORT.md"

if command -v pnpm >/dev/null 2>&1; then
  echo "## JS Dependencies" >> "$OUT/LICENSE_REPORT.md"
  pnpm licenses list --json > "$OUT/js_licenses.json" || true
  echo "- JS license inventory saved to $OUT/js_licenses.json" >> "$OUT/LICENSE_REPORT.md"
fi

if command -v cyclonedx-py >/dev/null 2>&1; then
  cyclonedx-py --format json --output "$OUT/python_sbom.json" || true
fi

echo "Done. Report in $OUT."
