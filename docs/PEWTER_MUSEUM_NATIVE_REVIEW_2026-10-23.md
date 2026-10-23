# Pewter Museum native source review — 2026-10-23

The genuine HGSS Museum is now source eligible and rendered accepted on official0.3.96 FR/LG after focused staircase correction `e9fdfe43`. Main and staff native entry/return checks pass. Exact source geometry, PNGs and portal anchors remain unchanged; the original footprint guard belongs to the queued regional batch. See [solid approach correction](PEWTER_MUSEUM_STAIRS_2026-10-23.md).

## Current-engine evidence

The latest official release changed to v0.3.96 before this batch. Official source bundle SHA256 `c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b` and Linux AppImage SHA256 `7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3` match its release checksum file. Source ZIP CRC/path checks pass; shell reports LÖVE11.5. New isolated profiles reimport the user's existing local FR/LG ROMs through public `POKEPORT_IMPORT_ROM`, producing required native cache140. Older cache139 was correctly rejected; no readiness stamp or engine callback is bypassed. Player saves and normal installation remain untouched.

Actual `FR_PEWTER_CITY` Museum origin(12,0) retains both native portals: main(17,6) and staff(25,4), each to `FR_PEWTER_CITY_MUSEUM_1F`. Both entry/return pairs pass in both editions, then repeat after the new exact triangle guard. Each native full-map hash remains `6d5257d9c36f01ec29c51b70c740f85e58966e947cb3680f5bce1a93e7f45b9f`. LG missing-PNG fallback also passes both real entries/returns; its native fallback image was inspected. No ticket payment, exhibit interaction or ordinary story progression is claimed. Driver PASS records are authoritative; the official shell returns1 on normal shutdown.

Native source overviews, both entrance contacts/animations where native frames exist, left/right views, original2D comparison and neighborhood views were inspected. A rear camera would lie outside the original map's north bound, so the driver skips it explicitly. Independent source front/side/rear/quarter/low/underside views confirm the complete source shell. The source exports no separately instanced Museum door panels; its existing native card surfaces remain at their original authored portal anchors. No unrelated source door is substituted. Characters, Pokémon and flowers retain HD2D.

## Exact blocked footprint

`Gen3ImportedPewterMuseum.clearance` now checks every source triangle against the actual nonrectangular native civic mask, including the walkable wing-header and staff-approach gaps. A temporary read-only lookup rebases the shared clipper's body origin; native cells never change. An adversarial triangle with all three vertices on blocked cells still crosses the wing-header walking gap and is correctly rejected. The original fitting and native portal surfaces stay unchanged, including `groundInset=.05`; source contact-ring vertices recess without moving the building or ground.

Focused LuaJIT checks pass for complete drawing/ownership/permission/base guards, both portals, exact projected-triangle safety, existing measured closure/alpha and missing-image fallback.

## Corrected approach diagnosis and acceptance

The approach is native row7, MIDs0x2ba/0x2bb/0x2bc, behavior0 and flat native support. Earlier row6 MIDs0x2b2/0x2b3/0x2b4 are the arch base already claimed by the civic building. Contrary to the earlier diagnosis, the Museum did not enter the generic semantic stair branch. The whole unclaimed row7 tile projected its upper arch pixels onto the ground. The generic branch independently did have duplicate cap and hidden box faces, now corrected with exposed union surfaces.

Exact Museum approach ownership now supplies two solid shallow steps and a closed landing using original plain lower-band stone paint. Its top meets the existing1.0125px source threshold without moving the building/portal or native floor support. Front, side, rotated and first-person captures were inspected; both actual main/staff entry-return pairs repeat in FR/LG with unchanged native map hashes. Museum is rendered accepted on0.3.96.

The canonical852-map inventory is0.3.96. Existing134 other accepted assemblies retain explicit `renderedRuntime=v0.3.95`, so older visual evidence is not relabeled. Museum `nativeReview` records0.3.96, both returned portals, source/provenance hashes, verified source footprint and corrected solid stair contact. Per-edition totals:426 maps/76 outdoors/133 assemblies/55 families,75 source eligible/**68 rendered accepted**/58 unmatched/6324 unclassified blocked cells. Seven other shared-ground gaps remain. Physical phones, production Scene and combined package verification remain separate release-owner work; no whole-game coverage is claimed.
