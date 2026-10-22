# Local ORAS scenery source pipeline

`tools/oras_scenery_source.py` audits the user's decrypted ORAS RomFS and exports
selected source rooms/maps for review. It enables no runtime placements and adds
no game or converter dependency to the standalone mod. Raw archives, BCHs, PNGs,
GLBs, inventory JSON and captures stay in scratch, outside the mod checkout.

## Verified native archive links

The two supplied Alpha Sapphire/Omega Ruby dumps have this inventory:

| Purpose | RomFS archive | Logical records | Nonempty subfiles |
| --- | --- | ---: | ---: |
| Zone data (ZO) | `a/0/1/3` | 538 | 538 |
| Area graphics/textures (AD) | `a/0/1/4` | 229 | 229 |
| Separately instanced map objects (BM) | `a/0/2/3` | 380 | 380 |
| Map graphics chunks (GR) | `a/0/3/9` | 857 | 857 |
| Map matrices (MM) | `a/0/4/0` | 431 | 431 |

There are **536 actual ZO records**; the remaining two zone-archive entries are
aggregate tables. The area/object/graphics/matrix archives are byte-identical
between the supplied editions. The zone archive bytes differ, but all parsed
zone→area/matrix links and matrix→GR lists agree.

Use native zone data, not a globally merged texture-name dictionary:

1. ZO slot 0 has the 56-byte zone record. `MapArea` is the u16 at offset 2;
   `MapMatrix` is the u16 at offset 4.
2. The selected MM slot 0 has dimensions at offset 4 and u16 GR indices at
   offset 8. `0xffff` means an empty matrix cell.
3. Selected GR records contain seven slots. Slot 1 is the static room/map BCH;
   slot 0 retains tile permissions and slot 2 retains original `coll` data.
   Other original slots are retained separately, including object instances and
   animation data. The exporter does not bake them into the static model.
4. The selected AD has twelve slots. **Slot 11 supplies GR textures; slot 1
   supplies BM object textures.** Same texture names can have different pixels
   in these two scopes, so merging them is rejected/avoided.

The source for mapGR/mapMatrix archive identities and zone/matrix structures is
[pk3DS](https://github.com/kwsch/pk3DS/tree/6daaca934ca2284a73ab743bf89c848c57cd9de1),
particularly `GARCReference.cs` and `OWSEStructs.cs`. Other archive roles above
were checked against actual container magics, names and complete texture binding.
The often repeated `a/0/2/4` object path is wrong for these dumps: that archive
contains UI layout resources, not the 380 BM records.

## Converter assessment and repairs

The external, unmodified
[n3ds_importer](https://github.com/sxrmss/n3ds_importer/tree/a68959eae2f476526845a78af6990648cfe3434d)
checkout is supplied explicitly with `--decoder`. Its pure Python CTR layer
works without Blender/Maya, but two defects were reproduced and corrected by
the adapter:

- BCH backward version `0x21` uses a **44-byte** inline material identity record,
  with a pointer to texture mappers. The decoder assumed the older 88-byte
  layout, producing corrupt names such as `CH`. The adapter reads source
  material/texture names using the reviewed version's layout. Geometry export
  rejects other BCH versions until they are reviewed.
- Its ETC1 routine expects network-order color blocks, whereas this 3DS source
  stores each 64-bit color word little endian. The adapter reverses each color
  word before decoding; ETC1A4 alpha words remain unchanged. Without this repair,
  original gray floor tiles rendered as colored noise.

[SPICA](https://github.com/gdkchan/SPICA/tree/bd29a7828595d7839cda2ac61c76bb63f9071250)
is the permissively licensed reference for BCH material versioning and ETC block
handling. Its application uses .NET/OpenTK; it was read as a reference, not
installed as a runtime dependency. No SPICA or n3ds_importer code is vendored.
The latter is GPL-3.0; keep its license with its external checkout.

[nitrogen](https://github.com/jorgecafe/nitrogen/tree/e22879d8e2cf7835c43ab3a7ccc73ac1218b4ec1)
was useful as an independent decoder. It is a young repository (two commits at
review), whose metadata declares MIT but whose checkout has no standalone
license text. It remains scratch-only. Its README's validation claims were not
treated as evidence for our source: local byte/attribute comparisons were run.

The in-repo archive parser independently validates GARC v4 sizes, section
boundaries, FATO offsets, FATB bit positions (including sparse bits), original
logical IDs, mini-container offsets, LZ10/LZ11 back references and output budgets.
Inner binary records are never classified as compressed merely because their
first byte happens to be `0x10`/`0x11` (real map types can have those values).

## Usage

After separately dumping/decrypting a user's local game, keep the RomFS and
external decoder in scratch. No ROM download, key retrieval or automatic
converter installation is performed by this tool.

```sh
python3 tools/oras_scenery_source.py /scratch/romfs inventory \
  --output /scratch/scenery-inventory.json
python3 tools/oras_scenery_source.py /scratch/romfs zone 345 \
  --decoder /scratch/n3ds_importer --output /scratch/review-zone345
```

The zone output includes original selected BCHs/record slots, source archive
hashes, decoder source-tree hash, exact decoded RGBA hashes, and review GLBs.
GLBs retain original positions, UVs, vertex RGBA and material/texture names.
Only the base texture/color pass is approximated: PICA TEV, alpha/cull/sampler
state and animations need source review before runtime use. Current exports
reject bone-bearing models instead of silently discarding their transforms.
Matrix placement is recorded in the inventory and is not applied to GLBs.

## Evidence and remaining work

- Seven source-room GPU captures inspected with the approved official 0.3.95
  native LÖVE shell (11.5): front/right/back/left/quarter/top/low eye.
  **ZO345 → AD148 → MM255 → GR600**, `c108r0301_00_00`, 24 submeshes,
  5,561 triangles. Original floor, wallpaper, windows, cabinets, table/chairs,
  potted plants and vertex lighting decode coherently after the ETC repair.
- The source has open/cutaway wall backs and intentionally omits separately
  instanced objects. It is not yet a closed standalone room or a native GBA
  map replacement. Keep furniture separate and preserve native GBA boundaries,
  warp openings and clearance when selecting parts later.
- ZO6 → AD8 → MM1 exported all six selected outdoor chunks with complete source
  texture binding. Their matrix placement and BM objects are not assembled.
- Independent GARC/LZ/GR extraction matched SHA256 for **all 4,683 nonempty map
  leaves**, including 953 BCH leaves, against nitrogen output.
- Independent BCH comparison matched names, material identities, vertex counts,
  positions and UVs across ten representative GR models (**96,166 vertices**).
  Decoded RGBA was byte-exact for **163 textures** from AD8/24/148 slots1/11,
  including ETC1 and ETC1A4.
- `python3 tests/oras_scenery_source_test.py`: seven ROM-free checks pass, covering
  corrupt offsets, sparse IDs, invalid LZ back references, binary false positives,
  matrix holes, ETC alpha preservation, and GLB index/texture/channel validation.

Scratch evidence is under the dated local ORAS source workspace: inventories,
`independent-validation.json`, `decoder-validation.json`, `review-zone345-verified`,
`review-zone006`, `review-viewer` and `review-renders`. No source game data or
captures are included in this commit.

Vegetation leads shared with the tree-import agent: BM5 `t101_bm_trees` uses
`chip_wood_a/b` in AD8/31/32 slot1 (six bones); BM91 `c108_bm_tree01` uses
`c108a_wood` in AD24/202/203 slot1 (two bones). BM92 `d112_bm_flower01` uses
`d112_higan`/`d112r05_kuki` in AD67–71 slot1 (two bones). These require proper bone
transforms and source/native footprint review before placement.
