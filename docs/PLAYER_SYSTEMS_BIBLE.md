# PLAYER SYSTEMS & SAVE FRAMEWORK

## Profile
`player_id = SHA256(device_hash + creation_timestamp)`

Files:
- `profile.json` – metadata  
- `progress.yaml` – resources, era, upgrades  
- `chronicle.json` – narrative  
- `config.yaml` – settings  
- `metrics.json` – optional telemetry

## Save Logic
Autosave 60 s active, 5 min idle. Local-first JSON delta compression 80 %.  
Checksums CRC32; restore rollback if mismatch.

## Meta Layers
Era → Legacy → Chronoshards → Achievements → Moral Alignment.  
Prestige snapshots before reset.

## Menus
Main, Build, Upgrade, Research, Legacy, Shop, Settings, Chronicle.  
Schema `/ui/layout.yaml`.

## Security
Local AES-256, Ed25519 signing, GDPR/CCPA compliant, “Data Purge” button.

Exports: `/assets/player/`
