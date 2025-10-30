# TECHNICAL PIPELINE & BUILD FLOW BIBLE

## Stack Overview
Frontend: Phaser 3 (WebGL)  
Wrapper: React Native + Expo (WebView)  
Backend: Firebase (sync + telemetry)  
Build: EAS Build + Submit (Play Store)

## Replit Integration
`bash scripts/game_auto_release.sh`  
1. Build `/webgame` → compile Phaser assets  
2. Expo prebuild → generate Android project  
3. EAS build `.aab`  
4. Optional EAS submit → Play Console internal track  
5. Auto tag commit on GitHub

## Determinism Rules
- Seed value = `SHA256(build_timestamp + version)`  
- Asset hashing enforces reproducible export  
- Timestamp differentials drive idle calculations

## Build Optimization
- Bundle split: `app.bundle.js` < 15 MB, `webgame.bundle.js` < 30 MB  
- Textures compressed ETC2  
- Minified JS + tree-shaken imports  
- Lazy-load UI after map init (T+1.5 s)

## Provenance
Build log → `/provenance/builds/{version}.log`  
Each build signed with Ed25519 keypair.  
CI verifies checksum chain.

## Exports
`/tools/build_scripts/` and `/provenance/builds/`
