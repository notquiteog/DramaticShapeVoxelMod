# Kanto First Person interior integration inventory

Source: vendored `payload_ceiling.lua`, payload-version 28 (release1.60.0).
Author redistribution permission was confirmed by the user. This inventory concerns
interiors; camera, flora, surface effects and sky have separate owners.

| Source feature | Integration / deliberate constraint |
|---|---|
| Ceiling enable, headroom, cutaway | `KfpInterior` shared settings; `InteriorDiorama` is the single authoritative shell. Headroom never lowers an existing room or cave's clearance. Gen2 shell fallback applies the same policy. |
| Upper risers and enclosing boundary | Existing `InteriorDiorama` native-theme closed shell; no overlapping second riser mesh. Native staircase recesses and warp openings remain open. |
| Ceiling material | Existing per-room material palette retained. Importing a second atlas face would cause overlapping surfaces. |
| Wall picture rail / floor skirting | Existing native-theme upper moulding and lower wall courses cover these roles. No busy unrelated tile strip or extra wall depth is added. |
| Door frames / leaves | Existing warp jambs and lintels are outside the passage. Source closed door art is retained in vendor source but not drawn across traversable exits: that would contradict the explicit requirement that geometry indicate native collision. Native animated doors remain authoritative. |
| Windows | Original generated frame/mullion/highlight artwork in optional `KfpInteriorDecor`; no front-wall windows or overlap with stairs/posters. |
| Posters | Original three vendor sheets, frame dimensions and deterministic placement hash; optional dressing only, native style stays default. Cave rooms receive none. |
| Pendant model | Original four-sided shade, crossed cable and mounting plate; five-cell spacing in large rooms, central fallback in small rooms. Headroom <40 skips fixtures; stair voids and doorway lanes excluded. |
| Lamp pools / doorway daylight | Optional additive low-alpha overlays, bounded by the room, skipped over stair holes, depth tested without rewriting collision or native floor textures. |
| Timber joists | Original beam dimensions and residential restriction. Suppressed with ceiling cutaway. |
| Cave ceiling relief / skirts | Original deterministic per-cell heights and shade constants; skirt faces close neighbouring relief gaps. |
| Cave hanging spikes | Original four-sided spike form and stable hash; attached above traversal clearance. Ground spikes from the source are intentionally excluded because source randomness can put them in native walkable cells. |
| Painted floor-contact strips | Existing scene shadow/depth system retained. The source redraws native floor UVs with dark shading; copying that would repeat floor patterns and reintroduce the reported ugly wall shadows. |
| Installer, global status, self-removal | Not executed. Modules load through the fork namespace; no engine file patching, cross-mod shared globals or dependency on another mod. |

These are explicit integration choices, not claims that the untouched source
patcher runs. Every cosmetic imported feature is optional and works through the
same shell policy in all three generations; original map traversal is unchanged.

## Verification

`tests/kfp_interior_test.lua` covers policy/cache invalidation, Gen2 fallback,
original mesh dimensions, cave clearance, door/stair exclusions, window/poster
separation, light bounds and large-room fitting density. The existing 0.3.74
captures in `.scratch/kfp-20261011/{emerald-interiors074,crystal-interiors074}`
cover homes, Sprout Tower and Dark Cave in first person and orbit.

The large-room fitting update was rendered and inspected on official 0.3.75 in
Emerald Brendan's house and Oldale Pokémon Center, AIRY/TALL first-person and
orbit: `.scratch/kfp-capture-20261011/interior-grid075/`. Pendant supports meet
the ceiling, timber remains residential, wall/window/poster art stays intact,
and orbit opens the shell without leaving floating lamps. The partner catch HUD
is visible in these captures; it was not changed for this interior test.
