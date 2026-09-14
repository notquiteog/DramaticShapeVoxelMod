# Crystal 1.17.0 — layered scenery

**As of 1.17.1, layered HD-2D is the default Crystal presentation for this
fork.** The CRYSTAL SCENERY selector and its VOXEL HD / SOURCE ART alternatives
have been removed. Old saved values are ignored. Johto Diorama 1.9.0 also
hides Wilds' overworld Poké Ball HUD by default. Version 1.17.2 labels
the camera control HD-2D CAMERA and applies the first-run FULL preset
immediately, including Gen 2 boots where the initial restore preceded save creation.
Existing explicit camera choices remain saved.

The new maple, pine and spreading crowns use original transparent artwork,
layered around real trunk geometry. Distant forest fill uses the same models
and materials and retains every essential crown layer. Headbutt shrubs and
fruit bushes grow as low foliage mounds; native Cut cells keep the small
sapling model. Source collision, events, harvest and regrowth remain native.

Flowers now have small stems, leaves and cupped petals, with low Park bed
rims. Forty-four additional furniture recipes expand interiors, alongside
sixteen floor finishes. Empty source crops no longer claim floors as objects.
Unequal short reef clusters replace four equally spaced ocean stones. Rock
underlays come from adjacent native ground/water. Existing walkable coastal
islands remain land. Reviewed Johto beaches use irregular wet-sand slopes.
Ledge tops now roll down into grass as rounded mounds; the outward,
unjumpable face keeps its source dirt art. The three-pixel footprint and
2.5-pixel outer crest preserve the thin ledge proportions (lowered in 1.17.1).

**HD-2D LIGHT → SOFT LIGHT / CINEMA** and **DEPTH OF FIELD** are optional.
World post-processing leaves text and menus sharp. The battle diorama remains
through knockout/escape dialogue until the native battle screen closes.
Double Battles 0.9.2 keeps modern HUD panels outside attack-effect image bakes.

## Verification

- Native imported Crystal, Gen1Recomp 0.2.59, all thirteen cart companions,
  LOVE software GPU under Xvfb. No Android/hardware-GPU validation.
- Coverage inventory: 388 maps, 35 tilesets, 79 furniture recipes; 77 recipes
  match 1,447 actual placements. The map rendering sweep produced 388 views
  across two bounded runs. Final foliage/flower/shore changes received focused
  native reruns; the complete sweep is not proof every prop looks finished.
- Eight focused flower/rock scenes replace 255 source flower tiles; native
  Park rims are asserted shallow. Original map tiles remain unchanged.
- Sixteen-map scenery/roof/interior pass, native fruit-rock draw ownership,
  restored Sky Ride scientist presence without party changes, 1440p fixed-style
  migration, shader composition, and native doubles attacks/KO/escape pass.
- Geometry checks cover closed rocks, bounded uneven reef clusters, continuous
  mound corners and shore slopes, low shrubs, cut sapling size, furniture/floor
  isolation, retained distant foliage and existing Gen 1 tree budgets.
  Gen 2 support: 181 checks; doubles core: 39 checks; HUD regression passes.

## Remaining work

This release moves toward the supplied Gamma Emerald references; it does not
provide exact visual parity or fully authored coverage of every object.
Follow-up 1.18.0 replaces Park benches/bins and corrects the unused radio desk
and Center counter-ball recipes against native placements. Crown caps improve
steep views; Dark Cave has continuous fractured wall surfaces and muted floor
materials. Other generic architectural/interior surfaces, further terrain and
foliage art, and hardware/performance review remain open.

The fast, bouncing Charmander remains reported in New Bark Town on cart1.9.0.
A 900-frame-per-city probe in both depth and flat views found no multi-cell
jumps. Its source is unconfirmed; no speculative movement slowdown is included.
Wild Skies 1.12.2 corrects native neighbouring-map collision arguments; Online+
0.5.3 omits unsupported Gen 1 map-script registration on Crystal. This does not
port the Casino Lounge map. Native static-cache snapshots and RAM encode/decode
now pass; persistent storage still depends on the host. Optional companion
provider notices can remain. These runs are not described as warning-free.

Foliage was generated with the built-in image-generation tool, without copying
reference-game assets. The unchanged PNG and exact prompt are recorded in
[depth-crowns-v2.md](../assets/crystal/depth-crowns-v2.md).
