# RSE corridor prop-ground audit

The outdoor prop branch of `Gen3Scene` paints an entire 16x16 ground plane using
`shape.ground`, then draws the separate sign/fence/plant. Hoenn's shared General
MID `0x003` board always supplied `ground=0x001` (grass). Imported signs preserve
this same ground decision; `Gen3SceneryModels` only replaces sign geometry and
rebinds its message art. This explains grass squares beneath Rustboro signs.

The source board MID contains the board drawing throughout its lower atlas
layer; the over-layer contributes no different pixels. There is no clean native
BG floor underneath it that can simply be copied. Selecting the nearest grass
or pavement cell would also be unsafe at source terrain boundaries and repeating
metatile patterns.

## Verified native cases

Read-only inspection used the source indexed atlases, palettes and `.mid`
layouts in isolated official 0.3.95 QA caches. All three R/S/E editions have the
same twenty MID3 signs along Littleroot, Oldale, Routes101–104, Petalburg,
Petalburg Woods and Rustboro. Five are surrounded by Rustboro paving:

| Map suffix (RU_/SA_/EM_) | Zero-based x,y | Native paving continuity |
| --- | --- | --- |
| `RUSTBORO_CITY` | 30,8 | left/right `0x2BB`, repeated both ways |
| `RUSTBORO_CITY` | 17,20 | left/right `0x2BB`, repeated both ways |
| `RUSTBORO_CITY` | 25,35 | left/right `0x2BB`, repeated both ways |
| `RUSTBORO_CITY` | 12,38 | north/south `0x2BB`, repeat north; southern border remains |
| `RUSTBORO_CITY` | 19,49 | left/right `0x2BB`, repeated both ways |

These are fifteen affected placements across the three editions. The source
paving border south of some signs includes `0x2F9` and `0x309`; those are distinct
native edge rows and must remain in place. The other fifteen signs per edition
mostly stand on grass and retain their existing material. No corridor modeled
fence family was found: the Hoenn fence recipes belong to Mauville/Verdanturf.
Petalburg's hedge family has native green/grass surrounds and remains unchanged;
its world footprint is not a pixel mask that could safely remove source foliage
from a ground texture.

Building footprint inference is a separate cause: `Gen3Civic.prepare` selects
nearby ground donors. That module is owned by the parallel building task and is
not edited by this change. Generic `Gen3TileShape.layout` nearby floor selection
is limited to indoor league walls, so it is not this outdoor defect.

## Native source priority recheck

The user's native-footprint rule takes precedence over every neighbor inference.
Raw metatile data (before image composition) confirms this sign-only exception:

- Ruby/Sapphire General MID3: bottom tile entries `{4405,4406,4421,4422}`;
  all four top entries zero; native attribute `0x0000` (normal layer).
- Emerald General MID3: bottom entries `{309,310,4421,4422}`; all four top
  entries zero; attribute `0x0000`.
- In all three editions, `mids_mid` equals `mids_under`; the over-layer is
  256 zero bytes. Every under pixel is nonzero palette0/1 board art. There are
  no palette2 grass pixels (the actual grass uses indices44–47), no paving
  pixels, and no hidden clean BG3 floor behind a covered top layer.

`boardOnly(ts)` now validates the original indexed source fingerprint and empty
native over-layer before `resolve` admits any inference. Only metadata
checksums are bundled. Missing/replaced blobs, genuine grass pixels, changed
source patterns and a nonempty over-layer stand down. Both original R/S and
Emerald signatures were checked against the supplied source caches. This rule
must not be generalized to Center/building footprints with actual native dark
grass, nor to other props with surviving ground/background pixels.

## Safe helper and integration

`Gen3PropGround.ground(cells,c)` returns the inferred native MID, or the current
`c.shape.ground` when evidence is absent. `resolve` limits the replacement to
blocked RSE General MID3 signs; other prop families retain reviewed recipes.
`infer` is only the reusable topology check; callers must separately establish
that no native ground art exists before using it. It implements:

- Opposite native flat, walkable cells must carry the same MID. An additional
  same MID establishes ordinary continuation.
- With alternating A-B-A strips proven on both sides, use the correct hidden
  phase rather than repeating the immediate neighbor's MID across a 32px/2x2
  source pattern.
- Conflicting axes, different pairs/heights/map regions, nonnormal behaviors,
  streamed boundaries, provider-owned props/buildings and missing native atlas
  materials stand down. There is no distance vote or grass/pavement preference.

Parent integration owns `Gen3Scene.lua`: replace the outdoor prop branch's floor
MID lookup with `V.require('Gen3PropGround').ground(cells,c)`. This changes only
the one covered cell's material. Native neighboring edge cells, collision,
permissions, elevation, warps and prop ownership remain untouched.

## Verification

`tests/gen3_prop_ground_test.lua` passes with the exact six-cell source strips
for all five Rustboro cases, source grass preservation, alternating floor phase,
conflicting junctions, absent materials, source ownership and no source mutation.
The source gate was additionally exercised against the actual original indexed
blobs for Ruby, Sapphire and Emerald, each admitting the proven Rustboro paving
case. LuaJIT compilation and `git diff --check` pass.

Source comparison PNGs, the cache inspection script and per-edition coordinates
remain in scratch `corridor-ground-20261023`. A read-only runtime driver is also
prepared there as `native.lua` if live recolored/palette source comparison is
needed. No game pixels or layout archives are committed. This batch has no new
GPU scene capture; parent integration/native QA must confirm the final draw.
