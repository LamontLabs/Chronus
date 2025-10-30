#!/usr/bin/env bash
set -euo pipefail

mkdir -p provenance/legal
echo "== Scanning dependencies for license info =="

pnpm licenses list --json > provenance/legal/pnpm_licenses.json 2>/dev/null || true
npm list --json --depth=3 > provenance/legal/npm_tree.json 2>/dev/null || true

if [ -f provenance/legal/pnpm_licenses.json ]; then
  jq '.dependencies | keys' provenance/legal/pnpm_licenses.json > provenance/legal/license_summary.txt
  echo "License summary generated: provenance/legal/license_summary.txt"
fi

echo "Scan complete."
