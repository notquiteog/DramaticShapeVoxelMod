# Native Gen3 Centers and Marts — 2026-10-13

Official release rechecked as **0.3.85** (`releases/latest` -> `v0.3.85`).
Runtime: extracted official Linux LOVE shell, `.scratch/runtime-0.3.85/engine`.
Checkout loaded as `BATTLE_ART_VOXEL_FORK`; separate `gen3-<game>-qa` identities
under `.scratch/gen3-20261013/profiles`. Disposable new-game fixtures only.

## Source inventory and scope

The inventory enumerated public map IDs containing `POKEMON_CENTER` or ending
`_MART`, and grouped exact pair, dimensions, metatile IDs and native collision
layouts. It does not group by NPCs, events, scripts or every possible shop name.

| Edition | Matched maps | Distinct layouts | Rendered representatives |
|---|---:|---:|---|
| FireRed | 48 | 4 | Celadon 1F/2F, Indigo Plateau 1F, Cerulean Mart |
| LeafGreen | 48 | 4 | Celadon 1F/2F, Indigo Plateau 1F, Cerulean Mart |
| Emerald | 45 | 4 | Battle Frontier 1F/2F and Mart, Lavaridge 1F |
| Ruby | 42 | 4 | Dewford 1F/2F, Lavaridge 1F, Fallarbor Mart |
| Sapphire | 42 | 4 | Dewford 1F/2F, Lavaridge 1F, Fallarbor Mart |

Actual imported original artwork was inspected separately, including the
partitioned Ruby/Sapphire upper floor versus Emerald's service counters.
225 map-layout inventory entries are **not** 225 individually rendered rooms.

## Changes

- Corrected the FR/LG right counter return (`2AD/2B5`) and cross-marked medical
  pedestal (`2AC/2B4`), formerly swapped. Hoenn's medical device now has its
  actual upright cross-marked head, side detail and closed pedestal, instead
  of a computer-like replacement. Its projected head is read from source
  `253`; the physical device remains inside blocked `25B`.
- Closed Center adapter boxes underneath, without double-closing the shared
  designed-furniture adapter. Healing-machine housings and glass tables have
  actual angled corners; tray, raised sides and rear frame are separate solids.
- Preserved low nurse counters, with physical chamfered fronts, source service
  plate and apron. FR/LG counter corners have tan pots, leaves and rounded
  blue/white/coral flowers. Hoenn corners retain rounded red desk ornaments.
- FR/LG upper wall strips now have a grounded backing behind the machines.
- Glass tables have closed rims, inset source reflections and four legs.
  Native walkable FR/LG seat pads remain shallow, matching the existing Hoenn
  floor-pad treatment rather than becoming obstacles.
- Native healing balls are closed spheres on the tray. Only the public
  `PokecenterHeal.drawBalls()` result is sampled: native appearance order,
  party count, animated palette and teardown remain engine-owned. The
  32x24 canvas returns to empty; readback failure retains the original flat
  effect and retries at most once per second. No private heal state is read.

## Verification

Scratch root: `/home/admin/Projects/.scratch/centers-marts-20261013`.
- `sources.lua`, `<game>-source`: original artwork, complete layout rows,
  aliases and inventory totals.
- `review.lua`, `<game>-accepted`: production renderer, four orbit directions
  plus a low eye-level view for each of the four layouts in all five games.
  All five logs end `PASS INTERIORS <game> 4` without scene fallback.
- `leafgreen-detail`, `emerald-detail`: unobstructed healing tray closeups.
  `leafgreen-polish`: final rounded flower-petal refinement, repeated room
  renders and native-footprint checks. This last cosmetic refinement was
  rendered in LeafGreen; FireRed shares that exact recipe and source layout.
- The changed Center medical devices, counters, wings, healers, tables, pads
  and upper strips were checked against public `Collision.isWalkable`, using
  full cell edges (not just a narrow central lane): **zero intersections**
  above the 1.5px floor-pad allowance. Collision/warps were never modified.
- Every edition's native six-mon healing fixture measured 1 -> 2 -> 6 balls
  from the actual rendered effect, then completed and reset. No substitute
  animation clock or persistent decorative tray balls.
- Original local floors retained. Nurse visibility checked in low frontal
  views; rear/side views inspected for the changed fixtures. Existing Mart
  checkout, register, shelving and aisle models were visually reviewed.
- LuaJIT: `gen3_center_furniture_test`, `gen3_healing_balls_test`,
  `gen3_hoenn_test`, `gen3_ruby_sapphire_test` pass; `git diff --check` passes.

## Limits and remaining work

This batch does not certify all interior objects, all aliases' NPC arrangements,
all department stores or live traversal. Mart geometry was reviewed, not broadly
rewritten; the zero-intersection claim concerns the changed Center families,
not every legacy fixture. Existing escalators, upper-floor booths, plants and
Indigo statues need their own exhaustive low-clearance audit before claiming
complete room coverage. Ruby/Sapphire QA retains an unrelated lower HUD overlay;
room geometry and aisle/orbit views are visible. GPU readback/mesh construction
occurs only during native healing; mobile performance was not measured.
