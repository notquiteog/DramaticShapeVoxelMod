# Corridor fence source audit — pending implementation

This snapshot records verified source findings only. No new fence replacement
is enabled, and no complete modern fence coverage or native visual pass is
claimed. Work stopped for the user's immediate commit/push/release request.

## Native corridor inventory

Read-only original R/S/E cache census covers Littleroot, Oldale, Petalburg,
Rustboro, Dewford, Routes101–106/116, Petalburg Woods and Rusturf Tunnel.
General149 is a broad two-post/one-rail white fence, not generic ground.
Each edition contains19 such cells on Route104 and12 in Petalburg Woods:
93 across R/S/E. Route104 rows27/28/40 and Woods rows5/38 contain the groups.
Other listed corridor maps have no149. Hoenn's current shape dispatch does
not classify149 as a fence, explaining why this family remains flat.

Rustboro has a separate ornate black/white oval railing. Horizontal MID2FC
and its corner/vertical neighboring drawings need distinct source-checked
placements; replacing these with white149 posts would change their identity.
Native static tile sheets and full Rustboro map composition were inspected.
The entire city fence vocabulary/underlayers are not yet accepted.

Reproduce the metadata census without changing source data:

```sh
python3 tools/audit_gen3_corridor_fences.py /scratch/profile/emerald/data/generated/gba
```

The tool records original packed permission bits separately from engine
collision values. Imported native caches and generated census JSON remain in
scratch. Fence ground must be proved from original tile layers/quadrants;
do not replace Rustboro edge/background paving with a nearby single grass tile.

## Genuine ORAS sources identified

The user's Alpha Sapphire local RomFS supplies both physical families:

| Native family | Original ORAS physical source | Texture bank |
|---|---|---|
| Broad rural posts and one rail, General149 | `a/0/3/9` GR0042 slot1, `world04_03_07`, submesh/material `chip_steps01a` | AD0011 slot11, texture `chip_steps01` |
| Ornate Rustboro railing | GR0032/33/37/38, `chip_saku02` physical frames/posts and `chip_saku02b` lattice panel | AD0011 slot11, textures `chip_saku02`/`chip_saku02b` |

The misleading `chip_steps01a` material name is not sufficient to classify
the rural object as stairs. Its actual mesh is a long fence: two broad posts
and one rail per18-unit period, original beveled/sloping caps and source UVs.
GR42 selected source front/quarter renders were inspected with official0.3.95
LÖVE. Source posts are at x2..7 and11..16 in a0..18 repeat interval, matching
the native two-post rhythm. The two original posts plus their connecting
rail contain27 source triangles (11+12+4); source Y is.25..20.75, source Z
is-353..-349. Hidden rear/underside and repeat-end closure remain to audit.
Repeat variants must join without gaps or duplicate posts at native cell edges.

Rustboro source uses22-unit high frames and18-unit post spacing. It has
different geometry and must remain separate from the low rural fence.
Its physical model needs segment clipping/repeat preparation, corner/terminal
closure and original UV/panel-thickness review before a native adapter.

`chip_saku_kg01` in the public Route104 archive and several GR chunks is
only a transparent horizontal shadow sheet: its image has low alpha and the
GR42 mesh lies on one height plane. It is not a physical fence model and must
not be promoted as one. Source `projection_dummy` boxes are also not accepted
as physical fences. No raw GARC, BCH, archive or converter is bundled.

AD11 was read directly with the repository's validated GARC/mini parser;
the earlier Nitrogen scratch extraction has no AD0011 directory. Do not guess
a similarly named texture from another area. The exact native link is
zone16/26/42/43 →AD11 →matrix4, which contains the Rustboro/Route104 chunks.

## Remaining acceptance work

Prepare selected processed geometry/PNG/provenance, close actual source rear/
underside boundaries, remove only proven source baked lighting/shadow overlays,
and register through existing SceneryModels. Provide `build(cells,newMesh,parts)`
with exact regional native art/permission/elevation guards and atomic fallback.
Mark original fence paint suppressed only after every upload succeeds. Keep
native floor identity, blocked footprint and all walking/warp cells unchanged.
Root owns Scene integration; tree files are outside this worker's scope.

No native gameplay fixture was run for a new fence adapter. Required front,
side, rear, first-person, source comparison and all-R/S/E family validation
remain pending. Source-only geometry renders are not that runtime acceptance.
Scratch evidence is under `/home/admin/Projects/.scratch/fences-20261022/`.
