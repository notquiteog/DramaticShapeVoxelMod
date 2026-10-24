# Exact Kanto civic floors and source-door integration hold

The subsequent production dispatcher integration resolves the19 door holds
documented at this checkpoint. Current counts are82 eligible/82 accepted per
edition; see KANTO_SOURCE_DOOR_DISPATCH_2026-10-23.md for final production proof.

Four complete original drawings now select their own source-proven native
underlay instead of nearest unrelated terrain: Cerulean Gym uses lawn1; Saffron
Dojo, Center and Mart use native paving0x2E5. These cover seven assemblies per
edition: Cerulean(28,17); Saffron City Dojo(37,8),Center(22,34),Mart(38,18);
connection projection Dojo(27,1),Center(12,27),Mart(28,11).

The rule lives in Gen3Civic and requires the canonical native tileset pair,
kind, complete dimensions, every original MID and the same uninterrupted civic
owner, without prop/boundary/hidden ownership. Native Civic preparation precedes
region assignment; the floor identity follows that complete original drawing
rather than relying on unavailable map labels. Other pairs and changed drawings
keep the old fallback. Source placement/anchors, mesh/contact ownership, body,
source closures, ground height and every native grid/collision/warp remain
unchanged. No extra floor mesh or whole-building translation is introduced.
Existing explicit third-party floor recipes still retain their own priority.

Read-only proofs inspect actual imported FR and LG atlases, independently
resolving each edition's secondary-tileset addresses. Original Cerulean lower
Gym corners expose native lawn13; roof-header under layer is lawn13 with actual
roof art retained separately above it. Donor1 is clean lawn8/13/14; nearby roads
212/228 use distinct indices. Saffron's exact service lower corners retain
five-pixel paving margins matching donor0x2E5 at identical coordinates; both
Dojo lower corners retain its entire bottom paving row. Donor0x2E5 contains only
166..171 and no upper art. Service roof/header and foundation MIDs contain real
building artwork and are not flattened as clean floor donors. Tests preserve
all native indices/permissions/elevation/shape objects and cover complete-body
identity, other pairs, hidden/boundary cells and hostile nearby donors.

Latest official runtime checked:0.3.96, isolated standalone API3, official Linux
LÖVE11.5, same engine/shell hashes as ONE_ISLAND_CENTER_SOURCE_2026-10-23.md.
Both editions pass process0 for all seven current-production placements:
front/quarter/side/rear/overview views, four actual City entrances/returns and
three native connection projections with no invented warp. Inspectable front,
quarter and near ground contacts show continuous native paving/lawn without
observed contact gaps/flicker. Neighboring walls occlude some side views;
rear views close to those walls are recorded as occluded, not new geometry proof.
Original source all-side/underside proof remains in the separate model documents.
Shared-floor fallbacks pass source masking at both Dojos, both Marts, both
Centers and Cerulean Gym across the paired editions. Unrelated Pallet houses
and Oak's Lab actual entry/interior/return pass on LeafGreen.

Native SHA256 remains identical in both editions:
- Cerulean City: `aed68bfe91dac11cfe83f774c4a1048c33c483783bd500950ba0cab393aa2219`.
- Saffron City: `c04f98e91c3445778d425fb1cdc1097651b99a0e1ebabb9b7552540650134371`.
- Saffron connection: `4a0165cd3cffe945a45a285ae41949b75f0ac90b0fb881370b17a33b61d4a5fe`.

The review exposed a separate current Scene integration defect: its stale direct
build paths for standard Kanto Centers and plain Viridian houses bypass the
already-registered modern dispatcher. Their body adapters exclude source doors,
while their original leaf draw/release/ownsDoor calls exist through that
dispatcher. Native gameplay still enters/returns, so an entry pass or positive
source count alone did not detect the visually absent closed leaves.

Production Scene is unchanged in this batch (root owns that file). Its SHA256
is `433080dd2401f809ad9efae5bcbb19fa6d1ac68e6e5c071f15d95a3b4a2c0d82`.
A scratch-only patch removes the two stale direct build branches, leaving
existing dispatcher specs, fallback and all shared Scene policies intact.
Candidate Scene SHA256:
`814cb7754b2445042cb8c71fa0c59126b39b7a143ad5baad43b68dfee0bb3439`.
Both editions' all18 standard Centers pass native process0 with the original
source-door helper asserted to actually reach Scene draw; all36 front/overview
entries are visually inspected. This covers17 actual entry/return portals and
one blocked no-warp projection per edition. Original blue leaves, three source
states and contacts are visible. Both editions' plain Viridian candidates also restore the
original hinged orange leaf and pass real entry/return. These are candidate
integration results and do not establish current production acceptance.

Canonical current counts per edition:426 maps,76 outdoors,136 assemblies,
82 source eligible,63 currently rendered accepted,54 unmatched,6232 unclassified
blocked cells. Five earlier ground-held placements are now accepted. All18
standard Centers and the plain Viridian house are explicitly held (19) for the
known Scene door bypass, superseding older accepted views for current-source
claims. The two Saffron Center grounds are corrected but remain among that hold.
See identifier-only `frlg-exterior-render-holds-2026-10-23.json`. Checked-in current holds automatically supersede older command inputs. Later failed
reviews now invalidate earlier acceptance, with a regression for this exact
stale-proof ordering; a later verified repair can clear a hold. Root must
integrate the Scene patch and replace those negative proofs with verified final
source reviews before clearing the corresponding checked-in hold records. No whole-game completion claim follows.

Nineteen focused Lua suites, both-edition actual native-art proof, chronological
acceptance/refusal regression and changed Lua/Python compile pass. Scratch
captures/logs excluded from Git: `.scratch/frlg-exteriors/api3-resume/out/`
`cerulean_gym-{firered,leafgreen}`, `saffron_{dojo,marts,centers}-{firered,leafgreen}`,
paired `-missing` directories, `ground-oak-regression-leafgreen`,
`civic-ground-ledger-{firered,leafgreen}`, `center-dispatch-{firered,leafgreen}`
and `viridian_plain-*`. Original mismatch references are `ground-before-*`.
Candidate patch: `.scratch/frlg-exteriors/api3-resume/scene-dispatch.patch`.
No raw archives, ROMs, native caches, captures, runtime or player saves are shipped.
