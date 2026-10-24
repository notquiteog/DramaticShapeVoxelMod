# Original Rustboro Flat1 and southern home

Rear-review correction: original source backs were open; previous rear views
showed front/interior backfaces. Rear acceptance is superseded by the explicit
[rear closure correction](ORAS_REAR_CLOSURES_2026-10-23.md). Existing source
identity, native door, footprint and contact-ring results remain valid.

Two more actual town sources extend the existing Rustboro dispatcher. Original
ZO16 portal records and GR object instances bind Flat1 to BM13 at(2205,3537),
destinationZO297, and southern House3 at(2529,3987), destinationZO294. Their own
static bodies are GR33 around(−315,297) and GR38 around(9,27), respectively.
Nitrogen independently checks every original position, UV and triangle before
processing. The original four accepted source arrays and BM13 poses compare
exactly unchanged against the preceding committed data.

Flat1 retains1586 original physical triangles, including40 original trim faces
at opacity0.6. Thirty-six original window-return triangles overlap column side
faces on the three storeys. Only those returns narrow to their exposed Z6.5–7
strips with interpolated source UVs. The physical triangle count stays unchanged;
a projected-area coplanar audit finds zero remaining static overlap pairs.
House3 retains614 original physical triangles and needs no such cleanup.

Original22/16 bottom-rim points close Flat1/House3 with20/14 triangles using the
source bottom-wall texel. Both bodies have zero original horizontal base ground
faces. Only Y0 contact vertices/closures recess0.05 native units. BM13 keeps its
original150 physical panel/glass triangles and three original hinge samples;
its previously reviewed top-contact inset also prevents lintel overlap here.
Native floors, upper geometry, source proportions, portals, collision and warps
remain fixed. No source terrain/fence/ground meshes are copied.

Exact native candidates are Flat1 at(9,25),9×6 cells with door(13,30), and House3
at(24,42),6×5 with door(26,46). Uniform blocked-body fits occupy approximately
142×79 of144×80 and80×63 of96×64. Exact edition/map, art rows, permissions,
owner, region and level guards validate both. Every physical triangle and every
source door state passes native blocked-footprint checks. The facade handles
the two original doorway row offsets through the same atomic transaction.

The latest official release was rechecked before verification:
[Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell ran isolated R/S/E profiles. All18 native source
uploads/hinges/cap depth/opacity/rollback checks pass across the six Rustboro
families. Source front/sides/rear/top/underside renders were inspected.
The parent f24ff378 Scene (blob09e0b2aee1fdd34f692f69e05e18a9644d40fede) with
this source/facade override passes18 actual native entries and returns, exact
destinations, unchanged native map hashes and zero streaming recovery failures.
Emerald missing-source mode passes all six native fallback entries/returns.
Native source/front/first/side/rear/open/returned captures were inspected for the
two new variants; visible wall/door-floor contacts are clean.

A live controller initially entered the background Xvfb process, causing
unrequested movement even in native2D. Those failed exploratory transition runs
are not acceptance. The successful complete rerun disables the joystick module
only in the isolated QA engine's standard LÖVE config; keyboard-driver actions
still use native movement and warp APIs. The driver now rejects attached
controllers, checks exact destination/player coordinates, waits for native
warp/script readiness, and chooses camera cells with collision0. Cutters' left
side has no walkable viewpoint because of native barriers; that view is skipped
and reported, with original-source views supplying the geometry inspection.
Some other views retain normal scenery occlusion. Physical-controller gameplay
is not established by these automated tests.

Modern-source candidate totals are39 Emerald,38 Ruby and38 Sapphire:115 of244
recognized civic placements. The571-map census remains eligibility metadata,
not whole-map acceptance. Three Rustboro families remain: Devon, the nonenterable
tower and Flat2. Flat2 is located at original GR37/ZO292, but its centered-door
ORAS model fitted to the native off-centre doorway occupies only79.62×62.94 of
the112×128 blocked drawing (35% area). It remains native fallback pending fit
review; neither source stretching nor native collision changes are introduced.
