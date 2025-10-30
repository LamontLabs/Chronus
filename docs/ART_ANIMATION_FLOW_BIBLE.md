# ART & ANIMATION FLOW BIBLE

## Style
Stylized 2D, clean silhouettes, readable on 6" screens. 60 FPS deterministic.

## Era Transition (2.0 s)
1) Fade-out 0.3s → 2) Particle dissolve 0.4s → 3) Hue shift 0.5s → 4) Geometry morph 0.6s → 5) Fade-in 0.2s. Logged with seeds.

## Building Loops
- Energy: glow-pulse 60f tied to yield.
- Habitation: window flicker 90f.
- Knowledge: orbit glyphs 120f.
- Production: conveyor 75f to BPM.
- Culture: banners/crowd 90f.

## Characters
Idle 30f breath, talk 3+12f, walk 16f, dissolve 20f shader `time_shift`.

## UI Motion
Tap scale 120ms; bars accelerate last 10%; menus 200ms ease.

## Particles
Global cap 2000; GPU instanced; per-family schemas (embers, sparks, code, quantum, ascension).

## Shaders
BaseDiffuse → GlowPulse → RefractionWarp → TimeRipple → LensFlare (Ascension).

## Camera
Layers, 0.8–1.4× zoom, 8px shake on milestones, parallax 1:2:4.

## Light/Weather
Day/night 6 min; fog/smog/aurora profiles; deterministic timing.

## Performance
≤16 ms/frame; atlases ≤2048²; ETC2; particle LOD if <55 FPS.

## Ethics
Auto-dim after 10–30 min, flicker <3 Hz, color-safe LUTs.

Exports: `/assets/animation/*` and `/assets/shaders/*`.
