# Native XD option parity — 2026-10-22

Found and fixed a concrete settings gap: Gen3XDActors could consume the selected
XD pack, but Gen3Integration omitted XDModels.setting from its shared schema and
live native controls. The setting also escaped SettingsCatalog and category
coverage. FR/LG/Ru/Sa/E now register the same OFF-by-default setting as R/B/Y/G/S/C,
under POKEMON ART. Selected pack validation and fallback are unchanged.

Verification uses official Gen1Recomp0.3.95 source and the LÖVE11.5 shell from
the0.3.89 AppImage, NVIDIA, isolated test profiles with all seven mods. All five
Gen3 editions pass native row uniqueness, OFF default, live ON, engine option
persistence, absent/unvalidated-pack fallback and restoration to OFF. Ruby and
Sapphire require cartridge-native rows when constructing the native page; the
initial fixture omitted them, and passed after following that native contract.
These are runtime control checks, not visual XD model or phone acceptance.

Focused LuaJIT suites pass: option_categories, native_live_options,
native_option_arguments, xd_gen3_actors and stadium_models_api (18 checks).
Audit TSV/JSON now include XD's actual remaining limitations and reflect the
already-delivered richer-color RS indexed hatch quantization correctly.

The remaining non-model boundaries remain those in PARITY_BATCH_2026-10-22:
authoritative simultaneous particle owners and GSC recall cues are absent from
the official engine, unrestricted RGBA/oversized RS hatch compositor insertion
is unavailable, and special pose/identity/optional provider assets must exist.
XD material/animation/import readiness is independently unfinished; exposing a
setting does not make unvalidated packs ready. No native gameplay or models were
changed here, and no full parity or physical-device claim is made.
