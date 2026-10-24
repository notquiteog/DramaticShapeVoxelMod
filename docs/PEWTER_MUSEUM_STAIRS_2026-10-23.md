# Pewter Museum solid approach correction — 2026-10-23

FireRed/LeafGreen `FR_PEWTER_CITY`, Museum origin `(12,0)`, main portal
`(17,6)`, staff portal `(25,4)`. The native approach is `(16..18,7)`,
MIDs `0x2ba/0x2bb/0x2bc`, ordinary behavior0/collision0/elevation3. Its
upper eight artwork pixels contain the arch base, and its lower eight contain
the original stone stair bands. The old renderer placed that whole row flat,
leaving duplicate facade artwork beneath the authentic HGSS Museum.

The earlier generic-terrace diagnosis was incomplete: these Museum cells do
**not** enter the semantic `shape.kind='steps'` branch. The focused fix claims
only the exact complete three-cell approach beneath the complete native Museum
civic drawing. `Gen3Stairs.prepare/append` already have production Scene hooks;
no Scene edit or queued source-adapter change is needed.

The approach now has two real tread/riser levels, closed outer cheeks and back,
and a landing meeting the existing source threshold. The fitted source door
anchor is `.003962818 * 255.5 = 1.0125` native pixels above support; step heights
are `.50625` and `1.0125`. The landing reaches source frontZ110, two pixels
north of approach rowZ112, within the original Museum footprint. Plain stone
paint comes only from native center-stair MID`0x2bb` at lower-band pixels
`(8,9.5)`, `(8,10.5)`, `(8,11.5)`; no facade pixels are projected on treads.
Native floor support stays0 at portal/approach/street. Building fit, source PNGs,
anchors, camera/actor support, native collision and warps are unchanged.

The generic semantic terrace branch also now emits its exposed union rather
than adjacent boxes and additional top faces: one top per band, outer cheeks,
and only visible riser segments. Original rise, direction and UV strip mapping
are retained, with no internal half-box walls or buried cap duplicates.

## Verification

Latest official engine rechecked as0.3.96, official source SHA256
`c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b`,
Linux official AppImage shell SHA256
`7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3`,
LÖVE11.5. Isolated FR/LG cache140 profiles and new-game fixtures; no companion.
Battle Art native field integration level3 overview and level6 first-person,
yaw0/rotated±30°/sides, pitch8°, day, render distance16. Rear camera beyond the
native north boundary is explicitly skipped; existing source rear/underside
review remains separately documented.

Before: scratch `museum-current-{firered,leafgreen}/1-front.png` shows arch
artwork on the approach. After: scratch
`museum-stairs-solid-{firered,leafgreen}/1-modern.png`, `1-front.png`,
`1-rotated.png`, `1-left.png`, `1-right.png`, `2-front.png`, both `*-returned.png`.
Inspected front, rotated and first-person captures show the two shallow solid
steps, clean building contact and continuous flat walls. Native lower-stair
paint and original 2D comparison were inspected separately. Both actual main
and staff entrance/return pairs pass each edition, including interior captures
and unchanged complete native map SHA256:
`6d5257d9c36f01ec29c51b70c740f85e58966e947cb3680f5bce1a93e7f45b9f`.
No ticket/story progression claim; this is native warp testing from a disposable
new-game fixture. Test processes close; player progress is untouched.

Reproduction driver: `tools/qa/pewter-museum-stairs-review.lua`; use existing
isolated runtime launcher with `QA_UTIL`, `SHOT_DIR`, and a disposable `*-qa`
identity. It records exact runtime/source/hash and both real portal roundtrips.
`QA_MISSING_ASSETS=1` exercises source fallback. Scratch capture/log/cache files
are not committed. Production ZIP acceptance remains the release owner's task.

Focused LuaJIT checks pass: `tests/gen3_museum_approach_test.lua` verifies exact
native guards, partial/third-party rejection, measured source threshold,
unchanged support, closed shallow geometry and no positive-area coplanar pairs
for Museum and both semantic terrace directions. `tests/gen3_stairs_test.lua`
passes39 up/34 down source assemblies and ladders. Diff whitespace check passes.
The release owner additionally checks native semantic terraces at
`FR_MT_EMBER_EXTERIOR (17..18,12..14)` (behavior0x2a/MIDs0x91/0x89) and Oak's Lab
on the exact ZIP; this document does not pre-claim those package results.
