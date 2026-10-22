# Dewford native doors and sand

The two reviewed native Dewford house drawings now require the genuine ORAS
hinged house door alongside the existing ORAS narrow house. A missing door
resource or failed upload rejects the complete modern replacement, preserving
the native Civic fallback. The idle closed door is always rendered; the engine's
public door animation frames select closed, half-open and open source poses.
Native collision, movement, sound, callbacks and warp timing remain unchanged.

## Source and placement

The user's Alpha Sapphire RomFS supplies `a/0/2/3` BM0034 slots0/1,
`t103_bm_door01`, and `a/0/1/4` AD0010 slot1 texture `muro_door`.
The exporter retains all18 physical triangles, UVs, thickness and source hinge
rotation. Independent Nitrogen inverse-bind comparison differs by at most
4.77e-7. It samples the original six-frame Y-rotation track at0/2.5/5
(0/-40/-80 degrees). The separate untextured24-triangle floor-light effect is
excluded. Source PNG paint is unchanged; source baked vertex tints are recorded
and omitted according to the user's clean-lighting preference. Hashes, source
bounds and processing details are in the selected asset's provenance JSON.

Uniform fit uses the existing model's actual aperture anchors, retains original
proportions, and checks every pose against the native64x48 blocked house body.
The door swings inward and never crosses the native walking apron.

Native source sand is MID124. Both house-body backgrounds216/217 contain this
exact sand quartet. The Center209/20A retains matching native sand at its lower
outer corners. Accordingly both house families, the hall and Center use each
edition's native124 instead of default General001 grass. Seven clean source
header metatiles retain their actual native underlayer when the public split
atlas exists. North-house212/218 contain tree bases and are deliberately
excluded from floor reuse; they must never become flat tree fragments.
Other source-ground policies, including Oldale's original dark lawn, are intact.

## Native verification

Official engine0.3.95, native shell
`/home/admin/Projects/.scratch/runtime-0.3.95/squashfs-root/bin/love`.
Isolated engine/mod/profile snapshots are under
`/home/admin/Projects/.scratch/truck-camera-20261022/`.
No companions or player's saves were used. Environment style was Modern3D,
actors HD2D. The disposable Scene connects the helper as described below.

Driver `dewford-entry.lua` starts a fresh native town fixture, then walks up
through each actual door and down through the actual interior exit. R/S/E all
passed both homes: north(8,8) to HOUSE2 and south(17,14) to HOUSE1. Native
frames0/1/2, entered interior, and returned apron were recorded; 3D stayed active
without nativeRequired or recovery errors. Captures and logs are in
`dewford-entry-{ruby,sapphire,emerald}/`. Closed, half-open, inside and returned
captures were inspected. The rear view is too close to evaluate the whole ground
footprint; raw native underlay tests and top-down captures establish that scope.
These are native rendered driver checks, not interactive keyboard/focus proof.

Eight focused Lua suites passed: Dewford doors/import, Civic ground/geometry,
Center doors, Hoenn families, truck cargo and truck room. The source-proof test
reads all three imported native caches and verifies sand identities, split-layer
headers and tree exclusions. Actual LuaJIT2.1 compiled543 production files with
`loadfile`; the repository's Python compile wrapper could not run because the
system Python lacks Lupa. `git diff --check` passed.

The same combined snapshot also verifies the earlier uniform truck-floor API:
`uniform-floor-emerald/03b-moving-35.png` and `06b-open-35.png` were inspected.
The original plain floor extends beneath all props and closed/open exits;
crate art is no longer projected onto the floor. Native2D retains original art.

## Scene integration seam

`Gen3ImportedDewford.build` atomically prepares `g.importedDewfordDoors`.
For each imported Hoenn building, Scene calls
`Gen3DewfordDoors.draw(g, doors.getActiveAnim(), drawMesh)` in ordinary opaque
and shadow geometry passes, and `.release(g)` when releasing geometry.
When `.ownsDoor(g, x, y)` is true, skip the native door-overlay surface at that
cell. Only the two exact imported Dewford houses qualify. Root owns these Scene
hooks; this commit does not modify Scene or native engine files.

Test processes ended; isolated option/profile copies remain in scratch for
review. No raw ROM, BCH, full archive, native cache or screenshot is committed.
