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

Native airborne-art adapter (2026-10-11): DISTANT BIRDS defaults OFF and
resolves active native front artwork through the GB sprite provider or GBA
public Pokémon API. The donor's centered second wingbeat frame is derived in
memory; no imported assets or generated caches are shipped. Images are owned
by this adapter, released on game changes, and never release native sprite
caches. Billboards use the actual scene-camera heading in every generation.
This is decorative airborne wildlife, not encounter ownership. Ground-flock
behavior remains excluded until a native collision/height owner is supplied.

Official0.3.75 Emerald and Crystal native boots rendered16 airborne sprites
without adapter errors; the skyward Emerald capture visibly shows the small
native silhouettes with transparent backgrounds. QA fixture:
`tools/qa/kfp-birds.lua`; captures under
`.scratch/worker-closure-20261011/{emerald-birds-close075,crystal-birds075}`.
Focused tests cover provider selection, centered alpha frames, bounded cache,
owned image release and donor isolation. These are representative checks,
not an all-maps visual claim.
Red0.3.75 also passed after waiting for the native scene's loading veil; the
skyward render visibly shows native monochrome bird silhouettes. The fixture
waits for actual draw dispatch rather than assuming a fixed frame count.
