# Hoenn source tree vocabulary and native ownership

The compact-tree batch revealed additional actual R/S/E source drawings that
were absent from the native tree classifier. This batch completes those exact
families and removes false import rejection for proven forest/terrace owners.
No model texture or geometry is changed here. Genuine ORAS broadleaf, compact
broadleaf and completed evergreen source models retain their existing UVs,
materials, closed bark and canopy topology.

## Source identity

The live native general atlas was inspected, including underlying grass and
the native Route104/Rustboro/Route115 layouts:

- DE/DF and F2/F3 are curved ordinary round-tree lower halves on grass. They
  complete existing D4–D7 upper halves into one whole32×32 owner. They are not
  new independent compact trees. The FRLG Viridian numberedF2 cliff rule stays
  unchanged; R/S keeps its own explicit classifier vocabulary.
- F4/F5 have the same evergreen lower foliage/trunk identity as016/017. A
  matching blocked whole-crown owner and lower-body owner emit one foreground
  evergreen atomically, with per-owner bounds, rather than two overlapping trees.
- E8/E9 and FC/FD carry projected caps on walkable grass at a cliff foot. The
  cleanup requires the matching blocked native tree body directly below. It
  restores grass through the existing tree ground renderer; it never creates
  tree ownership or a trunk on the walking cell. A connected map may have a
  different secondary pair but must share the general primary/source IDs.
- EA/EB have paved ground and F6/F7 have water; they are deliberately outside
  this grass cleanup. EE/EF/F0/F1 contain genuine cliff rock with a small leaf
  cap and must retain rock ownership. Those need their own source-ground and
  rock adapters; recognized-tree counts alone cannot prove complete pixel coverage.

## Strict placement changes

Whole ordinary2×2 trees may retain the reviewed six-pixel native terrace span
on blocked floor layers0/3. The three Route115 coastal12px owners require
layer0 throughout and exactly low-left/high-right bands with the trunk on the
unchanged lower left datum. Arbitrary spans, diagonal/inverted12px layouts,
walking corners, foreign owners and conflicting props/palettes are rejected.

Explicit synthetic forest owners may contain permissionnil/forest cells, or a
reviewed blocked native join, without pretending the synthetic cells have native
permission7. Each full source crown remains in its own blocked rectangle.

A native16×32 evergreen owner containing two whole crown cells may cross exactly
six pixels on native floor layers0/3. It emits each source tree at that cell's
unchanged ground height. Full replacement bounds and canopy height include both
heights. Mixed permissions, foreign map ownership or arbitrary elevation spans
stand down. The exact Route104 C6/016 foreground join at(6,39–40) uses the
unchanged lower trunk's base6, rather than adding a duplicate tree or flattening
its crown cell's base0; this exception requires the verified source IDs, native
blocked cells, common region and floor layer0.

All imported owner marking remains conditional on complete successful upload.
Native MID, collision, elevation, treeBounds and owner references are unchanged.

## Verification

Official latest v0.3.95 was checked2026-10-22; testing uses the matching native
LÖVE shell in isolated edition profiles and a separate mod link. Player saves
and the user's installed engine link are untouched.

The test starts Route115(21,76), walks the real southern boundary into
Rustboro(21,4), then checks Route104's flower-shop forest edge and walking cap
at(35,22). Native layout hashes remain stable and the blocked body still prevents
walking south. CPU tests cover all three classifiers, exact source combinations,
closed-source bounds, native/synthetic permissions, terrain bands, no duplicate
foreground planting and failed-upload fallback. Native screenshots are kept in
scratch and reported to the integrating parent. No all-map visual acceptance,
Android performance or every source-pixel coverage claim is made.

Native R/S/E boundary runs show437/437 imported recognized owners on Route115
and533/533 after the real Rustboro connection. The smaller owner totals relative
to the prior448/548 are deliberate: newly recognized curved lower halves join
whole2×2 trees instead of leaving duplicate compact fragments. No failed image,
register or upload appears. The initial final Emerald/Ruby Route104 run replaced
990/991 owners, compared with875/991 before the forest/layer fixes. The subsequent
Sapphire run includes the strict C6/016 step and replaces991/991 owners at the
flower-shop view,849/849 at the last stepped-pine view, and the walking cap view
is checked separately. The stepped-pine screenshot was inspected: closed canopy,
original upper-band trunk ground, no duplicate lower tree or walking overhang.
Existing source comparison and compact front/rear/side/under acceptance still
apply because this patch changes source recognition and placement grounds only.

## Follow-up source composites

The Route104 painted lower canopy bands were source EC/ED: ordinary round-tree
lower bodies composited over the following evergreen crowns. They now form
whole ordinary round owners with D4–D7 above, preserving separate pines below.
There are14 such native cells per edition on Route104, plus7 in Emerald or8 in
R/S on Route116. Three native Route116017 bodies below verified whole EC/ED
owners are distinct evergreen trees, now fitted only to their original16×16
blocked bodies. Incomplete/foreign/mixed-height background owners stand down.

Source1C6/1C7 is the tiny projected round-tree cap over encounter grass. Exact
permission24 cells with matching blocked round body below become non-root tree
ground0xD. Native grass and encounter collision remain intact. These caps occur
on Routes101–104/116 and Petalburg Woods; they never gain a trunk or footprint.

Route116's five source F0/F1 cells per edition are real cliff faces with a tiny
projected leaf strip. The guarded adapter requires matching D4–D7 blocked tree
body below, same source pair, and exact native071 walking terrace support (or
reviewed blocked7D cliff join) above. It reuses the current edition's existing
Hoenn074 cliff profile and genuine071 wall texture. It does not copy arbitrary
neighbor heights or change the real upper floor, native collision or elevation.
The parent can retain its reviewed cosmetic enclosure height in that profile.

Native0.3.95 Emerald captures were inspected at Route104(35,22), Route116(30,6)
first-person, and the real walking upper terrace(58,16). The conspicuous EC/ED
painted bands are gone, the three017 tree bodies render genuine grounded pines,
and all five rock composites become continuous retaining geometry. The extra
lower-view driver assertion failed because the proposed area is beyond the
native20-row Route116 map; it is not evidence of a gameplay or rendering failure.
The upper view and static native source footprint are the evidence for that
cliff join. R/S share measured source rows and pass their own classifier tests;
additional native release views remain the integrating parent's responsibility.

The native/tree-owner denominator still omits some painted source families.
A separate remaining full-crown source040 and generated forest DC/DD mixed-six-
pixel boundary owners were discovered during this check and remain next work.
No complete corridor visual acceptance is claimed by this source-family commit.
