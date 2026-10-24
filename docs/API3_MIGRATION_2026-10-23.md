# Portable API 3 migration — 2026-10-23

Target: official Gen1Recomp v0.3.96, `modApi = 3`. Battle Art declares API3
and requires engine0.3.96 or newer (development builds remain permitted).
This is an interface migration; it does not certify complete scenery or
feature parity across every edition.

## Corrected boundaries

- The live game is read from documented `mod.game`. Portable `mod.world`
  deliberately has no `.game` member; native GSC send-out ownership now uses
  the current owner without retaining a stale facade.
- Crystal species patches use portable Gen2 fields. Gen1-only battle-scale
  fields stay on the Gen1 branch. Detached content reads are never mutated
  for runtime color changes: the public `pokemon.sprite` context supplies
  the current true-color choice. Optional providers resolve through `mod.find`.
- API3 rejects unknown engine hook names. Battle Art's own HUD registers its
  claim through `battlePresentation.registerSuppression(owner, callback,
  priority)`; owner replacement, unsubscribe, failure isolation and unload are
  bounded. The existing version1 suppression hook remains a compatibility
  reader for older API1/2 consumers, without API3 subscriptions to it.
- Ambient-audio cleanup uses `core.update` and `core.quit_to_launcher`, rather
  than assigning `love.update`.
- Every generation registers settings through `ui.options.rows`. Native GBA
  category pages use registered `content.screens`, `mod.ui.push` and public
  ListMenu input/lifecycle. Edition-native GBA window/font drawing decorates the
  instance because the stock public GB font is absent from native GBA imports.
  No native `option_rows.build` or `group` replacement remains.
- Persistent mesh bytes use installation-scoped `mod.cache`, with a bounded
  version-specific index (32,768 keys/4MiB index). It validates paths, separates
  editions and removes an unindexed new blob if index persistence fails.
  Runtime diagnostics also use `mod.cache`; asset checks use scoped
  `mod.assets:info`. API3 does not fabricate a save/playthrough for derived data.

## Intentional native access

`engine_internals` remains declared for the terrain/battle renderer, native
sprite/animation readers, free-camera collision integration, and GBA font/window
artwork. API3 has no equivalent full Gen3 field-render replacement or native GBA
widget font. Existing Gen2 render facades remain where they provide native
art/collision data; this is not a claim that the renderer runs without internals.
Older-engine adapters remain for isolated legacy regression fixtures, but the
API3 path selects the current services and is checked for removed-call reports.

## Verification

The current official SDK is used for source contracts. Focused tests cover
public option registration/persistence/unload, native send-out ownership,
optional presentation-owner replacement/failure/unload, installation-cache
version separation/restart/deletion/key validation/failed-index rollback, and
existing mesh formats. Native matrix and final artifact results are recorded
with the ecosystem release so source checks and packaged checks remain distinct.
The API3 native driver checks loaded manifest levels, world service records,
actual field rendering, real options-row dispatch/opened GBA screens, loader and
runtime errors, and `loader:legacyReport` on each exercised path. Detailed flying,
organic encounter, battle and online contracts belong to their standalone mods.
