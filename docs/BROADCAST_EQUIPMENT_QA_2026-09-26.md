# Broadcast rooms and Rocket equipment — 1.28.9

Native source art determines the models. Crystal's receiver crops include an empty eight-pixel apron; the old generic case sampled it as cabinet material. Dedicated models sample only the equipment. The complete 48x24 studio desk matches before partial receiver/counter recipes. Broadcast stools now use rounded low cushions, separate legs and the original red/pink colors; their support stays four world pixels.

The FRLG Rocket processing machine claims its full 3x3 drawing, including the source wall strip, before wall folding. It has a closed stepped vessel and chassis, seven separate radiator fins, recessed controls, side fittings and feet. The source wall strip is not pasted onto the machine. Matching is pair-local and all-or-none. Added the complete executive-desk variant. Fifteen previously flat teal partition pieces gain room geometry with Rocket's floor donor; walkable copies remain flat and Silph's separate cream-wall family retains its blue floor.

## Evidence

Engine: official Gen1Recomp 0.3.22, Linux LÖVE under Xvfb, isolated `ascendant-*-qa` identities with all five companions and Wild Skies enabled. Native imported Crystal/FireRed/LeafGreen/Yellow; normal player saves/settings and installed carts untouched.

Scratch root: `/home/admin/Projects/.scratch/ascendant-20260926`.

- Native references: `results/crystal-industrial-source/RADIO_TOWER_5F.*` and `results/firered-industrial-source/FR_ROCKET_HIDEOUT_B4F.*`.
- `studio-before.lua`: reproduces generic radio equipment and flat Rocket machine/partition drawings.
- `studio-atlas.lua`: native and drawn atlas captures isolate source sampling from palette/texture corruption.
- `studio-after.lua`: initial models; review caught a rust-colored chassis sample and the oversized generic radio chair. Both were corrected before release.
- `studio-release.lua`: static, orbit/rear and first-person captures at Crystal Radio Tower 5F `(4,7)` and Lavender Radio Tower 1F `(3,5)`; FRLG Rocket B4F `(2,22)` and Silph 3F `(16,11)`; Yellow Oak's Lab `(5,8)`. Inputs reset every frame, camera locked during stationary views. Native map tile/collision signatures remain identical. Both GBA editions assert three complete processing machines in B4F after normal tileset binding. Earlier fixture-only failures called a nonexistent invalidation helper and queried LeafGreen aliases before drawing; the driver was corrected.
- Inspected native renders show closed machine bodies, separate fins, gray receiver cabinets, low stools and upright Rocket partitions. Silph's existing wall/terminal family and Yellow's lab remain rendered.
- Tests: `broadcast_equipment_test.lua`, `designed_interiors_test.lua` (160 complete designs), `gen2_depth_furniture_test.lua` (62 crops, 36 assemblies), `gen3_additional_furniture_test.lua` (19 complete drawings), `industrial_props_test.lua`, production LuaJIT compilation and whitespace checks.

These are stationary native rendering fixtures and focused structural regressions, not manual gameplay or full-map certification. Unmatched desk variants, remaining flat equipment/partitions, other specialty interiors, Gen3 world-space battle actors and five-mod multiplayer parity remain in the backlog. Mesh revision 81 invalidates earlier scenery. No ROM art, screenshots, save files or generated cache are bundled.
