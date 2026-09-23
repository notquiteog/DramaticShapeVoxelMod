# Full-body staged back sprites

Run `python3 tools/import_full_body.py` from the repository root before packing.
The release carries 502 animated back atlases: normal and shiny for dex 1–251.
The source remains separate from imported artwork. Missing imports fall back to
Crystal's normal picture provider. No player assets or ROM data are required.

Source: https://github.com/PokeAPI/sprites at
`2ecb4eeacd5a1718621fc30f12772e3f60d830b9`, Gen V Black/White animated backs.
Each imported source URL and SHA256 is recorded in the release's sources.json.
Pokémon artwork belongs to its respective owners; the repository's code license
does not relicense the artwork. Frames use their GIF timing and a shared alpha
bounding box; nearest filtering preserves pixels and animation motion.

`exports.stagedPokemonSprite(mon, back)` returns nil or an image, quad, dimensions
and animation metadata record. It never mutates the mon or the battle. Enable
`full_body_backs` in mod options (the Johto cart pins it on). Flat menus, summaries,
Dex pages and the original battle screen keep their established Crystal art.
