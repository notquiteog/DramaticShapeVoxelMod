# Emerald Navel Rock rock volume and exit

Navel Rock's native rock faces previously passed through Hoenn's flat fallback:
first-person showed those walls on the floor beneath a generic brown enclosure.
Its reviewed pale/dark rock identities now use native-painted raised caps,
bevels and independent boulders. Exact blocked collision7 is required; native
walking caps, sky, stairs, ladders, water and unknown drawings remain in their
existing adapters. This uses Emerald's own art, without a substituted dungeon.

Twenty Emerald maps share the affected sheet: eighteen normal cave rooms, the
Lugia bottom chamber and the outdoor Ho-Oh summit. The new vocabulary produces
2,169 rock wall cells and eleven boulders. The summit receives the same solid
rock vocabulary, while its sky drawing remains unchanged; its complete outdoor
presentation is outside this interior acceptance. No complete map is accepted.
Ruby/Sapphire and FRLG have no maps using this canonical Emerald sheet; their
separate cave vocabularies are unchanged.

The complete native `258/259/25A` exit header is separately claimed once as a
three-cell arch, rather than raised into a solid wall. Its closed box union has
a real 16×24 central opening, jambs, lintel, rear and underside. Internal contact
planes and duplicate faces are absent. Only the foot caps recess .025 pixels
below the unchanged native floor. The exact exposed area is5,123.2 square pixels,
closed volume15,372.8 cubic pixels; every point stays in the three original
blocked cells. Native `207` arrow/warp approach stays outside that footprint.

Latest official engine checked for this batch: **Gen1Recomp0.3.96**, official
Linux LÖVE shell and standalone API3 Battle Art. Disposable `*-qa` identities
use isolated writable options/saves and immutable cache seeds. Before-state
native art, four first-person directions and overviews were inspected across
seven representative maps. The final run passes all20 maps with four
first-person directions, native/modern overviews and unchanged live native
cell/elevation/warp hashes. Both alternating small-room variants, the long
fork, bottom water/HD2D Lugia and summit HD2D Ho-Oh were inspected. The actual
exit uses native input: step onto `207`, then the next down intent activates
the native arrow warp to `EM_NAVEL_ROCK_EXTERIOR`; rendering remains healthy.

The 560 focused contracts cover native art/palette identities, walkable-copy
exclusion, sky/floor/ladder preservation, exact arch ownership, open centre,
closed union area/volume and zero positive-area coplanar overlaps. Existing
cave profiles,597 Hoenn cave contracts,5,532 shell contracts, enclosure,
native furniture and424 Meteor spike contracts pass. A fresh all519-map
Emerald census preserves every native hash and civic; only these20 maps gain
rock classifications and the entrance gains one native arch owner. The
all-five furniture ledger retains2,161 maps, unchanged imported candidate and
acceptance counts, and all whole-map flags false.

Reproduction: `tools/qa/navel-rock.lua`, external `QA_UTIL`, disposable Emerald
QA profile and `SHOT_DIR`. Metadata-only evidence is in
`docs/coverage/gen3-caves-2026-10-23/navel-{maps,native-runs}.jsonl`; the native
arch has a separate component record in the interior ledger. Raw native
pixels, screenshots, caches and saves remain uncommitted. Scene is untouched;
no hook, version bump, push or release is included.

Remaining cave work includes volcanic/underwater families, native stairs and
platform details, source-derived multi-row rock columns and complete exterior
summit/sky review. These component checks do not establish full cave coverage.
