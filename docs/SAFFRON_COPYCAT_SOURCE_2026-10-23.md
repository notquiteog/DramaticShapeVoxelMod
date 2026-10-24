# HGSS Saffron Copycat landmark — 2026-10-23

The authentic `ybc_mmc-mesh` Copycat house now fits the original FR/LG
Copycat footprint at `FR_SAFFRON_CITY (21,10)` and the nonenterable connection
projection `(11,3)`. Its pink facade, recessed windows, four rooftop fixtures,
barrel profile and original interior remain intact. The identically drawn
Mr. Psychic house is explicitly excluded; its matching source is separate work.

## Source and closure

Newest verified source: [Saffron City, asset592877](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/),
Kuramapika1, submitted2026-09-01; original Nintendo/Creatures/GAME FREAK art.
Archive SHA256`f7597b3bc790147e55b98b7fcef935e6dae731479d3e26083caaf3e919c9fe1a`,
DAE SHA256`789316266c83cc38c036cd4000da572e4c8127cad886c4485571d5549f0b3966`.
Archive remains outside source. Original329 triangles include the separately
instanced8-triangle door and4 shadow triangles; all325 physical source triangles,
UVs and five PNG byte streams are retained. Four shadow triangles are excluded;
measured closure gives371 triangles total, body355/closed door16.

Missing rear siding/plinth continues the original two side-wall UV bands.
The detailed original front barrel end is copied to its actual rear cut with
reversed winding. An inset inner gable closes the remaining gap. The roof
underside follows its measured three-segment barrel profile; a flat lower
ceiling would visibly cross upper windows and is rejected by a regression test.
Foundation underside/skirt closes just beneath original Y2, with explicit
`groundInset=.05` on the contact ring. Building, original ground and portal
stay at their native datums; no source shading is baked into the new geometry.

The source scene matrices prove the genuine `ybc_dor1-mesh` belongs to Copycat:
body position`(-224,104,30.99999)`, panel`(-222,94.54883,30.36132)`, converted to
common Y-up local offset`(2,-.638672,9.45117)`. Its original front/right faces
are unchanged; missing left/back/top/underside close from measured panel bounds
and plain original side paint. Door parts are absent from static body batches.
Native FR/LG frames0/1/2 drive authored inward0°/42.5°/85° poses about its actual
right/front hinge. The open panel stays within the original interior rear and
blocked body, and avoids becoming coplanar with the right jamb at90°. This is an
authored placement animation, not an extracted HGSS animation track. Source
panel/height/UVs stay intact; no native card is layered over it.

## Exact native acceptance

Complete native4×5 drawing, map identity, translated region origin, original
permissions and body support are mandatory. Full projected source triangles and
all door poses remain within original blocked body cells. Header remains clear.
Uniform fit fills about62.82 of64px native width, without stretching; door anchor
is body-local`(24,59.25)`. City portal `(22,14)` retains native collision113 and
warps to `FR_SAFFRON_CITY_COPYCATS_HOUSE_1F`; connection `(12,7)` remains collision7
and has no warp. Mr. Psychic, partial drawings and altered native data fail closed.

Official latest engine rechecked0.3.96. Verified official source SHA256
`c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b`,
Linux AppImage shell SHA256
`7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3`,
LÖVE11.5, separate FR/LG cache140 QA profiles. Disposable new-game fixture sets
native hide flag0x3e, hiding the original front-door youngster through normal
native flag handling; no player save is written. This checks the cleared approach
and real warp, without claiming ordinary story progression. Native map data,
actors, collision, scripts and warp tables are unchanged.

Both editions: two source placements reviewed, one real city entry/return pair
and one explicitly nonenterable projection. Original2D, source shell front/side/
rear/quarter/underside, native overview, front/quarter/sides/rear/first-person,
ground contact, panel frames0/1/2 and interior/return captures inspected. Shared
native yellow paving remains original under and around this recipe. No source
floor/ground overlap or exposed join flicker was observed in these captures.
LG missing-PNG fallback covers both placements and the real entry/return; its
native rebuilt building was inspected. No combined-package or phone claim.

Both editions retain native full-map SHA256:

- City:`c04f98e91c3445778d425fb1cdc1097651b99a0e1ebabb9b7552540650134371`.
- Connection:`4a0165cd3cffe945a45a285ae41949b75f0ac90b0fb881370b17a33b61d4a5fe`.

Evidence scratch directories: `copycat-native-firered`, `copycat-closed-renders`,
`copycat-source-doors-{firered,leafgreen}`, `copycat-fallback-leafgreen`,
`copycat-ledger-{firered,leafgreen}`. Reproduce with
`QA_FAMILY=copycat tools/qa/frlg-imported-exterior-review.lua`, external `QA_UTIL`
and an isolated native launcher/profile. Render distance16, day, no companions;
level3 overview and level6 first-person, pitch8°, front/quarter/side/rear yaw.
Scratch archives/caches/captures are excluded. Tests close; player saves untouched.

Focused LuaJIT checks pass: exact native landmark/variant/footprint guards,
substantial fit, source closure and pose bounds, source UV/height preservation,
noncoplanar open hinge, missing-image/partial-GPU/body-failure cleanup, dispatcher
routing and neighboring Saffron blocks. All589 production Lua files compile
under LuaJIT2.1; seven importer outputs are byte-for-byte deterministic.

## Coverage and hook contract

Per edition:426 maps/76 outdoors,133 assemblies/55 families,77 modern eligible,
70 rendered accepted,56 unmatched,6324 unclassified blocked cells. Copycat adds
two eligible and accepted placements per edition. Existing older reviews retain
their own explicit runtime; no whole-game completion claim. Seven other shared
native-ground gaps and the unmatched families remain listed in canonical JSONL.

Standalone dispatcher kind:`saffronCopycat`, marker:`g.importedSaffronCopycat`;
source panel cache:`g.importedSaffronCopycatDoors`. Route build/draw/release and
ownsDoor through `Gen3ModernKantoBuildings`; production Scene remains owned by
the release integrator. Static batches retain normal caller ownership. This
batch edits no production Scene or existing native building recipe.
