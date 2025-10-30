# REPOSITORY STRUCTURE GUIDE

## Directories
/docs — Design documentation  
/assets — Data packs  
/webgame — Phaser core  
/app — Expo wrapper  
/tools — Build scripts  
/qa — Test suites  
/provenance — Hash and signature logs

## Standard Files
README.md  
INSTALL.md  
BUILD_SYSTEM_SPEC.md  
PROVENANCE_SYSTEM_SPEC.md  
LICENSE

## Contribution
No unverified merges  
Commit format: `[buildID] summary`  
CI validates determinism pre-tag

## Binder Export
`make binder` compiles /docs to PDF  
`make verify` checks hashes and updates /provenance/logs

Exports: `/docs/`
