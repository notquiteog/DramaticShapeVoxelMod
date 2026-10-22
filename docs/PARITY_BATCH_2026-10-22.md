# Parity batch — 2026-10-22

Implementation was batched before validation. Model coverage was excluded because
another worker owns it. This is not a full parity certification.

## Delivered

- Ruby/Sapphire selected binary-alpha hatch art no longer falls back merely
  because it has more than 15 colors: deterministic weighted RGB555 quantization
  uses native indexed OAM, masks, affine transforms and fade. Source frame size
  must still fit 64×64. See RS_HATCH_PALETTE_2026-10-22.md.
- GBA release adapter accepts a proposed exact per-particle owner capability,
  validating battle, slot, actor and Pokemon identity. Official 0.3.95 does not
  ship this capability; it retains the already-supported exclusive-epoch path
  and native fallback for ambiguous simultaneous particles. See
  NATIVE_RELEASE_RECALL_BOUNDARIES_2026-10-22.md.
- All three generation battle HUD consumers share optional semantic `hudColor`:
  COLOR gives dark floating header ink/bright shadow; INVERTED gives pale ink/dark
  shadow. Modern UI retains its asymmetric rails and semantic HP/gender colors.
  Cards are copied before forwarding; provider OFF and older provider APIs keep
  their supported fallback. No dependency between mods was added.

## Verification

Latest official engine checked: 0.3.95. Native renderer: LÖVE11.5 shell from the
0.3.89 AppImage, running official 0.3.95 engine source, NVIDIA, isolated Emerald
save. Both HUD modes rendered and screenshots inspected at1280×720. Initial QA
used nonpersistent option sync; final run uses the native setting setter and
asserts both selected mode and the forwarded provider contract.

30 combined Lua suites passed:14 relevant Battle Art option/HUD/release suites
and all16 Modern UI suites. Hatch worker additionally passed53 actual0.3.95
decoder/palette checks (33 mocked checks are included in the adapter suite).
These are source/API checks, not eleven-game visual or physical phone approval.

## Exact unfinished boundaries

- Engine: simultaneous GBA particles need authoritative per-draw ownership;
  GSC recall needs a native presentation cue; unrestricted RGBA/large RS hatch
  art needs a supported compositor insertion seam. No fabricated cues/private
  compositor overrides were introduced.
- Assets/providers: optional matching location, sound, pose and model assets
  must exist; ordinary art cannot stand in for missing identity/pose artwork.
- Verification: physical Android/iOS/Windows and exhaustive edition-specific
  visual acceptance remain outstanding. Small native animation text retains
  the engine raster limitations.
- Separately owned: scenery/model-family parity and broader geometry cache
  coverage from the previous audit are not marked complete by this batch.
