# Authentic ORAS corridor Marts and guarded adapters

Original GR0004 `world01_02_02` supplies703 physical source triangles and its
original `friendry_01` texture. The nineteen original bottom-rim vertices form
an exact seventeen-triangle closed underside, retaining the front recess and
angled corners. Original source positions, UVs and indices were independently
compared through n3ds_importer and Nitrogen. Vertex exposure lighting is omitted;
source texture paint is retained. Source front/sides/rear/top/underside renders
were inspected. There is no source lawn or duplicate ground plane in the model.

The matching BM0009 `com_bm_fsdoor01` supplies43 physical triangles. Its source
`move` bone slides a single complete panel from X13.99994 to41 over six source
frames. Closed/half/open cached poses sample0/2.5/5; all original geometry and
textures survive. The24-triangle nonphysical light effect is omitted. Independent
geometry comparison and stored moving inverse bind checks pass.

Other towns must not inherit this source automatically. GR0008 Petalburg has
different original topology/UVs; GR0038 Rustboro differs in original positions
and UVs. Both actual variants are now separately exported from their original GR0008 and
GR0038 arrays, retaining each topology/UV/vertex detail. Native AD0009/0011
textures were independently compared to their own source pixels before sharing
identical processed PNGs. The current adapter accepts only the exact nine native
R/S/E Oldale/Petalburg/Rustboro placements and native MIDs,
permissions, owner, level and region. Uniform fitting leaves the original
walkable rear drawing row clear; triangle clipping rejects source faces spanning
walking cells. The original entrance remains x+1/y+3. Body and door use the same
base, with the closed underside0.05units below native ground.

Latest official release rechecked2026-10-23: Gen1Recomp0.3.95. Actual R/S/E native
Oldale/Petalburg/Rustboro source drawings were inspected. Isolated official Linux native QA uploaded
the body and all source door states, checked their counts and atomic failed-upload
rollback in all nine town/edition candidates. Lua regression also checks exact native anchor,
source closures, rejected native cells and missing-source fallback. Reusable
native driver: `tools/qa/hoenn-oldale-mart.lua`.

These are source/adapter checks, not final Scene acceptance. Parent Scene must
route `Gen3ImportedMarts.build` alongside its building candidates and draw/release
`Gen3MartDoors` for successful `g.importedMartDoors`. Its `ownsDoor` predicate
replaces only that native door animation. Native front/first/side/rear and actual
entry/return remain pending integration. No raw game archives or captures ship.
