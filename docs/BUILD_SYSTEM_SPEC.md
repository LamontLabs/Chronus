# BUILD SYSTEM SPECIFICATION

## Structure
/app/ — Expo React Native wrapper  
/webgame/ — Phaser 3 deterministic core  
/assets/ — Game data (YAML/JSON)  
/docs/ — Design documents  
/tools/ — Build + verify scripts  
/qa/ — Automated testing

## Environment
EAS_TOKEN  
GOOGLE_SERVICE_ACCOUNT_JSON  
GH_PAT  
PLAY_TRACK  
ANDROID_PACKAGE

## Steps
1. `scripts/game_auto_release.sh`
2. Build → tag → push → verify
3. EAS Submit optional
4. Generate BUILD_REPORT.md

## Proof
`.aab` logs:
