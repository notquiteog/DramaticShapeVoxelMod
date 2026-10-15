# Ruby/Sapphire indexed hatch art — 2026-10-15

The native RS hatch renderer exposes its Scene draw, displayed OAM records and
transferred palette. `NativeIndexedHatchArt` uses these public objects to supply
selected frames through the original PPU. It changes only the displayed front
sheet and its private palette bank for that draw, restoring both on success or
error. Native egg/shards, visibility, affine matrices, priority, OAM timing,
position, cries, naming and hatch progression remain original.

This closes a bounded part of the indexed-renderer gap without adding an RGBA
compositor. Selected frames must be 64x64 with binary alpha and at most 15 opaque
GBA RGB5 colors. The original `Vram.indexedPic` silently merges additional
colors; the adapter explicitly rejects them. Oversized FULL images, translucent
or richer-color frames, missing CPU pixels/decoder failures, shared palette
banks and unexpected native frame layouts retain native art. Unsupported frames
are cached as unsupported rather than rescanned every draw. Special forms,
eggs, Spinda and Deoxys retain native pictures.

The current transferred `displayFx` snapshot supplies the native palette blend,
including the white hatch reveal and later black fade. The adapter does not
advance palette animation or infer timing from the current animation counter.
It leaves native base/faded palette buffers and the persistent front sheet
untouched. Prepared source pixels come from the existing CPU image cache; no
GPU texture readback or player data change is introduced.

## Verification

Focused tests currently pass 32 cached-frame/scope cases plus 51 comparisons using
the actual 0.3.89 indexed decoder and native Palette blend across all 17 fade
coefficients and three target colors. These cover identity, OFF/missing art,
representability guards, errors, cache reuse, native position/affine/priority,
palette sharing, restoration and unload. Native interface 77 checks pass.

Official latest release was checked immediately before the batch: **0.3.89**.
The matching native Linux shell ran both isolated Ruby/Sapphire profiles at
480x320, Littleroot fresh fixtures, native 2D, Crystal pack, FIT/FULL/OFF, with no
companions. `tools/qa/native-rs-indexed-hatch-art.lua` exercises original normal
Pikachu and shiny Cyndaquil hatch sequences, including shell/reveal, nickname
decline, result callbacks, reset and per-draw palette/OAM restoration. Both pass
with 1454 clean restored draws each. All 20 captures were inspected: native shell,
white reveal/shards, selected normal/shiny art, original UI and OFF fallback.
Native affine progression continues between captures. The hatch result retains
the original party mon, PID/shiny identity and exactly one native callback.

The first Ruby check found an existing native nickname-frame fade error even
with interface art OFF: `gba_fx.lua` expects RGB5 channels but RS supplies a
packed RGB555 value. A separate OFF baseline reproduced it. The adapter now
converts only that temporary draw argument and restores the original transferred
record on success/error. It preserves the native color/effect rather than
suppressing the fade. Final Ruby/Sapphire runs have no mod draw errors.

Logs/captures are under `.scratch/voxel-parity-20261015/`:
`indexed-hatch-art-0389/{ruby,sapphire}/`, runner
`run-indexed-hatch-art-0389.sh`; baseline is
`indexed-hatch-off-baseline-0389/ruby/run.log`. All runtime processes ended.
Player saves were untouched; only isolated QA profiles were used.
The shared broad run (`suite-indexed-hatch-final.log`) completed311 passed,
1 failed and58 external-prerequisite skips. The sole failure is the performance
integration's `gen3_adapter_test` fixture missing a stub for its new public
Game3 dependency; all hatch tests pass. The performance owner is correcting
that fixture separately before release. SDK1173 passes within this run.

No version/release metadata, model artwork, independent assets or published
archive changed. The inventory must remain partial for unsupported indexed
frames and other native dedicated-pose/asset/provider constraints.
