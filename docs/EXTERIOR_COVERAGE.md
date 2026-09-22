# Exterior reconstruction work

Unreleased working tree, tested on the actual Linux Gen1Recomp0.2.73 payload.
Native art is read through the live engine providers; no imported pixels or
ROMs are shipped. Gameplay collision, warps and source cells are unchanged.

## Source coverage

The native catalogue contains77 Crystal and76 FireRed outdoor maps. The
[per-map queue](coverage/exterior-maps.csv) records whole-drawing matches:
244 Crystal placements and103 FireRed placements. These include decorative
houses without entrances. A zero does not imply that the map has no buildings;
it means the new whole-drawing matcher has no result there. Earlier Pallet
models and generic column models are counted separately in the tile ledger.
All per-map visual sign-offs remain pending until their complete exterior
contents have been reviewed, not just the matched families.

Crystal square brick/plaster buildings preserve source door/sign arrangements.
Brown timber roofs keep their own treatment; Kanto small houses retain their
roof window band at the correct height. Side/rear masonry continues the facade
material without duplicating front entrances or signs.

FireRed civic roofs/facades are separated into their actual source rectangles.
Gyms have flat centers with narrow edge bevels. House families retain native
roof/facade artwork. Alternate Center/Mart designs and Viridian chimneys have
separate treatments. Inferred side/rear window placement does not claim to be
an original rear elevation, because the native 2D game does not supply one.

## Lavender Tower and surrounding terrain

The tower's top eight rows live in the connected Route10 map. They are matched
and claimed together with Lavender's lower seven rows. Its green dome, antenna
and faceted upper body sit above a full rectangular48-unit masonry podium.
The source doorway remains on the front. The podium reaches the native cliff
boundaries instead of leaving diagonal gaps at the base.

Reviewed General cliff art becomes32-unit rock masses. Shared boundary heights
keep neighboring cells joined; a4-unit steep bevel returns exposed edges to
ground. Cliff edges touching the actual tower base stay raised. The claimed
upper source drawing behind the tower does not masquerade as solid masonry.
Native rock cap/face textures follow the appropriate horizontal axis.

This is not yet a general walkable elevation system: paths, actors, collision,
small grass/sand jump ledges and unrelated tiles retain their existing heights.
Multi-level terrain, embedded cave entrances and specialty cliff families still
need dedicated review. Do not describe all FireRed terrain as complete.

## Verification and remaining work

- 244 Crystal placements captured from four sides; latest Kanto roof correction
 has separate focused captures.
- 93 initial FireRed placements captured from four sides; later families have
 focused captures. Not every generated image has individual visual sign-off.
- Final tower/terrain pass:44 turntable captures across11 placements, followed
 by12 normal first/third-person views across Lavender, Route10 and Viridian.
- Crystal normal cameras:27 views across Ecruteak, Pallet and Olivine.
- Geometry tests cover square podium corners, joined tower source rows,
 bounded dome geometry, shared cliff heights, tower contact, and preservation
 of small jump ledges/indoor classification.105 shape and181 support checks
 pass. The static validator retains six pre-existing MK301 findings.

Large landmarks, route gatehouses, omitted roof variants, connected-map
streaming boundaries and complete all-map visual review remain outstanding.
The reference catalogue and tile ledgers are inventories, not a declaration
of perfect coverage or finished Gamma Emerald parity. No new package or cart
pin has been made for these unreleased changes.
