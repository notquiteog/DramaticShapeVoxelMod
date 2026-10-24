# Original ORAS healing machines and native animation surfaces

One complete original Alpha Sapphire healing machine replaces the exact two-by-two native healer in 87 edition-room instances: Emerald 17, Ruby 16, Sapphire 16, FireRed 19 and LeafGreen 19. Approval covers this furniture component with the reviewed Scene surface bridge. Complete room coverage remains unaccepted.

## Source and closed geometry

Source linkage: ZO228 → AD108 → MM169 → GR511, model `t102pc0101_00_00`, submeshes 16/15 (`pc_mc01` machine and `pc_mc02` tray). All 454 original triangles, original vertices/indices/UVs and both opaque PNGs remain. The importer independently verifies positions, UVs and indices against Nitrogen, exact original model hash and texture bindings. Provenance records original BCH/pixel/PNG hashes and bounds. Source vertex lighting becomes white; room shadows, room floors and other light geometry are excluded.

The joined machine/tray have ten original open boundaries. Joining their edges first avoids adding an internal tray cap. One boundary spans both the floor contact and rear silhouette; it splits exactly along their common existing edge. Eleven planar closures use concave-polygon ear triangles and an original neutral shell texel, adding 96 triangles (550 total). Original handle openings and the shaped tray remain open spaces. All nineteen imported furniture models pass the strict positive-area coplanar-overlap check. Source and closure triangles remain nondegenerate.

The source fits uniformly inside the native 32×32 blocked footprint, retaining an approximately 24.73 pixel total height. Only physical floor contacts recess 0.025 pixels; no blanket elevation moves the machine or native floor. The source tray stays at its actual fitted height, approximately 18.65 pixels. First-person eyes can naturally lose sight of the tray behind its front housing; normal third-person orbit views expose the complete machine and six balls. Source proportions and normal camera behavior are preserved.

## Renderer contract

`Gen3ImportedInteriors.build(cells,newMesh,parts,{healingSurface=true})` explicitly declares that the renderer supports source animation surfaces. Without that capability, the complete native healer remains. Other furniture continues normally. Missing either required source texture atomically retains all existing native interior furniture, and no source animation surface is returned.

For an uploaded healer, `Gen3ImportedInteriors.healingSurface(prop)` returns the fitted world quad and `{centers[1..6],radius}` ball layout. The layout derives from the original flat tray bounds and transforms with the same source fit; it cannot cross the tray edges. The original engine still owns party count, placement timing, palette pulses, monitor animation and teardown. `Gen3HealingBalls.append/canvas` accept the optional layout as their last argument; existing callers retain exactly the native geometry.

The small reviewed integration patch is [gen3-healer-scene.patch](integration/gen3-healer-scene.patch). It passes the build capability, selects the returned effect quad and passes the ball layout to the existing native-palette geometry callback. The repository Scene file was left untouched; native proof used only an isolated shadow copy with that patch. Root owns final integration. A renderer without the patch safely keeps the native healer.

## Native proof and scope

Latest official release checked before this coherent batch: 0.3.96. An isolated official engine, standalone API3 mod and independently writable imported profiles passed all 87 source rooms and all 87 missing-texture rooms. Native room overviews, every owner approach, complete orbit and available side views were reviewed, together with nine final source angles including both undersides. HD2D actors remain separate, and the native staff aisle/counter placements remain unchanged.

In each of the five editions, the actual native FLDEFF 25 animation ran with a six-member party in both source and failed-source modes. All sequential one-through-six ball counts were observed through native canvas readback, captured in normal orbit, and the engine effect completed. Source mode used the fitted source layout; failed-source mode verified the absent source layout and original native spheres. This is visual field-effect proof; it does not claim new Nurse Joy dialogue or gameplay coverage.

The fresh 2,161-map census matches every prior native hash and furniture-family count. Only 87 healer candidates are added: E591/R548/S548/FR438/LG438 (2,563 total). The separate ledger contains 2,518 accepted components across 280 edition/map pairs, with a Scene-bridge prerequisite explicitly attached to healer approvals. Every whole-map acceptance flag remains false. No map-entry script deltas occur in these 87 rooms, and native hashes remain unchanged before/after source generation, animation and rendering. Per-room module/bridge hashes, upload counts and observed native animation counts are recorded in `coverage/gen3-interiors-2026-10-23/center-healer-runs.jsonl`.

Focused geometry/contact/anchor/native-ball-count tests, nineteen-model plane checks, exact regional identity/kind/collision/failure and unaware-renderer standdown tests, existing PC/native-ball regressions and SDK scenery/resource checks pass. Clean source regeneration is byte-identical for Lua, provenance and both PNGs. Raw BCH files, captures, runtime copies, caches and profiles stay local.

Remaining service counters, screens, cabinets and room framing retain separate queue entries. Existing generic Indigo Plateau openings and other unfinished room envelopes remain unaccepted.
