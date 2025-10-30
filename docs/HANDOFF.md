# HANDOFF & ACQUISITION PACKAGE GUIDE

## Repository Deliverables
- Full codebase (Expo + Phaser + assets)
- Build reproducibility logs
- Provenance verification chain
- QA results + telemetry anonymized summary
- Design bibles (world, psychology, economy, UI)
- License and compliance audit
- SBOM (CycloneDX format)

## Binder Package
1. `/docs/` compiled into PDF binder
2. `/provenance/` contains full build logchain
3. `/assets/` compressed into `game_data.zip`
4. `/qa/` includes test verification logs

## Acquisition Notes
- Ownership: Jesse J. Lamont, Lamont Labs
- Rights: 100% transferable IP
- Verification: Ed25519 provenance signatures
- Build proof: deterministic hash reproduction across systems

## Verification Commands
make binder  
make verify  
make package
