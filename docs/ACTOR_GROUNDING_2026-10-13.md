# Overworld sprite grounding — 2026-10-13

Fixed three demonstrated renderer issues, without altering gameplay positions:

- Gen3 native `spriteYOffset` already contains `jumpSpriteY()` in official
  0.3.85. Actor, first-person eye and motion input previously added both. They
  now share `Gen3SpriteAnchor.playerLift`, applying the native offset once.
  Surf descent, explicit flight/ride heights and legacy jump-only providers
  remain supported.
- Public Gen3 sprite providers can return GPU Images without CPU `imageData`
  or Canvas readback. Their transparent footer previously remained above the
  floor. `SpritePixels` snapshots such an Image once through a temporary Canvas,
  restores graphics state, releases owned resources and caches measured alpha
  bounds. Frames are inferred from quads when frameCount is absent. Failure
  retries are debounced for one second; changed image/CPU pixels retry promptly.
- GB sprite alpha-read failures previously cached an ungrounded fallback forever.
  Failed reads now retry after one second, and the measured foot anchor forms
  part of the mesh key so recovered art replaces the fallback geometry.

Explicit provider anchors and water masks remain authoritative. Existing
per-frame visible-foot placement is shared by visible cards, shadows and
reflection paths; there is no global downward offset or terrain clamp.

Official 0.3.85 (parent verified for this batch), isolated runtime evidence:
`.scratch/actor-ground-20261013`. `provider.lua` presents the *same imported
Emerald player Image* through a valid GPU-only sprite provider, omitting its CPU
pixels. Before/after use the old/new anchor helper in the production renderer:
`emerald-provider/{before,after}.png`; log reports native footer1, old padding0,
new padding1: visible foot gap1px becomes0. This reproduces the public provider
failure; it does not claim ordinary CPU-backed native sprites all floated.

Actual native characters plus HGSS followers were rendered standing and after
walking in Yellow (`yellow-hgss-final`), Crystal (`crystal-hgss`) and Emerald
(`emerald-hgss-final`). Images inspected. Yellow/Crystal follower logs show
terrain0/lift0 and visible anchors29/28 in32px sheets. Emerald follower spawns
following actual native steps; no fabricated stationary trailer. Some HUD and
shadow offsets affect apparent clearance, so geometric alpha bounds establish
contact rather than the distant sun shadow alone. Fixture boot/options syntax
failures were corrected before the successful runs; no affected test is claimed
passed. Runtime wrappers exit1 at shutdown as previous batches.

LuaJIT: gen3_sprite_anchor_test, sprite_billboards_test and
crossgen_grounding_test pass. Regressions cover GPU-only pixels, inferred frames,
readback/cache/release, failure debounce, streamed GB mesh replacement, explicit
anchors/masks, one native jump arc and retained surf/ride offsets. Physical
ledge traversal and every species/style/frame are not exhaustively verified.
Battle actor grounding belongs to a separate worker/change. No user save or
collision/warp data changed.
