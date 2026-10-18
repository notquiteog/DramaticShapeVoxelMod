# GLES scene availability — 2026-10-17

The reported Android symptom is a loaded cart remaining in 2D. Two actual
scene-shader defects were reproduced using the official Gen1Recomp 0.3.89
LÖVE 11.5 shell in OpenGL ES 3.2 on NVIDIA 615.71.09:

- Battle occlusion injected an integer constant into float arithmetic. GLES
  rejected `w + 20`; the generated source now explicitly converts the margin.
- After compilation succeeded, GLES linking rejected `reflectionClip`: vertex
  and fragment stages inherited different default precision. Its precision is
  now explicit and identical in both stages.

Plain, grid and unlit scene variants now compile and link. Unrecoverable errors
retain the driver message and log once per attempted variant, keeping the
existing cached 2D fallback rather than retrying every frame.

## Verification

`tests/scene_shader/main.lua` is a ROM-free real-driver probe:

```
DS_MOD_PATH=/absolute/mod LOVE_GRAPHICS_USE_OPENGLES=1 love tests/scene_shader
```

Run without the GLES environment variable for desktop OpenGL. Both pass on the
above shell/GPU. `scene_shader_failure_test.lua` verifies diagnostic retention
and no repeated compilation after failure; battle occlusion checks also pass.
The shared broad run passed 328 suites, with its one camera headless-fixture
failure corrected and passing in a targeted rerun (329 combined passes,
58 external-fixture skips). The new failure-cache test passes separately.

Native isolated Red and Crystal forest/lab/first-person fixtures and Emerald
actual Route 104/Petalburg connection plus six reversals pass. Successful scene
begins were counted (649/413/342); this is actual geometry rendering, not merely
an enabled menu. Rendered captures were inspected. The Emerald camera view
exposed a separate canopy-obstruction regression forwarded to the camera owner;
this is not claimed as a visual camera pass.

Evidence: scratch batch `android-compat-20261017`, including original compiler
and linker errors, successful desktop/GLES probes, native logs and captures.
User save files were untouched. No physical Android device, phone GPU driver,
iOS runtime or Android touch hardware was available: these checks reproduce and
fix GLES incompatibilities, not certify every mobile device. No release bump.
