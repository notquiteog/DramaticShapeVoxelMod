# Regional source-model integration1.58.0

This batch integrates the separate Kanto, Hoenn and interior source queues on
top of Portable API3 release1.57.12. All five GBA editions retain original map
cells, collision, elevations, portals and native underlays. Characters, Pokémon
and flowers retain HD2D defaults. Companion mods remain optional.

## Source scope

- FRLG: original HGSS Lavender houses/Name Rater, Saffron blocks/Gym/Dojo,
  Copycat/Mr Psychic, Celadon blocks, regional Marts and standard Center doors.
  The original Museum solid steps remain intact.
- RSE: original ORAS Rustboro homes/flats/school and Devon, own Slateport Mart,
  Oceanic Museum and Harbor, including original materials/door tracks and
  native admission. Source rears, undersides and contact planes are closed.
- Interiors: original ORAS cupboards, sinks, bookcases, cases/cartons, Emerald
  floor cushions and Mt. Pyre memorials; BDSP institutional server racks.
  Native archive boxes stay below their room ceilings. Flat wall/floor ownership
  and original room traversal remain authoritative.

Detailed source identities, closure edits and earlier review evidence remain in
individual source documents and provenance files. No ROMs, raw import archives,
test captures or generated playthrough caches belong in the release ZIP.

## Measured inventory and limits

The current FRLG exterior ledger records79 source-eligible and72 historically
reviewed assemblies of133 recognized assemblies per edition;54 recognized
assemblies still lack a candidate. These are building/component counts, not
whole-map completion percentages. The Hoenn ledger records127 candidates of244
recognized civic placements;117 remain unmatched. Unrecognized art is additional.

The interior acceptance ledger contains2056 reviewed component records across
274 edition/map pairs, up from127 records before queue integration. Older broad
reviews retain their actual0.3.95 labels. The complete2161-map inventory still
marks whole-map acceptance false. Eligibility, accepted components and complete
rooms must remain distinct. The most recent JSONL ledgers supersede older
introductory prose totals in the historical source documents.

## Current engine verification

Latest official release checked before verification: Gen1Recomp0.3.96, matching
Linux LÖVE11.5 native shell. Disposable fixtures only; player saves untouched.

- Root combined source suite:486 pass,0 fail,58 explicitly missing external
  fixture skips. All639 production Lua files compile under native LuaJIT2.1.
- Hoenn merged API3 queue:15 source jobs/30 placements,15 native entry jobs/36
  entrances and normal returns pass across RSE. All cached poses, contact
  insets and atomic failure cleanup pass; source/native hashes remain unchanged.
- Kanto merged API3 queue: Mr Psychic/Copycat in both editions,8 source
  placements,4 real entry/return pairs and4 nonenterable connection projections
  pass. Original sources, doors, walkable approaches and hashes remain intact.
- Interior merged API3 queue:6 original case/carton views,6 missing-source
  fallback cases and54 Emerald cushions across13 rooms pass; all16 imported
  source plane checks pass. Two existing entry-script changes remain documented.
- Root all-seven-mod integration: actual Celadon/Cerulean Center, Emerald Harbor,
  Ruby Devon and Sapphire Museum entries/returns pass with zero loader/runtime
  errors or removed-API reports. Representative final overview captures inspected.
- Exact release ZIP compatibility checks and checksums are attached to the release.

This is incremental source-model coverage. It does not certify every room,
all gameplay/multiplayer paths, Android hardware or complete AAA polish.
The agents continue with remaining native/source families after this frozen batch.

Current source rechecks: [Kanto](KANTO_API3_SOURCE_RECHECK_2026-10-23.md),
[Hoenn](ORAS_QUEUED_EXTERIORS_API3_2026-10-23.md),
[interiors](INTERIOR_API3_QUEUE_RECHECK_2026-10-23.md).
