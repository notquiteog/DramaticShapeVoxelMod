# XD model import work

This feature is **not playable yet**. Existing Stadium integration is unchanged.
`tools/import_xd_models.py` prepares source PKX records; a separate converter now produces portable meshes and baked clips, but complete
material/animation/particle support and runtime acceptance remain unfinished.

The intended finished flow is one disc selection, one conversion, and a portable
model pack usable by all eleven games. Android/iOS must consume that prepared
pack without Python, Dolphin, Blender, subprocesses or desktop filesystem access.
Mobile rendering still requires bounded GPU uploads, lazy species loading,
GLES shaders, small-screen controls and real-device verification.

## Source preparation

The combined desktop preparation command now handles extraction and conversion
transactionally. Configure the pinned parser checkout and standalone `mathutils`
once, then run:

```sh
python3 tools/prepare_xd_pack.py --parser /path/to/pinned-parser
```

It opens a disc/archive picker and destination picker. For headless use, supply
the source path and `--output /path/to/new-pack`; `--dolphin-tool` and `--sevenzip`
select tools outside PATH. Cancellation or conversion failure does not publish a
partial pack. This prepares data only: mobile installation and rendering acceptance
are still pending, and `renderReady` remains false.

Converter revision 2 removes original bone/material curve graphs after baking.
Pikachu metadata fell from 9,920,636 to 1,656,704 uncompressed bytes (83.3%);
all 29 texture/pose files and baked clip metadata remain identical. These are
metadata-size measurements, not measured phone RAM or frame-time improvements.
Revision checks prevent resuming a conversion with stale converter output.
Twelve CPU intake/conversion/orchestration tests pass; file dialogs have not yet
been exercised interactively.

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

Experimental offline conversion (`tools/convert_xd_models.py`) and a dormant
mesh/pose consumer (`lib/XDModelInstance.lua`) are also present. Conversion uses
an external parser and mathutils; its pinned parser revision is enforced against the checkout. Only the first texture layer is rendered; missing named
textures can become white. Material/UV animation, animated lighting and parallel
conversion are prototype code, without native-game or mobile acceptance. Failed
converted records can leave diagnostic folders; output still declares
`renderReady:false`.

Still required before enabling packs: multi-layer material composition (477
meshes), shiny filters, particles (15 models), shape/sub-animation composition,
source-accurate spline timing, forms and Gen1/2 paired actor ownership, full native
animation effects, simple import/portable installation UI, all-eleven in-game
tests and physical Android/iOS checks. Do not expose an import-success option
in-game until these are ready. The generated assets are kept outside the
repository and are not a distributable mod release.

Format references:

- [Dolphin disc tool](https://github.com/dolphin-emu/dolphin)
- [GoD Tool's XD table documentation/source](https://github.com/PekanMmd/Pokemon-XD-Code)
- [StarsMmd's GameCube model parser](https://github.com/StarsMmd/Blender-Addon-Gamecube-Models)

No third-party parser code or game artwork is bundled by this change. The latter
parser is GPLv3 and has documented particle limitations; its source was inspected
as a possible separate conversion dependency, not copied into the runtime.

## Consumer/material correctness batch — 2026-10-22

The shared portable consumer now honors material vs vertex color/alpha source,
preserves unlit surface shade, respects explicit closest/linear filtering and
restores SDK texture samplers even after draw failure. Primary Physical/Special
clips take precedence over suffixed alternates and Extra composites; invalid
pose metadata cannot replace a valid active clip. Converter revision3 includes
material/UV key durations instead of truncating them to bone-track durations.
Old converted output must be regenerated to gain that duration fix.

Audit of the existing454-model local pack found6852 MATERIAL-color meshes,
24VERTEX-color meshes,78UNLIT surfaces and two explicit Closest texture layers;
these counts establish affected source semantics, not visual approval for each.
Primary-clip choice changes41physical and16special selections. A native LÖVE11.5
NVIDIA Pikachu idle-orbit preview was rendered and three front/side/rear images
inspected using current consumer code and the existing local pack. This isolated
preview uses the0.3.95 JSON decoder; it is not an eleven-game battle test.
Six Python converter tests, two preparation tests, XD native actor lifecycle and
new source-material/pose/sampler restoration Lua regression pass.

No pack was marked renderReady. Multi-texture combiners, shiny parameters,
particles, shape/sub-clip composition, verified authored path timing, GB paired
ownership, source-form selection, import installation UI and all11/mobile battle
acceptance still prevent production readiness. This batch does not alter scenery
or distribute source game assets.

## Native identity and presentation batch — 2026-10-22

The shared pack receives native Unown letter identity (GSC DVs/GBA PID) and
edition-specific Deoxys forms. Form changes invalidate both live and failed
actor cache entries. Missing Castform weather models, unresolved Transform form
identity and unsupported Spinda PID markings retain native sprites instead of
silently displaying another form. GBA substitute/pending-Transform/ghost cards
also retain native presentation. Physical GBA models face the opposing row;
orbiting the camera no longer rotates their bodies.

Four focused Lua suites pass, including form selection/cache changes, original
Stadium provider compatibility, camera-independent model matrices and native
substitute/ghost fallback. All five Gen3 native0.3.95 profiles additionally pass
public Unown identity and edition Deoxys form assertions with the existing
isolated option fixture. This is native API verification, not a rendered
all-model battle claim. The model pack gate remains false. Form selection is
now wired; complete form artwork, shiny filters, multi-layer materials,
particles, shape/sub-animation composition, GB paired ownership, import UI and
native battle/mobile acceptance are still outstanding.

## Move categories and failure isolation — 2026-10-23

Gen1/2 now pass native move metadata through the optional model adapter. XD
resolves the current generation's public damage category instead of always
playing Physical; other providers can ignore the additional optional argument.
GBA model metrics, update, clip and drawing failures retain native sprite
ownership and cache failed actor identity until an actor/form/style change,
preventing repeated per-frame model construction. Explicit failed updates in
the shared GB provider also trigger its established native fallback.

Focused LuaJIT tests pass for native category routing, four GBA failure modes
and retry suppression, model material/context behavior, and24 original Stadium
bridge checks. These are source/API regression checks; no new GPU or phone
acceptance claim. Pack validation remains disabled, with the same outstanding
multi-layer/shiny/particle/sub-animation, paired GB actor and import acceptance
work documented above.
