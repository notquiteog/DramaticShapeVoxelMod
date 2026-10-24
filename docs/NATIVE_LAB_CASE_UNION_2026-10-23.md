# Native laboratory case solid contacts

The native fallback for `birch_free_books` and `birch_free_books_end` now emits
only the exterior of its original closed-box union. Previously each shelf,
frame, top, archive box and lid emitted a full closed box. Their shared ends
and resting faces overlapped on exactly the same planes. Original artwork,
UV, upper dimensions and native gameplay cells remain unchanged.

The pure box-union helper partitions each original face at other box bounds,
removes buried portions and emits coincident exterior portions only once.
Exposed overhang undersides remain closed. UVs interpolate from each original
face; original face planes and shading remain. Only these two reviewed native
recipes opt in. Their exact Y0 contacts also recess 0.025 pixels below the
native floor, including matching side edges.

The regression reproduces the original coplanar overlap, then proves zero
positive-area coplanar intersections in the resulting native case, including
shelf joints, archive-box base and lid. Separate tests check touching,
overlapping and identical solids against exact union surface areas, original
UV bounds and native case dimensions. Six focused suites pass, including
legacy native grave contacts and all fourteen imported source models.

Official latest 0.3.95 was checked before native validation. All six cases
across RSE pass live scene/source-count and unchanged native-hash assertions.
Close first-person views, farther views from verified walking cells and room
overviews were inspected. Native artwork, floors and actors remain. Drivers
emitted PASS; Linux shell returned 1 on shutdown.

The existing fallback archive-box height remains 35 while these room shells
are 32 high, so its top is partly ceiling-clipped. This batch preserves that
height and makes no complete-case/room acceptance claim. The original-source
case and independent storage-box assembly remain in progress. This adds no
modern source candidates or accepted source components. Evidence is separately
recorded in `coverage/gen3-interiors-2026-10-23/accepted-native-fixes.jsonl`.
No raw source, native pixel, profile or capture files enter the repository.
