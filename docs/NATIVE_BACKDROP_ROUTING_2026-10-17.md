# Native backdrop routing — 2026-10-17

Native Gen3 ARENA FILL now considers the encounter's original resolved terrain,
using public `BattleBg.TERRAIN` names across all five editions. Outdoor water
and ponds select the existing neutral ocean/shore plates; otherwise-unmapped
mountains select the rocky family. Cinnabar and Safari water keep their authored
priorities. Unmapped desert, underwater and indoor scenes retain the world when
no suitable illustration exists. Boss/crop/time handling and all native battle
state remain unchanged. LG-prefixed aliases now normalize alongside FR names;
LeafGreen's actual official imported definitions remain FR-canonical.

Focused backdrop/trainer/light suite: 59 checks pass. Official latest was checked
again on October 17 and remains 0.3.89. Five isolated runtime API fixtures pass
27 native map/terrain cases total, plus missing-image/OFF/WHITE behavior and
unchanged native encounter fields. Actual public native terrain tables and
imported outdoor/gym definitions are used. The fixture initially assumed absent
Hoenn route aliases and nil instead of the existing false no-image sentinel;
those fixture assumptions were corrected before successful runs.

This is API/selection verification, not rendered illustration acceptance: the
optional GEN6 and boss directories contain only their README files. No missing
art was fabricated or copied. Runtime logs and exact release metadata are in
`.scratch/voxel-parity-20261017/backdrop-routing-0389/<game>/` and
`latest-backdrops-release.json`; driver `tools/qa/native-gen3-backdrop-routing.lua`.
All processes ended, isolated QA profiles only, player saves untouched.

Remaining constraints: optional illustration collection, regional boss/location
art, BLUE's compatible Stadium scene provider and native fishing provenance
beyond the resolved terrain. No models, release metadata or published archives
changed. Full feature parity is not claimed.
