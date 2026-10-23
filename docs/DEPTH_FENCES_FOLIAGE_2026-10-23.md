# Building contact depth, Hoenn fences and foliage — 2026-10-23

Building adapters explicitly opt into a0.05-world-unit contact inset. Only
sourceY0 vertices move below the native ground; shared positional seams remain
closed. Source tops, UVs, door anchors, native collision and warps stay fixed.
Generic/third-party registrations retain their original geometry unless their
adapter opts in. Prototype and batch keys include the inset. Reviewed adapters:
Hoenn/Kanto Centers, Route104 house/shop, Dewford/Lavaridge houses, Viridian
houses and Pewter Museum. Existing Pallet buildings already bury their footing.

Authentic ORAS rural rails and Rustboro ornate railings now replace21 native
metatile families. Original lattice openings and closed geometry are retained.
Clean ground donors are checked against original source quadrants across RSE;
separate edition-specific leaf masks preserve border foliage. Includes196
reviewed native fence cells in Emerald and195 each in Ruby/Sapphire. FRLG's
unrelated roof149 is excluded by the classified native-fence ownership guard.
Any model/texture/upload failure retains the complete native drawing.

The genuine ORAS evergreen's cyan canopy is harmonized with Hoenn broadleaf
foliage using explicit vertex paint. Original source PNGs, UVs, alpha, trunk and
geometry stay unchanged. Separate model identities preserve Kanto's palette
when switching regions; resource failure keeps the original source tree.

Verification: official Gen1Recomp0.3.95 Linux/LÖVE/OpenGL, isolated profiles for
all five games, native hashes unchanged, zero renderer recovery. Inspected
front/first-person/rotated Center and Pallet contact views, Oak interior
regression and Rustboro border fence views; Ruby/Sapphire source masks separately
verified. Some exploratory Briney/Dewford first-person camera fixtures were
poorly positioned and are not visual acceptance for those locations. Earlier
full fence fixtures also inspect Route104/Petalburg Woods, Rustboro sides/rear
and missing-texture fallback. Tests cover source closure, source-ground hashes,
portal stability, cache separation and regional palette isolation. Raw ROMs,
source archives, native pixels and QA captures remain outside the package.

This batch does not assert complete coverage of every building, map or interior.
The canonical all-map census and queued source families continue separately.
