# USER INTERFACE SYSTEM DESIGN BIBLE

## Philosophy
UI communicates trust. Each tap yields a visible reaction within <60 ms.

## Layout
- **Top Bar:** Resources, Time, Prestige.
- **Center:** Map / City grid / Eras.
- **Bottom Dock:** Build, Upgrade, Research, Legacy, Shop.
- **Overlay:** Events, Notifications, Chronicle, Pause.

## Visual Hierarchy
- Tier 1: Interactive gold/white highlights.
- Tier 2: Informational muted blue/grey.
- Tier 3: Decorative low-opacity background.

## Components
| Component | Type | Response |
|------------|------|-----------|
| Buttons | 3D-flat hybrid | press scale 0.95× |
| Sliders | radial & linear | snap feedback tone |
| Tabs | icon+label | slide 200 ms |
| Modals | centered glass-blur | fade 150 ms |
| Tooltips | delayed 300 ms | pulse glow |

## Accessibility
High-contrast, text scale +25 %, narration toggle, haptic cues ≤25 ms.

## Deterrent Mechanics
No flashing ads, no forced prompts. Confirmation modals for purchases.

Exports: `/assets/ui/` and `/assets/menus/`.
