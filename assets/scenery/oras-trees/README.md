# ORAS Route 104 broadleaf tree

Source: [Route 104 — Pokémon Omega Ruby / Alpha Sapphire, asset 364272](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364272/),
uploaded by **MasterPengo**, June 29, 2025. Original game art:
**Nintendo / Creatures / GAME FREAK**. Attribution does not transfer ownership or
assert a new license for the source art.

`oras_route104_broadleaf` extracts one actual trunk and its six leaf clusters
from `world03_02_02.dae`. Both bundled PNGs, `wood_base.png` (128×128) and
`forest_wood_a.png` (256×256), retain their original archive bytes. The original
108 triangles, their UVs and per-vertex RGB colors are preserved. The processed
family has **360 triangles in five parts**, including separately identified
authored completion:

| Part | Triangles | Origin |
| --- | ---: | --- |
| Trunk | 60 | Original connected bark geometry |
| Canopy | 48 | Original six curved alpha-cutout leaf clusters |
| Bark closure | 24 | Rear strip, top and underside using existing bark art |
| Canopy quarter turns | 144 | Original leaf clusters copied at 90°, 180° and 270° |
| Inset bark backing | 84 | Closed, slightly inset bark hull behind source root cutouts |

The raw source was optimized for its original camera and was not a complete
360-degree tree. The added leaf shells fill side/rear views while retaining the
original shell shapes and artwork. Leaf edges intentionally remain cutout
foliage. Bark hulls are geometrically closed; the inset backing prevents root
texture cutouts from exposing the underside cap. No character, Pokémon, flower,
new sign or unrelated attachment is imported.

[provenance.json](provenance.json) records archive/model/texture hashes,
selection, source/processed bounds, grounding, scale, and authored additions.
[ImportedTreeData.lua](../../../lib/ImportedTreeData.lua) contains processed
vertex/index data and optional source RGBA. Source ZIPs and map/model packs stay
outside the repository. Rebuild with:

```sh
python3 tools/import_route104_tree.py /path/to/364272.zip --output-root /path/to/mod-checkout
```

[The source verification document](../../../docs/IMPORTED_TREES_2026-10-20.md)
separates model inspection from native placement and final archive verification.
