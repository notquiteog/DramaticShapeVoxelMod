# Native ground, docks, cargo and tree fixes — 2026-10-22

This is an incremental presentation repair. It does not certify complete regional
model coverage or completion of the category style renderer.

## Building ground

Nineteen reviewed Hoenn building-header metatiles have clean native terrain in
the lower atlas and roof artwork in the upper atlas. The previous scene drew
both atlases on their floor planes, putting detached roof fragments behind
Centers and shops. `Gen3Civic.underOnly` identifies only these reviewed floors;
the scene uploads them separately and draws their native lower atlas once in
ordinary, shadow and reflection terrain passes. Other building surfaces keep
both original layers. Mesh elevation and cleanup follow the existing scene
ownership. No source pixels or native floor/collision fields are edited.

Native0.3.95 R/S/E captures cover nine buildings and five signs per edition,
including Oldale/Petalburg Centers and Marts and Rustboro Center/Mart/Gym,
east building and Devon. Front/native comparisons and Center/Devon first/rear
views were inspected. Oldale foundation remains the native dark lawn; the
reviewed roof overhang background retains its actual lawn/path quadrants.
All three original cached native lower/upper atlases independently pass the
read-only source proof. The distinct Pallet foundation overlap is a separate
source-model coplanarity issue, not this atlas bug.

## Hoenn docks and ocean datum

Thirteen blocked Route104 ocean cells inherited raised land/dock support from
the native terrain sampler. The water planner now propagates actual connected
surf-floor support into automatic blocked-water cells, retaining distinct
native heights/layers, waterfall/underpass behavior, boundary policy and
explicit third-party water settings. Native floor fields remain unchanged.

Exact native Route104 and Dewford pier patterns receive closed two-pixel-thick
wooden boards. Original plank grain/nail UVs stay on the tops; upright sides
sample wood, and physical gaps expose the actual animated ocean below. Painted
blue fringe/deck planes and soil banks are suppressed only for the reviewed
complete patterns. The native277 land corner remains a solid rock shore, and
land adjoining water beneath a deck receives a closed bank to the actual
ocean. The dock no longer erases its attachment to the mainland. Water donors come from genuine surrounding water after its
height plan. Native permissions, surf cells and map identities remain intact.
Unknown/replaced/partial patterns retain the ordinary fallback.

Native0.3.95 R/S/E captures cover both docks in front/native/first/side/rear/close
views and Birch's Lab after outdoor-to-interior reload. All six docks match,
water below them is Y=-4, and before/after native map hashes are identical.
Physical board closure, ownership, gap rays and fallback are tested separately.
The scenery retains other unfinished native terrain/model families; this is
not an acceptance claim for every coastal rock or cliff.

## Truck opening

The truck's complete native recipe previously matched only the final open
exit, and R/S excluded it from their recipe whitelist. Known closed/open native
exit drawings now match the same exact cargo family, while live walking/exit
cells and permissions remain engine-owned. The moving graphics113 crate has
closed six-face native-source geometry and follows the engine's own position
and raise offsets, including shadow/reflection passes. HD2D prop selection and
missing/unreviewed source retain native cards. No character/Pokémon style is
changed. These native-source cargo repairs precede the separate authentic ORAS
exterior import; the cargo room conversion remains tracked independently.

Fresh native new-game truck callbacks run without outdoor start overrides.
Camera input checks need a genuinely focused test window: an unfocused Xvfb
window suppresses ordinary input, and the official driver loop omits the
normal platform core-update hook. Neither is evidence of a production camera
lock. No engine callback or production focus gate is replaced. The 3D floor uses
one clean native gray material across the full reviewed room, including under
separate cargo and across original exit-light drawings; native2D stays intact.

## Verification scope

Runtime: official Gen1Recomp0.3.95, checked against the official latest release
before this batch; native Linux LÖVE11.5/OpenGL3.3/NVIDIA. Only Battle Art was
installed in the isolated scene fixtures, with disposable QA profiles. Native
map identifiers in LeafGreen share the engine's FR_ family; fixture game
identity remains LeafGreen. FireRed and LeafGreen Pallet/Oak's Lab render
regression fixtures pass. Characters, Pokémon and flowers retain HD2D defaults.
These checks do not certify phone/Switch performance or exhaustive model/style
coverage. ROMs, raw source archives, caches and screenshots are excluded.

## ORAS Briney boat and compact rock profiles

The native graphics88 actor receives the authentic ORAS BM0086 body, original
textures and rigid source transforms, with a closed keel and a reviewed source
waterline. Source ripple geometry is omitted in favor of the native water.
Baked source vertex lighting is removed; painted trim/windows and texture UVs
remain intact. Actor heading is captured before camera-relative sprite facing,
and its engine-owned position/offsets drive the model, shadow and reflection.
A single cached source mesh set serves moving boats. Dynamic prop resources
are released on scene invalidation/renderer release, rather than rebuilt on
every discarded terrain prefetch. Missing assets and nonmodern prop styles
retain native cards. No boat scripts, flags, collisions or passenger ownership
are changed. See the separate boat source/bind proof.

Cosmetic Hoenn rock enclosures use compact8/12/16px profiles in place of the
old16/24/32px walls. The ORAS Route104 t103gake geometry spans18 source units
per36-unit map tile, matching8 native units. Existing independently proven
upper terraces/stairs still set their actual support heights; a compact profile
does not flatten a real landing. Native walkability/elevation fields and
explicit/custom terrain profiles remain unchanged.


## Outdoor ORAS truck

The genuine ORAS BM0006 truck replaces the original outdoor actor94 in
Littleroot in Modern3D props mode. Source cabin, open loading doors, wheels,
lettering and cargo remain actual model geometry. The native actor still owns
position, visibility, story scripts and lifetime. Source shadow sheets and
vertex lighting are removed; the original painted textures and alpha remain.
Both engine-owned truck sites use one cached model set, with ordinary,
shadow and reflection passes and explicit release on scene invalidation.
No terrain replacement is needed beneath this actor. See
[the source and verification record](ORAS_OPENING_TRUCK_2026-10-22.md).

## Dewford doors and sand

The actual ORAS hinged-door model and animation poses now serve both native
Dewford houses, including the idle closed state and real entry/return sequence.
Native animation timing and warp ownership stay with the engine. Reviewed
native sand124 continues beneath homes, Hall, Center, Gym and both signs;
source tree-base art is excluded from the clean underlay. Independent original
GBA metatile proofs pass in all three editions. Atomic missing-door failure
retains the whole native house. Source/native door and ground evidence lives in
[the Dewford record](GEN3_DEWFORD_DOORS_2026-10-22.md).

## Modern tree coverage

Uniformly fitted original ORAS crowns now include compact one-cell and narrow
forms with closed trunks. Reviewed source tree halves, forest joins and real
six/twelve-pixel terraces receive whole models at their original trunk support;
walkable cells and source floor/elevation remain unchanged. Actual native
Route115-to-Rustboro crossings pass independently in R/S/E. Exact source
families and limitations are listed in
[the tree vocabulary record](HOENN_TREE_VOCABULARY_2026-10-22.md).

`tools/qa/hoenn-corridor-inventory.lua` audits every cell in the selected
settlements, connecting routes and interiors without changing native data.
It emits identifiers, native hashes and adapter eligibility only. It is not
rendered acceptance: unclassified painted foliage, composite terrain/tree
sources and every missing modern building/interior still need individual work.
