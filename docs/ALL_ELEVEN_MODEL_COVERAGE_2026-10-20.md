# Eleven-game model coverage and next work — 2026-10-20

The current request covers every location, building, interior and outdoor object
in Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire
and Emerald. This is a larger scope than the existing five-edition starting-region
queue. Complete coverage has not been established. This inventory records the
current adapters, reviewed source evidence and concrete gaps; a catalog entry,
a recipe match or a reusable art family is not a native placement signoff.

The current 1.53 batch must finish its exact-archive checks before a new import
batch. Source verification below does not imply that this pending archive has
passed. Existing native-art 3D models remain the fallback and may already model
many of the buildings listed for future source comparison.

## Actual imported adapters, per game

“Selected trees” means only a matching mature broadleaf with a complete, level,
blocked owner rectangle and sufficient fitted height. It excludes unmatched
conifers, special palettes, saplings, small fragments, optional authored forests
and unavailable assets. Signs require the reviewed General sign families and
native nonwalkable permissions; this does not cover every sign or board.

| Game | Native locations in full request | ORAS standing grass | ORAS selected tree adapter | BW2 native-faced sign adapter | Imported whole buildings placed |
| --- | --- | --- | --- | --- | ---: |
| Red | Kanto, routes, islands present in its native map set, all interiors | Yes; native 8px masks | No Gen1 registry added | No | 0 |
| Blue | Kanto and all edition-specific native maps/interiors | Yes; native 8px masks | No Gen1 registry added | No | 0 |
| Yellow | Kanto and all edition-specific native maps/interiors | Yes; native 8px masks | No Gen1 registry added | No | 0 |
| Gold | Johto and Kanto, routes, caves, ships and all interiors | Yes; native 8px masks | Existing wide 2×2 tree registry only | No | 0 |
| Silver | Johto and Kanto, including edition-specific maps/interiors | Yes; native 8px masks | Existing wide 2×2 tree registry only | No | 0 |
| Crystal | Johto and Kanto, including Crystal-specific maps/interiors | Yes; native 8px masks | Existing wide 2×2 tree registry only | No | 0 |
| FireRed | Kanto, Sevii Islands, routes and all interiors | Yes; native 16px cells | Matching broad/round families | General source IDs 2/3 | 0 |
| LeafGreen | Kanto, Sevii Islands, routes and all interiors | Yes; native 16px cells | Matching broad/round families | General source IDs 2/3 | 0 |
| Ruby | Hoenn, routes, islands/dungeons and all interiors | Yes; native 16px cells | Matching mature Hoenn families | General source IDs 2/3 | 0 |
| Sapphire | Hoenn, routes, islands/dungeons and all interiors | Yes; native 16px cells | Matching mature Hoenn families | General source IDs 2/3 | 0 |
| Emerald | Hoenn, Emerald-specific facilities, routes and all interiors | Yes; native 16px cells | Matching mature Hoenn families | General source IDs 2/3 | 0 |

These are code eligibility statements, not all-map visual certification. Grass
source fixtures cover all eleven editions. Tree source fixtures cover GSC Ilex,
RSE Petalburg and FR/LG matching broadleaf scenes; common Pallet conifers retain
their own native model. Native sign review is representative rather than a count
of every board in five games. See the [grass evidence](IMPORTED_GRASS_2026-10-20.md),
[tree evidence](IMPORTED_TREES_2026-10-20.md) and
[static catalog evidence](STATIC_SCENERY_CATALOG_2026-10-20.md).

## Available source assets and matching limits

| Verified source | Current usable scope | Next inspection / gap |
| --- | --- | --- |
| [ORAS standing grass, 353363](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/353363/) | Green standing grass integrated; dry and tall prototypes available | Select dry/tall only where native regional art matches; do not replace flower sprites |
| [ORAS Route 104, 364272](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364272/) | One actual broadleaf family, source textures/colors preserved, separately authored 360° completion; selected bank materials | Inspect source Briney-house, fence, stair and route prop geometry for separate complete objects, transforms, UVs, door anchors and native footprint fit before enabling |
| [HGSS Pallet Town, 592847](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592847/) | Selected terrain/bank reference materials; source scene inspected | Candidate source for newer matching Pallet houses, fences and Oak exterior; its slanted tree cards are excluded as full 3D trees. Whole buildings are not placed |
| [ORAS Pokémon Center, 292908](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/292908/) | Closed catalog model, original front and materials retained | Hoenn-native Center doorway/blocked-footprint adapter and source comparison; no current native placements |
| [HGSS Oak’s Lab, 294796](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/294796/) | Closed catalog model with recorded material repair/closures | Compare newer Pallet-scene source first; support original translucent shading part correctly before native placement. Do not substitute it for Birch’s or Elm’s Lab |
| [BW2 Sign 01, 582551](https://models.spriters-resource.com/ds_dsi/pokemonblack2white2/asset/582551/) | Imported body with native Kanto/Hoenn board UVs in five GBA editions | GB/GSC source-family and permission adapter; remaining directional, boundary and specialty signs require individual review |

“Newest available matching” means compare the newest suitable source for that
location or object family, preserve its regional identity and document why a
source was chosen. A newer upload is not automatically better geometry. HGSS
Kanto/Johto and ORAS Hoenn are the first source families to investigate; BW2 can
supply matching generic props. Unova landmarks are not substitutes for unrelated
Kanto, Johto or Hoenn buildings. No complete ORAS/HGSS/BW2 library has been
downloaded or approved by this inventory.

## Concrete location and family gaps

| Editions | Priority location groups | Imported-model work still needed |
| --- | --- | --- |
| Red / Blue / Yellow | Pallet, Viridian, Pewter, Routes 1/2 and Viridian Forest first; then remaining Kanto settlements/routes | Region-matched houses, Oak exterior, Centers/Marts, gyms, Pewter Museum, gates and route fixtures; no imported building or tree adapter exists for Gen1. Check each edition’s roofs, ship decks and source-art exceptions |
| Gold / Silver / Crystal | New Bark, Cherrygrove, Violet and their routes first; then remaining Johto plus Kanto | Elm’s Lab and local houses, Centers/Marts, gyms, gates, towers, shrines, radio/department facilities, docks/ships and interior furniture. Import matching conifers/round trees rather than forcing the mature broadleaf onto every tree |
| FireRed / LeafGreen | Pallet, Viridian, Pewter, Routes 1/2 and Viridian Forest first; then Kanto and Sevii | Native imported house/lab/service-building adapters; Pewter Museum/gyms, regional gates and props, remaining tree families; subsequent department stores, Silph, league/towers, mansion/ship and island-specific architecture need individual source comparisons |
| Ruby / Sapphire | Littleroot, Oldale, Petalburg and Routes 101–103 first; then remaining Hoenn | Native imported Center/home/Birch-lab adapters; Petalburg Gym and route props; then Rustboro Devon Corporation, Slateport Museum, Lilycove Museum, Mossdeep Space Center and their actual room layouts. RS differences remain separate from Emerald |
| Emerald | Same early Hoenn scope, then Emerald’s distinct Hoenn locations | Same matching-source adapters with Emerald-native art/layout checks, plus Battle Frontier and other Emerald-only facilities; shared RSE family eligibility alone does not approve each location |

For every group, exterior and interior are separate work items. A building
exterior does not cover its rooms, floors, stairs, counters or furniture.
Existing modeled signs, fences, bridges, cliffs and room kits need replacement
only where a matching source improves the native scene without breaking its
blocked footprint. Room walls stay flat and continuous; wallpaper/trim wraps
around appropriate walls, furniture stands separately and native openings stay
clear. Elevated terrain, bridges and banks retain closed depth, local ground and
native walkability. Characters, Pokémon and flowers remain HD-2D.

## Existing regional queue: historical baseline, not eleven-game completion

The [five-edition starting-region queue](GEN3_STARTING_REGIONS_2026-10-15.md)
contains 125 edition-map placements. Its **84 verified / 41 queued** count measures
native-art scenery polish, not imported whole-building coverage:

| Editions | Maps per edition | Verified per edition | Queued per edition |
| --- | ---: | ---: | ---: |
| FireRed / LeafGreen | 28 | 18 | 10 |
| Ruby / Sapphire / Emerald | 23 | 16 | 7 |

Kanto’s ten queued maps per edition are Pallet, Viridian, Pewter, Routes 1/2,
Viridian Forest, Viridian/Pewter gyms and Pewter Museum floors 1/2. Hoenn’s seven
are Littleroot, Oldale, Petalburg, Petalburg Gym and Routes 101/102/103. Earlier
outdoor boundary, gate, grass or tree improvements do not automatically close a
map whose other object families remain unresolved. Red/Blue/Yellow and
Gold/Silver/Crystal are outside this 125-placement denominator.

The [Gen1 ledger](GEN1_MODEL_COVERAGE_2026-10-09.md) and
[Gen2 ledger](CRYSTAL_MODEL_COVERAGE_2026-10-09.md) contain reviewed native-art
families and remaining exceptions, rather than a complete edition-map census.
Historical exterior matcher counts likewise are not live signoffs or imported
asset counts. The next all-eleven census must enumerate actual native map IDs,
edition-specific layouts, source families, candidate model, adapter state and
review evidence before assigning a completion percentage.

## Execution order and acceptance record

1. Finish the current 1.53 frozen-package tests and publish only that verified
   scope. Preserve unrelated active partner work.
2. Compare newest matching Pallet/Hoenn building sources and place one coherent
   exterior family at a time, starting with native houses, labs and Centers.
   Review all applicable editions and door approaches before broad reuse.
3. Complete early-settlement interiors and connecting-route families, including
   native registers, separate furniture, fences, bridge depth and missing tree
   shapes. Retain original native models on source/asset/footprint mismatch.
4. Expand through each region’s remaining settlements, landmarks, special
   interiors and dungeons. Track every native map and story/layout variant;
   prevent generic family coverage from hiding unreviewed rooms.

Each batch records source URL/archive identity, model parts/materials, source and
authored geometry, native map/cells, complete blocked footprint, door anchors,
local ground/elevation, front/sides/back/underside and actual first-person views,
entry/walking checks, optouts/missing-asset/ordinary-backend behavior and resource
cleanup. Optional third-party scenery definitions use bounded public catalog
APIs; native placement still requires the same guards. Partners remain optional,
feature UI remains native, and no engine collision or gameplay rewrite is part
of this coverage work.
