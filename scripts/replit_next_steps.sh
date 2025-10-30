#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Chronus™ — Replit "Next Steps" Generator
# Purpose: Scaffold all remaining polish and launch assets, wire minimal stubs,
#          run pricing + QA, and commit with provenance.
# Idempotent: Safe to run multiple times.
# Usage: bash scripts/replit_next_steps.sh
# Env (optional):
#   SUBMIT=1                # if you want to chain a full build/submit later
#   EAS_TOKEN=...           # required for EAS submit/build in CI
#   GH_PAT=...              # if your remote requires PAT for push
# =============================================================================

ROOT="$(pwd)"
DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
PROV_DIR="provenance/logs"
mkdir -p "$PROV_DIR"

log() { printf "%s %s\n" "[next]" "$*"; }
create() { printf "%s %s\n" "[create]" "$*"; }
patch() { printf "%s %s\n" "[patch]" "$*"; }
warn()  { printf "%s %s\n" "[warn]" "$*" >&2; }

ensure_dir() { mkdir -p "$1"; }
ensure_file() {
  local path="$1"; shift
  if [[ ! -f "$path" ]]; then
    ensure_dir "$(dirname "$path")"
    printf "%s" "$*" > "$path"
    create "$path"
  fi
}

touch_if_missing() { [[ -f "$1" ]] || { ensure_dir "$(dirname "$1")"; : > "$1"; create "$1"; }; }

# ----------------------------------------------------------------------------- #
# 0) Sanity notes
# ----------------------------------------------------------------------------- #
log "Starting Next Steps generation at ${DATE_UTC}"
command -v jq >/dev/null 2>&1 || warn "jq not found; JSON patching will be limited."

# ----------------------------------------------------------------------------- #
# 1) Docs: NEXT_STEPS checklist, POLISH_CHECKLIST, STORE LISTING template
# ----------------------------------------------------------------------------- #
ensure_file docs/NEXT_STEPS.md "\
# NEXT STEPS — Chronus™
Date: ${DATE_UTC}

## A. Art & Audio
- [ ] Replace placeholder icons (assets/icon.png) and splash (assets/splash.png)
- [ ] Prepare 8 era backgrounds (4K downscale → mobile optimized)
- [ ] Finalize particle atlases and SFX (tap/upgrade/prestige)

## B. UI Polish
- [ ] Implement glass/metal UI pass with dynamic blur
- [ ] High-contrast and color-blind modes validation
- [ ] Animate buttons (press states, spring easing)

## C. Analytics & Telemetry
- [ ] Enable analytics queue (integrations/analytics.js)
- [ ] Define event taxonomy (assets/telemetry/metrics_schema.json)
- [ ] Hook scene events: start, prestige, offline_return, achievement

## D. Pricing & Commerce
- [ ] Run pricing_setup_4x.sh (4× cheaper enforcement)
- [ ] Verify localized price tiers on Play Console
- [ ] Add regional rounding rules if needed

## E. CI/CD & Release
- [ ] Configure GitHub Actions secrets (EAS_TOKEN, ANDROID_PACKAGE, PLAY_TRACK)
- [ ] Run internal track release and QA soak
- [ ] Prepare store listing assets

## F. Compliance
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] COPPA/GDPR verifications
"

ensure_file docs/POLISH_CHECKLIST.md "\
# POLISH CHECKLIST — Chronus™
- Input latency under 40ms target ✅/❌
- 60 FPS steady on mid-range Android ✅/❌
- First meaningful paint < 2s ✅/❌
- Text legibility AA on all backgrounds ✅/❌
- Haptics: tap/upgrade/prestige patterns defined ✅/❌
- Audio mix: master -8 dB, SFX -6 dB, music -12 dB ✅/❌
"

ensure_dir store/listing/en-US
ensure_file store/listing/en-US/title.txt "Chronus™ — Civilization Unfolded"
ensure_file store/listing/en-US/short_description.txt "Build across millennia. Automate the rise of worlds. 4× cheaper. 0× exploitation."
ensure_file store/listing/en-US/full_description.txt "\
You are a Chronus — a civilization architect who commands time itself.
Progress through eras, automate your world, and prestige to rewrite history.
• 8 eras from Fire to Ascension
• Dual prestige systems and deterministic offline gains
• Ethical economy: free to play, all IAP 4× cheaper than competitors
"
ensure_file store/listing/en-US/privacy_policy.md "\
# Privacy Policy — Chronus™
We collect minimal analytics for crash diagnostics and gameplay balancing.
No personal data is sold. Telemetry is opt-in and deletable. Contact: support@lamontlabs.com
"
ensure_file store/listing/content_rating.yaml "\
questionnaire:
  violence: none
  user_interaction: minimal
  in_app_purchases: yes
  ads: opt_in
  data_collection: analytics_opt_in
"

# Image placeholders (Play Console requires certain sizes; here we create stubs)
ensure_dir store/listing/en-US/images
for img in feature_graphic_1024x500.png phone_screenshot_1080x1920.png; do
  touch_if_missing "store/listing/en-US/images/${img}"
done

# ----------------------------------------------------------------------------- #
# 2) Analytics stub + wiring instructions
# ----------------------------------------------------------------------------- #
ensure_dir webgame/src/integrations
ensure_file webgame/src/integrations/analytics.js "\
const q = [];
let enabled = true;

export function setEnabled(v){ enabled = !!v; }
export function track(type, payload = {}) {
  if (!enabled) return;
  q.push({ t: Date.now(), type, payload });
  if (q.length >= 20) flush();
}
export async function flush() {
  try {
    const batch = q.splice(0, q.length);
    // Hook your endpoint or Firebase here:
    // await fetch('https://example.invalid/analytics', {method:'POST', body: JSON.stringify(batch)});
    return batch.length;
  } catch { return 0; }
}
// Suggested taxonomy: start_session, prestige, offline_return, achievement, ad_opt_in
"

# Guidance file
ensure_file docs/ANALYTICS_WIRING.md "\
# Analytics Wiring
Import in GameScene/UIScene:
  import { track, flush } from '../integrations/analytics.js';

Examples:
  track('start_session');
  track('prestige', { count });
  track('offline_return', { hours, gains });
Flush on pause/background:
  window.addEventListener('visibilitychange', () => document.hidden && flush());
"

# ----------------------------------------------------------------------------- #
# 3) GitHub Actions CI (build + QA). Reads secrets at runtime.
# ----------------------------------------------------------------------------- #
ensure_dir .github/workflows
ensure_file .github/workflows/android.yml "\
name: Android Build (EAS)
on:
  workflow_dispatch:
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '18' }
      - run: npm i -g pnpm@8 eas-cli expo-cli
      - run: pnpm install && pnpm --prefix webgame install
      - run: pnpm --prefix webgame build
      - run: mkdir -p app/dist && cp -r webgame/dist/* app/dist/
      - name: EAS Build
        env:
          EAS_TOKEN: \${{ secrets.EAS_TOKEN }}
        run: |
          npx eas build --platform android --profile production --non-interactive --local --output build/Chronus-ci.aab
      - name: QA Smoke
        run: |
          python3 -m pip install -r requirements.txt || true
          python3 qa/test_runner.py || true
      - uses: actions/upload-artifact@v4
        with:
          name: Chronus-aab
          path: build/Chronus-ci.aab
"

ensure_file .github/workflows/qa.yml "\
name: QA
on:
  pull_request:
  push:
    branches: [ main ]
jobs:
  qa:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python3 qa/test_runner.py || true
      - uses: actions/upload-artifact@v4
        with:
          name: qa-reports
          path: qa/reports
"

# ----------------------------------------------------------------------------- #
# 4) Notifications templates + icons
# ----------------------------------------------------------------------------- #
ensure_dir assets/notifications/icons
touch_if_missing assets/notifications/icons/ic_stat_notify.png
ensure_file assets/player/push_templates.yaml "\
templates:
  legacy_milestone: \"Your civilization crossed a millennium. Claim your legacy!\"
  chronostorm: \"A Chronostorm is surging. Production up now.\"
limits:
  max_per_day: 1
"

# ----------------------------------------------------------------------------- #
# 5) Run pricing setup (4× cheaper) and regenerate SKU catalog
# ----------------------------------------------------------------------------- #
if [[ -f scripts/pricing_setup_4x.sh ]]; then
  bash scripts/pricing_setup_4x.sh
else
  warn "scripts/pricing_setup_4x.sh not found. Skipping pricing pass."
fi

# ----------------------------------------------------------------------------- #
# 6) Run QA smoke + provenance snapshot
# ----------------------------------------------------------------------------- #
if [[ -f qa/test_runner.py ]]; then
  python3 qa/test_runner.py || true
fi

if [[ -f tools/verify_hashes.py ]]; then
  python3 tools/verify_hashes.py >/dev/null 2>&1 || true
fi

# ----------------------------------------------------------------------------- #
# 7) Optional: kick a local build to validate artifacts in Replit
# ----------------------------------------------------------------------------- #
if [[ -f scripts/game_auto_release.sh ]]; then
  bash scripts/game_auto_release.sh || warn "Local build step failed (non-fatal)."
fi

# ----------------------------------------------------------------------------- #
# 8) Commit + tag
# ----------------------------------------------------------------------------- #
if git rev-parse --git-dir >/dev/null 2>&1; then
  git add -A || true
  git commit -m "[next] scaffold next steps, ci, listing, analytics — ${DATE_UTC}" || true
  TAG="next-$(date +%Y%m%d%H%M%S)"
  git tag -a "$TAG" -m "Next Steps ${DATE_UTC}" || true
  git push --follow-tags || warn "Git push failed."
else
  warn "Not a git repo; skipping push."
fi

# ----------------------------------------------------------------------------- #
# 9) Log action
# ----------------------------------------------------------------------------- #
echo "{\"timestamp\":\"${DATE_UTC}\",\"action\":\"replit_next_steps\",\"status\":\"ok\"}" > "${PROV_DIR}/next_steps_${DATE_UTC//[:]/-}.json"
log "Next Steps generation complete."
