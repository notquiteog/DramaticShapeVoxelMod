# Native BW enemy animation — test.10

The test.9 release shipped animated BW back atlases but only static BW front
fallbacks. Its native front renderer requested a picture every frame correctly;
the selected Gen5 front atlas was absent, so the enemy remained static.

Test.10 bundles real front GIF frames for National Dex 1–386, normal and shiny:
772 atlases, 51,133 timed frames, and 28,810 distinct pixel frames. Every atlas
has at least two distinct frames. Missing sources: zero. Static-only entries:
zero. The PNGs total 37,502,294 bytes before release ZIP compression.

`tools/import_bundled_bw_fronts.py` imports from PokeAPI/sprites revision
`2ecb4eeacd5a1718621fc30f12772e3f60d830b9`, the same pinned public source as the
existing bundled animated backs. The `assets/bw-front-animated/sources.json`
manifest records source URLs, source and output SHA256 hashes, frame counts,
independent normal/shiny timing, and pixel variance. Raw GIFs stay in scratch.
Artwork attribution and ownership follow the existing bundled backs; the mod's
code license does not relicense Pokémon artwork.

The shared `AnimatedBattleArt` decoder selects installed custom Gen5 atlases
first, then these bundled fronts. Gen5 backs keep their existing provider.
STATIC and ROM remain distinct choices. Gen1/2 Crystal pack defaults and other
selected generations remain unchanged. Unsupported species/forms retain the
existing native/static fallback; this is not an all-form animation claim.

Validation before publication:

- 772 atlas hashes, dimensions, per-frame timing counts and distinct-frame
  measurements pass against the generated source manifest.
- 782 native front checks cover every normal/shiny definition plus timed frame
  changes in native single and double draw contracts, same-species shiny
  identity, custom-atlas precedence, other-generation selection and ROM opt-out.
- Existing native battle identity checks: 22 pass. External interface atlas
  decoder checks: 25 pass. Changed Lua files compile; whitespace checks pass.

These are asset and contract checks, not visual gameplay approval. The real
native pixel-change fixture is prepared at
`/tmp/full-parity-20260922/native-front-animation-driver.lua` and must run only
after the exact test.10 archive is published. It compares actual native enemy
picture pixels in singles and same-species normal/shiny doubles, captures both
states, and returns to the field. No user profile is involved.
