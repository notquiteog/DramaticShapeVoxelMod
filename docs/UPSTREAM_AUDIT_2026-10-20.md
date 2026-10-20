# Seven-mod upstream check — 2026-10-20

Fetched all seven origin/main branches and each configured upstream. No origin
commits were missing locally. The voxel checkout's additional local commit was
preserved. No implementation changes or releases were needed by this audit.

| Mod | Original source checked | Result |
| --- | --- | --- |
| Battle Art voxel | absol89/DramaticShapeVoxelMod, master a07146b | Entire current upstream branch is an ancestor of our main. |
| Kanto Wilds | YoDrehDenSwagAuf/overworld-spawn-mod, main e66e03d5 | Entire current upstream branch is an ancestor of our main. |
| Double Battles | shanehudson-gen1recomp-mods/monorepo, double_battles path b66f3c7, version 0.6.1 | Latest original lead-choice/partner preservation fix is already included. The separate release mirror has only README history; it is not the source branch. |
| Wild Skies | Same monorepo, wild_skies path 79bb106, version 1.12.1 | Latest original missing-player-cell fix is already imported, documented in our 1.12.2 entry. Configured mirror branch is also fully included. |
| Online Plus | gamecorner-033/Gen1Online, master a5251ee | No later direct-source changes. Original fork root b9d033a shares 41 byte-identical files out of 45; the other four contain documented fork edits. |
| Dramatic Sky Ride | Original burgerslayer7/dramatic-sky-ride and README's mfrtechconsult/dramatic-sky-ride | Both GitHub URLs return 404. Last retained source 759f521/version 0.2.18 is already imported: its main.lua matches our initial fork, with the manifest version changed. Cannot certify inaccessible newer upstream work. |
| Modern UI | notquiteog/modern-ui main bcde575 | Authoritative repository is current; no separate parent/upstream is declared. |

Online's credited foundation alamops/RBYMMOMod was also inspected at ea822a5.
It is not this fork's direct source: its current CoopBattle/MediatedBattle,
custom simulators and Node/TCP hub differ from Online Plus's native battle UI,
engine simulator and ENet transport. Its latest sprite/HP/packet-size changes
address modules absent here. No unrelated history or alternate architecture was
merged. The original Online snapshot's excluded assets/archive were not mistaken
for subsequent upstream code changes.

Checks were Git ancestry, GitHub source/path commit metadata, source comparison
and existing integration history. No runtime test claim is made for this
read-only source audit. Model development remains with its separate owner.
