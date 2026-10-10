## 2026-10-09 refresh

Fetched all seven partner origin remotes: no missing origin commits at audit.
Fetched absol89/master, Wilds upstream/main and Skies upstream/main: all commits
already contained. All72 literal upstream setting keys retained; all7 manifests
have no required dependency. These are inventory assertions, not runtime parity.
Kanto reference Git fetch failed with repository-not-found/authentication errors;
its cached checkout remains available, but current revision is NOT confirmed.

Focused checks passed: Ride native Gen3 HUD; Online native room rendering across
three generations and activity-safe walk-up menu; Wilds standalone follower boot
and catching-HUD ownership. Broader live networking, every menu, special moves
and all mod combinations remain unverified. Modern UI agent committed verified
Gen1/2 party UI ff9945c; remaining specialized screens are still open.

Added optional Gen3 scenery alias API for region authors deliberately reusing
known tile layouts, with owner guards, disposal and cache invalidation. See
CUSTOM_REGION_SCENERY.md. No new hard dependency; no gameplay UI restyling.

# Upstream and independent-mod audit — 2026-10-04

All 72 literal ModSetting keys declared in absol89's current upstream/master
are retained in SettingsCatalog. Restored VIRIDIAN FOREST's upstream label;
persisted keys/values are unchanged. Legendary Visuals presets and migration
remain available. This is inventory parity, not complete native-world parity:
OptionSupport still records incomplete Gen2/3 Legendary geometry families.

Fetched configured remotes. Battle Art includes all upstream/master commits;
Wild Skies and overworld-spawn include their configured upstream/main histories.
All five partner forks matched their origin/main when inspected. Ride and doubles
have old upstream refs without configured remotes; those histories were not
blindly merged. Future upstream changes still need compatibility review.

Gameplay/scenery mods now require an optional, enabled Modern Pokemon UI public
provider before activating their modern battle HUD, hidden-panel or textbox
styling options. Without that provider their UI gates return native behavior.
All old preference keys remain, so installing/removing the UI provider does not
destroy preferences. No mandatory mod dependencies were added. The manifest
independence and upstream key checks are repeatable with
`python3 tools/audit_partner_contracts.py` in the shared project workspace.

## Evidence and limits

- Focused UI gate, textbox, native option consumer, Gen2/3 battle option and
  doubles adapter tests pass. Legendary preset/migration checks pass.
- Official engine 0.3.51 Emerald battle fixture: native settings row toggles
  Modern UI, native chrome returns on OFF, projected cards/commands return on ON.
  Inspected both captures. Separate profile with ONLY Modern UI loaded also
  boots and toggles the native silver healthbox palette; capture inspected.
- Standalone mocked adapters cover Gen1/2/3 and uninstall. Gen1/2 standalone
  visuals, wide battle layouts, and the full attack/capture/transition matrix
  are not visually verified this round. The old Legendary full SDK suite needs
  `tests.modkit`, absent from the current official engine fixture.
- Full game-wide native-UI ownership audit is unfinished (legacy forced-layout
  paths, integrated sprite packs and all partner overlays). Do not claim NONE
  of the existing code can affect UI yet.
- Modern UI is a local preview, not a finished replacement for every menu.
- Kanto/Ascendant comparison is in ASCENDANT_FEATURE_PARITY.md; live exterior
  window views and all special world families are not complete.

Runtime fixtures/captures: `.scratch/coverage-20261004/modern-ui*.lua` and
`results/emerald-modern-ui*`. Isolated profiles only; no player saves changed.
