# Running-window streaming

Gen3 now completes the pending window of an unchanged world when a running
player requests another window. Previously every new window canceled the
candidate, leaving stale scenery and wasting completed CPU/GPU work. Reversing
back into the active window still cancels unnecessary work. Map and gameplay
edits retain immediate invalidation; incomplete meshes are never published.

Layout/gameplay context is now separate from atlas-provider readiness. A new
neighbor atlas no longer forces a synchronous cold restart. Published geometry
records its final provider key, and request fingerprinting traverses dependency
rows once instead of twice. The renderer still includes connected map regions;
no tree quality, draw distance, resolution or shadow settings were lowered.

## Measured scope

Official Gen1Recomp 0.3.85, Linux extracted LOVE, NVIDIA RTX 5060 Ti/615.71.09,
2560×1440 window under Xvfb, isolated Emerald identity. Oldale and loaded
connected scenery, rotating third person; fixed 720-pixel synthetic traversal
at two pixels/frame (render-streaming stress, not collision/gameplay proof).
Other agents' timed GPU work was paused for these paired runs.

| Running measurement | Before | After |
| --- | ---: | ---: |
| Mean frame | 45.94 ms | 45.66 ms |
| p95 frame | 55.70 ms | 55.46 ms |
| Worst frame | 161.29 ms | 73.12 ms |
| Canceled candidates | 6 | 0 |
| Completed replacement windows | 2 | 4 |
| Mean scene CPU submission | 7.62 ms | 7.01 ms |

Presentation still accounts for about 35 ms/frame in this environment; this
patch reduces stalls, not the general steady-state rendering bottleneck. Cold
loads and individual GPU uploads can still exceed a frame budget. Source tests
cover continuous request changes, atomic swap, reversal, warp, failure cleanup,
provider changes and gameplay edits. Full SDK: 1173/1173 checks passed.

Evidence in projects `.scratch/streaming-20261013/emerald-{baseline,after}1440`.
Gen1/Gen2 connected destination precaching is documented separately in
`GEN2_PRECACHE_2026-10-13.md` if present; its native seam tests measure readiness,
not a broad FPS improvement. No all-game smooth-frame-rate claim is made.
