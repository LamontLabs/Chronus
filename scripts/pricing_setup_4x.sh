#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Chronus™ — Pricing Setup Script (4× Cheaper Framework)
# Purpose:
#   - Enforce free-to-play with in-app purchases priced at 25% of competitor baselines
#   - Generate pricing rules and baseline files if missing
#   - Produce derived pricing.json
#   - Patch assets/commerce/sku_catalog.json with new prices
#   - Log provenance snapshot
# Usage:
#   bash scripts/pricing_setup_4x.sh
# Env (optional):
#   PRICE_FACTOR=0.25
#   CURRENCY=USD
# ============================================================

ROOT="$(pwd)"
COMMERCE_DIR="${ROOT}/assets/commerce"
PROV_DIR="${ROOT}/provenance/logs"
mkdir -p "$COMMERCE_DIR" "$PROV_DIR"

jq_exists() { command -v jq >/dev/null 2>&1; }
if ! jq_exists; then
  echo "jq is required. Install jq and re-run." >&2
  exit 1
fi

PRICE_FACTOR="${PRICE_FACTOR:-0.25}"
CURRENCY="${CURRENCY:-USD}"
DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

RULES_PATH="${COMMERCE_DIR}/pricing_rules.json"
BASELINE_PATH="${COMMERCE_DIR}/pricing_baseline.json"
OUTPUT_PATH="${COMMERCE_DIR}/pricing.json"
SKU_PATH="${COMMERCE_DIR}/sku_catalog.json"
LOG_PATH="${PROV_DIR}/pricing_${DATE_UTC//[:]/-}.json"

# ------------------------------------------------------------
# 1) Ensure pricing_rules.json
# ------------------------------------------------------------
if [[ ! -f "$RULES_PATH" ]]; then
  cat > "$RULES_PATH" <<JSON
{
  "meta": { "version": "v0.1-alpha", "date": "$DATE_UTC" },
  "currency": "$CURRENCY",
  "price_factor": $PRICE_FACTOR,
  "snap_rules": [
    { "lt": 0.60, "set": 0.49 },
    { "lt": 1.00, "set": 0.79 },
    { "lt": 1.50, "set": 1.19 },
    { "lt": 2.00, "set": 1.49 },
    { "lt": 3.00, "set": 2.49 },
    { "lt": 5.00, "set": 3.19 },
    { "ge": 5.00, "round": 0.10 }
  ]
}
JSON
  echo "[create] $RULES_PATH"
else
  echo "[found ] $RULES_PATH"
fi

# ------------------------------------------------------------
# 2) Ensure pricing_baseline.json (competitor averages)
#    You can expand this list; the script applies the factor to any entries.
# ------------------------------------------------------------
if [[ ! -f "$BASELINE_PATH" ]]; then
  cat > "$BASELINE_PATH" <<JSON
{
  "meta": { "version": "v0.1-alpha", "date": "$DATE_UTC" },
  "currency": "$CURRENCY",
  "baselines": [
    { "sku": "premium_unlock",        "label": "Ad-free / Premium Unlock", "competitor_avg_usd": 4.99 },
    { "sku": "voicepack_archive7_a",  "label": "Voice Pack A",             "competitor_avg_usd": 2.99 },
    { "sku": "city_theme_bronze",     "label": "Cosmetic Theme",           "competitor_avg_usd": 2.99 },
    { "sku": "idle_boost_4h",         "label": "Idle Doubler 4h",          "competitor_avg_usd": 1.99 },
    { "sku": "token_pack_50",         "label": "Token Pack (50)",          "competitor_avg_usd": 4.99 },
    { "sku": "era_expansion",         "label": "Era Expansion",            "competitor_avg_usd": 9.99 },
    { "sku": "prestige_bundle",       "label": "Prestige Boost Bundle",    "competitor_avg_usd": 7.99 },
    { "sku": "season_pass",           "label": "Seasonal Event Pass",      "competitor_avg_usd": 12.99 }
  ]
}
JSON
  echo "[create] $BASELINE_PATH"
else
  echo "[found ] $BASELINE_PATH"
fi

# ------------------------------------------------------------
# 3) Generate pricing.json from baseline × factor with snapping
# ------------------------------------------------------------
gen_pricing() {
  jq --argjson factor "$PRICE_FACTOR" '
    def snap($rules; x):
      # Apply threshold snaps or round-to-increment rule.
      # Rules are checked in order; first match wins.
      ( $rules[] | select( (has("lt") and (x < .lt)) or (has("ge") and (x >= .ge)) ) ) as $r
      | if $r|has("set") then $r.set
        elif $r|has("round") then
          # Round to nearest increment
          ( ( (x / $r.round) | floor ) * $r.round )
        else x end ;

    . as $rules
    | (input) as $baseline
    | {
        meta: {
          version: "v0.1-alpha",
          date: $baseline.meta.date,
          currency: $baseline.currency,
          price_factor: $factor
        },
        prices: (
          $baseline.baselines
          | map({
              sku: .sku,
              label: .label,
              competitor_avg_usd: .competitor_avg_usd,
              target_usd_raw: (.competitor_avg_usd * $factor),
              target_usd: (snap($rules.snap_rules; (.competitor_avg_usd * $factor)) | (. * 100 | round) / 100)
            })
        )
      }
  ' "$RULES_PATH" "$BASELINE_PATH"
}

gen_pricing > "$OUTPUT_PATH"
echo "[write ] $OUTPUT_PATH"

# ------------------------------------------------------------
# 4) Patch assets/commerce/sku_catalog.json with derived prices
#     - Only updates SKUs that exist in both files.
# ------------------------------------------------------------
if [[ ! -f "$SKU_PATH" ]]; then
  # Create a minimal catalog if missing, using baselines as seed
  jq '
    {
      meta: { build_hash: "", version: "v0.1-alpha", date: "'$DATE_UTC'" },
      products: ( .baselines | map({
        sku: .sku,
        type: (if .sku|test("theme|voicepack") then "non_consumable" else "consumable" end),
        price_usd: 0,
        entitlements: []
      })),
      receipts: { hash_algo: "sha256", store: "play" }
    }
  ' "$BASELINE_PATH" > "$SKU_PATH"
  echo "[create] $SKU_PATH"
fi

PRICES_TMP="$(mktemp)"
jq '.prices' "$OUTPUT_PATH" > "$PRICES_TMP"

SKU_TMP="$(mktemp)"
jq --slurpfile prices "$PRICES_TMP" '
  . as $root
  | .products = ( .products
      | map( . as $p
        | ($prices[0] | map(select(.sku == $p.sku)) | .[0]) as $price
        | if $price == null then .
          else .price_usd = $price.target_usd end
      )
    )
' "$SKU_PATH" > "$SKU_TMP" && mv "$SKU_TMP" "$SKU_PATH"
echo "[patch ] $SKU_PATH (prices updated)"

# ------------------------------------------------------------
# 5) Provenance log
# ------------------------------------------------------------
jq -n --arg date "$DATE_UTC" \
      --arg factor "$PRICE_FACTOR" \
      --slurpfile rules "$RULES_PATH" \
      --slurpfile baseline "$BASELINE_PATH" \
      --slurpfile output "$OUTPUT_PATH" \
      --slurpfile sku "$SKU_PATH" \
'{
  timestamp: $date,
  action: "pricing_setup_4x",
  price_factor: ($factor|tonumber),
  rules_sha256: ( ($rules[0]|tostring)|@sha256 ),
  baseline_sha256: ( ($baseline[0]|tostring)|@sha256 ),
  output_sha256: ( ($output[0]|tostring)|@sha256 ),
  sku_catalog_sha256: ( ($sku[0]|tostring)|@sha256 )
}' > "$LOG_PATH"
echo "[log   ] $LOG_PATH"

echo "== Pricing setup complete: factor=$PRICE_FACTOR, currency=$CURRENCY =="
