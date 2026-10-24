# Original Verdanturf pickets — 2026-10-23

Actual official0.3.96 native RSE census establishes four gray-post cells:
Verdanturf Town(4..7,12), General/**Mauville**, MID34d,collision7. The former
`secondary=='verdanturf'` generic fence branch was unreachable for this native
pair. Exact reviewed General/Mauville34d now opts into the source adapter.
Its visible grass belongs to dense-lawn34e, not General1. Missing donor or source
resources retain native art. Native green390/391 art was inspected in context:
these are the neighboring house roofs and are excluded from fence coverage.

## Original source and geometry

User supplied original Alpha Sapphire RomFS, Verdanturf matrix6/zones11+44:
GR0054 slot1 `world06_02_02`, material `sidake_house_sidake_waku`; AD0013 slot11
original128x128 `sidake_waku` paint. Exact source hashes:

- Model BCH: `125dd8e0d31c568420df26ccd471f37862ecf07cca992677c80cb0e865401f36`.
- Texture BCH: `e3b478e160f44f9cc95089ded9e9510535383ba1024d44950ad2a7c1685eb8e4`.

The town's original modern fence consists of alternating pointed pickets.
Exporter takes adjacent original21.5/22-high pieces (12/11 source triangles),
closes absent source faces with original edge paint (6/5 added triangles), and
retains original physical proportions and UVs at scale.5. It does not invent
horizontal rails. Native centers3.5/11.5 and contact14 are explicit; source
heights10.75/11, width2.5 and depth2 remain unchanged. Model has34 triangles,
closed edges2, zero coplanar overlaps and exact original paint. Contact caps
recess.025 below existing ground without moving upper vertices/portals/floors.

`audit_hoenn_verdanturf_fence_pixels.py` independently proves110 unoccluded
native base pixels equal the34e donor in each edition; every remaining base or
over pixel is one of five exact native fence paints. Terrain hidden by fence
paint is not claimed byte-exact. No global ground or collision changes occur.

## Native acceptance

Latest official release checked before this batch: **v0.3.96**, commit
`0e92b587468c2db7c386f055fc272e6505b0f401`, published2026-10-23T21:49:15Z.
Actual native0.3.96 LÖVE shell, standalone/API3, separate disposable identities
and imported native RSE caches. Test-only fresh new-game fixtures/teleports;
player saves/shared release engines untouched. Captures do not assert saved
story progression or physical keyboard movement acceptance.

Scratch root `.scratch/hoenn-world-096-20261023/`:

- `verdanturf-census/`: all six General/Mauville outdoor maps, complete used
  native art/collision grids and base/over atlases;4 exact fence cells per
  edition; independent `source-pixel-proof.json` passes all3.
- `verdanturf-before/`: actual Emerald native reference and prior flat gray
  fence between the two houses, before source activation.
- `verdanturf-after/`: actual RSE **4/4 source owners each**, unchanged settled
  native grids, image errors0/recovery0.
- `verdanturf-review/`: all3 repeat **4/4**, three walkable views each including
  explicit north(5,9)/down and close south(6,14) points; native/front/first/
  side/rear captures. Inspected EM north first-person closed backs, RU close
  side/front contact, SA north/front and original lawn/adjacent house edges.
  Original pointed tops/wood grain visible, no observed contact fighting or
  leftover flat gray fence in reviewed source views. Initial extra viewpoint
  candidate(7,14) was correctly rejected as the native sign cell; it is not a
  production collision change.
- `verdanturf-missing/`: separate engine/mod copy omits only original
  `sidake_waku.png`; actual Emerald **4 expected/0 source**, recovery0,
  unchanged native grid and original gray fence/dense lawn retained. Native
  north first-person fallback inspected.

Actual geometry test/eligibility/native-pair/donor/atomic-fallback tests PASS;
new LuaJIT data and Python helpers compile; diff whitespace passes. Source
archives, native atlases/captures/caches are scratch only. Actor/flower HD2D
and standalone/public API3 behavior remain unchanged.

## Remaining gate

The larger rural tour's shared8MiB source-image cache exhaustion at Route115
remains root-owned; no cache/catalog limits were raised. Combined uninterrupted
long-tour/optional-mod release acceptance must follow that resource fix. This
four-cell family establishes no whole-game completion. Lavaridge/Mt. Chimney
fence variants continue separately. Held Littleroot houses and inactive
Shipyard prototype are excluded from this focused batch.
