# Native UI audit — 2026-10-05

Engine: official Gen1Recomp v0.3.51 (latest release checked with GitHub).
This is an ownership audit with targeted rendered checks, not certification of
all screens, inputs, attack animations, doubles or network transitions.

| Surface | Ownership / evidence | Remaining |
| --- | --- | --- |
| Battle Art settings | Native Gen1/2 menus and FRLG/RSE option pages; shared categories, live rows | See OPTION_PARITY.tsv for missing consumers |
| Battle HUD/commands without Modern UI | Provider-gated styling; ownership unit suites; runtime OFF captures in Yellow, Crystal, LeafGreen, Emerald | Full transitions/doubles matrix |
| Modern UI standalone | Native labels, HP updates, commands and inputs retained; GB palette-safe framing and native Gen3 healthbox shader | Gen1 WIDE intentionally native; standalone modern command layout not implemented |
| Modern UI with Battle Art | Optional v1 public theme, projected heads/cards; runtime ON/OFF captures in all four fixture games | Full link/doubles and attack matrix |
| Gen3 bag/party/summary while battle exists | Regional FRLG AND RSE menu guards now exclude battle styling | Broader native scene visual matrix |
| Legendary settings | Gen3 now loads master profile and uses live setting rows; effective values, CUSTOM edits and direct-options migration verified | Specialty models and capture effects still missing; master is marked PARTIAL |
| Ride native Gen3 menu/HUD | Source audit: lib/gen3/hud.lua adds custom dark rounded panels/system font | Needs native chrome/font conversion; not compliant with requested native styling yet |
| Online native room/chat | Source audit: lib/crossgen/ui.lua adds custom dark panels/system font | Needs native chrome/font conversion; chat layout and Unicode need dedicated testing |
| Wilds settings / catching HUD | Own settings adapters; optional catching HUD explicitly added by mod | Every menu and ball-selector visual review remains open |
| Doubles | Own extra-slot adapter; optional presentation provider; original game mechanics owner retained | Native appearance and all replacement/target/link cases need broader review |
| Skies | Optional independent encounter provider and native option adapter | In-game matrix beyond manifest/settings checks remains open |

No source-inventory status is promoted merely because a menu row exists.
Partner custom overlays identified above were not silently replaced or marked
native. The release notes retain these open items.

Evidence: .scratch/ui-release-20261005/results/*-alone,
.scratch/coverage-20261004/results/{yellow,crystal}-modern-gb,
{leafgreen,emerald}-modern-ui, emerald-legendary-native.
All profiles are isolated QA profiles; no player saves were used.
