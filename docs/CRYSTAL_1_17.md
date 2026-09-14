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
Park benches and several generic architectural/interior surfaces still use
source-derived boxes. The unused radio mixing-desk and centre-counter-ball
recipes need further source inspection. Cavern and terrain material refinement,
more natural high-angle foliage, and broader hardware/performance review remain.

The reported fast, bouncing Charmander is still un-reproduced. A stationary
three-city probe found no Charmander or multi-cell jumps; no speculative global
movement slowdown is included. Known companion issues remain: Online+ uses a
Gen 1-only map_scripts registry, and Wild Skies reports a Gen 2 defCellTile
argument mismatch on some ticks. Optional cache writes can fail while completed
GPU meshes remain usable. These runs are not described as warning-free.

Foliage was generated with the built-in image-generation tool, without copying
reference-game assets. The unchanged PNG and exact prompt are recorded in
[depth-crowns-v2.md](../assets/crystal/depth-crowns-v2.md).
