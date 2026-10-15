# Starting-region Centers and Marts — 2026-10-15

## Scope and construction

The user prioritized Center/Mart polish during the first-three-settlement pass.
This batch covers both Center floors and the Mart in Viridian and Pewter
(FireRed/LeafGreen), and Oldale and Petalburg (Emerald/Ruby/Sapphire): **30 native
edition-map placements**. The same complete native corner families can be reused
by other rooms and third-party regions through the existing tileset alias API.
Unrecognized corner drawings retain the existing room renderer.

Native source diagrams for each edition supply the corner cuts, wallpaper,
fixture positions, floor patterns and original materials. Joined polygon walls
replace the rectangular shell; flat north walls sit behind the machines rather
than folding around furniture. The floor, foundation and ceiling follow the
same chamfers. Native walkable lower-corner centers stay inside the perimeter;
source blank padding is excluded. Exits and descending escalator wells stay open.

Wallpaper is composed once from native BG layers and continues around the room.
One-row native Mart wall art stretches vertically once, rather than repeating
its cap halfway down the wall. Original windows, columns, maps and monitors stay
separate, with closed backing and small depth offsets. No imported pixels or
replacement textures are shipped.

The healer has a closed beveled white arch with an open center, side posts,
control surfaces and the original low seven-unit tray. Native healing animation,
party count and timing remain engine-owned; its monitor follows the new screen
plane. Registers face west toward their native clerks and have closed drawers,
upright displays, sloped key beds and individual keys. Rear Mart glazing has
real cases/frames; the Hoenn clock is retained. Kanto racks, the low glass case
and counter edges stop before the native walking rows. Every escalator component,
including decorative rail/source faces, fits the native middle flight/warp row.

Characters, Pokémon and flowers remain HD-2D. Native UI, scripts, movement,
collision, quests and warps are unchanged; every partner remains optional.

## Verification

Official Gen1Recomp 0.3.89, checked before the batch. Disposable imported profiles
only; no player Continue save is overwritten. Scratch captures and native source
pixels are excluded from Git and releases.

- Broad regression suite: 307 passed, zero failures, 58 missing-fixture skips.
- Polygon regression checks: exact native corner matching/stand-down, closed
  miter joins, padding, native walking centers, open descending wells, clipped
  UVs and no wall folding into the healing bay.
- Register regression checks: closed drawer/display/wedge, sloped keys, source
  UV bounds and native service-cell clearance.
- Native census across all 30 placements: 560 existing/new component instances,
  zero ordinary-solid face overlaps into native walking cells. 118 native low
  seat pads are explicit separate exceptions, plus the original low Kanto
  counter stool patches; decorative foliage is not classified as furniture solid.
- Front, sides, rear and low-eye rendered views inspected independently in all
  five editions, including Emerald's upper counters and RS privacy booths.
- Native input, exact archive and optional-partner evidence is recorded below
  after package verification.

Early QA fixtures selected a decorative FRLG exit-apron warp instead of the
native south-arrow tile, assumed Hoenn's customer approach for the Kanto clerk,
and expected a shop menu during the fresh Viridian Oak's Parcel branch. These
failed fixture attempts are not passes. Final input uses native arrow behaviors
and counter/clerk positions, preserving the Parcel script instead of forcing
quest flags or replacing native callbacks/VMs.

## Coverage limits

This release completes the service-room polish batch within the larger regional
request. Other homes, gyms, route buildings and regional terrain remain in the
map-by-map queue. The initial source/render capture survey includes all 125
requested edition-map placements; captured maps are not automatically marked as
visually verified or corrected. No complete regional/ORAS-equivalent coverage or
multiplayer-network validation is claimed.
