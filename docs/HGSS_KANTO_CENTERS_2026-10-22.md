# HGSS standard Center native adapter — 2026-10-22

`Gen3ImportedKantoCenters` places the standard [HGSS Pokémon Center,
Cheesy Mac n Cheese, August23,2015](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/293549/)
in the matching complete FR/LG service-building family. Original game art:
Nintendo / Creatures / GAME FREAK. The standard256-triangle source retains its
original PNG bytes, UVs, recessed center entrance, rounded/beveled corners,
roof/badge and0.2903226 ground-shadow opacity. The Violet/Ecruteak variant is
excluded. Source ZIPS and OBJ/MTL remain outside source control.

`tools/import_hgss_center.py` generates the separate `HGSSCenterData` module and
texture/provenance directory. The ZIP has mismatched accented filenames between
local headers and its central directory; the converter uses bounded central
metadata and verifies original compressed streams, decompressed sizes and CRCs.
Every name repair and archive/model/material/texture hash is recorded. No source
geometry or UV repair is needed.

The original rear and underside are open. Separately named authored parts close
the original stepped rear outline: outer wall ends(x±36,z−28), original center
partitions(x±18,z−30), roof soffit joins and a thin foundation. Wall and band art
continues from the source side-wall UVs. The bottom is0.05source units below the
source shadow, preventing the underside flicker observed in the first preview.
Processed geometry totals324triangles. No front entrance, roof silhouette,
original face or fixture is removed. Source material metadata remains explicit.

Eligibility requires an existing ordinary native five-column Center civic,
exact body/roof/last-row metatiles, native blocked permissions(including0x82),
the original0x71door, a complete level footprint and no boundary/hidden cells.
Models fit uniformly in the four blocked body rows with0.25px inset; the roof
header row receives no model geometry. No entrance deformation is needed. The
centered entrance stays rigid and aligned to the native warp tile. Whole source
footprint is about74.5px of80px available, body about70px. Original lawn remains
owned by the native civic ground recipe.

Existing imported FR and LG definitions each identify16eligible placements:
Viridian, Pewter, Cerulean, Lavender, Celadon, Fuchsia, Saffron, Cinnabar,
Routes4/10, and Two through Seven Island. Seven Island's four-row map-boundary
form and Lavender's exact mixed header permissions are supported. Vermilion's
water-permission header, One Island's custom wider building and the non-warp
Saffron connection preview retain native fallback. No other game is implied.

API is `build(g,cells,newMesh,parts)` with success marker
`g.importedKantoCenter`, plus `doorSurface(g,tx,ty)`. It consumes civic groups
already claimed by `Gen3Civic`; failed image/mesh uploads leave their ordinary
native renderer available. Native door/collision/warps and HD-2D actors are
unchanged. Parent owns scene integration and the source blend pass.

Guard/geometry tests pass, including missing-resource fallback, ordinary/short
map/Saffron/Lavender forms, changed permission/tile/elevation/boundary rejection,
bounded source geometry and exact portal alignment. Seven source and seven
closed asset-viewer angles were rendered/inspected on the0.3.95LÖVE11.5shell
with Mesa llvmpipe. These previews are asset evidence; final native FR/LG static,
rotating, first-person, held-input door/collision and fallback verification is
still required. No all-map or all-game visual acceptance is claimed.
