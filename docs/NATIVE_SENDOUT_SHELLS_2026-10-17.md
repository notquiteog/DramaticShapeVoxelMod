# Native GBA send-out shells — 2026-10-17

Supported Poke/Great/Ultra/Master/Safari send-out balls now use the existing
Legendary shell model in the native world-card draw boundary. Native projected
positions, visibility, flight rotation and closed/half/full lid frames remain
authoritative. Live BALL SIZE retains the native lower contact point. Lit and
shadow passes use the same shell pose. No ball animation, particle, cry, battle
state, item or party timing is replaced.

OFF, non-world stages, doubles, captures, specialty models, ambiguous coincident
balls and native darken/flash/blend/alpha effects retain the original native card.
Failed shell drawing also falls back. No new art/model was authored or copied.
This closes supported send-out **shell** geometry; full Q57 release energy and
subject materials remain incomplete, as do unsupported model types.

Focused27 contracts and existing world-battle capture tests pass. Official0.3.89
(native Linux LÖVE shell, latest release checked2026-10-17) passed the NVIDIA
fixture on FR/LG/Ruby/Sapphire/Emerald. Each run exercised native initial send-out,
four actual switches across the five supported ball types, then an OFF switch:
180 lit replacements,36 shadow replacements,36 OFF native draws per edition.
The fixture verified actual party index, open/closed frames and cleanup.

`tools/qa/native-gen3-sendout-shells.lua` uses isolated QA profiles,480x320,
level3 native field, distance16, Legendary enabled and initial shadowsON;
shadowsOFF after initial send-out bounds the remaining type/OFF checks. Maps are
the editions' starter towns at(7,8), down, with Charizard/Blastoise versus wild
Rattata.15 captures were inspected: closed flight, open shell during the native
reveal, and OFF native card for each game. Native HUD/message layers remain
visible. Ball type coverage is instrumented; the15 snapshots show the initial
Poke Ball and OFF state rather than all type/phase combinations.

Evidence directory: session scratch `gen3-sendout-shells-nvidia-0389/<edition>`;
`contact.png` combines the15 inspected images. Runs used the established
`gpu-perf-20261015/run-desktop.sh` with `QA_ENGINE=engine`. All exited0 and used
isolated saves. The earlier FireRed Xvfb/llvmpipe attempt reached its180-second
limit after closed/open captures; it is not a completed native-switch pass.

No performance, Android, doubles or full release-effects parity claim is made.
