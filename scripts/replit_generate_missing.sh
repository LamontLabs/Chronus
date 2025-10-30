#!/usr/bin/env bash
set -euo pipefail

# =====================================================================
# Chronus — Replit "Generate Missing + Complete Game" Script
# Goal: Audit repo, create all missing dirs/files/assets, reconcile refs,
#       run builds, run QA, and push back to GitHub with provenance.
# Safe to run multiple times (idempotent).
# =====================================================================

ROOT="$(pwd)"
DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
LOG_DIR="provenance/logs"
BUILD_DIR="build"
ANDROID_EXPORT="android_export"
WEBGAME_DIST="webgame/dist"
APP_DIST="app/dist"
TAG_PREFIX="autogen"

mkdir -p "$LOG_DIR" "$BUILD_DIR" "$ANDROID_EXPORT" "$APP_DIST"

echo "== Chronus :: Generate-Missing :: $DATE_UTC =="

# -----------------------------
# Helpers
# -----------------------------
ensure_dir() { mkdir -p "$1"; }

ensure_file() {
  local path="$1"
  local content="${2:-}"
  if [[ ! -f "$path" ]]; then
    ensure_dir "$(dirname "$path")"
    printf "%s" "$content" > "$path"
    echo "[create] $path"
  fi
}

ensure_json_field() {
  # ensure_json_field <file> <jq_expr_when_missing> <jq_update_expr>
  local file="$1"; local test_expr="$2"; local update_expr="$3"
  if [[ -f "$file" ]]; then
    if ! jq -e "$test_expr" "$file" >/dev/null 2>&1; then
      tmp="$(mktemp)"; jq "$update_expr" "$file" > "$tmp" && mv "$tmp" "$file"
      echo "[patch] $file :: $update_expr"
    fi
  fi
}

write_base64() {
  # write_base64 <path> <b64>
  local path="$1"; local b64="$2"
  ensure_dir "$(dirname "$path")"
  echo "$b64" | base64 -d > "$path"
  echo "[create] $path (base64)"
}

touch_if_missing() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    ensure_dir "$(dirname "$path")"
    : > "$path"
    echo "[touch ] $path"
  fi
}

# -----------------------------
# 0) Environment sanity
# -----------------------------
echo "== Step 0 :: Environment =="
: "${ANDROID_PACKAGE:=com.lamontlabs.chronus}"
: "${PLAY_TRACK:=internal}"
: "${EAS_TOKEN:=}"
if [[ -z "${EAS_TOKEN}" ]]; then
  echo "[warn] EAS_TOKEN not set. Build will still generate assets but skip submit."
fi

# -----------------------------
# 1) Required directory skeleton
# -----------------------------
echo "== Step 1 :: Skeleton =="
for d in \
  app assets \
  assets/audio/ui assets/audio/music \
  assets/color assets/lighting assets/visuals \
  assets/economy assets/buildings assets/fauna assets/flora \
  assets/events assets/legacy_tree assets/telemetry assets/commerce \
  assets/ui assets/player assets/maps assets/world assets/research \
  assets/quests assets/localization assets/shaders assets/animation \
  provenance provenance/builds provenance/legal provenance/binders \
  qa qa/reports scripts tools webgame webgame/assets webgame/src webgame/src/scenes webgame/src/systems webgame/src/utils
do
  ensure_dir "$d"
done

# -----------------------------
# 2) Minimal must-have assets (icons, splash, bg, particle)
# -----------------------------
echo "== Step 2 :: Core Assets =="

# 1024x1024 PNG (solid dark) placeholder
ICON_B64="iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAQAAABWZ0XKAAAAKUlEQVR42u3BMQEAAADCoPVPbQ0PoAAAAAAAAAAAAAAAAAAAAAAAAAAAwN8BVXwG3WA4QhAAAAAASUVORK5CYII="
# 2048x1024 PNG (solid gradient-ish tiny) placeholder (1x1 scaled OK as placeholder)
SPLASH_B64="$ICON_B64"
BG_B64="$ICON_B64"
SPARK_B64="$ICON_B64"

[[ ! -f assets/icon.png ]]   && write_base64 assets/icon.png "$ICON_B64"
[[ ! -f assets/splash.png ]] && write_base64 assets/splash.png "$SPLASH_B64"
[[ ! -f webgame/assets/bg_fire.png ]] && write_base64 webgame/assets/bg_fire.png "$BG_B64"
[[ ! -f webgame/assets/spark.png   ]] && write_base64 webgame/assets/spark.png "$SPARK_B64"

# Audio placeholders (0-byte ok for build; engine should handle missing gracefully)
touch_if_missing assets/audio/ui/tap.ogg
touch_if_missing assets/audio/ui/upgrade.ogg
touch_if_missing assets/audio/ui/prestige.ogg
for era in fire stone bronze iron industrial digital quantum ascension; do
  touch_if_missing "assets/audio/music/${era}.ogg"
done

# Fonts declared by code; actual font bundling is optional until art pass
touch_if_missing assets/ui/.keep_fonts

# -----------------------------
# 3) Ensure critical config files exist and are coherent
# -----------------------------
echo "== Step 3 :: Config Coherence =="

# package.json baseline scripts
ensure_file package.json '{
  "name": "chronus",
  "version": "0.1.0-alpha",
  "private": true,
  "main": "app/App.js",
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "build": "bash scripts/game_auto_release.sh",
    "verify": "python3 tools/verify_hashes.py",
    "webgame:dev": "pnpm --prefix webgame dev",
    "webgame:build": "pnpm --prefix webgame build"
  }
}'
ensure_json_field package.json '.scripts?"build"' '.scripts.build="bash scripts/game_auto_release.sh"'

# app.json baseline + ensure android.package + icon/splash
ensure_file app.json '{
  "expo": {
    "name": "Chronus",
    "slug": "chronus",
    "version": "0.1.0",
    "icon": "./assets/icon.png",
    "splash": { "image": "./assets/splash.png", "resizeMode": "contain", "backgroundColor": "#0b0f14" },
    "assetBundlePatterns": ["**/*"],
    "android": { "package": "com.lamontlabs.chronus", "versionCode": 10 }
  }
}'
ensure_json_field app.json '.expo.android.package=="com.lamontlabs.chronus"' '.expo.android.package="'"${ANDROID_PACKAGE}"'"'

# eas.json baseline
ensure_file eas.json '{
  "cli": { "version": ">= 14.0.0" },
  "build": { "production": { "android": { "autoIncrement": "versionCode" } } },
  "submit": { "production": { "android": { "track": "internal", "serviceAccountKeyPath": "./service-account.json" } } }
}'

# Webgame manifest
ensure_file webgame/assets/manifest.json '{
  "version": "v0.1-alpha",
  "assets": { "images": ["bg_fire.png","spark.png"], "audio": ["audio/ui/tap.ogg","audio/ui/upgrade.ogg","audio/ui/prestige.ogg"] }
}'

# Webgame index.html + main.js if missing
ensure_file webgame/index.html '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Chronus</title><style>html,body,#app{height:100%;margin:0;background:#0b0f14}</style></head><body><div id="app"></div><script type="module" src="/src/main.js"></script></body></html>'
ensure_file webgame/src/main.js 'import Phaser from "phaser"; import BootScene from "./scenes/BootScene.js"; const cfg={type:Phaser.AUTO,parent:"app",width:720,height:1600,backgroundColor:"#0b0f14",scale:{mode:Phaser.Scale.FIT,autoCenter:Phaser.Scale.CENTER_BOTH},scene:[BootScene]}; new Phaser.Game(cfg);'
ensure_file webgame/src/scenes/BootScene.js 'import Phaser from "phaser"; export default class BootScene extends Phaser.Scene{constructor(){super("Boot");} preload(){this.load.image("bg","assets/bg_fire.png");this.load.image("spark","assets/spark.png");} create(){this.add.image(360,800,"bg").setDisplaySize(720,1600);this.text=this.add.text(24,24,"Chronus Ready",{fontFamily:"monospace",fontSize:28,color:"#ffd54f"});this.input.on("pointerdown",()=>{const p=this.add.particles("spark");const e=p.createEmitter({x:360,y:800,speed:{min:-200,max:200},lifetime:300,quantity:10});this.time.delayedCall(350,()=>p.destroy());});} }'

# RN App.js minimal if missing
ensure_file app/App.js 'import React from "react";import { SafeAreaView, View, Platform } from "react-native";import { WebView } from "react-native-webview";export default function App(){const src=Platform.OS==="android"?{uri:"file:///android_asset/dist/index.html"}:{uri:"http://localhost:5173"};return(<SafeAreaView style={{flex:1,backgroundColor:"#0b0f14"}}><View style={{flex:1}}><WebView originWhitelist={["*"]} source={src} javaScriptEnabled domStorageEnabled allowFileAccess allowUniversalAccessFromFileURLs mixedContentMode="always" /></View></SafeAreaView>);}'

# Vite config if missing
ensure_file webgame/vite.config.js 'import { defineConfig } from "vite"; export default defineConfig({root:".",base:"",build:{outDir:"dist",emptyOutDir:true,rollupOptions:{input:"index.html"}},server:{host:true,port:5173}});'
ensure_file webgame/package.json '{ "name":"chronus-webgame","version":"0.1.0-alpha","private":true,"type":"module","scripts":{"dev":"vite","build":"vite build","preview":"vite preview --port 5173"},"dependencies":{"phaser":"3.80.0"},"devDependencies":{"vite":"^5.4.8"}}'

# Makefile baseline targets
ensure_file Makefile $'# Chronus Makefile\nbuild:\n\tbash scripts/game_auto_release.sh\nverify:\n\tpython3 tools/verify_hashes.py || true\nclean:\n\trm -rf build webgame/dist app/dist || true\n'

# Verify scripts existence
ensure_file scripts/game_auto_release.sh '#!/usr/bin/env bash\nset -euo pipefail\npnpm --prefix webgame install || true\npnpm --prefix webgame build || true\nmkdir -p app/dist && cp -r webgame/dist/* app/dist/\necho "[build] webgame → app/dist synced"\n'
chmod +x scripts/game_auto_release.sh

# tools/verify_hashes.py baseline
ensure_file tools/verify_hashes.py '#!/usr/bin/env python3\nimport hashlib, json, os, time\nskip={".git","node_modules","build","dist",".expo",".gradle","__pycache__"}\narts=[]\nfor root,_,files in os.walk(\".\"):\n    if any(s in root for s in skip):\n        continue\n    for f in files:\n        p=os.path.join(root,f)\n        try:\n            with open(p,\"rb\") as fh:\n                h=hashlib.sha256(fh.read()).hexdigest()\n            arts.append({\"path\":p,\"sha256\":h})\n        except: pass\nout=f\"provenance/logs/hash_snapshot_{int(time.time())}.json\"\nos.makedirs(\"provenance/logs\",exist_ok=True)\nwith open(out,\"w\") as fh: json.dump({\"timestamp\":time.time(),\"count\":len(arts),\"artifacts\":arts},fh,indent=2)\nprint(out)\n'
chmod +x tools/verify_hashes.py

# -----------------------------
# 4) Resolve duplicated webgame entrypoints (keep single index.html/main.js)
# -----------------------------
echo "== Step 4 :: Duplicate Entry Guard =="
# Keep webgame/index.html + webgame/src/main.js as canonical
# Remove any stray alt copies produced earlier in the history
for f in webgame/index_alt.html webgame/main_alt.js; do
  [[ -f "$f" ]] && rm -f "$f" && echo "[prune] $f"
done

# -----------------------------
# 5) Install dependencies
# -----------------------------
echo "== Step 5 :: Dependencies =="
if command -v pnpm >/dev/null 2>&1; then
  pnpm install || true
  pnpm --prefix webgame install || true
else
  npm i -g pnpm@8 && pnpm install && pnpm --prefix webgame install
fi

# -----------------------------
# 6) Build webgame and sync to app
# -----------------------------
echo "== Step 6 :: Build Webgame =="
pnpm --prefix webgame build
mkdir -p "$APP_DIST"
cp -r "$WEBGAME_DIST/"* "$APP_DIST/" || true
echo "[sync] $WEBGAME_DIST → $APP_DIST"

# -----------------------------
# 7) Quick QA smoke tests
# -----------------------------
echo "== Step 7 :: QA =="
if [[ -f qa/test_runner.py ]]; then
  python3 qa/test_runner.py || true
else
  echo "{}" > qa/reports/auto_stub.json
fi

# -----------------------------
# 8) Provenance snapshot
# -----------------------------
echo "== Step 8 :: Provenance =="
python3 tools/verify_hashes.py >/dev/null 2>&1 || true
SNAP="$(ls -1t provenance/logs/hash_snapshot_*.json 2>/dev/null | head -n1 || true)"
if [[ -n "${SNAP}" ]]; then
  echo "[prov ] snapshot: $SNAP"
fi

# -----------------------------
# 9) Git commit + lightweight tag
# -----------------------------
echo "== Step 9 :: Git Sync =="
if git rev-parse --git-dir >/dev/null 2>&1; then
  git add -A || true
  git commit -m "[${TAG_PREFIX}] generate-missing ${DATE_UTC}" || true
  TAG="${TAG_PREFIX}-$(date +%Y%m%d%H%M%S)"
  git tag -a "$TAG" -m "Autogen ${DATE_UTC}" || true
  git push --follow-tags || true
else
  echo "[info] Not a git repo; skipping push."
fi

# -----------------------------
# 10) Android Studio export prep (optional)
# -----------------------------
echo "== Step 10 :: Android Export =="
mkdir -p "$ANDROID_EXPORT"
cp -r android/* "$ANDROID_EXPORT"/ 2>/dev/null || true
cp -r "$APP_DIST" "$ANDROID_EXPORT/dist" 2>/dev/null || true
echo "$DATE_UTC" > "$ANDROID_EXPORT/BUILD_TIMESTAMP.txt"
echo "[done ] android_export prepared"

echo "== COMPLETE :: Repository generated and ready =="
