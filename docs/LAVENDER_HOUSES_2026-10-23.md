# Lavender ordinary houses — 2026-10-23

Two original native FR/LG Lavender drawings at(8,8) and(3,13) now use the matching
HGSS ordinary house `si_h01-mesh`, from the September1,2026 Lavender Town asset
[592838](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592838/)
by Kuramapika1 (original art: Nintendo / Creatures / GAME FREAK). The original
purple/gold facade, inset window, flat roof and separate `si_door1-mesh` are
retained. The door's relative offset was measured from the corresponding source scene
transforms. Source SHA256/texture hashes are beside the textures.

The source has117 triangles including16 lighting/shadow triangles. Those16 are
excluded; measured rear wall, rear roof fascia, flat soffit and closed underside
add16 physical triangles, leaving117 processed triangles (109 static,8 original
door). Rear siding continues the original purple side-wall paint; it invents no
rear windows or doors. The contact closure joins the original low outline at its
actual vertex heights. `groundInset=.05` recesses only contact-ring vertices;
native floor, door and upper geometry retain their datum.

The original left-handle door follows an authored inward rotation around its
right rear edge (0°,−45°,−90°) driven by original FR/LG animation frames. This is
an adaptation of the original panel, not an extracted HGSS animation track.
Uniform source fitting stays inside the exact native80×48 blocked body, with
native doorway X40. No source part is flattened or stretched. Exact drawing,
permissions, ownership, level and pair checks precede source uploads. Missing
images/late upload failure retain the complete native family.

`Gen3ModernKantoBuildings` adds `lavenderHouses` with the existing dispatcher
contract. No production Scene edit is included. Its ordinary build/draw/release
and original-door ownership hooks remain standalone and optional.

Latest official engine checked before this batch: v0.3.95, official Linux
LÖVE11.5 shell, isolated FR/LG QA profiles and Mesa llvmpipe. Both editions passed
both real native entrances and returns (Volunteer Pokémon House and House1),
with unchanged map layout hashes. Source and processed seven-direction views,
native drawing, modern/front/left/right/rear, native door states and ground
contacts were inspected. Contact/closure joins show no coplanar striping.
FireRed with all source PNGs deliberately absent also passed both entrances and
returns using the complete native model. The shell exits1 after driver success;
explicit PASS/results records establish these checks.

Reproduce with `tools/qa/frlg-imported-exterior-review.lua`, `QA_FAMILY=lavender`,
an external `QA_UTIL`, a disposable `*-qa` identity and `SHOT_DIR`.
`QA_MISSING_ASSETS=1` exercises native fallback. Test-only map loads select the
fixtures; this is not a claim about normal story progression. Three focused Lua
suites cover exact eligibility, blocked fit, original door frames/resource
failure and dispatcher routing. Regeneration is byte-for-byte deterministic.
Raw archives, saves, native art and captures remain outside tracked files.

Canonical inventory remains426 maps/76 outdoors/132 recognized assemblies each
edition, now28 source-eligible,10 inspected and104 unmatched. Ten of54 recognized
families have at least one eligible source; the Gym family remains partial.
A third native Lavender house at(8,13) has a distinct Name Rater header
`648,641,642,643,652` not recognized by the old civic recipe. It remains an
explicit discovery/source gap for the next batch, alongside the Tower and Mart.
The census does not prove there are no further assemblies in unclassified cells.
