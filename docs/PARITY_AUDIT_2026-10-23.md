# Feature/options parity audit — 2026-10-23

Full parity is not complete. This audit compares the current source consumers,
not only registrations, across R/B/Y, G/S/C and FR/LG/Ru/Sa/E. It supersedes old
control counts, not historical runtime evidence. Model coverage remains with
its separate owner; no model or optimization code is changed by this batch.

## Concrete fix

All eight VisualStyles preferences were registered after main.lua's early Gen3
return. Native Gen3 consumers read their defaults but the native schema had no
editable controls or public style export. Gen3Integration now registers those
same live settings, exports the shared policy and invalidates scene/shadows on
changes. WORLD and POKEMON ART categories match existing menus. This closes a
settings adapter gap; it does not implement every style/category renderer.

All five native Gen3 editions pass eight-row uniqueness/editability, live
getter changes, persisted options, scene/shadow invalidation and restoration.
Official0.3.95 source/LÖVE11.5 shell from0.3.89, NVIDIA, isolated seven-mod
profiles. These are native API/control checks, not scenery appearance/mobile
acceptance. Four focused Lua suites pass: option_categories, visual_styles,
native_live_options and native_option_arguments.

## Reconciled inventory

Eight previously omitted controls bring the catalog to132 per generation.

| Generation | Implemented consumer | Partial | Missing consumer | Optional provider | Other engine | Alias |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
|1|112|5|4|5|6|0|
|2|67|49|5|6|2|3|
|3|71|49|2|6|0|4|

These are option rows, not independent feature counts or visual-certification
counts. One unfinished feature can account for many settings. Gen1 is not a
complete baseline for the newly added three-way style controls either.

Explicit newly inventoried gaps: GB building/flower/interior style consumers;
all-generation three-way terrain styles (Gen2 only gates a menu row); Gen3 field
character style consumer. Existing original presentation remains. Legacy native
TREE ART/TREE TRUNKS/ROCKS & PLANTS preferences are overridden by the newer
TREE STYLE/PROP STYLE policy, so are recorded as aliases, not independent fully
working controls. Existing tree/prop/model-family shortcomings remain partial.

## Remaining non-model functional boundaries

- XD: multi-layer texture combiners, shiny interpretation, particle and
  shape/sub-animation composition, verified authored path timing, paired GB
  actor ownership and completed portable import/install UX. Native move/form
  identity and guarded failures are implemented; renderReady remains false.
- Official engine seams: authoritative simultaneous GBA particle ownership,
  a GSC recall presentation cue, and unrestricted RGBA/large RS hatch insertion
  that preserves its native indexed compositor. Supported fallbacks remain.
- Optional providers/assets: matching boss/location plates, cave/Ember audio,
  trainer/model providers and special identity/pose art must exist. An exposed
  option cannot manufacture these assets or a provider's generation support.
- Verification: physical Android/iOS/Windows and exhaustive edition-specific
  gameplay/visual acceptance remain unverified. Shared generation consumers are
  not proof that all eleven games received complete device acceptance.

See OPTION_PARITY.tsv/option-support.json for exact consumers and limitations,
XD_IMPORT_STATUS.md for unfinished importer work and PARITY_BATCH_2026-10-22.md
for native engine boundaries. Model coverage and165FPS performance completion
are not certified by this options audit.
