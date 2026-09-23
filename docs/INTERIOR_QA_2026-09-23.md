# Designed interior furniture — 1.25.0

This pass targets Crystal and FireRed/LeafGreen player houses (both floors), Elm/Oak labs, Pokémon Centers (both floors) and Marts. Gen 1's source-part approach is the reference: separate screens, keys, cases, tabletop/aprons, legs, cushions, shelving and merchandise. It is not a claim of exhaustive visual or option parity.

## Implementation

`InteriorFurniture` emits authored native-textured components through two atlas adapters. Complete drawing recipes are tileset/pair scoped. Source wallpaper, floor and perspective aprons are separated from actual furniture. Cases have closed sides/backs/undersides, recessed CRT faces, pedestals and vents. Desks have kneespace; game consoles have separate controllers/cables. Beds are horizontal with a frame, mattress and pillow. Shelves have recessed source books/stock and separate frame boards. Center cushions are 2.5 pixels high; existing staff-safe reception footprints remain intact.

Crystal's runtime bedroom decorations differ from the base imported map: the bed uses tiles 3/4,19/20,35/36,51/52; 59/60,75/76,91/92 is the television. Both now have independent complete models. Center carpet-edge tile 1 remains ground even under blocked collision cells. Wall claims are row-scoped; backing continues behind appliances. No collision, warp, script, NPC position or ROM art is changed. Furniture support stays presentation-only. Static mesh revision 69 invalidates older emitted geometry.

FireRed/LeafGreen ledge jumps and their landing dust now remain in the selected 3D camera; player and first-person eye height follow the native hop arc. Sand/grass path transitions retain their original cap artwork and continuous ledge height instead of tapering into false ends. Adjacent Mart checkout sections meet without inset seams.

The existing closed roof-shell/eave/soffit regression checks also pass; this batch does not change roof profiles.

## Evidence

Official latest engine v0.3.2 (release API checked September 23). Scratch `/tmp/interior-studio-20260923` contains native source diagrams, fixture drivers, logs and screenshots. Profiles/imported ROM caches are isolated copies; user saves were not edited. Six target rooms per game are captured in static, orbit, reverse and first-person views. Flat Crystal captures verify the live decorated bedroom and carpet edges, not just the base source map.

The initial captures exposed hidden native monitors, incomplete wallpaper, the unmodeled runtime Crystal bed and raised carpet. Follow-up captures were inspected after correcting them. The initial Viridian Mart fixture triggers the native Oak parcel greeting; its UI-obstructed pictures are not full-scene approval. The final archive fixture uses Pewter Mart (same native shop pair) to avoid that story trigger.

Focused checks cover complete native matches, UV bounds, geometry heights, horizontal beds/healing trays, shallow cushions, source-pair isolation, native Center/escalator fixtures, stairwell openings, floor exemptions and generation isolation. The old bin/bed assertion was updated from implementation-specific folded rows to emitted horizontal tray area and height. Two historical Astra tests need private baseline fixtures and were not executed successfully; the engine-SDK tile-shape test requires `tests.modkit`, which the release runtime does not bundle. These are not reported as passes.

## Limits

This is a focused model/placement improvement, not a certification that every tile, alternate decoration, furnishing interaction or camera position is perfect. Other room families, shared lighting/floor materials and the broader cross-generation option/integration backlog remain separate work. Exact archive and release audit results are appended to the root handoff.
