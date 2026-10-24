# Original Mauville railings — 2026-10-23

## Native scope

Actual official0.3.96 edition-native outdoor layouts and composited base/over
atlases establish **132 blocked railing cells per edition**: Mauville City80,
Route11125 and Route11727. Six outdoor maps use General/Mauville; the other
three contain no member of this art family. Complete used-secondary art-board
review identifies eleven families:273,280,282,288,28a,290,291,292,2b1,2b2,2ba.
The old generic table omitted292/2b1: four cells per edition, three in the city.
Its281 entry is yellow building brick/roof art and is now excluded.

Native depth centers are3.5/11.5, with horizontal ground contact at14.273 is a
T;280/282 turn downward,290/292 turn upward,2b1 is a right-axis upward corner,
2b2 a left-axis upward corner,2ba an upper depth start. Exact per-MID graphs
are in `Gen3FenceFamilies.mauville`; no neighbor or MID-range guesses are used.
Only General/Mauville collision7 cells with reviewed native classification and
no prop/civic/boundary/stair/hidden ownership may use these models.

## Original source

User-supplied Alpha Sapphire original RomFS:

- GR0739 slot1 `c103c_01_02`, submeshes12/13 `chip_saku02`/`c103_saku`.
- AD0198 slot11:128x128 frame paint and32x32 open railing panel.
- Model BCH SHA256: `78dcd34de8a13b2a6428c6d20e53af96b030b0b8ccb95d147af6ff0ba4e486d2`.
- Texture BCH SHA256: `c961d9297d7afbee9d72407f8b9ef23efc795f45d241070795e0a35699f205d7`.

This is the actual modern Mauville railing, with its pale open panel and dark
frame, rather than unrelated white field-fence primitives. Frame texture bytes
are identical to the already bundled original `chip_saku02.png`; only the new
original `c103_saku.png` is added. Raw BCH files/ROMs/decoder/captures do not ship.

Exporter preserves original physical plinth/top/vertical-strip cross sections,
source paint/UVs and half-scale height11. Longitudinal span alone adapts to the
native repeat. Eight source spans receive closed absent rear/underside/end
faces using original edge paint. The original476 opaque panel texels have
actual front/rear/hole-edge surfaces; adjacent front/rear texels coalesce only
where their original UV mapping remains linear. Transparent openings stay open.
BCH transform noise under.0001 is canonicalized at exact physical contact
planes; upper model/portal/ground anchors are not translated.

Eleven joined native models use UV-preserving coplanar clipping. Eight exported
source primitives have closed atomic edge counts2; all eleven joined models
have zero positive-area coplanar overlap and remain in16x16 blocked cells.
The geometry test checks original476 texel occupancy/paint/UVs and a bounded
combined catalog below30000 vertices. Joined models preserve their covered
internal contacts; no claim of a single global manifold is made.

## Ground and fallback

Six layered native families have byte-identical General1 grass bases. For the
five baked families, every visible pixel outside the four native brown fence
paints and green baked shadow equals the same grass donor. Terrain hidden by
baked fence/shadow is not claimed byte-exact. `audit_hoenn_mauville_fence_pixels.py`
proves these witnesses independently in E/R/S and identifies281 as building art.

Source contact caps recess.025 below the existing native ground. Other source
vertices, native collision/elevation/warps, adjacent ground and walkway cells
retain their anchors. Native over art hides only after the whole source batch
succeeds. Missing texture/catalog/build resources keep the native drawing.

## Runtime and inspected evidence

Official latest release checked before this batch: **v0.3.96**, engine commit
`0e92b587468c2db7c386f055fc272e6505b0f401`, published2026-10-23T21:49:15Z.
Actual0.3.96 native LÖVE shell, standalone API3 mod, disposable RSE QA identities
seeded from the existing native caches. Player saves and shared release engines
were untouched. Test drivers enter fresh native new-game skeletons and teleport
only to validated walkable viewing cells; this is presentation QA, not story
progression or saved-game movement acceptance.

Scratch evidence root: `.scratch/hoenn-world-096-20261023/`:

- `mauville-before/`: original native reference and previous generic scene,
  all3 editions/maps;132 expected,0 imported Mauville owners before activation.
- `mauville-census/`: complete native atlas/census, independent
  `source-pixel-proof.json`;132 cells,4 omitted corners per edition.
- `mauville-after/`: uninterrupted City→Route111→Route117 in each edition,
  **132/132 source owners each**, unchanged settled native grids, recovery0,
  image errors0.
- `mauville-review/`: repeated same tour with **21 walkable views per edition**
  (city11,Route1116,Route1174), native/front/first-person/side/rear captures;
  **132/132 each**, image errors0, unchanged native data/recovery0. City front
  boards across all3, EM first-person view7, RU rear10, side/rear/routing boards
  and adjacent floor/closed frame contacts inspected. Continuous rails, correct
  side axes, closed original panel backs, no remaining flat brown gaps or
  observed source/ground fighting in reviewed views.
- `mauville-missing/`: separate QA engine/mod copy omits only `c103_saku.png`.
  Actual Emerald City **80 expected/0 source**; original native art/floors remain,
  unchanged grid/recovery0. Rendered fallback inspected.

CPU: imported-fence eligibility/rollback/native-anchor suite PASS; actual
Mauville source geometry/alpha/UV/bounds suite PASS; released31 Rustboro and
nine rural actual geometry regression suites PASS. New source LuaJIT modules
compile; Python helpers compile; diff whitespace check passes.

## Remaining scope / release gate

Mauville's three-map uninterrupted tours pass. The larger prior rural tour
still exhausts the shared8MiB texture cache at Route115; root owns safe resource
lifetime/deduplication and must rerun long combined tours before release. No
budgets were raised here. These results do not establish every Hoenn map or
optional-mod combination. Verdanturf's distinct railing and facility families
remain source intake/verification work. Held Littleroot source houses and
inactive Shipyard prototype remain separate from this focused fence batch.
