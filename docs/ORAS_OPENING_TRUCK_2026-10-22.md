# Authentic ORAS opening truck

The native RSE Littleroot outdoor truck actor94 can render genuine ORAS
BM0006 `t101_bm_truck` with its original cabin, wheels, lettering, open rear
doors and visible interior cargo. This replaces the48x48 upright sprite only
in Modern3D props mode. Other modes, maps, actors, changed source frame
dimensions, unavailable data and upload failures retain the ordinary sprite.
The engine owns visibility, position, scripts, collision and lifetime.

## Source

User Alpha Sapphire RomFS `a/0/2/3` BM0006 slot0 and native Littleroot AD0008
slot1 from `a/0/1/4`. Only selected processed geometry, original `track` and
`in` PNGs, hashes and provenance are committed. The exporter independently
compares all source positions, UV0, indices, rigid palettes and the three
identity inverse binds against Nitrogen. No converter or raw game archive
is a runtime dependency.

All2104 original physical triangles remain. User-requested clean lighting
removes original baked vertex RGB tint,136 cargo-shadow overlay triangles
and54 ground-shadow sheet triangles. Original UVs, texture pixels and vertex
alpha remain. Two precise planar underside boundary rings (4 and6 vertices)
are closed with6 triangles using their source edge UVs. Original loading
openings are retained. The source underbody edge proves the truck's original
longitudinal heading: a rigid Y rotation aligns the cabin left/rear right,
then a single uniform fit retains every source proportion. ORAS source has
open loading doors in its bind pose; its TEV or texture/skeletal animation
is not emulated by this exterior helper.

## Integration

The Gen3 scene calls the exterior helper after resolving native actor height and before drawing the ordinary sprite:

```lua
if V.require('Gen3TruckExterior').draw(
 gid,x,z+(opts.depthOffset or 0),height,spr,frame,draw,reflectPlane
)then return end
```

Scene invalidation/release calls `.clear()` alongside TruckCargo/Boats.
The exact guard requires native94, the original48x48 inanimate single-frame
drawing, R/S/E, and Littleroot's `general__petalburg` layout. No map cells or
native sprite resources are changed, and no source truck paint is present in
the native town terrain, so terrain suppression is unnecessary.

## Verification

Latest official release checked again2026-10-22:
[engine0.3.95 /2b45436](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Native executable: `/home/admin/Projects/.scratch/runtime-0.3.95/squashfs-root/bin/love`.
Isolated full engine/mod/profile copies under
`/home/admin/Projects/.scratch/truck-camera-20261022/`; no companions or player
saves. Modern3D props and HD2D actors. Fixture `exterior-audit.lua` starts a
fresh Littleroot map at(5,11), facing left. It records actor94 at(2,10) and
(11,10), original48x48 frame metadata, and nearby native metatiles/permissions.
This generic fixture does not set story visibility flags, so both trucks may
be visible: the helper does not decide which one exists.

R/S/E rendered captures inspected:
`exterior-modern-emerald-v2/modern.png`, `exterior-modern-ruby/modern.png`,
`exterior-modern-sapphire/{side,reverse}.png`. Front, side and open loading
rear are visible; source texture/body, native lawn, walking apron and nearby
houses remain intact. R/S source replacement counters reach1368 draws without
an error. Source-only rotated views are also retained in
`oras-local-20261022/truck-exterior-viewer/`. These are inspected native
rendered fixtures, not interactive focus or story-completion evidence.

`gen3_truck_exterior_test.lua` verifies source topology and uniform fit,
actor/map/art/style isolation, native fractional motion and height,
reflection/shadow matrices, immutable caching, cleanup and atomic failed-source
fallback. Existing cargo/room/Hoenn suites remain green; actual LuaJIT2.1
compilation and `git diff --check` pass. Runtime copies and captures stay in
scratch; test processes ended and player settings/saves are untouched.

The distinct authentic ORAS room was also identified as zone399 (also535)
→AD180→matrix302→GR653 `sptruck_00_00`. Its separate wall/floor/cargo conversion
is the next batch; this exterior commit makes no claim to replace that room.

Root integration verification: the merged scene, rather than a worker-only
override, rendered Emerald native/front/side/rear views in official0.3.95.
The ORAS helper completed810 draws with no reported error. Original actor94
positions remained(2,10)/(11,10); both source loading bays, wheels and rear
doors were inspected. Fixture story flags remain intentionally unadvanced.
