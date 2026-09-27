# Raised floors and enclosed caves — 1.28.5

Runtime: official Gen1Recomp 0.3.20, native imported Yellow/Crystal/FireRed/LeafGreen caches. Isolated `ascendant-<game>-qa` identities, Xvfb and the bundled LÖVE binary. Checkout on main, based on 607baf1. Player saves and the running AppImage were not modified. Fixtures teleport only isolated QA worlds; movement checks then use normal input.

## Implementation and scope

TerrainLevels solves complete floor regions from actual stair runs. Native GBA collision elevations separate compatible floors; their numbers are never used as world heights. Neighboring map seams share a placement datum. Source-reviewed Crystal profiles cover cave shelves, brown mountain paths, ports, Ice Path borders, Dance Theater, Violet/Blackthorn gyms, train stations and Dragon's Den. FireRed/LeafGreen native stairs constrain terraces, with reviewed raised deck profiles for Cerulean Gym, S.S. Anne exterior and Three Island Port.

Actors, first-person/orbit cameras, terrain, vegetation, furniture, effects and Gen3 water reflection planes use physical support height. Cache revision 77 invalidates old meshes. Existing Gen1 authored elevations are retained.

InteriorDiorama now includes Gen1 CAVERN, Gen2 CAVE environments and Gen3 underground maps (type 4). Four outer walls and a ceiling enclose ground-level views; cameras outside receive the established interior cutaway. Cave ceilings clear the highest platform by at least 64 pixels. Native boundary exits/connections and descending stair openings remain open. Walkable collision alone cannot punch holes in the shell. Cave cameras continue following the player; room framing does not take over. Outdoors remain excluded.

## Evidence

Scratch root: `/home/admin/Projects/.scratch/ascendant-20260926`.

- Native census (`elevation-final` Crystal/FireRed, `elevation-release` LeafGreen): 388 Crystal maps, 17,582 raised floor cells, 69 stair columns/runs; 426 maps per FRLG edition, 7,265 raised cells, 293 stair columns/runs. Zero contradictory hard stair constraints. This is structural coverage, not visual approval of every map.
- Rendered overview/first-person captures inspected: Dark Cave Blackthorn entrance, Burned Tower B1F, Blackthorn City, Olivine Port, Dance Theater, Violet Gym, Blackthorn Gym 1F, Goldenrod train station and Elm's Lab; FRLG Victory Road 1F, Mt Ember, Sevault Canyon, Cerulean Gym, S.S. Anne exterior and Oak's Lab. LeafGreen release captures confirm the pool walkway and pier stand above water.
- Real-input `elevation-walk`: LeafGreen Mt Ember support 24→36, Crystal Dance Theater 0→6. Largest contact increment 1.5 pixels, matching individual treads. FRLG first-person eye 49.5 = floor 36 + eye height 13.5. Initial theater double-height classification found and corrected before release.
- `cave-final`: inspected enclosed first-person views in Yellow Mt Moon/Diglett's Cave, Crystal Dark Cave/Ice Path and FireRed/LeafGreen Victory Road/Mt Moon; overview remains visible. The first shell iteration exposed walkable-border gaps; final openings require native exit/connection metadata.
- Yellow forest/lab regression captures inspected (`elevation-legacy`); no new elevation profile is applied to Gen1. Existing sprite orientation/presentation still needs broader polish; these captures are not an all-scene visual quality approval.
- Focused LuaJIT suites pass: terrain_levels_test, native_elevation_test, cave_enclosure_test, interior_diorama_test, gen3_terrain_test, gen3_stairs_test, house_stairs_test, gen3_sprite_anchor_test, scene_stream_test, gen2_flowers_test and low_grass_test. Production LuaJIT compilation and diff whitespace checks pass.

## Limits

Unreviewed drawings without stair or source-floor evidence retain their existing height. Generic outdoor jump-only loops do not impose contradictory global terrain levels. This release does not certify every platform or bridge layer in every map, every camera/warp/battle combination, multiplayer elevation behavior, Android, or complete five-mod parity. Cave enclosure is a stone boundary shell behind existing native maze geometry; individual cave wall artwork and specialty objects still need further visual refinement. User saves remain untouched; test processes exit after capture.
