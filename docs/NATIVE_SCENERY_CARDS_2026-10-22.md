# Native scenery HD2D cards — 2026-10-22

`NativeSceneryCards` provides actual upright native source art for Gen3 civic
buildings, whole furniture recipes and individual ungrouped source cells.
Existing civic/furniture modules produce native voxel geometry; only the
plant/rock/tree/actor paths previously offered cards. Disabling imported models
alone therefore did not provide an HD2D building/furniture presentation.

The module reads the active provider's native `imageData`, `overImageData`,
`midToSlot`, `cols` and `rows`. It emits original atlas UVs without allocating,
baking, copying or releasing any game texture. Its draw helper resolves
`ts.image` and `ts.overImage` on every draw, retaining provider replacement and
native atlas animation. Geometry uses nearest native pixel boundaries and
neutral shade. No imported game assets or captures are stored in this change.

API:

- `prepareCivic(g,cells,options)` uses the complete `g.rows`, exact native
  source drawing, actual `c.civic==g` ownership and `Gen3Civic.ground(c)`.
- `prepareFurniture(p,cells,options)` uses `p.recipe.rows`, `c.prop==p` and
  `Gen3Furniture.groundAt(c)`. Floor openings with `recipe.noGround` stand down.
- `prepareCell(c,cells,options)` handles a genuinely ungrouped single source
  cell using `c.shape.ground`. It does not reconstruct a cropped multi-cell
  tree/building; grouped source drawings must use their whole-object adapter.
- `prepare(spec,cells,options)` is the reusable form. A spec supplies `owner`,
  `rows`, `ts`, `cx`, `cy`, `owns(cell)` and `groundAt(cell)`, with optional
  `base`. Coordinates are native cells. `options.cellSize` defaults to 16 and
  supports other atlas cell sizes, including 8, without assuming a Gen1/2
  object registry or providing those games' scene integration.
- Preparation returns `card,error`. `append(card,emit,uvFor)` validates all UVs
  before emission, then emits ordinary XYZ/UV/shade quads with local Y. Parent
  batching must supply its native live atlas and lift by `card.base`.
- `build(card,newMesh,parts,uvFor)` lifts vertices, verifies atlas availability,
  uploads a mesh, appends its scene-owned part and marks
  `owner.nativeSceneryCard` only on success. Failure leaves the parts list and
  source ownership unchanged. Use its returned success to suppress the prior
  voxel/imported model. `draw(part,draw)` resolves live atlas images.
  `release(part)` releases only the mesh and clears its matching success mark.
- `doorSurface(card,tx,ty,options)` returns a source-aligned native door panel
  only for an owned original `0x71` warp cell at its segment front. Default
  viewport is 16×32, preserving native 16/32-pixel door sheets; width/height
  overrides support reviewed alternatives. All source/world coordinates stay
  at the original warp. Parent native door drawing remains authoritative.

Every source cell must still exist with the original mid and atlas reference.
Hidden/boundary cells and unequal owned ground heights stand down. Source
ownership is never mutated. Each vertical source column is grounded at its
last actually owned row; adjacent columns with the same front form a segment.
This preserves a projecting arch and a shallower east wing without projecting
their cards over native walkable gaps. Artwork pixels keep native source size.
Fixed upright cards retain their full width; rotating a wide building around
the camera would violate a narrow footprint or require shrinking its art.
These cards intentionally do not use cylindrical yaw billboarding.

Floor separation uses the complete native local-ground palette, removed only
where connected to the drawing's outer border. Enclosed window/highlight
pixels with matching colors remain intact. Unowned cells never emit source
geometry, even when they lie inside a mixed complete drawing. Existing civic/
furniture ground rendering remains responsible for the horizontal local floor.
`options.backgroundMids` can add explicitly reviewed wall/background swatches;
`background(r,g,b,a,x,y,cell)` replaces palette classification, and
`mask(x,y,cell)` supplies an explicit foreground mask for ambiguous mixed art.
An unknown ground with no explicit policy, empty silhouette, missing source/
UV/image, malformed input or failed upload retains the native model fallback.

Limits: 65,536 source pixels and 16,384 merged source rectangles per object.
Mask topology is prepared from the current source drawing. Animated art whose
silhouette grows outside that mask needs an explicit union mask or a rebuild;
ordinary interior door overlays use the separate native door surface. Wall-
mounted recipes that include wallpaper require reviewed background swatches
or masks before their HD2D source silhouette can be considered accepted.
Ground surfaces stay horizontal; this helper does not convert arbitrary
terrain to upright rectangles. No all-eleven-edition coverage is claimed.

Focused CPU tests cover exact source pixels/UVs, enclosed matching colors,
mixed owner fronts and two warp rows, provider replacement, failure fallback,
mesh versus atlas ownership, generic cell size and unchanged native cells.
Parent VisualStyles dispatch and scene suppression/door integration, then
native static/orbit/eye, animation, local-ground, input/collision and missing-
asset checks, remain required before runtime acceptance.
