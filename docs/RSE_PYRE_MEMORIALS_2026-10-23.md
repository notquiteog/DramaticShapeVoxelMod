# RSE Mt. Pyre memorial coverage

This batch adds the original ORAS memorial to all 793 complete native graves
on Mt. Pyre 1F–6F: 261 Emerald, 266 Ruby and 266 Sapphire. The original
source and disjoint closure geometry are documented in
[the source audit](ORAS_PYRE_MEMORIAL_2026-10-23.md). No model geometry or
texture changes were needed for this adapter batch.

| Native art | Emerald | Ruby | Sapphire | Underlay |
| --- | ---: | ---: | ---: | --- |
| 0x2ee common grave | 195 | 200 | 200 | 0x2e6 native floor |
| 0x326 wall-shadow grave | 66 | 66 | 66 | 0x2e7 native shadow floor |

The three native atlas drawings were inspected and are byte-identical.
Matching requires the RSE edition, `general__facility`, primary `general`,
the exact blocked collision-7 tile and uniform native height. Source eligibility
additionally requires the exact Mt. Pyre floor map name after region binding.
The floor underlay keeps the original common/shadow distinction. No walkable
collision-43 floor, native stair, item, NPC or opening is claimed.

The original source proportions fit one blocked 16×16 native cell at height17.
Only exact source Y0 vertices receive the existing 0.025-pixel contact recess;
upper geometry, X/Z bounds and all native floor cells stay unchanged. The same
opt-in recess now applies to all six existing Kanto grave fallback variants
and both RSE native grave drawings. CPU comparisons prove that only their
bottom vertices and matching underside/side edges move, retaining closure.
No depth-bias workaround is introduced.

Official latest 0.3.95 was checked before the native batch. Isolated profiles
rendered all 18 floors with every common and shadow memorial. All 793 individual
first-person contact-sheet entries and 18 final room overviews were inspected.
Views use actual native collision-43 walking cells. Thirteen entries per
edition have an obstructed direct line of sight; the ledger records
`firstPersonNativeObjectOcclusion: true` for those entries. Native NPCs and
dialogue overlays remain visible. This is component acceptance, not a claim
of an unobstructed view of every triangle or keyboard-driven floor traversal.

Missing-PNG runs passed all six Emerald floors and all six FireRed Pokémon
Tower floors; representative native fallback captures were inspected. Drivers
emitted PASS; the Linux shell returned 1 at shutdown. Eleven focused suites
pass, including exact edition/art isolation, fallback contacts, source bounds,
source closure and zero positive-area coplanar intersections in all twelve
imported furniture models.

The full five-edition census retains all 2161 native hashes and all earlier
furniture-family counts. The only additions are these 793 owners on 18 maps.
There are now 1979 source-placement candidates and 1934 accepted components
across 258 maps. Complete-map acceptance stays false. Mt. Pyre's existing
rectangular generic room shell does not follow its irregular native floor
boundary; flat native wallpaper/opening work remains outstanding. Raw native
pixels, source archives, profiles and captures stay outside the repository.
