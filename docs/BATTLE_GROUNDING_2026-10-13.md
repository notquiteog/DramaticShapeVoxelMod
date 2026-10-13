# Battle sprite footing — 2026-10-13

Three specific presentation defects were corrected without changing battle
simulation, attack transforms, species data, or terrain:

- Gen2Staged aligned image/atlas-frame extents to the floor, including empty
  lower rows. It now uses visible bounds, separately for a doubles partner,
  while respecting existing prepared-art shared anchors. The integrated
  full-body provider exports an animation-wide `groundY` from all its frames;
  common padding disappears while authored raised poses remain raised.
- The shared Gen1/2 card matrix rounded its vertical foot offset. A common
  Gen2 anchor of 143 in a 144px canvas was lifted by 2/7 world pixels. The
  vertical correction is now exact; horizontal sampling remains snapped.
  Native Gen1 images also receive alpha-bound metrics when they lack external
  artwork metadata. The observed Yellow pair already had zero bottom padding;
  this is a missing-path correction, not a reproduced large Yellow padding gap.
- Gen3 cards omitted the thin-caster `ShadowMap.snug` used by Gen1/2. Terrain
  acne allowance detached their shadows despite correct alpha foot anchors.
  The caster and visible-pass shadow lookup now use the same compensated
  transform. Visible model matrices and native movement offsets are unchanged.

No terrain adjustment was justified by the flat fixtures: Emerald actor
support and sampled terrain both measured zero. No per-species or all-game
coverage claim is made. Native cropped back pictures still end at their
visible crop boundary; this does not manufacture legs for them. Existing
soft-shadow filtering can leave a small contact transition even with an exact
foot plane. Deliberate animation poses can legitimately rise above the shared
animation ground row.

## Evidence and checks

Engine: official 0.3.85, its extracted Linux LÖVE executable; current repository
checkout with concurrent UI/overworld work. Latest release verification was
attempted earlier this session but network/DNS failed. Disposable copied QA
profiles only, under `.scratch/battle-ground-20261013/profiles`; no player save
or normal persistence profile touched. Driver-created parties/battles, native
command-menu entry, optional Modern UI retained. No Windows/controller test.

Scratch root `/home/admin/Projects/.scratch/battle-ground-20261013`:

- `gb.lua`: Yellow Pallet Town, Pikachu/Rattata; Crystal New Bark Town,
  Totodile/Sentret. `rom` selects ROM artwork setting and full-body OFF;
  `animated` selects animated artwork setting and full-body ON. Installed
  Crystal pack ownership remains active; setting names alone do not prove
  every displayed image's source generation.
- `gba.lua`: Emerald Oldale Town, Charizard pair, original native backs versus
  selected full-body animation. `emerald-before` and `emerald-after` contain
  inspected `rom.png` and `animated.png`. Alpha foot traces show zero native
  gap and a -1px rasterized animated ally difference; both world supports are
  zero. The missing-caster correction improves visible foot/shadow attachment.
- Crystal pre-fix source: `crystal-after/animated.png` was captured before the
  Gen2-specific padding fix. `crystal-union-final/animated.png` was inspected
  after it; both visible bottoms equal anchor 143. The latter directory's
  `rom.png` still had full-body enabled and shows an intrinsic raised frame,
  so it is not evidence for native cropped backs.
- Final explicit style toggles: `yellow-styles-final` and
  `crystal-styles-final`. Both styles were visually inspected in each game;
  both sides report zero alpha-bottom gap in these sampled frames. Native
  cropped backs and complete full-body backs are visibly distinct. Foot traces
  and render completion are in `run.log`.

Focused checks: `battle_foot_anchor_test.lua`, `battle_sprite_footing_test.lua`,
`gen2_staged_pair_test.lua`, `gen3_world_battle_test.lua`,
`native_full_body_test.lua` pass. They cover fractional foot offsets, explicit
hop displacement, animated union anchoring, separate partners, and matching
shadow caster/lookup matrices. Engine-backed `gen2_support_test.lua`: 202/202.
`git diff --check` passes. Runtime drivers reach explicit GROUND QA PASS;
LÖVE shutdown returns shell status 1 without a driver error, as in earlier
085 fixtures, so process exit is not described as clean.
