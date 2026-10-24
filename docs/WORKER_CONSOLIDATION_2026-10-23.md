# Worker consolidation — 2026-10-23

All three active workers were stopped at coherent final checkpoints and their complete Git ancestry merged onto released main 1.58.2:

- Hoenn world/buildings: `a260268e`, including the original Littleroot homes, rural/Mauville/Verdanturf fences, bounded scenery resource sharing and exact native-art cave mouths through Sootopolis. Story-open Magma/Altering and eight mutually exclusive Terra weather placements retain native state guards. The curated Shipyard prototype is committed, default disabled and absent from dispatchers.
- Kanto world: `82529dee`, including genuine Vermilion/Fuchsia Gyms, reviewed outdoor cave reveals, the story-open Ruby Path and native Dotted Hole closed/open assemblies. Every native projection lane, sealed-state bump and opened entry/return remains unchanged.
- Interiors: `6598910f`, including original chairs, tables, healers, bookcases, drawers, sideboards and Meteor stalagmites, Hoenn rock volumes/enclosures, Emerald Navel Rock and the six RSE Seafloor current rooms. The reviewed healer Scene bridge is now production code. Reception counters remain native because the source prototype has not passed visual acceptance.

The separate Double Battles 0.14.9 and Wilds 2.6.10 bug releases are preserved and used as optional companions during combined verification. No hard dependencies were added. No raw ROMs, BCH dumps, source archives, caches, player saves or captures are committed. Historical bed/stair/underwater research remains preserved in local snapshots; it is not activated or claimed as reviewed production scenery.

## Shared shadow filter

Native first-person Dotted Hole review exposed diagonal shadow bands. Initial ON/OFF comparison called these acne, but public shadow-map readback and exact triangle rays demonstrated real frame/column occlusion with fixed PCF weights quantized in 1/16 steps. Unoccluded corrected slab depths differ by at most 0.02 world pixels. Increasing bias would erase real contact shadows and is not the repair.

The soft filter now uses continuous, separable quadratic weights derived from the receiving fragment's fractional texel position. The weights sum to one and remain continuous when the nearest texel changes. Texture fetches remain nine; the original caster transforms, depth bias, slope limits, contact geometry and non-soft filter are unchanged. Same-scene native before/after captures show smooth frame shadows with the cast boundaries retained. A discarded determinant-threshold experiment and a high-bias diagnostic are not included.

Two legacy tests mocked `SceneryModels.image` directly, bypassing the new managed leases. Their fixtures now use the actual image loader with controlled provider bytes and ordinary scene-cache teardown. Original upload-failure, cancellation, fallback and ownership assertions remain enforced.

## Verification and scope

Individual worker evidence is linked from the corresponding component documents. Consolidation additionally runs the repository Lua suite, LuaJIT compilation, merged RSE resource/cave tours and exact-release ZIP checks in isolated official Gen1Recomp 0.3.96 profiles. The release verification attachment records the final results and exact artifact hash. Native grids, interactions and component coverage are distinct from complete-room or whole-game acceptance.

Scenery remains incomplete, including unmatched buildings/regions and broader Sootopolis portico, underwater and source-fit work. All characters/Pokémon and flowers retain HD2D defaults; model/style choices and standalone fallbacks remain intact.
