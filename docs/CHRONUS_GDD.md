# CHRONUS: CIVILIZATION UNFOLDED — MASTER GDD

> Idle / Civilization Builder / Temporal Simulation • Lamont Labs

## 0) Scope & Principles
- **Core fantasy:** Architect time across eras.
- **Pillars:** Determinism • Ownership • Clarity • Flow • Ethical Compulsion.
- **Target:** Android mid-range+, 60 FPS, ≤300 MB.
- **Offline cap:** 12h. **Prestige mult:** `1.5^(count)`. Premium-lite (no subs).

## 1) World & Environments
- **Eras:** Fire, Stone, Bronze, Iron, Industrial, Digital, Quantum, Ascension.
- **Biomes:** Plains, Forest, Desert, Mountain, Coast, Ruins, Skyplate.
- **Weather impact:** ±10% yield. Procedural grid, per-user seeded.

## 2) Buildings & Production
- Families: Energy, Habitation, Knowledge, Production, Culture, Monuments.
- **Yield:** `base * tier_mult^tier * auto * era * event`.
- **Cost:** 1.4× per tier. Visual tier every +5 levels.

## 3) Wildlife
- Era-evolving fauna; ambient motion anchors; deterministic FSM.

## 4) Resources
- I: Wood, Stone | II: Food, Metal | III: Energy, Knowledge | IV: Artifacts, Chronoshards.
- Conversions and uses defined; meta via Chronoshards.

## 5) Narrative
- NPCs: Shaman/Philosopher, Inventor, Archive-7, Chronicler.
- Personality axes influence tint/soundtrack and micro-buffs.

## 6) Economy & Prestige
- `era_mult = 1 + 0.15*era_index`
- `offline = rate * hours * 0.9` (≤12h)
- Local prestige → talents; Global → Chronoshards, relics.

## 7) Artifacts & Events
- 100+ relics (Temporal/Cultural/Tech/Ethical). Fusion: 3→1 higher.
- Events: Time Rift, Prestige Contracts, Global Projects, Alliance Missions.

## 8) UI/UX
- Top resources, center map, bottom actions, overlays for meta.
- Predictive progress bars, <60 ms input feedback.

## 9) Monetization
- $1.99 premium removes ads, adds voicepacks/cosmetics/QoL.
- Rewarded ads only, 30 min cooldown. Hash-logged transactions.

## 10) Analytics
- Session, ad opt-ins, prestige rates; visible balancing, no stealth.

## 11) Art & Audio
- Warm→cool→gold palette journey; synesthetic SFX mapping; generative eras.

## 12) Expansion
- Guilds, Artifact Fusion, Chronicle export, seasonal sets, desktop port.

## Status
Systems defined. See Bibles in `/docs` for deep specs.
