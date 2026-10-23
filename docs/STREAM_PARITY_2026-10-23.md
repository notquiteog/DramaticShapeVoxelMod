# Streaming and parity — 2026-10-23

Gen3 changing-window keys reuse the validated layout/provider snapshot. Tests
compare warm keys to cold fingerprints and mutate native edits and atlas data
during window changes. Shared tree-anchor normalization now yields every2048
vertices, preserving all original positions, UVs and explicit anchors. This
reduces an unbounded CPU preparation segment; it does not make atomic GPU calls
preemptible or remove cold synchronous scene completion.

Ten existing stream/cache/effect suites, mesh upload tests and the new10001-vertex
slicing test pass. Parity commit62ae6982 passed four focused suites, including24
Stadium compatibility checks. Its native move-category routing and failure
fallback do not enable unfinished XD packs.

Official engine0.3.95 checked2026-10-23. Native shell is LÖVE11.5 from0.3.89,
running that official0.3.95 source with isolated profiles and NVIDIA rendering.
Before the final normalization slice change, actual five-game1440p running
connections passed native neighbor/camera checks, but showed wall p95/max(ms):
FR36.74/314.46, LG31.84/252.30, Ruby27.49/66.14, Sapphire27.93/37.38,
Emerald22.22/60.90. FRLG forced cold completion took286/225ms. These include
newer scenery than previous benchmarks and are not a controlled speedup claim.
The remaining cold-build/upload costs and165FPS target are unresolved.

No exhaustive scenery, physical Android/iOS or full XD acceptance is claimed.
