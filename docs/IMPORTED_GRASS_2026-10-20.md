# Imported ORAS grass — source verification, 2026-10-20

This incremental scenery batch places the original ORAS standing grass model on
eligible native grass in Red, Blue, Yellow, Gold, Silver, Crystal, FireRed,
LeafGreen, Ruby, Sapphire and Emerald. It uses existing native grass predicates,
local ground and elevation; it does not add encounter areas, change collision,
or certify complete scenery coverage in these games. Characters, Pokémon and
flowers remain HD-2D. Partner mods remain optional.

## Source and processing

The source is [Tall Grass from Pokémon Omega Ruby / Alpha Sapphire, uploaded by
MasterPengo](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/353363/),
submitted June 24, 2024. Original game art belongs to Nintendo / Creatures /
GAME FREAK. See [the asset README](../assets/scenery/oras-grass/README.md) and
[provenance](../assets/scenery/oras-grass/provenance.json) for source/archive,
model and texture hashes.

| Catalog ID | Source model | Standing triangles | Indexed vertices | Original texture |
| --- | --- | ---: | ---: | --- |
| `oras_green` | `grass.dae` | 16 | 33 | `hureai_grass.png` |
| `oras_dry` | `grass02.dae` | 16 | 33 | `hureai_grass2.png` |
| `oras_tall` | `grass04.dae` | 24 | 36 | `hureai_grass04.png` |

The converter evaluates the full COLLADA scene hierarchy and weighted bind pose,
including bind-shape/joint transforms, declared units and `Z_UP`. Applying an
axis swap to raw positions alone would mishandle these exports. Standing
`hureai` material geometry is retained; the separate scattered `grass_tiru`
cut-leaf geometry is excluded from ordinary standing fields. This batch does
not add a new particle simulation or skeletal animation.

All three shipped PNGs are byte-identical to the source archive. UV V is
converted once to LÖVE's convention. Out-of-range U coordinates are preserved,
and both texture axes retain the original repeat sampler with nearest filtering.
No blades or texture pixels are invented. X, Y and Z receive the same scale:
the mesh is grounded at its actual minimum Y, centered in X/Z, and fits within
96% of its square extent. Integer quarter-turns preserve this footprint.

## Native placement and lifecycle

Gen 1/2 scans the native grass artwork at **8-pixel subtile** resolution and also
requires the containing native cell to be grass. It places green tufts at the
native local ground, including Gen 2 elevation. This avoids expanding a partial
grass drawing to an entire 16-pixel cell. The authored Safari presentation keeps
its own vegetation through the existing Safari renderer.

Gen 3 uses eligible **16-pixel native grass cells**, their local base height and
deterministic quarter-turns. Boundary/stage-hidden cells and the adapter's
excluded collision class are skipped. Native cell art remains authoritative for
the ground below the tufts. `oras_green` is the default; dry and tall forms are
prepared catalog variants, not a claim that every regional grass family has
already been assigned its own imported model.

`GrassModels` shares immutable CPU prototypes and uploads shared instanced
meshes when supported. Its ordinary merged-mesh fallback splits uploads into
bounded chunks of at most 8,192 vertices. Source two-sided blades use the
existing alpha-cutout renderer. The adapters suppress their old grass cards only
after a complete model build succeeds. Missing textures or failed uploads
retain the existing native grass presentation. Gen 3's `PROPS = CARDS` choice
also retains the native presentation.

Scene-owned output tables receive each part before an upload or cooperative
budget checkpoint can yield. Pending Gen 1/2 FULL and BODY builds have separate
ownership guards: cancelling one cannot release another build or the visible
previous generation. Cancellation, replacement and invalidation release model
and instance resources. Renderer reset releases scene batches before cached
images/prototypes. These are bounded resource/lifecycle changes, not a measured
whole-game FPS improvement.

Native Cut presentation removes affected instance positions or merged vertex
indices immediately while normal scene reconstruction catches up. Gen 3 also
prunes tufts when native metatile/collision edits change the underlying grass.
These operations do not implement encounters, HM eligibility, source map edits
or collision; those remain engine-owned.

## Verified source fixtures

These results use official Gen1Recomp **0.3.91**, desktop LÖVE/NVIDIA, isolated QA
profiles and Battle Art alone. They verify the source checkout used by the
fixtures. **Final release archive verification is pending**; no exact archive
hash or packaged-install pass is asserted here.

### Red / Blue / Yellow / Gold / Silver / Crystal

The native driver [gb-grass-models.lua](../tools/qa/gb-grass-models.lua) checks
Route 1 in Red/Blue/Yellow and Route 29 in Gold/Silver/Crystal. Each R/B/Y fixture
has **416** native grass subtile placements; each G/S/C fixture has **640**.
Assertions compare every model origin with the native mask, reject duplicates,
confirm actual draw submission, and compare native tile/grass/walkability hashes
before and after the presentation tests.

All six editions passed a one-cell native grass walk, overview and four actual
first-person headings. Each fixture hid **16** tufts through a Cut presentation
rectangle and restored the exact source mask after invalidation. Missing-asset
fallback, late asset restoration, and the ordinary non-instanced backend also
passed. **84 accepted captures** were inspected, including the final correctly
framed Crystal run. Four earlier out-of-frame Crystal captures are superseded
and excluded from that count.

The GB rectangle test invokes the presentation invalidation path used by Cut.
It does **not** exercise HM menu input, badge checks, or native Cut gameplay.
Reconstruction restores its fixture grass because the source map was never
modified.

### FireRed / LeafGreen / Ruby / Sapphire / Emerald

The native driver [gen3-imported-scenery.lua](../tools/qa/gen3-imported-scenery.lua)
passed all five editions using the real public `Field.executeFieldMove`
callbacks for **Cut and Surf**, including completion/unlocked state and actual
native metatile/player-state changes. Cut reduced imported placement counts
from **120 to 116** in the FireRed/LeafGreen fixture and **37 to 34** in each
Ruby/Sapphire/Emerald fixture. Switching to native grass cards and back preserved
the completed native Cut data. Surf advanced into the selected native water
cell and produced the expected native surfing state; overview and actual
first-person views were captured. **30 source functional captures** were
inspected across these five runs.

These calls verify native callback behavior with explicit QA action/mon inputs.
They do **not** verify obtaining the HM, party selection through the menu, badge
prerequisites or a player's saved progression. The water/shoreline appearance
has separate evidence and is not certified by this grass document.

## Reproducible focused checks and remaining limits

The following checks cover the importer and adapter contracts:

```sh
python3 tests/oras_grass_import_test.py /path/to/353363.zip
luajit tests/grass_models_test.lua
luajit tests/gb_grass_models_test.lua
luajit tests/gen3_grass_models_test.lua
```

The source archive is supplied explicitly and remains outside the repository.
The importer check verifies affine hierarchy order, all **168** original
standing triangle vertices after weighted bind-pose evaluation, unchanged PNG
bytes, sampler wrap and deterministic output. Lua tests cover bounded rotated
footprints, prototypes, instance/merged backends, fallback, Cut edits and pending
build cleanup.

This evidence is representative native grass coverage across eleven games, not
an all-map or all-grass-family visual certification. Android/GLES, general
performance, every companion combination and the final frozen release archive
remain outside these source fixture results. The default grass model does not
replace flowers, actors, authored Safari vegetation or unrelated scenery.
