# ORAS standing grass assets

Source: [Tall Grass — Pokémon Omega Ruby / Alpha Sapphire, asset 353363](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/353363/),
uploaded by **MasterPengo**, June 24, 2024. Original game art:
**Nintendo / Creatures / GAME FREAK**. Attribution does not change ownership or
assert a new license for the source art.

| Original PNG | Processed catalog ID | Standing mesh |
| --- | --- | --- |
| `hureai_grass.png` | `oras_green` | 16 triangles / 33 indexed vertices |
| `hureai_grass2.png` | `oras_dry` | 16 triangles / 33 indexed vertices |
| `hureai_grass04.png` | `oras_tall` | 24 triangles / 36 indexed vertices |

These PNG files retain the original archive bytes. The processed six-float
vertex/index data lives in [GrassModelData.lua](../../../lib/GrassModelData.lua).
The converter evaluates the source hierarchy, weighted bind pose, units and
`Z_UP`, flips UV V once, and preserves the original repeating sampler and UVs
outside the unit interval. It uniformly grounds and fits standing meshes inside
96% of an 8- or 16-pixel native square. Separate scattered cut-leaf materials
are not included in standing fields.

[provenance.json](provenance.json) records the source URL, archive/model/texture
SHA-256 hashes, original bounds, normalization and excluded parts. Original ZIPs
and COLLADA model packs remain outside the repository. Rebuild with:

```sh
python3 tools/import_oras_grass.py /path/to/353363.zip --output-root /path/to/mod-checkout
```

[The grass verification document](../../../docs/IMPORTED_GRASS_2026-10-20.md)
describes native placement, Cut/fallback behavior and the source-only evidence
limits. Green is the current default native placement; dry/tall variants are
catalog assets and do not imply new regional coverage. Characters, Pokémon and
flowers remain HD-2D; all companion mods remain optional.
