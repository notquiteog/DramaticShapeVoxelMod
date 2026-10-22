# Authentic ORAS cargo and truck room finishes

The exact native RSE opening truck now uses genuine ORAS GR653 strapped
dressers and cardboard-box geometry in Modern3D. The three native113 moving
crates use that actual ORAS cardboard model in Modern props mode, preserving
the engine's fractional raiseX/raiseY offsets, height, timing and lifetime.
Walls wrap the original ORAS metal-panel paint around the original native
boundaries. One clean ORAS corrugated-floor band covers the complete80x80
floor, including beneath cargo and closed/open exit cells. No native prop
sprite art is projected onto that floor. Native2D art is unchanged.

## Source and adaptation

User Alpha Sapphire RomFS link:
ZO399 (also535) →AD180 →MM302 →GR653 `sptruck_00_00`.
Model `a/0/3/9` GR0653 slot1; textures `a/0/1/4` AD0180 slot11.
`import_oras_truck_interior.py` independently verifies every original room
submesh position, UV0 and triangle index against Nitrogen. Runtime has no
ROM/converter dependency. Only selected processed geometry, original PNGs
and provenance/hashes are committed.

Selected source physical cargo contains the original312-triangle tall
strapped dresser,288-triangle short strapped dresser and8-triangle cardboard
box. The box's precise missing rear/bottom rectangular faces are closed with
4 triangles using opposite original panel UVs. All original source positions,
UVs and PNG pixels remain; original source vertex alpha is retained. Baked
vertex RGB tint is removed per the user's lighting preference.

The raw ORAS room is approximately126x89, while native RSE is80x80. Importing
the full room indiscriminately would block native walking/exit cells. Each
physical cargo component instead receives one uniform fit within its existing
native blocked rectangle. The15 static placements occupy12 blocked cells;
three other blocked cells belong to native moving-box actors and receive no
duplicate static body. Cardboard instances replace cardboard cargo, dressers
replace the large furniture cargo. The unrelated ORAS Azurill toy, plant and
wrapped wardrobe do not substitute for native cardboard boxes.

Original16-triangle flat-floor and11-triangle metal-panel meshes remain in
the data as finish/UV provenance. Runtime wall backing is the existing closed
native-boundary geometry with continuous source `wall01` paint; this is an
architectural adaptation, not the unchanged ORAS room mesh. The existing
native shutter volume uses the same metal paint and still opens only when
the live native exit metatiles open. The original broad corrugated `yuka`
floor UV band becomes one floor quad, with no cargo, light or shadow artwork.
Floor-light effects, original shadow decals and the untextured entrance-light
plane are excluded. Native room dimensions, collision, warps, sounds, actors,
protected callbacks and scripts are not modified.

## Integration and fallback

No additional Scene hooks are required. `Gen3ImportedInteriors` delegates the
exact complete truck recipe to `Gen3ImportedTruckRoom`, marks it only after
all batches upload, and suppresses its previous whole native cargo model.
`Gen3TruckCargo.draw` first tries the original ORAS box for Modern props;
Voxel/missing-source retains the previous native-source closed crate, and
HD2D retains the ordinary sprite. Native room framing chooses ORAS wall/floor
finishes only in Modern interiors, falling back to native gray panels and the
already-clean native uniform floor if source loading fails. Source textures
remain shared-owned by SceneryModels; cleanup releases only owned meshes.

## Verification

Latest official release checked2026-10-22:
[0.3.95 /2b45436](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Shell `/home/admin/Projects/.scratch/runtime-0.3.95/squashfs-root/bin/love`.
Isolated native engine/mod/profile copies under
`/home/admin/Projects/.scratch/truck-camera-20261022/`, no companions or player
saves, Modern props/interiors and HD2D actors.

Fixture `oras-interior-driver.lua` starts a real fresh native `new_game`
with `fieldCallback='truck'`, without an outdoor override. Full callbacks run
unchanged in R/S/E to frame865. Closed20D/215/21D exit cells become native
open208/210/218 with permission114. Native113 objects retain actual per-frame
offsets. Imported interior placements stay15, source room is `oras_gr653`,
3D remains active, nativeRequired is false and recovery failures remain0.
The driver only restores the public mod update hook skipped by the engine's
test-driver branch; native Game:update executes once per frame as usual.

Captures/logs: `oras-interior-{emerald,ruby,sapphire}/`; exact final guard/cache
changes rerun in `oras-interior-final-emerald/`. Moving/open35-degree, closed
inside-shutter and first-person captures were inspected. Actual original
source renders are in `oras-local-20261022/truck-viewer/`. These rendered
fixtures verify geometry and native callback state, not interactive camera
focus: focus was false in these runs. Earlier focused native camera checks
remain separate evidence documented in the truck cargo record.

Eight focused suites pass: imported truck room, imported public PCs, truck
room/cargo/exterior, Hoenn, Ruby/Sapphire and shared interior walkspace.
The new suite verifies every static placement's full bounding rectangle stays
inside native blocked cells, moving-box cells have no duplicate body,
open/closed/changed native topology guards, unchanged native cell state,
uniform source fit, clean finish selection, source failure, style isolation,
fractional native offsets, reflection/shadow matrices and cached mesh cleanup.
Actual LuaJIT2.1 compiles547 production files; `git diff --check` passes.
Test processes ended and player saves/options are untouched.
