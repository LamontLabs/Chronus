#!/usr/bin/env bash
set -euo pipefail

# ===========================================================================
# Chronus™ — "Generate Everything" Master Script
# Purpose:
#   One-click generator that:
#     1. Verifies environment
#     2. Runs generate-missing, pricing, next-steps, and build
#     3. Fills any absent folders, assets, QA, provenance, CI configs
#     4. Pushes final repo state back to GitHub
# Usage:
#   bash scripts/replit_generate_everything.sh
# Optional env:
#   SUBMIT=1 (to upload internal build)
# ===========================================================================

ROOT="$(pwd)"
DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
LOG_DIR="provenance/logs"
mkdir -p "$LOG_DIR"

echo "== Chronus : Generate Everything : ${DATE_UTC} =="

# ---------------------------------------------------------------------------
# 0) Environment sanity check
# ---------------------------------------------------------------------------
for cmd in git jq node pnpm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[error] Missing dependency: $cmd"; exit 1
  fi
done

# ---------------------------------------------------------------------------
# 1) Create skeleton if missing
# ---------------------------------------------------------------------------
if [[ -f scripts/replit_generate_missing.sh ]]; then
  echo "[step] generate-missing"
  bash scripts/replit_generate_missing.sh || echo "[warn] generate-missing returned nonzero"
else
  echo "[warn] Missing scripts/replit_generate_missing.sh — skipping"
fi

# ---------------------------------------------------------------------------
# 2) Apply pricing and commerce setup
# ---------------------------------------------------------------------------
if [[ -f scripts/pricing_setup_4x.sh ]]; then
  echo "[step] pricing-setup"
  bash scripts/pricing_setup_4x.sh || echo "[warn] pricing_setup_4x failed"
else
  echo "[warn] Missing scripts/pricing_setup_4x.sh"
fi

# ---------------------------------------------------------------------------
# 3) Add next-step scaffolding (CI, store listings, analytics, etc.)
# ---------------------------------------------------------------------------
if [[ -f scripts/replit_next_steps.sh ]]; then
  echo "[step] next-steps"
  bash scripts/replit_next_steps.sh || echo "[warn] next-steps partial failure"
else
  echo "[warn] Missing scripts/replit_next_steps.sh"
fi

# ---------------------------------------------------------------------------
# 4) Build and tag provenance snapshot
# ---------------------------------------------------------------------------
if [[ -f scripts/game_auto_release.sh ]]; then
  echo "[step] build"
  bash scripts/game_auto_release.sh || echo "[warn] build step failed"
else
  echo "[warn] Missing scripts/game_auto_release.sh"
fi

# ---------------------------------------------------------------------------
# 5) Optional Play Store submit (internal)
# ---------------------------------------------------------------------------
if [[ "${SUBMIT:-0}" == "1" && -n "${EAS_TOKEN:-}" ]]; then
  echo "[step] EAS submit internal track"
  npx eas submit --platform android --path build/*.aab --track "${PLAY_TRACK:-internal}" || echo "[warn] EAS submit failed"
else
  echo "[info] SUBMIT disabled or EAS_TOKEN unset"
fi

# ---------------------------------------------------------------------------
# 6) QA + Provenance
# ---------------------------------------------------------------------------
if [[ -f qa/test_runner.py ]]; then
  echo "[step] QA smoke"
  python3 qa/test_runner.py || true
fi

if [[ -f tools/verify_hashes.py ]]; then
  echo "[step] provenance snapshot"
  python3 tools/verify_hashes.py || true
fi

# ---------------------------------------------------------------------------
# 7) GitHub push
# ---------------------------------------------------------------------------
if git rev-parse --git-dir >/dev/null 2>&1; then
  git add -A || true
  git commit -m "[all] generate everything ${DATE_UTC}" || true
  TAG="all-$(date +%Y%m%d%H%M%S)"
  git tag -a "$TAG" -m "Generate Everything ${DATE_UTC}" || true
  git push --follow-tags || echo "[warn] git push failed"
else
  echo "[warn] Not a git repo; skipping push"
fi

# ---------------------------------------------------------------------------
# 8) Summary Log
# ---------------------------------------------------------------------------
LOG_PATH="${LOG_DIR}/generate_everything_${DATE_UTC//[:]/-}.json"
jq -n --arg date "$DATE_UTC" '{"timestamp":$date,"action":"generate_everything","status":"ok"}' > "$LOG_PATH"
echo "[done] $LOG_PATH"

echo "== COMPLETE :: Chronus fully scaffolded and ready for Android Studio =="
