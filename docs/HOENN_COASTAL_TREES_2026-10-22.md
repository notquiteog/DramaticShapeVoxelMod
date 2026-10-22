# Hoenn coastal evergreen source family

Source239/243 are the native tiered evergreen crowns on sand124;23A is the
same tree's lower foliage/trunk. The live R/S/E Dewford secondary atlas was
inspected directly. These are evergreen trees, not palms or water plants.
Existing genuine completed ORAS evergreen geometry, UVs, textures, alpha and
closed bark/canopy are reused unchanged.

Gen3ImportedHoennTrees now handles this exact secondary vocabulary. Two whole
native crown cells keep two compact pines. Crown+trunk keeps one bounded
foreground tree; a separate lower trunk joins the final crown atomically with
per-owner bounds. A walking239 projection remains sand without acquiring tree
geometry. Every group retains its original owner references, native collision,
elevation, local ground and blocked rectangle; failed uploads retain fallback.

Synthetic forest owners have a canonical complete tree portrait regardless of
the sampled phase of their repeated native source rows. A complete16×32 forest
owner gets one bounded foreground evergreen;16×16 gets one compact evergreen.
Explicit same-pair/sand/level/shared-owner native/forest and connected-map joins
are permitted. Walking, water, foreign art, custom palette, conflicting props
and inconsistent levels stand down. A native23A edge body below a completed
separate generated forest stays in its own16×16 tile.

R/S Route116's four017 stems below an ED projected evergreen cap have a normal
E4/E6 round-tree left foot in the neighboring half. These measured whole round
owners now allow the distinct pine below ED, retaining one round tree and one
compact pine rather than omitting the pine. Emerald's existing EC/ED pattern
and each edition's native data stay intact.

The uniform-datum static source/owner audit of thirteen early outdoors covers
all1674 recognized Emerald owners and the corresponding R/S owner families.
That audit is source eligibility, not final terrain or visual acceptance. It
excludes six unrecognized Route106242 cliff/evergreen composite cells per edition;
those remain pending a separate source-aware rock/ground adapter. Do not claim
complete corridor tree coverage from the recognized-owner denominator.

Native verification uses official latest0.3.95, checked2026-10-22, with the
matching native LÖVE shell and isolated existing-ROM QA profiles. Initial
Emerald Dewford, Route105 and Route106 overview/first-person captures were
inspected: genuine closed pines meet native sand, local walking bounds remain
unchanged and layouts keep their source hashes. The Route105 render window
imports31/31 recognized owners. That first batch exposed additional generated
boundary and connected-map joins; their final narrow guards were subsequently
added and pass meaningful R/S/E source, bounds, group/UV, native walking,
foreign-art and failed-upload tests. Final GPU recheck of those boundary cases
and R/S native captures are pending at the user's requested immediate all-work
snapshot. No Android/performance/all-map visual acceptance is claimed.

No shared Scene, ImportedTrees or SceneryModels changes are included; the
separate FAR64 whole-batch fallback diagnosis belongs to the integrating parent.
Captures, native source sheets, audit TSVs and ROM-derived data stay in scratch,
not Git. No raw game assets are added.
