# Kanto homes and school — 2026-10-17

## Scope and source

FireRed and LeafGreen each receive six home interiors and Viridian School:

- `FR_PLAYERS_HOUSE_1F`
- `FR_PLAYERS_HOUSE_2F`
- `FR_RIVALS_HOUSE`
- `FR_PEWTER_CITY_HOUSE1`
- `FR_PEWTER_CITY_HOUSE2`
- `FR_VIRIDIAN_CITY_HOUSE`
- `FR_VIRIDIAN_CITY_SCHOOL`

Both editions were independently inspected against their imported native
metatiles, complete layouts and walking permissions. Imported pixels stay in
private scratch; the package includes authored geometry and source references.
This batch retains published 1.45.0 and its 1.44.1 scene reuse/interface work.

## Geometry and compatibility

One continuous north wall sits at z=18.8 in living rooms and z=15.8 in the
bedroom/school. Native wallpaper continues around the room, with a single
composited finish instead of overlapping grey backing. Wall depth does not
follow individual cabinets. Windows, notices, maps and pictures use separate
closed frames just ahead of that plane; the TV's native note has a closed back.
Clean local native flooring replaces perspective wall drawings behind them.

Only the horizontal stair flight projects. There is no synthetic stair doorway
housing or front entry surround. Treads, risers, beams, rails and stairwell
frames stay within the native one-cell flight depth; model positions do not
alter collision, warp triggers or the engine's movement/elevation rules.

The school has a separate native window bank, framed chalkboard and map,
closed bookshelves, and a desk with an open textbook. Shelves and elevated desk
parts occupy blocked rows only. Original walkable chairs/stools use closed low
pads, preserving native lanes instead of inventing raised backrests. Mom's
existing HD-2D seated drawing receives the corresponding presentation support;
scripted walking remains native.

Eighteen complete source recipes have exact permission guards, together with
reviewed permissions for existing Kanto furnishings. The tileset alias API
supports third-party regions; unknown/walkable headers keep the prior room
renderer. Other editions retain their own family rules. Characters, Pokémon,
flowers, gallery figures, native UI/scripts/gameplay/warps stay unchanged. No
companion is required. Mesh cache revision103 invalidates older room geometry.

## Verification

Official Gen1Recomp0.3.89, latest release checked2026-10-17; native Linux LÖVE
shell, Xvfb/NVIDIA, disposable copied `gen3-*-qa` identities, no sync, no player
save writes. Standalone source shell contains only Battle Art. Both editions
use native map IDs beginning `FR_`; aliases resolve their own native atlases.

Source candidate: 320 regression suites passed, zero failures,58 unavailable
external-fixture skips. Focused checks cover atlas bounds, complete ownership,
changed walking permissions, low-seat height, unknown-header fallback and
stair solid depth. Native census:74 fixture instances per edition,22 native low
pads each, zero ordinary-solid face overlaps with walking cells (foliage cards
excluded). The census applies the same wall attachment as scene construction.

Before and candidate views cover all14 rooms. Inspected four orbit angles plus
low eye per room (70 renders), with flat continuous walls, separated furniture,
closed backs and preserved entry openings. Native-input driver exercises all14
room aisles, four stair transitions and12 south exits, retaining stock collision,
VM and input. OFF and actual1ST captures use central walkable viewing positions.
Driver fixture teleports position the player; movement and warps use normal
engine input. This is automated native-input/render evidence, not manual CUA
or Android evidence.

Final archive freezes runtime commit `2c9ec41` after correcting the open-book
crop to the native white pages, red bookmark and checked tabletop. All497
packaged Lua files compile under native LuaJIT; ZIP integrity and empty hard
dependencies pass. The archive contains11,417 files. Evidence-only final
repackaging must preserve every tested `data/`, `lib/`, `vendor/`, `assets/`,
entry/manifest/card hash.

Archive scene checks inspect115 orbit/low-eye renders:70 for this batch's14
rooms,30 for Oak's Lab, Viridian Center and the shared Celadon roof room across
FR/LG, and15 for Brendan's downstairs home in EM/RU/SA. The latter maps are
regression checks, not additional regional completion claims. Final archive
native input repeats14 aisles,4 stair transitions and12 exits;28 OFF/actual1ST
views are inspected. Final archive census repeats148 fixtures/zero ordinary
solid walking overlaps/44 native pads. Each launch verifies version1.46.0 and
nine installed runtime-file hashes before executing its driver.

All six optional partners load together and pass native FireRed home walking,
stair warp, exit, OFF and1ST with no mod errors. Repository/release audit finds
all six clean, with local HEAD, published main and latest release commit equal:

| Partner | Release | Commit |
| --- | --- | --- |
| wild_skies |1.15.2|`463913e6`|
| dramatic-sky-ride |0.5.5|`fd425f0b`|
| double-battles-gen2 |0.14.3|`5bfc0ef5`|
| gen1online-plus |0.11.2|`6e838e2c`|
| overworld-spawn-mod |2.6.4|`b81dc23b`|
| modern-ui |0.4.2|`bcde5759`|

Private scratch run groups: `verified-views-{firered,leafgreen}`,
`verified-input-{firered,leafgreen}`, `verified-census-{firered,leafgreen}`,
`verified-neighbors-{emerald,ruby,sapphire}` and `verified-all-six`.
`scene-review.lua` uses `QA_SPOTS` with the seven maps above plus neighbor maps;
`tools/qa/gen3-home-walks.lua` and `tools/qa/gen3-home-census.lua` consume the
seven-line `QA_MAP_LIST`. The shell launches with `--developer --no-sync`, an
edition-specific QA identity and the frozen extracted mod as its only mod (or
all six companions for the named smoke). Tests use `tools/run_tests.sh` with the
approved official engine root. ROMs, native pixels, copied saves, caches and
captures are excluded from Git and the release. Test processes exit; player
progress and concurrent primary-checkout edits remain untouched.

## Remaining coverage

71 of125 initial regional placements are verified;54 remain queued. Routes,
outdoors/terrain, laboratories, gyms, Kanto museum rooms and route buildings
still need this regional pass. Reused family geometry does not count as a
separate map/edition review. This batch does not claim whole-region completion,
ORAS-equivalent scenery or multiplayer interoperability.
