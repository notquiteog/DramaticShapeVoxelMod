# Pallet contact datum — 2026-10-23

The three HGSS Pallet buildings now use the shared explicit `groundInset=.05`
fit. Only source Y0 contact vertices recess beneath native ground. The previous
whole-building Y−0.05 shim is removed: source upper geometry and door surfaces
use the native ground datum. Original source geometry, UVs, collision and warps
are preserved. The unit check compares every fitted source vertex and verifies
that noncontact geometry remains at its source height and the portal shares the
native datum.

Latest official engine checked before this batch: v0.3.95. An isolated native
0.3.95 engine and official Linux LÖVE11.5 shell ran both editions through all
three original entrances and returns: player's house, rival's house and Oak's
lab. Front/first-person contact captures in both editions show continuous
foundation/lawn junctions without coplanar striping. Native map layout
hashes remained unchanged. The shell exits1 after successful driver completion;
each driver's explicit PASS/results records establish the stated checks.

Reproduce with `tools/qa/frlg-pallet-contact-review.lua`, an external `QA_UTIL`
frame helper, isolated `*-qa` identity and `SHOT_DIR`. Test-only native map loads
select the fixtures; this does not claim ordinary story progression testing.
Raw saves, native art, screenshots and archives remain outside tracked files.

The canonical ledger adds these three inspected placements per edition:26
source-eligible,8 inspected,106 unmatched recognized exterior assemblies in each
edition. This is a source-family inventory of426 native maps each, with remaining
unclassified blocked cells; it is not a claim of complete map or game coverage.
