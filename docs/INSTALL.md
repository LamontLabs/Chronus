# INSTALLATION GUIDE

## Requirements
- Node.js v18
- pnpm 8+
- Expo CLI
- EAS CLI
- Replit (optional)
- GitHub access

## Local Setup
git clone https://github.com/Lamont-Labs/Chronus
cd Chronus
pnpm install

## Development Run
pnpm start

## Android Build (.aab)
bash scripts/game_auto_release.sh

## Determinism Verify
make verify

## Troubleshooting
- Clear Metro cache: pnpm start -- --clear
- Clean EAS cache: eas cache:clear
- Reinstall deps: rm -rf node_modules && pnpm install
