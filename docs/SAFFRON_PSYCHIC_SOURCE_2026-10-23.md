# HGSS Mr Psychic source — 2026-10-23

Authentic southeast Saffron `ybc_h01-mesh` now occupies only Mr Psychic's native
city `(46,17)` and connection `(36,10)` drawings. Its original shorter golden
barrel roof, yellow walls/green plinth, window, rooftop fixtures and separately
instanced `ybc_dor1_001-mesh` panel are retained. Copycat and generic nonenterable
houses remain distinct. Native4×5 footprint, permissions, support and portals
are unchanged; source uniformly fills about62.82 of64px native width.

Source is the verified newest regional
[Saffron City asset592877](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/),
Kuramapika1,2026-09-01, original Nintendo/Creatures/GAME FREAK art. Archive
SHA256`f7597b3bc790147e55b98b7fcef935e6dae731479d3e26083caaf3e919c9fe1a`,
DAE SHA256`789316266c83cc38c036cd4000da572e4c8127cad886c4485571d5549f0b3966`.
Source scene places house`(192,-280,30.99999)`, panel`(194,-289.4512,30.36132)`;
common Y-up local offset`(2,-.638672,9.4512)` preserves original floorY2.
182 original physical triangles/UVs and four PNG streams remain byte-faithful;
four source shadows are excluded. Measured rear siding/plinth, inset gable,
original detailed barrel rear end, three-segment roof underside and recessed
foundation close the body. Original panel missing left/back/top/bottom returns
close from its measured bounds/plain side paint. Final226 triangles include
body210/door16. No flat underside crosses the window/roof line.

Native frame0/1/2 drives authored inward0/42.5/85° source-panel poses, not an
extracted HGSS track. Original UV/height/placement persist; all physical source
triangles and panel poses remain on original blocked body cells. The85° pose
avoids coplanarity with the jamb and fits the actual interior rear. Source door
parts occur only in their animated batches, with atomic upload/fallback cleanup.
`groundInset=.05` recesses only the contact ring. Native floors/door anchors stay
fixed. Native yellow paving under/around the building remains original.

Latest official engine0.3.96 rechecked. Same verified official Linux source and
LÖVE11.5 shell as the adjacent Copycat batch; isolated FR/LG cache140 QA profiles,
disposable new-game fixture/native hide flag0x3e only, no player save or story
progression claim. Both editions: city portal `(47,21)` enters and returns from
`FR_SAFFRON_CITY_MR_PSYCHICS_HOUSE`; connection `(37,14)` remains collision7/no warp.
Four placements inspected, two real entry-return pairs/two explicit nonenterable
projections. Native full-map hashes match Copycat's recorded city/connection
hashes exactly. Original2D, native front/quarter/side/rear/first-person/contact,
source closed-shell/underside and panel frames0..2 were inspected. LG missing-PNG
fallback passes both placements and the real entry-return, with native rebuilt
building inspected. Captures/logs remain scratch in `psychic-*` directories.

Focused native-guard/triangle/closure/pose/UV/atomic-failure tests, neighboring
Copycat tests and dispatcher checks pass; all592 production Lua files compile
under LuaJIT2.1; six converter outputs are byte-identical on repeat. No production
Scene edits. Dispatcher kind`saffronPsychic` handles build/draw/release/ownsDoor;
markers`importedSaffronPsychic`/`importedSaffronPsychicDoors`. Exact package/phone
verification remains release-owner work.

Canonical per edition:426 maps/76 outdoors,133 assemblies/55 families,79 eligible,
72 rendered accepted,54 unmatched,6324 unclassified blocked cells. Older accepted
evidence retains its own runtime. Seven other shared-ground gaps remain. The
adjacent native sign `(49,22)`, MID2, separately selects ground1 with proof
`unreviewed prop family`, producing grass where the original2D shows yellow
street; this preexisting shared prop-ground gap is outside building ownership
and was reported to the parent. These are building-only acceptances, never whole
map/game completion. Scenery work pauses at this clean batch for the user's
seven-mod current-engine API audit.
