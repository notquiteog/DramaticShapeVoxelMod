# Native GSC surfing provenance

Battle staging read the Gen1 `player.surfing` field. GSC stores locomotion in
`World.playerState`; native Player has no surfing field. Optional Ride may
populate a compatibility marker, but it can lag a same-frame native state
change. Staging now reads public `FieldMoves.isSurfing` for GSC unconditionally,
passes that state to the existing water-arena search and freezes the same value
on the battle's presentation metadata. Gen1 retains its original reader.
No movement, collision, encounter selection or native battle state is changed.

Latest official engine0.3.91 was rechecked before the batch; unmodified core,
Linux NVIDIA LÖVE, isolated profiles, all seven independent mods. The fixture
uses original `World.startBattle` with Cyndaquil20 and wild Tentacool8 on
ROUTE40, facing down, native Surf state, camera4, WORLD backs, distance16 and
shadowsOFF. Selected water cells are7,13 in Gold/Silver and7,17 in Crystal.
All have49/49 water cells in the sampled7×7 neighborhood.

All three editions pass actual water-arena input and render, frozen shore
backdrop selection after the field state changes, and a subsequent Route29 land
presentation that ignores the still-true companion marker. Three final captures
were inspected; native actors/UI remain present over the water scene.
Optional illustrated plates were not installed for this check: selection is
asserted through the live consumer, while captures use the world arena.

Early test reset attempts exposed the stale compatibility marker; the final
native-state precedence fixes that production edge. Final evidence lives in
session scratch `voxel-parity-20261020/surf-provenance-verified-0391`, with driver
`native-gen2-surf-provenance.lua`. Native processes exited cleanly; normal saves
were not written.80 focused backdrop assertions and all16 affected suites pass.
The preceding shared348/0/58 checkpoint predates this narrow change; it is not
relabeled as a new full-suite run.

Johto-specific illustrations and unsupported scenery families remain separate
asset/model work. These Linux checks do not establish physical-device parity.
