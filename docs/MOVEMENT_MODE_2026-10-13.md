# Shared movement preference

`3D MOVE` in WORLD defaults to `GRID`. First-person and rotating third-person
input remains camera-relative, but native tile steps own movement. `FREE`
enables continuous fractional steering in those views. Static camera views
retain native movement. Switching back to GRID returns the owned position to
its logical cell; scripts and relocations retain their own positions.

Gen1 reuses its existing continuous solver and now reads native step duration,
including running-shoes hooks. Gen2/3 validate movement through native public
collision and movement entry points, then let the real native completion chain
perform each cell arrival. Ledges, forced movement, bikes and other special
transactions retain native timing. Menu and dialogue gates remain native.

Official runtime: Gen1Recomp 0.3.85, isolated QA profiles. Yellow's Viridian
fixture at (18,24) passes native GRID stepping, diagonal fractional FREE input,
release, and GRID handback. Captures inspected at
`.scratch/streaming-20261013/yellow-movement-city`.

Unit checks cover default selection, scoped input restoration (including
errors), analog/diagonal movement, wall sliding, arrival counts, relocation,
mode handback and special-move ownership. Native Gen2/3 runtime evidence is
recorded alongside the adapter implementation. These are bounded fixtures,
not exhaustive route, script or companion-combination certification.
