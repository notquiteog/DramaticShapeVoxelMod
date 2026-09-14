# Crystal scenery and native animation/camera follow-up

This release builds on 1.14.2 and retains its staged HUD backplates.

- Live overworld item balls are four pixels high (previously nine), including
  their button. The shared position helper is unscaled so rock actors retain
  their dimensions. Ground, furniture and lift anchors are preserved.
- Elm's healing bed is horizontal: six pixels high across its 32-pixel depth.
  His bin has a tapered body, thick rim and dark recessed interior instead of
  a folded rectangular facade. The complete source drawings still own their
  original cells; interaction/collision data is unchanged.
- Three mature tree families and a shorter shrub use original foliage artwork
  on the lobes and outer boughs. Grass has irregular tonal patches instead of
  diagonal striping. The optional depth-based focus effect remains available.
  Artwork provenance and the built-in tool prompt are in CRYSTAL_FOLIAGE_ART.md.
- The Crystal importer in the tested engine already supplies native water,
  flower, lava, whirlpool and tower animation programs/strips. Gen2AtlasAnimation
  composes their frames over the HD atlas and selects immutable textures from
  the live world's animTimer. Duplicate frames share one texture. Missing
  imported strips remain static. No Gen 1 flower art or blanket tile-$14
  animation is substituted. The experimental battle-only clock tick is removed.
- 1ST/3RD rotate movement intent at native World.pollInput. Gen 2 retains its
  native grid steps, speed hooks, collisions and arrival pipeline; this is not
  Gen 1's continuous walk solver. Menus and scripts retain input. Sky Ride
  0.2.20 delegates to Battle Art's native world predicate so it does not disable
  camera movement halfway through an ordinary step. Older providers keep its
  legacy bridge. The companion patch lives in its own repository/package.

Verification on the local 0.2.59 engine and imported Crystal data, software GL:

- Full scenery driver: 16 maps, 18 map views plus optional depth-of-field view;
  no unclaimed tree/rock source cells; table/support and ledge dimensions pass.
  Latest lab view shows the horizontal bed, open bin and small starter balls.
- Camera/water driver: changing textures reach the actual Water.draw calls;
  both camera rungs move from (7,5) to (9,5) when forward is held at east yaw,
  with native grid landing. Leaving the rung releases camera input.
- SDK: 181/181 Gen 2 support and 95/95 tile-shape checks. Pure checks cover
  item-ball dimensions/anchors, bin/bed geometry, camera delegation, tree
  budgets/ownership, closed rocks/ledges, material ranges and depth unprojection.
- The current 13-companion set loads. Online+ 0.5.2 reports its existing
  unsupported Gen 2 map_scripts registration; this is not a zero-error claim
  for its casino/online features. Wilds still logs presentation fallbacks.

Open reports: the user saw a ground/water Pokemon darting around New Bark on
cart 1.5.0. Two instrumented current-build boots measured no multi-cell jumps;
water wandering covered six tiles over the sample, while a town ambient guest
moved at the native Fisher NPC's one-pixel-per-tick pace. This does not reproduce
or close the user's report. tests/gen2_spawn_motion_driver.lua records both
spawned and native/ambient actors for further comparison. Wilds movement is not
patched in this release.

These are desktop tests, not Android hardware validation. This release is a
scenery improvement, not a claim that every one of Crystal's 35 tilesets has
bespoke Gamma Emerald-quality art. The coverage audit and remaining native wall
and prop families still need review.
