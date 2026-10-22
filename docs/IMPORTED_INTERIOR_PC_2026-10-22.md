# Imported public PC — source and guarded adapter

This batch prepares the ORAS public PC for the complete native Center terminal
recipes in Ruby/Sapphire/Emerald and FireRed/LeafGreen. It does not cover home
computer desks, laboratory consoles, upstairs terminals, or other furniture.
`Gen3ImportedInteriors.build(cells, newMesh, parts)` returns scene-owned parts,
an error, and successful placement count. The scene must skip the existing
furniture mesh only when `prop.importedInterior` was set after successful upload.
Existing wall, floor, recess and interaction processing remains authoritative.

## Source

[PC, ORAS, asset 297853](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/297853/),
submitted by Hallow on 2016-06-02. Original game art: Nintendo / Creatures /
GAME FREAK. This is the blue freestanding public terminal with teal screen,
silver side vents, sloped keyboard, and open lower frame, matching the public PC
identity. It is not the secret-base Toy PC or a replacement for a bedroom desk.

Downloaded archive remains outside the repository. The selected body/screen
PNGs retain their exact original bytes. Per-file hashes, archive hash, source
model hash and processing details are in the neighboring `provenance.json`.

All 170 source triangles, source UVs where present and source vertex RGBA are
retained. The source's 30-triangle translucent sheen has no TEXCOORD stream.
Sampling the declared PNG at a fabricated coordinate produced visible artifacts;
a generated white 1px material instead retains its white vertex RGB and original
alpha (0, .2, 1). It is explicitly a blend part. The source website preview does
not show this sheen; the rendered repair preserves the source's supplied shape
and RGBA. A dedicated screen surface is separated from the nearly coplanar
casing by .01 source units (0.05% of source width).

The exported model has an open rear and missing undersides. A separate authored
32-triangle closure follows the source rim, using the source case-blue swatch.
It closes the stepped rear casing, keyboard underside, frame rear and bottom
surfaces, retaining the open knee space, source silhouette and original geometry.
This authorship is recorded separately in provenance; it is not original ORAS
rear geometry.

## Native contract

Eligibility requires exact recipe, pair, family, artwork, claimed ownership,
flat equal ground, no boundary/stage hiding/civic/stair ownership, and original
row permissions `{7}, {0x93}, {0}`. A missing or changed cell retains the native
furniture. The PC fits uniformly inside the middle blocked 16x16 cell with .25
padding and a 24-unit height cap. Its source width fills over 13 of the 16 units;
no mesh extends onto the native walkable approach row.

Official 0.3.95 native fixtures supplied by the coordinating worker confirm
Emerald Oldale Center 1F (10,0), pair `building__pokemon_center`, artwork
`20c,4,224`, and FireRed Viridian Center 1F (11,0), pair `network`, artwork
`285,62,295`, both with the permission sequence above. These examples are
eligibility evidence, not a claim that every matching map was visually reviewed.

## Verification

- LuaJIT adapter test: exact identity/ownership/art/height/permission guards,
  deterministic placements, empty scene and missing-resource fallback pass.
- LuaJIT data test: original source RGBA, PNG signatures, 202 triangles including
  32 separately authored closure triangles, uniform bounded fit and width pass.
- LuaJIT compilation and diff whitespace checks pass.
- Official 0.3.95 LÖVE 11.5 shell, NVIDIA OpenGL 3.3 source preview: front, rear,
  both sides, quarter, low eye and underside rendered and inspected. Case/vent
  silhouette, separated screen, retained open frame and closed rear/undersides
  inspected. Scratch viewer/captures and original archives are not committed.

Parent integration owns the in-game captures, all-map inventory, native approach
and interaction tests, source-missing fallback, standalone packaging and final
acceptance. This source preview does not claim those checks or phone testing.

## Native powered frames

Official 0.3.95 `pc_anim` uses FRLG public-PC body `62` OFF / `63` ON.
The official RSE native PC adapter resolves `METATILE_Building_PC_Off/On`
through edition constants: `4` OFF / `5` ON in R/S/E. Complete Center recipes
accept only those scoped body aliases. Actual native cells and recipe tables
remain untouched, and native fallback source crops use the live powered frame.
The imported public PC remains present through the native flicker/menu/off
sequence. Bedroom/lab machines and unrelated uses of these IDs are not aliased.
The all-five edition extraction/fallback regression and imported eligibility
test cover repeated OFF/ON/OFF transitions; parent owns real native interaction
captures for this follow-up.

Native `setMetatile(..., true)` also changes the body permission from initial
`93` to hard-blocked `7` throughout ON/OFF flicker. The exact reviewed body row
accepts both hard-blocked values; its header stays 7 and approach stays 0.
Tests reproduce this collision transition together with both artwork frames.
