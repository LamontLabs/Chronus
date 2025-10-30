#!/usr/bin/env bash
set -euo pipefail

echo "== Chronus :: Auto Release Script =="

# Env checks
: "${EAS_TOKEN:?Set EAS_TOKEN}"
: "${ANDROID_PACKAGE:=com.lamontlabs.chronus}"
: "${PLAY_TRACK:=internal}"

export EXPO_TOKEN="$EAS_TOKEN"

# 1) Build webgame
echo "[1/6] Building webgame..."
pnpm --prefix webgame install
pnpm --prefix webgame build

# 2) Prebuild Expo
echo "[2/6] Expo prebuild..."
pnpm install
npx expo prebuild --platform android --clean

# 3) Copy webgame bundle into app assets
echo "[3/6] Sync webgame → app assets..."
mkdir -p app/dist
cp -r webgame/dist/* app/dist/

# 4) EAS Build
echo "[4/6] EAS Build (.aab)..."
npx eas build --platform android --profile production --non-interactive

# 5) Optional Submit
if [[ "${SUBMIT:-0}" == "1" ]]; then
  echo "[5/6] EAS Submit → Play Console ($PLAY_TRACK)..."
  npx eas submit --platform android --profile production --non-interactive --track "$PLAY_TRACK"
else
  echo "[5/6] Skipping submit (set SUBMIT=1 to enable)"
fi

# 6) Git tag + provenance
echo "[6/6] Tag + provenance..."
VERSION="$(jq -r '.expo.version' app.json)"
git add -A
git commit -m "[build] v$VERSION - automated release" || true
git tag "v$VERSION" || true
git push --follow-tags

mkdir -p provenance/builds
DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "build_version=$VERSION" > provenance/builds/$VERSION.env
echo "build_date=$DATE" >> provenance/builds/$VERSION.env

echo "== Done. =="
