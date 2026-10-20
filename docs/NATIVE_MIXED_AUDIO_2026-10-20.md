# Mixed native release audio — 2026-10-20

A single original GBA release cue can refer to both normal and shiny battlers.
Previously that known mixed group always retained native sound. The consumer
now deduplicates exact variants and uses grouped optional playback. All source
files/clones/volumes are prepared first; a failed start stops/releases only that
group and leaves unrelated playing voices intact before native fallback.
Successful groups retain the12-voice limit, native SFX master, selected volume,
battle lifecycle and OFF cleanup. An explicit Source:play false result now also
counts as failure on the single-source path.

Official0.3.91 native FR/LG/Ru/Sa/E original paired intros pass:

| Case | Variant attempts | Replaced cues | Native cues |
| --- | ---: | ---: | ---: |
| Normal | 2 | 2 | 0 |
| Shiny | 2 | 2 | 0 |
| Mixed | 3 | 2 | 0 |
| Mixed failure | 3 | 0 | 2 |
| Failed | 2 | 0 | 2 |
| OFF | 0 | 0 | 2 |

The two sides each issue one native cue; the mixed side requires two variants.
The fixture substitutes a playback sink, not an audio recording or bundled asset
pack. It verifies original intro completion, variant routing and suppression;
focused source tests verify missing files, clone/start exceptions, explicitfalse
play results, rollback, live gain and cleanup. Unknown actor ownership and
caller-supplied mixer options still use original sound.

All seven companions enabled, isolated QA profiles, Pallet or Littleroot,480×320,
camera35, shadowsOFF, distance16. Five final mixed captures inspected with all
four native actors/HUDs present. This is not broad environment/model visual QA.
Scratch: `voxel-parity-20261020/mixed-audio-0391`; driver
`native-gen3-mixed-audio.lua`. Native NVIDIA shell, official unmodified engine
core; QA harness support has the previously documented older provenance.
No physical Android/iOS or audible optional-file validation is claimed.
