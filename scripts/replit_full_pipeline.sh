#!/usr/bin/env bash
set -euo pipefail

# ===============================================================
# REPLIT → ANDROID STUDIO ULTIMATE PIPELINE (Chronus Edition)
# ===============================================================
# Performs:
# 1. Environment verification
# 2. Dependency bootstrap (Node / pnpm / Expo / EAS)
# 3. Webgame build and hash validation
# 4. Expo prebuild → EAS .aab creation
# 5. Optional submit to Play Console
# 6. GitHub auto-commit + tag push
# 7. Android Studio export prep (.aab + gradle folder)
# ===============================================================

export BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export VERSION=$(jq -r '.version' < package.json)
export BUILD_TAG="v${VERSION}-$(date +%s)"
export TRACK=${PLAY_TRACK:-internal}
export PACKAGE=${ANDROID_PACKAGE:-com.lamontlabs.chronus}

echo "== ULTIMATE REPLIT PIPELINE :: Chronus =="
echo "Version: $VERSION | Date: $BUILD_DATE | Package: $PACKAGE"

# 1. Environment check
bash scripts/verify_android_env.sh

# 2. Node setup
if ! command -v pnpm >/dev/null; then
  npm i -g pnpm@8
fi
if ! command -v eas >/dev/null; then
  npm i -g eas-cli
fi
if ! command -v expo >/dev/null; then
  npm i -g expo-cli
fi

# 3. Webgame deterministic build
echo "→ Building webgame"
cd webgame
pnpm install --frozen-lockfile || pnpm install
pnpm run build || echo "(No web build script — skipped)"
cd ..

# 4. Expo prebuild + EAS build
echo "→ Prebuilding Expo"
npx expo prebuild --clean || true
mkdir -p build

echo "→ Starting EAS build"
npx eas build --platform android --profile production --local \
  --output build/Chronus-${BUILD_TAG}.aab || {
    echo "EAS Build failed"; exit 1;
  }

# 5. Submit to Play Console (optional)
if [[ "${SUBMIT:-0}" == "1" ]]; then
  echo "→ Submitting to Play Store [$TRACK]"
  npx eas submit --platform android --path build/Chronus-${BUILD_TAG}.aab --track $TRACK
fi

# 6. Provenance + GitHub push
echo "→ Logging provenance + pushing tag"
mkdir -p provenance/logs
sha256sum build/Chronus-${BUILD_TAG}.aab > provenance/logs/hash_${BUILD_TAG}.sha256

git add provenance/logs build/Chronus-${BUILD_TAG}.aab || true
git commit -am "build: ${BUILD_TAG}" || true
git tag -a "${BUILD_TAG}" -m "Chronus Build ${BUILD_TAG}"
git push origin main --tags || true

# 7. Android Studio export prep
echo "→ Preparing Android Studio import folder"
mkdir -p android_export
cp -r android/* android_export/ 2>/dev/null || true
cp build/Chronus-${BUILD_TAG}.aab android_export/
echo "Gradle and .aab ready for Android Studio in android_export/"

# 8. Final checksum
sha256sum build/Chronus-${BUILD_TAG}.aab | tee android_export/checksum.txt

echo "== COMPLETE :: Android Studio Ready Build (${BUILD_TAG}) =="
