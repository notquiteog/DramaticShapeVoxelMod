# Early outdoor boundaries and bridge depth — 2026-10-17

## Scope and source

Version 1.48.0 preserves published 1.47.0. Source/native cell inventories cover
Pallet, Viridian, Pewter, Routes 1/2 and Viridian Forest in FR/LG; Littleroot,
Oldale, Petalburg and Routes 101/102/103 in EM/RU/SA:30 edition-map placements.
The Kanto timber bridge (Route24/Cerulean pair) and Hoenn Fortree bridge are
additional bridge fixtures, outside the early connecting-route minimum.

Native pixel exports and the live public atlas provider supply the source art.
No imported artwork, ROMs, saves or captures ship. The two Kanto editions were
checked separately; RS hedge drawings were compared independently with Emerald.
Unknown art and altered native permissions retain their existing presentation.

## Changes

- Native Kanto EA/F8/F9 brown stake ends become closed posts without invented
  connecting rails. Eleven Viridian native shrub cells now have bounded hulls.
- Nine Petalburg hedge drawings create35 hedge cells per Hoenn edition. Complete
  adjoining sections share exact top coordinates and omit internal faces; native
  capped ends retain their smaller blocked footprint. Ground remains local grass.
- General Kanto rock profiles change32→16 pixels and general Hoenn24→16.
  Boundary extensions inherit the donor profile/material. Upper terrace support
  still determines retaining height; cave walls, small jump ledges, museum
  terrace geometry and separately authored regional landmark bands are retained.
- Complete five-cell Kanto bridge rows require the original IDs and permissions.
  Deck undersides have3px depth and native blocked side rails have real posts.
  Fortree semantic bridge cells have2.5px deck depth. Exposed fascia closes edges;
  the top stays on the existing walking surface. Timber comes from clean native
  board pixels, excluding Fortree's green gaps and refreshing on provider reload.
- Separate Fortree layer support now tests canonical behavior178, the public
  engine's FORTREE_BRIDGE ID.170 is an ocean warp/bridge behavior, not Fortree.
  Native collision/layers and the requirement for matching lower banks remain.
- Geometry cache105. Tileset alias registration continues to support third-party
  maps reusing reviewed source layouts; no map-name ownership assumptions or
  partner requirement were introduced.

## Verification

Official Gen1Recomp0.3.89 remains latest at this batch's preflight. Its official
Linux LÖVE shell, disposable QA profiles and new-game map fixtures are used.
No player save, engine collision, scripting VM, native warp logic or NPC is
replaced. The QA core.update bridge invokes the public mod dispatcher.

Source suites:323 pass/0 failures/58 unavailable external-fixture skips. After
that run, the bridge material sampling regression was added and passed; the
changed source has the focused bridge test repeated. The regression checks
native permission stand-down, cell bounds, closed depth, continuous hedge joins,
plank sampling/provider reload and retaining support above a shorter profile.

Candidate native runs passed30 ordinary aisles and30 native blocked boundaries
(one each per early map), plus OFF and actual first-person captures. They assert
all source cell IDs/collision/elevation remain unchanged after walking. These
are bounded fixture paths, not full route traversals or whole-map art approval.

Final archive verification is recorded below after the frozen package matrix.

## Remaining work

Regional total stays76/125 fully verified,49 queued. This partial outdoor pass
is deliberately not counted as completion of the30 outdoor placements. Its
native walks cover their basic seams, not every object or native door/route warp.

Kanto Route2/Forest gates and their roof/header variants still need a complete
object review. Petalburg's tree/hedge composites and garden beds, Hoenn cut-tree
and berry/soil variants, and Route103's composite cliff/water drawings remain.
The existing sea-rock assembler owns some composite rock drawings independently
of the simple classifier; a flat-classifier count alone is not a missing-model
count. Remaining gyms, Pewter museum floors and route-building interiors also
remain in the regional queue. Fortree house models and all other bridge art
families are outside this focused bridge pass. No complete-region, ORAS quality,
manual keyboard, mobile, multiplayer or performance claim is made.
