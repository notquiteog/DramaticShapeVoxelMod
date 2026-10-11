# Embedded Kanto First Person integration

Source: mrmushrooms11's firstperson1.60.0, retained under vendor/kanto-first-person.
Author permission was reported by the project owner on 2026-10-11; see vendor
attribution for the archive hash. This is part of Battle Art, not a dependency.
The upstream file-replacing installer is never loaded.

Shared options expose original panorama artwork, sky/clouds/stars, aircraft,
rainbows, jump/head bob/doorstep presentation, ambient/step/door/rain audio,
NPC umbrellas, surface-aware puddles/splashes, ceiling/headroom/cutaway controls
and optional interior dressing. Native defaults remain unchanged. Interior
dressing includes original posters, windows, pendants, joists and cave relief.

Payloads run with isolated globals and random state. Asset reads use the mod's
public reader; runtime file mutation is disabled. Native maps supply eligibility,
terrain height and actor placement. Existing flora implementations are reused
rather than loading a second world renderer.

Evidence: focused isolation, motion, interior, ground and audio tests; inspected
0.3.74 Red sky, Crystal interiors and Emerald interiors/weather/water fixtures.
These representative checks do not establish every option in every edition.
Rainbows and aircraft timing need wider runtime coverage. Decorative bird art
adapters and remaining safe flora features are tracked in KFP_FLORA_AUDIT.md.
Vendored source presence is not a claim that every feature is ported.
