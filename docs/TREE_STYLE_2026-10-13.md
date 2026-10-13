# Source-tree defaults and consistent optional replacements

The Legendary AUTO/FULL presets no longer opt into alternate mature, Cut,
forest or Safari tree artwork. Source-accurate modeled trees remain the cart
default. CUSTOM still restores the user's saved individual choices.

Gen3 mature replacement trees previously fell back to source models whenever
the replacement's low geometry intersected a path or missing edge cell. The
same replacement template now fits into a blocked rectangle; projected edge
anchors use their known blocked root cell when necessary. No collision is
changed. Shared fitted templates retain instanced rendering. Explicit dedicated
forest/Safari families retain priority. Gen2 forest boundary donors now use the
same selected forest family as the adjacent map, with style-aware cache keys.

## Verification

- Official Gen1Recomp 0.3.85, extracted Linux LOVE shell, isolated Emerald QA
  identity `gen3-emerald-lamps-qa`; Oldale and loaded neighboring scenery.
- Source/default and AUTO renders retained source trees; explicit CUSTOM
  replacement and return-to-native switches passed.
- All 750 eligible mature-tree placements in this scene used the selected
  replacement (previously 732/750). Top-down and first-person captures inspected.
- Five focused suites passed: Legendary profile and migration, native mature
  replacement, native forest/Safari replacement, and boundary scenery.
- Path-edge regression checks cover a single blocked root surrounded by
  walkable/missing cells and a projected anchor on its boundary.

Local evidence: `.scratch/tree-style-20261013/emerald-final` in the projects
workspace. This is a scoped Emerald visual check, not an all-map visual audit;
the Gen2 boundary change has focused automated coverage only. Existing explicit
CUSTOM preferences are preserved. No release was published with this change.
