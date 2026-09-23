# Bundled Black/White front animations

Run `python3 tools/import_bundled_bw_fronts.py` to rebuild these normal and shiny
front atlases for National Dex 1–386. These are actual GIF animation frames,
not transformations of the static BW fallback pictures. The existing animated
Gen5 front selection uses them when a matching custom atlas is not installed.
Other generation selections and Crystal pack defaults remain unchanged.

Source: `PokeAPI/sprites` revision
`2ecb4eeacd5a1718621fc30f12772e3f60d830b9`, the same pinned source as the bundled
full-body backs, under `sprites/pokemon/versions/generation-v/black-white/animated/`.
`sources.json` records every source URL, GIF and atlas SHA256, exact GIF timings,
frame count, distinct pixel-frame count, and missing-source report.

Each atlas uses one alpha bounding box across the whole animation; pixels are
not resampled. Normal and shiny variants retain their own timing and geometry.
Raw source downloads live in scratch, outside the repository and release.
Pokémon artwork belongs to its respective owners; the mod's MIT code license
does not relicense the artwork.
