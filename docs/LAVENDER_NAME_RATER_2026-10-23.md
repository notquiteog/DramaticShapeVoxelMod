# Lavender Name Rater — 2026-10-23

The native Name Rater house at(8,13) has a distinct roof header
`648,641,642,643,652`, previously missed by the ordinary-house recipe. That exact
signature is now a separate civic family, with the original permissions, native
ground, dimensions, collision and doorway. Both editions resolve it independently.

Its actual modern source is the HGSS Name Rater tent `ko_seimei-mesh` in
[Lavender Town asset592838](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592838/),
submitted September1,2026 by Kuramapika1 (original art: Nintendo / Creatures /
GAME FREAK). Source curtains, window recesses, stepped conical roof, golden finial
and threshold remain original. All PNG bytes remain unchanged. The original
entrance is already open: `Gen3LavenderTentEntrance` suppresses the unrelated
native wooden-panel overlay while native warp scripts and timing continue.
No hinged door or curtain animation is invented.

The original134 triangles include16 lighting/shadow triangles. Excluding those
and adding26 measured closure triangles yields144 physical triangles. The rear
cloth follows the original three-height side profile and asymmetric rear edges;
rear roof bands follow the measured stepped silhouette and source paint. The
upper rear roof terminates on the existing ridge's rear boundary, avoiding a
second surface over that original narrow ridge. Rear eave return and underside
close the cut mesh. The underside is physically separate from the original
threshold; `groundInset=.05` recesses only its Y0 contact ring. Source upper
geometry and native floor/door datum stay fixed.

Uniform fitting occupies79.37px of the original80px blocked width and remains
inside the48px body depth. No source silhouette is flattened or stretched.
Exact native header/body/permission/ownership/base/pair guards gate the source.
The dispatcher adds `lavenderNameRater`; no production Scene edit is included.

Latest official engine checked before this batch: v0.3.95. The official Linux
LÖVE11.5 shell and isolated FR/LG profiles passed real entry into native HOUSE2
and return, with unchanged map-layout SHA256. Both source and closed models were
inspected in seven directions. Native modern/front/right/rear contacts, source
entrance frames and a clean rear quarter view were inspected; no coplanar
striping is visible. A neighboring ordinary house obstructs the default left
view, so the durable driver uses a front-left quarter position for this family.
LeafGreen with all tent source PNGs absent passed native model entry and return.
The shell exits1 after successful drivers; explicit PASS/results establish these
checks. Civic discovery/ground suites, exact source/fallback/entrance unit checks,
dispatcher checks and byte-for-byte deterministic regeneration pass.

A same-camera native comparison with Shadows OFF confirms that the scallop-shaped
dark patch on the side cloth disappears. It is a live cast shadow from the real
fringe, not a fixed source-texture shadow. No paint remap was applied.

Reproduce with `tools/qa/frlg-imported-exterior-review.lua`,
`QA_FAMILY=name_rater`, external `QA_UTIL`, isolated `*-qa` identity and
`SHOT_DIR`; `QA_MISSING_ASSETS=1` checks native fallback. Native map loads only
select QA fixtures; this is not normal story progression acceptance. No native
pixels, raw archives, saves or captures are tracked.

The canonical census now recognizes133 assemblies/55 families in426 maps per
edition:29 source-eligible,11 inspected,104 unmatched recognized assemblies,
6332 unclassified blocked outdoor cells. Those cells also include terrain and
boundaries. New discovery increases the assembly denominator; no whole-map or
whole-game completion percentage is inferred. Lavender's three ordinary/Name
Rater houses now have matching sources; its Tower and Mart remain source gaps,
and its eligible Center still needs separate per-map rendered acceptance.
