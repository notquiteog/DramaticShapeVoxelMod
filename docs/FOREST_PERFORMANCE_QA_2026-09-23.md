# Forest, performance and upscaling — 1.26.0

## Scope and implementation

Viridian Forest uses overlapping canopy cells 649/665, not only visible trunk 676. Complete native tree cards are now anchored from each crown; exposed trunks are retained when their crown is outside the loaded area, without double-emitting the final tree. Both native edition tileset mappings are used. General tall grass is seven world pixels high. Source artwork, walkability and encounters are unchanged.

Native scene preparation now fingerprints immutable layout references and sparse public overrides, connected-map placement and current atlas objects before constructing thousands of cell records. Unknown layout providers and recorded replay snapshots retain the complete scan. Public `Field.setMetatile` changes invalidate immediately. Camera turns reuse geometry; a changed build neighborhood still rebuilds. This is not a blanket cache of gameplay state or animated textures.

FSR 1 uses AMD's reference full-precision EASU/RCAS kernels with explicit LÖVE texture callbacks. The shared AA resolve path makes it available to Gen 1/2/3 scene passes, with native-resolution UI. OFF is the default. Quality ratios are 1.3/1.5/1.7/2; supersampling yields to FSR. GLSL 330 packing/bitfield shims and unsigned literals are compatibility adaptations, not replacement upscaling kernels. MIT provenance is in THIRD_PARTY_NOTICES.md.

The native forest A/B shadow probe isolated diagonal canopy stripes: they disappear with shadows disabled. Receiver-plane depth correction now evaluates each PCF tap at the actual sampled texel centre, removing that reproduced acne while retaining cast shadows. Stable anchor-based clip-depth tie-breaking separates overlapping coplanar foliage without moving its physical root/shape. Authored weatherboard face/lip/underside courses replace plain house side/back swatches in the Pallet shell and matched house families; other exterior families remain separate work.

## Checks and limits

Scratch drivers, captures and logs: `/tmp/interior-studio-20260923/qa/results`; final packages/audit: `/tmp/forest-performance-20260923`. Official engine 0.3.2; isolated ROM-import profiles, six companion mods, renderer reports OpenGL 3.3 / NVIDIA 615.71.09 / RTX 5060 Ti. User saves/options were not changed.

An initial 180-frame, 1280×720 same-view comparison reduced Gen3Scene.draw CPU submission from 15.40 ms average / 37.30 ms p95 to 0.63 / 1.09 ms, with zero geometry rebuilds during both samples. Overall sampled frame time changed 25.78 to 11.06 ms. Those short exploratory runs include native entrance UI and are not a general FPS promise. The fixed loaded view contains 265 authored forest trees. A separate 240-frame-per-mode, unobstructed 1440p run measured 38.97 ms native, 37.18 ms FSR Quality, 37.41 ms Balanced and 36.91 ms Performance. This fixture sees only a small overall uplift from upscaling; the proven CPU preparation improvement must not be presented as a 1440p FPS multiplier.

Real GPU checks cover FSR dimensions, source orientation/flat colours, all four quality levels, precedence over supersampling and switching back to native in Yellow/Crystal; 1280×720 FireRed and 2560×1440 LeafGreen forest/lab captures; native metatile cache invalidation; first/static/free foliage orientation tests. Native shadow ON/OFF comparison and corrected captures were inspected. Pallet side/back/first captures were inspected. The initial Viridian exterior viewing cell faced away from the house, so those pictures are not evidence of house quality there. No claim of all-map or all-angle perfection is made.

The settings inventory exposes missing consumers honestly. Before this new FSR option, Gen 2 had 38 implemented / 34 partial / 13 missing / 2 provider / 2 other-engine entries; Gen 3 had 31 implemented / 4 partial / 53 missing / 1 provider. FSR adds one implemented option per generation. These are source-consumer counts, not exhaustive device/gameplay validation. Full Gen 1 parity is unfinished.

## Native engine work still required

[AMD FSR 1](https://github.com/GPUOpen-Effects/FidelityFX-FSR) is spatial upscaling and needs no motion history. [AMD FSR 3 frame generation](https://gpuopen.com/fidelityfx-super-resolution-3/) instead requires native DX12/Vulkan swapchain integration and UI composition. [NVIDIA Streamline](https://developer.nvidia.com/blog/how-to-integrate-nvidia-dlss-4-into-your-game-with-nvidia-streamline/) requires compatible native rendering resources, including motion vectors. The current LÖVE/OpenGL mod has neither that backend nor a native presentation/SDK seam.

[DLSS 5](https://developer.nvidia.com/blog/whats-new-for-game-developers-dlss-5-with-3d-guided-neural-rendering-nvidia-ace-updates-and-new-rtx-kit-capabilities/) adds neural rendering using frame colour and motion vectors. It is not implemented here. There are no fake DLSS/frame-generation settings. A native engine port, motion-history/disocclusion work and platform/device testing remain prerequisites.

Known visual gap: final Pallet reverse-angle captures still show noisy house gable/siding pixels, and some close civic walls retain shadow bands. These are not signed off as fixed. The complete 1.26 package has compile/packaging validation; the runtime checks above used the same working source, not a final archive reinstall.
