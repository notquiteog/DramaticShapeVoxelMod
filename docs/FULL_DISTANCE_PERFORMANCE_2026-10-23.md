# Full-distance acceptance — 2026-10-23

Target remains165FPS at2560x1440 while moving, with FULL render distance. It is
not achieved. Previous AUTO measurements do not establish FULL performance.
Latest official engine checked this batch:0.3.95. QA uses isolated Emerald
Route104 profile, all seven mods, high shadows, native resolution, AA off,
18 connected regions. Fixture moves player pixels and camera yaw; this is a
render-load measurement, not a native boundary/input acceptance test.

FULL moving observations range40–51ms mean, far beyond6.06ms. No scene rebuilds
occur during warm phases. Another independent game/test process was discovered
running on this machine; these wall-time comparisons are observational and must
not be represented as controlled FPS improvement or target completion.

Changes in this batch:
- Cull physical casters against current LIGHT planes, preserving off-camera
  casters inside that volume. Main/shadow instance buffers retain separate views.
- Cull disjoint water sheets before redundant reflection passes. Unknown bounds,
  transformed water and curved geometry retain their full fallback.
- Reject native fallback sprite cards against current pass VP, after all model
  providers. Reflection uses its current VP; providers remain unchanged.
- Reject non-vehicle actors before truck/boat map queries or protected closures.
  Full scenes were invoking providers~1590 times/frame across render passes.

Same instrumented fixture drawcall observations fell~3347 to2071. Provider
truck checks fell~4.8ms to~0.16ms and aggregate water passes~17ms to~9.3ms, but
end-to-end frame times still miss target. Do not conflate submission reductions
with a verified FPS gain. Remaining repeated actor preparation, allocations,
full-scene rendering and cold transitions need further work.

45 focused LuaJIT suites passed. Four native1280x720 FULL camera-direction
renders compare byte-identically with culling disabled/enabled; the resulting
scene image was inspected. Source fixture/output lives in
.scratch/perf-full-20261023. Real saves untouched. Physical mobile, all-game
FULL performance, and full feature parity are not certified.
