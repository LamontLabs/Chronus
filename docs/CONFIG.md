# CONFIGURATION GUIDE

## Overview
Chronus uses environment variables and configuration files to define build, analytics, and determinism behavior.

## Environment Variables
EAS_TOKEN  
GOOGLE_SERVICE_ACCOUNT_JSON  
GH_PAT  
PLAY_TRACK  
ANDROID_PACKAGE  
BUILD_MODE (dev|staging|prod)

## Config Files
.env — local overrides  
config/app.yaml — Expo & UI configuration  
config/game.yaml — Idle simulation parameters  
config/telemetry.yaml — analytics + event pacing  
config/security.yaml — signing + key paths  

## Deterministic Parameters
- build_seed → generated per build  
- idle_cap_hours: 12  
- prestige_multiplier: 1.5  
- hash_algorithm: SHA-256  

## Verification
make verify  
Regenerates configuration checksum and compares to last stored value in `/provenance/config_hash.json`.
