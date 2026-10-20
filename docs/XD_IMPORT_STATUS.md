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

The portable converter now bakes 454 unique models (457 records), with 4,019
animation clips. All records in the USA source pack convert without errors.
Five path-driven records required a spline sampler; its basis tests pass, but
authored path timing/parent motion still needs visual comparison. Nine Python
intake/conversion tests pass. Conversion uses the pinned external parser and
standalone mathutils, not Blender. `--resume` retries failed records transactionally.

`XDModelInstance` renders CPU-skinned meshes at the source 30 Hz pose rate,
with cached GPU geometry, smooth normals, material color/UV animation and
temporary texture wrapping. An isolated Pikachu idle orbit was rendered and
inspected on desktop; this is not an in-game or mobile acceptance test.
SDK-owned textures are never released by instances.

The optional pack consumer is connected to the Gen1/2 provider adapter and a
persistent four-slot GBA battle consumer. GBA move/faint hooks preserve native
sequencing and missing models retain sprites. Focused actor lifecycle,
native-card fallback and Stadium bridge tests pass. The shared setting is OFF
by default, and the manifest deliberately remains `renderReady:false`.

Still required before enabling packs: multi-layer material composition (477
meshes), shiny filters, particles (15 models), shape/sub-animation composition,
source-accurate spline timing, forms and Gen1/2 paired actor ownership, full native
animation effects, simple import/portable installation UI, all-eleven in-game
tests and physical Android/iOS checks. The generated assets are kept outside
the repository and are not a distributable mod release.

Format references:

- [Dolphin disc tool](https://github.com/dolphin-emu/dolphin)
- [GoD Tool's XD table documentation/source](https://github.com/PekanMmd/Pokemon-XD-Code)
- [StarsMmd's GameCube model parser](https://github.com/StarsMmd/Blender-Addon-Gamecube-Models)

No third-party parser code or game artwork is bundled by this change. The latter
parser is GPLv3 and has documented particle limitations; its source was inspected
as a possible separate conversion dependency, not copied into the runtime.
