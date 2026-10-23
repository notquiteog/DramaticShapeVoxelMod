# Flush Hoenn home stair openings

Littleroot's original gold stair frame now meets the actual native wallpaper
plane. Its jambs and lintel extend only into the existing aperture; only the
tread flight projects into the room. Source upper geometry and native room
bounds, walls, floor elevations, warp coordinates and permissions are unchanged.
The final 0.2-pixel strip at the flight's existing landing is covered with its
native floor rather than exposing a gap. Native floor margins cover the
three-pixel sides of the narrower flight exactly once; below-floor cheeks
close descending wells. Floor UVs retain their native tile scale.

A single exposed-surface union replaces overlapping closed step/frame boxes.
It removes coincident internal wood/gold risers and tread-nose surfaces while
retaining the original five treads and reviewed source-pixel colors. CPU tests
require every welded solid edge to have incidence two, bound mesh complexity,
and reject every positive-area coplanar overlap. Both ascending and descending
flights pass. Source-native frame parts stay separate from imported furniture.

The room shell keeps the actual 24×28 native stair aperture. Its buried jamb
returns stop two pixels behind the wall plane, where the frame begins; the
combined shell/frame test rejects duplicate coplanar faces. Native wall columns
are also cut at the same opening by `Gen3HomeRooms.stairWallFace`, including
front, side, back and cap quads. This preserves UVs and non-aperture face area;
unknown/non-stair profiles stand down.

The native scene integration supplies the actual wall plane and routes the
reviewed aperture's stair faces into a dedicated mesh. Only that mesh bypasses
normal room clipping, which otherwise discards flush/recessed geometry at the
north boundary. Native side floor strips keep normal clipping. Native terrain,
shader bounds, walls and floor heights are not globally moved. Scene integration
is maintained separately by the root task and is required with these helpers.

The official latest engine was checked before verification: 0.3.95, published
2026-10-21T02:42:51Z. Disposable Emerald, Ruby and Sapphire profiles used that
matching source and official Linux LÖVE shell. Both floors of both starting
houses were inspected in each edition: 12 native layouts, each in room overview
and three first-person directions. Descending wells were additionally inspected
looking down. Every live native layout hash stayed identical across rendering,
and real native ascent/descent warps passed. Drivers emitted PASS; the shell
returned 1 at shutdown, so no clean process-exit claim is made. No captures or
native pixels are committed. The stair/home/diorama suites and existing source
furniture, Kanto-home and shared model suites pass.

The identifier/hash-only acceptance ledger covers these stair components only.
It does not claim modern source replacement or acceptance of complete maps.
