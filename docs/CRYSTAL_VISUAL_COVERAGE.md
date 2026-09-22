## September22 tile inventory and radio-desk follow-up (beta3 preview)

The native census was repeated across all388 Crystal maps:147,500 cells and
2,295 distinct drawing/collision/treatment rows. The committed ledger links
remaining generic walls and classified surfaces to example locations; see
[TILE_COVERAGE.md](TILE_COVERAGE.md). Classification alone is not approval.

All82 furniture recipes now have placements. The radio reception desk had
been shadowed by the taller equipment recipe because they shared monitor
pixels. Matching the whole counter+monitor first fixes the desk without
replacing the standalone equipment on5F. Nine fresh native views cover the
reception desk, upstairs equipment and Lavender mixing desk in static, first
and rotating third person. The stable sealed cart is still1.13.1/BA1.20.3;
these source/preview improvements have not been cart-pinned.

## September22 follow-up (1.21.0-beta.2 preview)

Fixed one specific cause of Goldenrod's oversized/stair-stepped roofs:
vertically adjacent complete Johto houses now split at actual ridge tiles.
Roof-coloured facade bricks do not trigger a split. Neighbor columns share
heights only within the same roof edge, leaving taller connected towers alone.
Goldenrod's pink paving and yellow facade brick now have muted masonry
materials. Mesh cache57. This does not certify every joined building.

Fresh native0.2.73 checks in a separate Crystal profile: New Bark, Ecruteak,
Goldenrod, Olivine and Celadon;45 captures (3static/6free views each).
`tests/gen2_city_views_driver.lua` asserts the measured stacked-house case,
window/brick continuity and static/free foliage modes. Results:
`/tmp/firered-hd2d/crystal-city-views`. These tests used standalone Battle Art;
the stable sealed cart remains1.13.1 and is not repinned to the FireRed preview.
The previous388-map census and remaining interior/recipe gaps below still
apply; this turn did not repeat an all-map visual survey.

# Crystal visual coverage — 2026-09-21

This is a coverage inventory, not a claim that every location or decoration
looks finished. The 0.2.73 AppImage loaded the Crystal sealed cart and the
production scenery classification and furniture matchers inventoried all
388 imported maps, 35 tilesets and 1,549 furniture placements. There are
31,353 generic wall cells in 1,236 distinct tileset/drawing combinations.
These include correct ordinary walls and building facades as well as props
that still need individual review; they are not 31,353 confirmed defects.

Of 82 furniture recipes, 81 matched at least one placement. The unplaced
`crystal_depth_radio_desk_terminal` needs investigation for shadowing by an
older recipe or a drawing mismatch. No imported artwork is included here.

The inventory does not test all lighting conditions, every camera position,
animated states, moving actors, cutscenes, seasonal/map variants, or hardware
performance. The last released 1.13.0 cart received focused New Bark/Route29
camera verification, five staged species, healing and mount checks. Historical
coverage screenshots from earlier sessions are not fresh verification.

Raw census: `/tmp/johto-hd/coverage-1203/{maps,furniture,generic-walls,actors}.csv`.
Reproduce with `tests/gen2_coverage_driver.lua` using `QA_INVENTORY_ONLY=1`
in the disposable Crystal cart profile. Omit that option for one native view
per tileset; `QA_ALL_MAPS=1` renders every map with a walkable camera, but each
capture still requires visual review and is not exhaustive camera coverage.

## Roof pass and visible follow-ups

The new pitched roof treatment uses rounded seams, concave pans, a capped ridge,
curved eaves and shaded soffits. Japanese ceramic roof construction references:
[Highlighting Japan: Nihongawara](https://www.gov-online.go.jp/hlj/en/march_2026/march_2026-08.html)
and [JAANUS: kawarabuki](https://www.aisf.or.jp/~jaanus/deta/k/kawarabuki.htm).
This is an inspired finish, not an exact reconstruction of historic architecture.

The refreshed representative survey generated35 native scenes at2560×1440,
with no missing walkable camera or scene-build assertion failure. Selected
full-size interior images and the roof views were inspected; these are still
representative views, not a visual sign-off of every object. Results are in
`/tmp/johto-hd/tileset-review-1203`. The driver now clears dialogue overlays and
sets the window size before capture. Earlier `tileset-views-1203` images had
stale-frame/dialogue artifacts and are excluded from this review.

The roof driver captures three static angles and six free-camera views in each
of New Bark, Ecruteak, Goldenrod, Olivine and Celadon. Native geometry build and
foliage-mode assertions passed. Inspected images confirm improved small-house
roof surfaces and no return of the old black roof bands. Separate roof unit
checks cover capped seams, face winding and tile/overhang bounds.

Visible follow-ups, not closed by this roof finish:
- Large or joined building facades have inconsistent heights and depths,
  especially Goldenrod. They need building-level reconstruction rules;
  changing roof material alone cannot fix their footprint/proportions.
- Some city wall and paving colors remain too bright and repetitive.
- Specialty interiors, caves and landmarks need individual art/model review;
  a representative tileset screenshot does not cover every object or state.
- The unplaced radio terminal recipe and generic decoration drawings need
  manual classification before reporting complete coverage.

| Tileset | Maps | Furniture placements | Generic wall cells |
| --- | ---: | ---: | ---: |
| TILESET_AERODACTYL_WORD_ROOM | 1 | 0 | 82 |
| TILESET_BATTLE_TOWER_INSIDE | 4 | 18 | 85 |
| TILESET_BATTLE_TOWER_OUTSIDE | 1 | 0 | 165 |
| TILESET_CAVE | 15 | 0 | 3159 |
| TILESET_CHAMPIONS_ROOM | 3 | 0 | 221 |
| TILESET_DARK_CAVE | 17 | 0 | 4965 |
| TILESET_ELITE_FOUR_ROOM | 11 | 0 | 1593 |
| TILESET_FACILITY | 7 | 85 | 539 |
| TILESET_FOREST | 1 | 0 | 80 |
| TILESET_GAME_CORNER | 7 | 42 | 135 |
| TILESET_GATE | 31 | 4 | 1404 |
| TILESET_HOUSE | 57 | 429 | 861 |
| TILESET_HO_OH_WORD_ROOM | 1 | 0 | 102 |
| TILESET_ICE_PATH | 6 | 0 | 1045 |
| TILESET_JOHTO | 29 | 0 | 1265 |
| TILESET_JOHTO_MODERN | 4 | 0 | 748 |
| TILESET_KABUTO_WORD_ROOM | 1 | 0 | 82 |
| TILESET_KANTO | 39 | 0 | 3166 |
| TILESET_LAB | 5 | 20 | 159 |
| TILESET_LIGHTHOUSE | 11 | 49 | 2482 |
| TILESET_MANSION | 6 | 12 | 184 |
| TILESET_MART | 28 | 299 | 304 |
| TILESET_OMANYTE_WORD_ROOM | 1 | 0 | 86 |
| TILESET_PARK | 3 | 15 | 358 |
| TILESET_PLAYERS_HOUSE | 6 | 34 | 82 |
| TILESET_PLAYERS_ROOM | 1 | 4 | 9 |
| TILESET_POKECENTER | 33 | 410 | 706 |
| TILESET_POKECOM_CENTER | 1 | 18 | 717 |
| TILESET_PORT | 3 | 0 | 186 |
| TILESET_RADIO_TOWER | 6 | 47 | 206 |
| TILESET_RUINS_OF_ALPH | 9 | 0 | 510 |
| TILESET_TOWER | 18 | 0 | 3702 |
| TILESET_TRADITIONAL_HOUSE | 10 | 9 | 180 |
| TILESET_TRAIN_STATION | 5 | 54 | 511 |
| TILESET_UNDERGROUND | 7 | 0 | 1274 |
