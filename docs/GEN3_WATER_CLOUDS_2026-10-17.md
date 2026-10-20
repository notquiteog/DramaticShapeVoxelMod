# Half-submerged rocks, continuous water and soft clouds — 2026-10-17

Battle Art 1.52.0 / mesh revision107. The native GBA water material uses each
edition's live source palette, shallow world-space ripples and the same cloud
material used in the sky. Characters, Pokémon and flowers remain HD-2D. Native
collision, elevation, scripts, warps and stock UI stay authoritative. No partner
or imported art pack is required. No companion production changes are included.

## Geometry and material

Complete Hoenn stacks/boulders and reviewed small wet rocks retain their closed
source-derived hulls but place their actual vertical midpoint on the surrounding
water plane. Immediate native water supplies the level and ground drawing;
blocked rock elevation cannot lift a square patch above the neighboring sheet.
A one-cell selective source halo completes recognized 2x2 drawings at the render
window edge. Source patterns and permissions still guard ownership. Unrecognized
or third-party altered drawings retain their normal rendering.

Wet-rock ground moves from the opaque terrain batch to the ordinary water batch,
so it shares animation, palette, lighting, reflection and height. FULL captures
one packed opaque depth image for submerged rock color; it reuses the existing
reflection color instead of making an extra color copy. Instanced and merged
fallback geometry agree, including mixed native base heights. Land rocks retain
their original placement. Detailed source/native checks:
[wet rocks](GEN3_WET_ROCKS_2026-10-17.md).

Native GBA water replaces the legacy 16-step quantized relief search with three
low analytic wave bands. Height and gradient are evaluated together; footprint
filtering fades fine detail at distance. Continuous presentation time avoids a
stalled legacy GB atlas clock. Wave displacement is restrained to +/-0.15 world
pixels around the mean plane. Legacy GB water retains its separate material.

The water body tint is derived from the dominant real water drawing for each
live atlas. Similar blue body colors receive reduced repeated-tile contrast;
shore, foam and alpha retain their source details. Provider replacement and
in-place native palette edits refresh the cached color. Missing or unsupported
source pixels retain original material. Tiny color probes replace repeated
full-tile scans. This consumes public live provider pixels; no ROM/cache art is
shipped or accessed privately.

The sky replaces fifteen cloud-deck draws / 5,616 vertices with one cached draw /
1,152 vertices. One normal/coverage atlas lights rounded crowns, soft silhouettes,
weather coverage and dusk/night phases without gameplay RNG. Native water
samples the same field and wind phase. OFF and indoor state clear eligibility.
Stars, birds, horizon and other existing options remain separate. Detailed
visual checks and bounded CPU submission measurements:
[clouds](GEN3_CLOUDS_2026-10-17.md).

## Pass cost and fallbacks

Water draw lists and sorted level groups are cached with scene geometry. SKY
skips the full frame color/depth reflection copies, retaining sky and planar
actor reflections. FULL passes the actual water plane to actor clipping and
avoids drawing the same actors into both reflection paths. The native shader
reuses its reflection color for submerged scenery, keeping its sampler count
within the existing eight-texture baseline. Missing shader/depth support and
water OFF preserve the existing flat native-water fallback. Native desktop
shader compilation is measured separately from mocked/static tests; Android
hardware has not been tested.

## Verification

Source suite:333 passed,0 failed,58 explicitly unavailable-fixture skips on the
official 0.3.89 engine harness. Focused checks include analytic gradients/phase
wrap, underwater depth-only allocation and restoration, live source palettes,
water-sheet continuity, immutable native cells, closed rock hulls and instancing
fallback, cloud resource reuse and OFF/indoor graphics-state cleanup.

Source appearance was checked in all five editions. Matched before/after Hoenn
rock tours cover45 views each plus native dry shore movement and no-surf bumps.
All50 cloud scenes across five editions were inspected, including +/-pi turns,
dusk/night/storm, sky OFF and Oak/Birch indoors. Final palette polish has ten
additional Route103/104 orbit/eye views, including cloud reflections, without
square rock underlays or the earlier strong diagonal body pattern. These are
rendered native captures, not a manual keyboard session.

The benchmark uses one NVIDIA process at a time, matched fixtures/settings,
warm frames, actual renderer/source hashes and an unrelated no-water lab
control. Software-renderer captures are excluded from hardware timing claims.
The final performance report records cost changes and presentation/control
variation; no generic FPS guarantee or Android result is inferred.

The release archive receives its own loaded-source hash checks and native
reruns before publication. Exact archive evidence is recorded below after those
checks complete. Regional coverage remains84/125 verified placements,41 queued;
this effects batch does not mark additional cities/interiors complete.
