# Native Hoenn starter selected-art adapter — 2026-10-15

`NativeStarterArt` draws selected previews immediately before the original
public `scene_kit.drawFade` call. The original starter class draws every other
element, while only its fixed64 native mon quad is temporarily omitted. The
selected image uses native position/affine scale and its own centered dimensions;
Ruby/Sapphire retain their original affine policy, with the viewport enlarged
only as needed for FULL artwork. Native balls, circle, text, confirmation,
cry/timing and selection results remain original. Mon state, fade function and
graphics stack restore on success/error; unload restores the class renderer.
Missing art and runtimes without graphics stack introspection retain native draw.

This source-only follow-up to4bc557a changes no release metadata or artwork and
is not claimed included in the existing1.41.1 archive.

## Verification and asset limitation

Latest official release API rechecked: **v0.3.89**, matching native Linux shell;
production engine unchanged, public QA support from0.3.88. Driver
`tools/qa/native-gen3-starter-art.lua`, scratch runner `run-starter-art-0389.sh GAME`.
Isolated Ruby/Sapphire/Emerald profiles, fresh Littleroot, 480x320 native UI,
no companions. Actual bundled Crystal selection has no Hoenn starters: it covers
species1–251, and optional Hoenn atlases are absent. The first preview therefore
verifies genuine missing-art native fallback and original B cancellation.

For renderer acceptance, the driver explicitly supplies temporary test-provider
frames made from each game's own starter RGBA pixels, enlarged2x on CPU. This
adds no artwork file or production provider and does not change the starter
roster. The shared interface fitter produces FIT and FULL images; Torchic's
FULL canvas is66x94, proving the old64 quad cannot silently crop it. Screens
switch FIT/FULL/OFF live, decline, change selection to Treecko, reopen and accept.
Exactly one callback returns the original selected index. Reopening/resetting
calls no completion; the original empty party remains unchanged. The fixture
observes results rather than progressing the opening battle or granting a mon.

All three runs pass and all15 final captures were inspected: missing-native,
provider-fit, provider-full, off-native and other-provider. Original native UI
and edition-specific confirmation remain; the FULL test frame extends beyond
the white circle without the fixed64 crop. Selected pictures in these captures
are explicitly test-provider art, not proof that a Hoenn selected pack ships.
An initial3x test frame exceeded screen bounds, so the final2x fixture isolates
the64-viewport case within the available screen. Production logic was unchanged.

Evidence: `.scratch/voxel-parity-20261015/starter-art-0389/{ruby,sapphire,emerald}`.
Focused starter14/interface77/inventory549 checks pass. Broad suite308 passed,
0 failed,58 external prerequisite skips, including SDK1173; log
`suite-starter-final.log` in the scratch parent. No player saves written.

Remaining native interface limits: RS indexed hatch, FRLG dedicated credit pose
images, Dodrio action pose sheets and optional selected-art asset coverage.
Native timers, assets and defaults remain authoritative. Other scenery/model,
capture and backdrop gaps remain in OptionSupport; this does not complete parity.
