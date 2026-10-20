# Native paired release audio and current settings coverage

A native GBA paired intro emits one shared ball-open sound for each team. The
optional Ember adapter now replaces that cue when every identified actor needs
the same normal/shiny variant. It checks every participant and deduplicates
aliased stage ball records. Mixed variants, unknown actors, empty groups,
explicit mixer settings, unavailable/failed playback and OFF retain native
sound. The original sequencer, cue count and actor clocks are unchanged.

## Native verification

Official engine 0.3.91, unmodified core, Linux NVIDIA LÖVE shell, all seven
independent mods, isolated QA profiles. `tools/qa/native-gen3-pair-audio.lua`
ran the original paired trainer intro in FireRed, LeafGreen, Ruby, Sapphire and
Emerald with two allied and two opposing actors. Every edition passed:

| Case | Replacement attempts | Replaced cues | Native cues |
|---|---:|---:|---:|
| Both allies normal | 2 | 2 | 0 |
| Both allies shiny | 2 | 2 | 0 |
| Mixed allied variants | 1 | 1 | 1 |
| Playback fails | 2 | 0 | 2 |
| Option OFF | 0 | 0 | 2 |

The opponent pair is normal, so it retains a valid replacement even in the
mixed-allied case. A playback sink verifies routing and failure behavior;
optional Ember files are not bundled and audible timbre was not verified.
Five post-intro captures were inspected, with all four actors and UI present.
Scratch evidence: `pair-audio-0391`. Focused native GBA audio, GSC audio and
shared capture-audio tests pass; inventory generation/check passes.

## Current eleven-edition options check

The original nested menus expose all 119 registered voxel controls in each of
Red/Blue/Yellow/Gold/Silver/Crystal and all 121 in each of the five GBA editions.
`tools/qa/voxel-native-options.lua` traversed the menus and changed/restored the
real inversion setting. All eleven pass on 0.3.91; eleven root-menu captures
were inspected. This proves registration and that consumer, not every setting's
visual behavior. Scratch evidence: `options-0391`, `options-refreshed-0391`.

The old FireRed/LeafGreen QA imports were cache revision 138; this official
runtime requires 139. Both were refreshed through the original importer using
existing authorized ROMs. No engine code or ordinary player saves were changed.
The nine other imports remained valid. Earlier 0.3.89 evidence is unchanged.

## Remaining scope

GSC paired Legendary Q57 release still needs separate per-actor world subjects:
`BattleScene.updateSendout` only iterates lead sides, and `q57/Adapter` uses
`arena[side]` while paired pictures are composed into shared side cards. Merely
allowing partner events in the reader would deform both teammates and is not a
valid fix. The separate native smoke/star and move adapters are implemented.
GBA ball particles still expose no exact actor owner through their public pool;
mixed simultaneous audio variants deliberately retain native sound. Optional
model deformation/poses remain provider-owned. Full feature parity and physical
Android/iOS/Windows validation are not claimed.
