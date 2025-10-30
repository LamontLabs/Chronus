# KNOWN LIMITATIONS

## Technical
- Replit GPU constraints limit complex particle effects
- Expo WebView adds small frame latency on low-end devices
- Firebase offline sync occasionally delayed >2s
- Asset load budget fixed <300MB
- Sound layering capped at 32 concurrent channels

## Design
- AI overseer narrative partially linear in v0.1
- Quantum Age visuals not yet procedural
- Legacy tree branches limited to 4 active paths

## Planned Fixes
- Native asset caching layer (v0.2)
- Procedural terrain + relic spawner (v0.3)
- Archive-7 adaptive pacing (v0.4)

All limitations transparently logged in `/docs/CHANGELOG.md`.
