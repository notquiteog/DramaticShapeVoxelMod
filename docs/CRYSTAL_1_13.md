# Crystal scenery update — 1.13.0

This release keeps Battle Art's scene ownership and the engine's collision,
warps, scripts, and movable objects. It adds visual recipes for Crystal's
player-house and lab tilesets, and improves Johto outdoor scenery.

- Border trees use the complete 16×32 drawing as a round hull anchored at its
  lower cell. Cut/headbutt bushes use a shorter 16×16 hull.
- Dining and starter tables stand 6 pixels high. Stools stand 5; kitchen
  worktops stand 8. Fridge/TV fronts and lab shelves fold onto 12px footprints;
  lab machines use 16px. The kitchen's long counter retains its drawn length.
- Table support comes from the same source recipes without requiring a mesh.
  Starter balls sit on the lid; the walkable apron remains at floor height.
- Johto's blocked retaining lip uses a 3px-wide, 6px-high edge with joined
  corners. The adjacent jump-trigger cell stays flat. Fences use posts/rails.
- Coastal boulders have closed faceted models. Each ocean barrier tile gets a
  separate 4px rock. Native Strength and Rock Smash actors use live models,
  including the shadow/reflection paths, so removal and movement follow the
  engine rather than leaving static copies behind.
- Gen 2 battle surround dimming and animation background clears are suppressed
  only while the 3D scene override is active. Stock behavior returns otherwise.

## Upstream integration

Fetched artyrambles/DRAMALESS_SHAPE main through
`97ca3e1f8f7c3aa0b3e671db497076150f494051`. Its history has no common ancestor
with this fork. Integrated the applicable mouse/menu fixes from `5bdde20` and
`fce6ace` as `aaf7ff6` and `4b0a3be`, preserving the input.pointer event and
source-owned button tokens. Variable sprite sizing and the guarded GBCFX call
already existed here. The separate upstream battle renderer is not a drop-in
replacement for Battle Art's scene owner. Its MIT attribution is retained in
[licenses/DRAMALESS_SHAPE.txt](licenses/DRAMALESS_SHAPE.txt).

## Verification

Desktop engine source `2cc86d5`, Crystal imported locally, software OpenGL under
Xvfb, disposable save identity. No ROM or generated cartridge assets are shipped.

- 95 Gen 2 classification/support checks; 181 generation/battle integration
  checks; 9 closed-rock and thin-ledge geometry checks.
- 35 mesh-budget, 7 storage-binding, 4 camera-inversion, 13 billboard-size,
  and 18 facade-culling checks. The facade test's stale dependency stub was
  updated to include the existing LegendaryTowerExterior dependency.
- Full-cart map driver checks clear camera positions, model ownership, furniture
  dimensions, table/apron support and actual rock/boulder actor draws. Covers
  New Bark, Route 29, Violet, Cherrygrove/coast, Elm's Lab from two aisles,
  Mom's house, Cherrygrove PC, Dark Cave and Blackthorn Gym 2F.
- Eleven-mod Crystal check exercises Running Shoes, Free Fly walk phases,
  modern start/PC menus, Gen 3 Boxes and Back, summary, and Modern Johto's
  optional split hook without mutating shared type data.
- A real Cyndaquil/Sentret battle reaches the menu and attack animation;
  screenshots show the diorama in margins and through animation clears.

These are desktop source-engine checks, not Android or dual-screen hardware
verification. Existing Wild Skies Map-API, Wilds sprite-fallback, and sandbox
cache warnings remain; a passing loader is not a claim of a warning-free log.
Modern Johto's balance switches remain at the author's off defaults in the cart.
