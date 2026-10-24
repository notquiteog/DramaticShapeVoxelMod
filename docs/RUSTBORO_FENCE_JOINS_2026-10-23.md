# Rustboro fence joins — 2026-10-23

The user reported missing and misaligned fences in Emerald Rustboro. Native
before captures reproduced flat navy rail sections, misplaced depth runs and
incorrect L-shaped models in the southern straight grass row. The initial
known-family census counted180 owners but missed2a7/352; the full native art
board and rendered city review exposed that omission before release.

`Gen3FenceFamilies` retains explicit source-art axes and native ground donors.
`join_oras_fences.py` composes those runs from the committed original ORAS fence
modules. It interpolates original UVs through exact projected triangle cuts,
removes positive-area coplanar overlap and opposite-facing internal contact
caps, and shares14 unique geometries across31 native families. It does not repaint the textures.
The existing model upload adapter recesses only bottom contact vertices. The
original upper geometry, native collision, scripts, elevation and actors stay
unchanged. The raw closed source primitives remain regeneration inputs.

Failed texture/model registration or GPU upload leaves the full original native
art intact. Runtime suppression is marked only after atomic successful upload.
All replacements stay inside their original16×16 blocked cells. There are no
new dependencies, API changes or UI changes.

Verification uses official Gen1Recomp0.3.96 and its Linux LÖVE11.5 shell with
isolated fresh profiles and existing imported caches. Root scratch evidence is
`rustboro-fences-20261023`; worker native/pixel evidence is
`hoenn-world-096-20261023/fences-after`. Source/native all-angle, first-person
and near-corner captures are inspected at walkable native viewpoints. All208 native fence owners build in each RSE city. Counts,
final package checks and release checksum accompany the release report.

Focused tests cover source failure atomicity, eligibility, exact floor UVs,
original source closure, full-height footprint fitting and coplanar ownership.
The native census records every one of the2400 city cells and checks the grid
before/after. Source pixels and scene owner counts are independently audited.
The full Lua suite passes486/0 with58 missing external fixture skips; native
LuaJIT compile and exact-package checks are recorded in the release report.

This release fixes the reviewed Rustboro city fence families across RSE. It does
not certify complete scenery coverage across all games. The next rural fence
variants and other source-model batches remain active separately. Linux
captures are not physical Android/mobile gameplay certification.
