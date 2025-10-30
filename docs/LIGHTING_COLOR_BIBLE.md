# LIGHTING & COLOR GRADING BIBLE

## Engine
WebGL2 deferred, PBR-lite, ACES tone map, linear space, gamma 2.2. Max 6 dynamic lights.

## Era Light Profiles
Fire(amber, 1.4 lux sim, amb 0.25, soft 3px) … Ascension(white-gold, amb 0.65).

## Time-of-Day
6 min cycle; Kelvin 2000→6500→3000; fog density 0.1–0.4; SSAO radius 1.2.

## Material Response
Metalness ≤0.9; roughness Fire 0.8 → Ascension 0.2; era-tinted specular.

## Palettes
Per-era primary/secondary/accent tables; warm/cool rules; LUT per era.

## Grading
ToneMap→LUT→Vignette 0.15→Bloom 0.4→CA 0.002 (Q/A)→Grain 0.03→Depth Fog.

## Events
Chronostorm strobe +50%; Relic spot +80%; Prestige beam; Era crossfade.

## Chronolux
`luminance = base * log10(age+1) * (1 + empathy*0.1)`; hue bias by moral vector.

## Safety
Flicker <3 Hz; color-blind LUTs; brightness cap 250 cd/m².

Exports: `/assets/color/*`, `/assets/lighting/*`.
