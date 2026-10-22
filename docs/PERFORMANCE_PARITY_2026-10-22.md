# Streaming and parity follow-up — 2026-10-22

Official engine checked: 0.3.95. Native runs used that engine with the LÖVE11.5
shell from0.3.89, NVIDIA5060Ti/615.71.09 and disposable profiles. All seven mods
were loaded; user saves were not changed. No model-family work was undertaken.

Changes:
- Gen1/2 foreground queue allowance2ms, speculative1.5ms; initial BODY6.5ms and
  covered30ms remain to avoid delaying the first usable floor/loading fades.
- Gen3 begins destination prefetch48cells out. Local windows and destinations
  share2ms normally/4ms near exits, replacing independent2ms+4/8ms allowances.
- Native model cache encodes sorted keys once, reuses unchanged settings encoding
  and packing scratch, and yields while replaying decoded quads. Settings edits,
  newly registered/removed options and source identity still invalidate records.
- Native dust/splash/door/healing geometry reuses GPU meshes, updating vertices
  without allocating and destroying the same small GPU buffer each frame.
- Parity commits cac3f0d and68d82fa expose XD in native Gen3 menus and correct
  shared XD materials/animation selection. These do not enable unvalidated packs.

Validation:
- Six GB editions complete forest/lab/first-person streaming fixtures. Five GBA
  editions cross actual native connections while running, keep camera ownership,
  promote the destination and match the native neighboring-map sampler.
- Original12-cell FireRed test lane had native obstructions; final common GBA
  fixture starts2cells before the exit. This deliberately cold late approach
  still stalls160–211ms: completion is synchronous when prefetch is unfinished.
- Cache encoding/reference tests,35 budget assertions, scene cache/stream,
  geometry slicing, civic materials, effect pooling and ground-effect tests pass.
  Native zlib/float/ImageData roundtrip verifies settings changes and identical
  quad data.120native splash frames preserve3D camera control.
- Canonical240-option encoding microbenchmark4000iterations:992ms before,
  419ms after. This is CPU key encoding, not an FPS measurement.
- Emerald1440p high shadows: still4.68ms mean/7.75p95; moving8.18/13.57;
  battle2.86/4.24; battle shadows OFF2.38/3.43. These are short synthetic fixture
  measurements, not whole-game certification. Normal12-cell running approach:
  p95wall23.16→21.26ms, maximum41.68→46.78ms (not an improved worst case).

Not complete: steady165FPS, synchronous cold destination completion, physical
Android/iOS/Windows validation, unsupported engine presentation hooks and full XD
render/import acceptance. Do not relabel these tests as full feature parity.
