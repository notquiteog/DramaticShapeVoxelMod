# Retained scenery instance bindings — 2026-10-13

`ModelInstances` previously attached and detached the same immutable placement
buffer on every shadow and scene draw. It now retains that mesh attribute until
another batch uses the prototype, an ordinary draw needs it, a batch is released,
or a draw fails. New-batch validation invalidates the old binding first. Releasing
an older batch cannot detach a newer batch's binding on the same prototype.
Shader instancing enable remains reset after each draw. No geometry, textures,
shadow quality, render distance, connected maps or collision were reduced.

The mocked regression makes 2,000 unchanged batch draws: one attach and zero
detaches, versus 2,000 of each before. It also covers ordinary draws, shared
prototype swaps, construction, release order, failed drawing and unsupported
attributes/drivers. This proves reduced state operations, not an FPS gain.
`draw_uniforms_test.lua`, `shadow_disabled_test.lua` and native LuaJIT parsing pass.

Runtime evidence uses official engine 0.3.85 and isolated Emerald QA profiles.
`tests/model_instances_gpu.lua` compares merged and instanced geometry plus sun
shadows byte-for-byte at four headings and draws the ordinary prototype afterward
to check state cleanup. Optional output directory saves those exact canvases.
Fixture: `.scratch/instance-bindings-20261013/driver.lua`; artifacts under the
workspace-level `.scratch/instance-bindings-20261013/`. Software-rendered equality
passed on llvmpipe; four headings were inspected. NVIDIA validation and presentation
control are recorded below. This synthetic shared renderer test is not all-map or
all-game visual coverage.

NVIDIA GeForce RTX 5060 Ti, driver 615.71.09, Xvfb: exact pixel/shadow equality
passed all four headings (`gpu-hardware/run.log`). Saved canvases and the native
and voxel control shots were inspected. Hardware launches require
`__GLX_VENDOR_LIBRARY_NAME=nvidia` and permitted GPU device access; sandbox-only
runs silently selected llvmpipe and were not used for hardware timing.

The control driver (`present-control.lua`) uses the same Oldale Town (8,12),
yaw .8, pitch .25, 2560x1440 vsync=0, AA off, render scale 1, automatic distance,
balanced modeled trees and `gen3-emerald-lamps-qa` profile as the parent benchmark.
It samples 180 settled frames in native, voxel level 7, then native again:

| Mode | Mean frame ms | Draw CPU ms | Present ms |
| --- | ---: | ---: | ---: |
| Native first | 37.78 | 0.95 | 35.01 |
| Voxel | 41.08 | 3.41 | 35.73 |
| Native repeated | 38.51 | 1.32 | 35.33 |

`control-hardware/run.log` contains phases and renderer identity. The roughly
35 ms presentation delay remains with voxel rendering disabled. This control
rules out attributing that whole delay to voxel geometry/shadows; it does not
identify the underlying swap/display-driver cause, establish physical-display
FPS, or measure an isolated FPS improvement from binding retention. No other
runtime was active during the hardware control. All test processes closed;
player saves were untouched. No version bump or release.
