# Pewter Museum native source review — 2026-10-23

The existing genuine HGSS Museum adaptation remains source eligible, with **rendered acceptance false**. Its main and staff entrances pass native entry/return checks; shared terrace-step artwork/geometry still prevents visual acceptance. This batch does not change shared stairs, native ground, source geometry, textures or door anchors.

## Current-engine evidence

The latest official release changed to v0.3.96 before this batch. Official source bundle SHA256 `c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b` and Linux AppImage SHA256 `7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3` match its release checksum file. Source ZIP CRC/path checks pass; shell reports LÖVE11.5. New isolated profiles reimport the user's existing local FR/LG ROMs through public `POKEPORT_IMPORT_ROM`, producing required native cache140. Older cache139 was correctly rejected; no readiness stamp or engine callback is bypassed. Player saves and normal installation remain untouched.

Actual `FR_PEWTER_CITY` Museum origin(12,0) retains both native portals: main(17,6) and staff(25,4), each to `FR_PEWTER_CITY_MUSEUM_1F`. Both entry/return pairs pass in both editions, then repeat after the new exact triangle guard. Each native full-map hash remains `6d5257d9c36f01ec29c51b70c740f85e58966e947cb3680f5bce1a93e7f45b9f`. LG missing-PNG fallback also passes both real entries/returns; its native fallback image was inspected. No ticket payment, exhibit interaction or ordinary story progression is claimed. Driver PASS records are authoritative; the official shell returns1 on normal shutdown.

Native source overviews, both entrance contacts/animations where native frames exist, left/right views, original2D comparison and neighborhood views were inspected. A rear camera would lie outside the original map's north bound, so the driver skips it explicitly. Independent source front/side/rear/quarter/low/underside views confirm the complete source shell. The source exports no separately instanced Museum door panels; its existing native card surfaces remain at their original authored portal anchors. No unrelated source door is substituted. Characters, Pokémon and flowers retain HD2D.

## Exact blocked footprint

`Gen3ImportedPewterMuseum.clearance` now checks every source triangle against the actual nonrectangular native civic mask, including the walkable wing-header and staff-approach gaps. A temporary read-only lookup rebases the shared clipper's body origin; native cells never change. An adversarial triangle with all three vertices on blocked cells still crosses the wing-header walking gap and is correctly rejected. The original fitting and native portal surfaces stay unchanged, including `groundInset=.05`; source contact-ring vertices recess without moving the building or ground.

Focused LuaJIT checks pass for complete drawing/ownership/permission/base guards, both portals, exact projected-triangle safety, existing measured closure/alpha and missing-image fallback.

## Shared approach gap

Museum approach MIDs0x2b2/0x2b3/0x2b4 include arch/door artwork above their native stair strip. Shared `Gen3Stairs.append` treats them as generic terrace steps and remaps each complete tile over four tread bands, visibly spreading facade artwork under the genuine source entrance. Its generic `box()` emits top faces, then the terrace branch emits another textured tread at exactly the same height. This is a static coplanarity finding as well as a captured artwork defect; temporal flicker was not separately measured.

Parent-owned shared stairs must preserve the actual rise/collision while selecting clean native tread material and emitting one surface per tread. Moving the Museum/portal, flattening its source arch or hiding the original ground would not satisfy that requirement. Metadata records this exact gap rather than accepting the source merely because entry and footprint checks pass.

The canonical852-map inventory is refreshed on v0.3.96. Existing134 accepted assemblies retain explicit `renderedRuntime=v0.3.95`, so their older visual evidence is never relabeled. The Museum's separate `nativeReview` records v0.3.96, both returned portals, source/provenance hashes and a verified source footprint; `renderedAccepted` remains false. Per-edition totals stay426 maps/76 outdoors/133 assemblies/55 families,75 source eligible/67 rendered accepted/58 unmatched/6324 unclassified blocked cells. Seven other shared-ground gaps remain. Physical phones, production Scene and the combined package are separate parent work; no whole-game coverage is claimed.
