# Wider One Island Center source placement

The exact FR/LG `SEVII_ONE_ISLAND` Center at(11,0),7×6 body, now uses the
original closed HGSS Kanto Center and its original separate sliding door.
This is an explicit wider native family; standard5×4/5 Centers keep their
existing fit and door coordinates. No sign, extra fixture or source artwork
is invented. Standalone API3 and existing actor/Pokémon/flower HD2D defaults
remain unchanged; no companion asset provider is required.

Original [Viridian source592881](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/),
`pc_011-mesh` plus `p_door_023-mesh`, original game art Nintendo/Creatures/GAME FREAK.
Existing provenance and processed closed source geometry/PNGs are reused without
modification. Archive SHA256
`969737481ce8e8e55887ffdd612f5ff96b8a19e8430f7433078d24ef444b918e`;
source DAE SHA256
`704ce4c6e39d630cbb2e55036ef3755c1ee482cb7156fd3ca4868bb80fb01433`.
Uniform fit112×96, padding.25, door target(56,83), produces approximately
104.48×80.1px original-proportion body within the exact blocked native rectangle.
The source door floor remains approximately.64px above the native datum.
Contact-only.05px recess retains upper geometry, source portal and native floor.
No source baked shadow, additional overlapping plane or whole-building offset
is added. Original closed source rear/soffit/foundation remain intact.

All42 body MIDs, permissions, native map/origin, pair, source triangle clearance
and equal floor guard eligibility. The native left pillar projection MID721 at
(13,6) lies outside the six body rows. Its native collision0/elevation3 remains
walkable. One exact optional `claimOutside` now gives its visible pillar artwork
the same civic owner and uses the existing local lawn16 beneath it. Atomic
validation precedes all claims; unknown MID/pair/collision, another owner,
boundary or staged-hidden cell refuses the recipe. Width/depth/rows, foundation
sample and neighboring sign/grass owners remain unchanged. The source and native
fallback both use this ownership; no extra seventh body row or collision edit.

Latest official engine query:0.3.96. Engine SHA256
`c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b`;
official Linux LÖVE11.5 shell AppImage SHA256
`7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3`.
Both isolated FR/LG profiles pass with native process0: source placement,
original sliding states0/1/2, actual main entry and return, then a real left
step from(14,6) onto original walkable pillar cell(13,6). The QA fixture sets
native variable0x4076 to3 to represent the completed mandatory Bill arrival
intro before loading this map; production scripts are untouched. Both full
native map SHA256 remain
`fd4122f75cb5f78514405f9f257b14f5d9cb873f032f5fc2dca2a6b621a629fe`.
LeafGreen missing-source fallback passes the same entry/return and projection
walk. Standard Pewter Center actual entry/return passes in both editions after
the shared door helper extension. Native grid, elevation, warps and collision
remain unchanged throughout.

Inspected native/modern overview, close front and quarter, source opening states,
entry/return and walked projection views show continuous grass, source door and
column contact without the former flat pillar glyph or an observed gap/z-fighting.
Native trees occlude much of both side views, and the northern map boundary
restricts rear first-person views. These are explicitly occluded views; the
existing isolated closed-source gallery provides rear/underside geometry proof.
No full-map or remaining-family acceptance is inferred from them.

Eighteen focused source, geometry, door, civic ownership, ground, dispatcher,
neighbor and shared mesh suites pass; changed Lua files compile. The additional
outside ownership refusal cases include wrong art/permission, absent cell,
existing owner, boundary and staged-hidden ownership, with no partial claim.
Fresh identifier-only native census passes all426 maps per edition with process0.
Canonical per-edition counts:136 assemblies,82 source eligible,75 rendered
accepted,54 unmatched,6232 unclassified blocked cells. Seven eligible shared-
ground review gaps remain separate. Source eligibility is not visual acceptance.

Scratch evidence, excluded from Git: `.scratch/frlg-exteriors/api3-resume/out/`
`one_island_center-{firered,leafgreen}`, `one_island_center-leafgreen-missing`,
`center_regression-{firered,leafgreen}`, `one-island-ledger-{firered,leafgreen}`;
before reference `one-island-before-firered`. Driver:
`tools/qa/frlg-imported-exterior-review.lua`, family `one_island_center`.
No raw source archives, ROMs, native caches, profiles or captures are committed.
