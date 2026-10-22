# Regional source buildings and native rooms — 2026-10-22

This is an incremental placement batch. Complete modern coverage of every map,
building and interior across the five GBA games remains unfinished.

| New coverage | FireRed | LeafGreen | Ruby | Sapphire | Emerald |
| --- | ---: | ---: | ---: | ---: | ---: |
| HGSS Pallet homes and Oak's Lab | 3 | 3 | 0 | 0 | 0 |
| HGSS standard Centers | 16 | 16 | 0 | 0 | 0 |
| HGSS Viridian ordinary house | 1 | 1 | 0 | 0 | 0 |
| ORAS Briney, Pretty Petal, two Dewford homes | 0 | 0 | 4 | 4 | 4 |
| ORAS public PCs | 19 | 19 | 16 | 16 | 17 |
| ORAS genuine home TVs | 9 | 9 | 15 | 15 | 14 |
| Native-art secret-base room templates | 0 | 0 | 24 | 24 | 24 |

The 52 new building placements supplement the 46 ORAS Hoenn Centers from1.56.0.
PCs retain the engine's screen-on animation and interactions, including its native
permission change. TVs replace only actual TV drawings with native0x86 behavior;
original low cabinets and FireRed/LeafGreen wall notes remain separate geometry.
Cupboards and bookcases with misleading recipe names are excluded.

Source provenance, original PNG hashes, authored closures and fitting notes are
beside each asset family and in the family-specific import documentation. The
newest available HGSS Pallet/Viridian source scenes are used for those locations.
Source fixtures, lettering, doors and colors stay intact. Closed rear/underside
completion and documented plain-wall depth adaptations fit blocked footprints.
The shop's living plants remain bounded flat HD-2D cards, facing the camera;
characters, Pokémon and native flowers stay HD-2D. No companion is required.

Source transparent shadows and PC glow use a scoped, lit alpha pass with no depth
writes. Ordinary sprites keep their cutout pass; errors restore draw state.
Missing source textures leave the complete existing native building/furniture.
Native map/collision/warp data and gameplay/UI callbacks are unchanged.

Secret bases now enter the existing native 3D adapter: six authentic source
palettes, four irregular layouts per edition, continuous32px cave/leaf walls,
clear entry frames, separate native PCs and recessed8px pits. This is native-art
geometry coverage, not imported ORAS secret-base interiors. Unknown decorations
retain their native surface and clearance rather than becoming guessed volumes.

## Verification

Official Gen1Recomp0.3.95 (2026-10-21 release), LÖVE11.5 native Linux shell,
NVIDIA OpenGL, disposable per-edition profiles and existing local GBA imports.
No player saves or source engine callbacks were changed. A historical test-only
bootstrap supplies helpers absent from the current release; its captures are not
relabeled as current-engine evidence.

Source SDK suite:386 passed,0 failed,58 explicit external-fixture skips.
Original-archive converter checks pass for Briney, Pretty Petal and Dewford;
all six catalog importer tests pass with their external source archives supplied.
Initial Python unittest discovery was unsuitable for standalone scripts requiring
archive arguments; the scripts were rerun correctly with their source ZIPs.

Native acceptance evidence and packaged verification are recorded below once
completed. Scratch captures, ROMs, archives and generated caches are excluded.

## Map ledger and remaining queue

[Identifier-only map ledger](coverage/gen3-map-ledger-2026-10-22.csv) covers2161
engine map records:426 eachFR/LG,395 eachR/S,519 Emerald, including engine fixture
records. All resolve through the native presentation adapter with zero preparation
errors. That establishes adapter support, not complete modern model coverage.
The three `batch_imported_*` columns count this batch only; the previous46 ORAS
Centers are outside those columns. `unclaimed_blocked_cells` is a heuristic queue,
not a count of unfinished models: existing native geometry can be claimed while
still needing a newer source model. The census does not certify every room's art.
Regenerate native inventory with `tools/qa/gen3-gap-census.lua` in isolated QA
profiles; model eligibility is separately checked against complete native drawings.

Next sources: exact Lavaridge variants, Pewter Museum with its irregular native
footprint and two entrances, authentic full-blocked Hoenn beds, and local ORAS
town/interior extraction. Vermilion and One Island Centers, Dewford's wide hall,
other regional houses/Marts and unverified interior families retain native models.
All-game modern replacement and the requested per-category three-mode settings
remain unfinished. No phone certification or general performance claim is made.
