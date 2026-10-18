# Native selected-art resource fallback — 2026-10-17

Static platform audit found the native battle picture fitter and GBA trainer
sheet composer could propagate failed canvas allocations/draws. The picture
fitter could also leave the temporary graphics state active after a draw error.
Both now return to their original native image readers, release partially built
resources, and restore pushed graphics state. Failed image/size or sheet keys
are remembered until normal unload, avoiding per-frame allocation failures.
Normal successful pictures retain existing fitting, orientation, cache and
species/shiny identity behavior. Failed optional art does not disable the mod
or change any native gameplay/animation clock.

`native_art_resource_fallback_test.lua` injects allocation and draw failures,
checks release/state restoration, prevents repeated allocation attempts, retains
native trainer/scripted-role ownership and restores readers on unload.
`native_battle_identity_test.lua` passes24 checks, including actual wrapped GBA
and GSC reader fallback. Existing native scale/fitting tests pass unchanged.
These are mocked failure-path checks, not real out-of-memory device tests.

The audited interface adapters use public LÖVE/engine APIs, no shell/file-path
or OS-specific branch. Their settings use engine option rows and their screens
retain native input dispatch. Native HUD shader/canvas creation already falls
back; its shader uses ordinary texture/color operations. GSC LCD/BGP composition
now explicitly returns to native veil drawing when the palette shader is not
available. This inspection does not certify the full renderer or touch camera
controls, which have separate owners and tests.

Android's reported loaded-but-2D symptom is being investigated in the renderer;
this failure-path fix is not presented as its cause or solution. No Android,
iOS, Windows, controller or touch execution was performed for this batch. Linux
0.3.89 evidence for preceding picture effects is recorded separately. Real
device/runtime details and native controls checks remain necessary before
claiming every supported platform is verified.
