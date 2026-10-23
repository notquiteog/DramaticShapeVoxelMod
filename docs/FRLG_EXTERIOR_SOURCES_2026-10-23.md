# FR/LG exterior source ledger and Pewter houses — 2026-10-23

The native audit enumerates **426 maps per edition**, including **76 outdoor
maps**, **132 detected civic assemblies**, and **54 distinct civic families**.
It separately records **25 source-eligible assemblies** and **107 unmatched
assemblies per edition**. Eight families have at least one eligible source adapter;
46 families still have none. The Gym family is partial:2 of11 assemblies per
edition have matching sources. These are
assembly counts, not percentages of whole-game completion.

The canonical identifier-only report is
`docs/coverage/frlg-exterior-sources-2026-10-23.jsonl`; the family/map table is
`docs/coverage/frlg-exterior-families-2026-10-23.csv`. Every map has a native
metatile/collision/elevation SHA256, pair, dimensions, map type and explicit
outdoor classification. Every detected assembly has its native drawing hash,
source archive/model/provenance hashes where available, exact coordinates,
source eligibility and separate rendered acceptance. The inspected batches accept
the two Pewter houses and the Viridian/Pewter Gyms per edition. Historical acceptance of the other source
families is deliberately not inferred from an eligibility census.

There are also **6346 unclassified blocked outdoor cells per edition**. This
includes terrain and boundaries; it is not a count of missing buildings. The
civic census cannot prove the absence of additional source assemblies there.
Maps without detected civics remain inventory records, not completeness claims.
Interiors, terrain, vegetation and fences belong to their separate inventories.

Rebuild with `tools/qa/frlg-exterior-source-ledger.lua` on an isolated native
runtime, then pass both JSONL files to
`tools/summarize_frlg_exterior_sources.py`. The latter's optional `--accepted`
files must come from manually inspected native scene/warp verification; it does
not promote eligible assets by itself.

## Newer regional Pewter ordinary houses

The selected original is `nbc_h01_005-mesh`, with its own separate
`nbc_dr1_005-mesh`, from [HGSS Pewter City, Kuramapika1, September 1, 2026](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/).
Nintendo / Creatures / GAME FREAK own the original game art. Native FR/LG art
was inspected before adapting the source: a left entrance, right window and
slate roof. The regional HGSS source retains its own original gabled roof,
cyan siding, windows, chimney, handle, recessed threshold, PNG bytes and UVs.
No town ground, actors, Pokémon or flower geometry is imported.

The original has160 triangles. All139 physical triangles remain;21 baked
shadow overlay triangles are excluded. Forty separately named authored
triangles close its rear siding, asymmetric rear gable, measured roof cuts,
pitched soffit, front gable returns and foundation. The final179 triangles
include the separate8-triangle source door. A rear closure offset of0.015
**source units** covers the original internal portal's coplanar rear face;
otherwise those faces flicker through each other. This only separates those
surfaces. The building position, native ground and doorway are not shifted. The explicit
`groundInset=.05` fit option from shared commit0fb2b673 recesses only source
Y0 contact-ring vertices below ground. Original anchors, upper surfaces and
UVs remain unchanged; first-person contact was rechecked in both editions.

`tools/import_pewter_houses.py` reproducibly produces the independent
`PewterHouseData` module and source/provenance hashes. `Gen3ImportedPewterHouses`
requires the complete native5×3 drawing, exact permissions, original civic
ownership, flat elevation and no hidden/boundary/prop conflict. Its uniform
fit keeps the entire physical source inside the original80×48 blocked rectangle
and fills63.34px of its80px width. The original door anchor aligns with native
X24/Z40. Source collision and warps are never edited.

`Gen3PewterHouseDoors` retains the actual8 source triangles independently of the
static body. Native frames0/1/2 drive an explicitly authored inward hinge pose
at0/45/90 degrees. This is a native-placement adaptation, **not an extracted
HGSS animation track**. The whole path stays in the native blocked rectangle.
Missing images, a late upload failure or cancellation release all partially
built door poses and retain native fallback. Static closed source doors cannot
remain behind transparent native open frames.

## Integration contract

The production Scene belongs to the parent integration worktree. This commit
contains no production Scene change. The native QA used a scratch Scene overlay
with these hooks:

- `Gen3ImportedPewterHouses.build(g,cells,newMesh,sceneryParts)` after existing
  regional building adapters. Cache successful groups as `importedPewterHouses`;
  skip the native building only on success. Add `chimney(g)` to source outlets.
- `Gen3PewterHouseDoors.draw(g,nativeDoorAnim,draw)` in the ordinary opaque,
  depth/shadow draw pass; `release(g)` in scene teardown.
- Suppress native door cards only when `ownsDoor(g,x,y)` is true. The native
  engine continues owning timing, sound, input, collision and warp behavior.
- Expose the cache count as `performanceSnapshot().scenery.pewterHouses`.

## Evidence and limits

The latest official release was checked before this batch: **v0.3.95**. Native
runs used its official Linux source and LÖVE11.5 shell, Mesa llvmpipe, isolated
`frlg-{edition}-qa` profiles and no companions. The native hash was unchanged
before/after each fixture. Both houses, at(8,28) and(32,9) in Pewter City,
rendered in FireRed and LeafGreen. Default and first-person front/side/rear
captures were inspected, along with the seven-direction source/closed asset
viewer. Native lawn/path and HD2D flowers remained in place.

Held up input opened all three source door states and entered the real
`FR_PEWTER_CITY_HOUSE2` / `HOUSE1` maps; held down input returned through the
native warps. Final captures wait for the native iris transition to finish.
Missing-source-image LeafGreen fixtures retained native buildings and both
real entrances/returns. All native drivers emitted PASS; the LÖVE shell returns1
on shutdown, so this is not reported as a process exit0.

Six focused Lua suites pass, including the two new tests for exact native
eligibility, original door geometry, pose clearance, late-failure resource
cleanup, source alpha/footprint and existing Pallet/Center/Viridian/Museum
regressions. A fresh temporary conversion reproduces every generated byte and
verifies every used PNG against the original archive hashes. Physical phones
and the parent combined production Scene remain separate acceptance work.

## Exact next gaps

The table lists every unmatched family and map. The regional Viridian and Pewter Gyms now have guarded, inspected adapters;
see `HGSS_KANTO_GYMS_2026-10-23.md`. Other Gym locations remain unmatched.

The twelve Mart drawings per edition include eleven real entrances and one
Saffron connection projection whose original door permission is blocked. The
local newer HGSS Viridian Mart has a left entrance and tall freestanding east
sign. Uniformly aligning it to FR/LG's right native entrance constrains its
physical body to about22px inside the64px native width. That is an inadequate
fit. An explicit faithful aperture/sign adaptation or better matching source is
required; the whole source is not blindly placed. The public catalog returned
HTTP403 during source discovery; existing downloaded regional archives remain
available, so local regional work can continue.
