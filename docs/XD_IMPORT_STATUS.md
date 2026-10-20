# XD model import work

This feature is **not playable yet**. Existing Stadium integration is unchanged.
`tools/import_xd_models.py` prepares source PKX records; it does not produce
renderable meshes or claim animations/materials/particles are supported.

The intended finished flow is one disc selection, one conversion, and a portable
model pack usable by all eleven games. Android/iOS must consume that prepared
pack without Python, Dolphin, Blender, subprocesses or desktop filesystem access.
Mobile rendering still requires bounded GPU uploads, lazy species loading,
GLES shaders, small-screen controls and real-device verification.

## Source preparation

Install Dolphin's `dolphin-tool`, then:

```sh
python3 tools/import_xd_models.py "/path/to/XD.zip" --output "/path/to/new-source-pack"
```

An extracted Dolphin disc directory containing `sys/boot.bin`, `sys/main.dol`
and `files/` is also accepted. `--dolphin-tool PATH` selects a local executable.
7z requires 7-Zip (`--sevenzip PATH`); ZIP is streamed with Python's standard
library. Disc containers are delegated to Dolphin: ISO/GCM, RVZ, WIA, GCZ,
CISO. These extensions are accepted, not evidence that every container was
tested. NKit recovery and multi-part discs are not advertised as supported.
Only XD retail revision 0 US/EU/JP is currently recognized.

Original discs are read-only. An existing output is refused. Temporary extraction
is removed on exit; the source pack is published only after complete validation.
Neither source packs nor extracted discs belong in Git or release archives.

Species mapping comes from common.rel's species/model indices, not filenames
or an assumed National Dex ordering. DOL tables identify normal models, shiny
exceptions and Unown/Deoxys forms. Missing or ambiguous records fail the import.
PKX records are decompressed, hashed and deduplicated. Ordinary shiny variants
still need their PKX color parameters interpreted by the future converter.

## Evidence and remaining work

All three user-provided regional RVZ discs yielded all 386 species and 457
table entries each. European verification caught incorrect offsets in published
format references; the importer uses the retail disc's corrected EU offsets.
Five intake tests cover malformed bounds, truncation, overlapping compression,
archive ambiguity and path traversal. These are source-intake tests, not GPU,
animation or eleven-game runtime verification.

Experimental offline conversion (`tools/convert_xd_models.py`) and a dormant
mesh/pose consumer (`lib/XDModelInstance.lua`) are now present. They are not
connected to gameplay, providers or settings. Conversion uses an external parser
and mathutils; its recorded parser revision is not enforced against the checkout.
Only the first texture layer is rendered; missing named textures can become
white. Material/UV animation, animated lighting and parallel conversion are
prototype code, without native-game or mobile acceptance. Failed converted
records can leave diagnostic folders; output still declares `renderReady:false`.

Still required: validated geometry/material/skeleton/animation conversion, shiny filters,
particle Pokémon, game-neutral renderer and battle/overworld ownership,
all-eleven species/form mapping, import/settings UI, mobile pack installation,
runtime tests and physical-device checks. Do not expose an import-success option
in-game until these are ready. The manifest deliberately says `renderReady:false`.

Format references:

- [Dolphin disc tool](https://github.com/dolphin-emu/dolphin)
- [GoD Tool's XD table documentation/source](https://github.com/PekanMmd/Pokemon-XD-Code)
- [StarsMmd's GameCube model parser](https://github.com/StarsMmd/Blender-Addon-Gamecube-Models)

No third-party parser code or game artwork is bundled by this change. The latter
parser is GPLv3 and has documented particle limitations; its source was inspected
as a possible separate conversion dependency, not copied into the runtime.
