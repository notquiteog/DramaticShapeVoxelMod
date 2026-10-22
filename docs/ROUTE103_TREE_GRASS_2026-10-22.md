# Route103 tree fallback and missing grass

Large connected-map forests exceeded the scenery API's4096-placement bound.
The single failed tree upload returned `invalid scenery batch`, so all trees
kept native voxel fallback. At FAR64, official0.3.95 Emerald reproduced zero
imports both on the Oldale/Route103 seam and after moving into the route.

The tree adapter now submits bounded chunks to the existing uploader. Native
replacement ownership commits only after every chunk succeeds. Late failures
release only this invocation's completed chunks, retain older caller resources
and leave every source tree visible through native fallback. Per-upload model,
texture and prototype limits remain unchanged. Tests cover8193 placements,
ordered4096/4096/1 uploads, atomic third-chunk failure and empty forests.

On the identical actual walking seam, the fixed native build keeps4796 source
trees in Oldale and5656 on Route103. East/west route revisits and Routes101,
102,104/PetalburgWoods retain imported trees without upload or recovery errors.
Native front/first-person captures were inspected; main source defaults and
native walkability/elevation are unchanged. The check used isolated Linux
LÖVE11.5/OpenGL and official Gen1Recomp0.3.95, with no companions/player saves.

Native C6/C7 encounter-grass cells carrying projected tree tips were converted
into non-root tree-ground owners. This excluded their actual grass from model
placement. Their exact reviewed source/permission now receives ordinary ORAS
grass while retaining the tree owner and all native gameplay data. A clean
native lawn donor is used only after successful model upload; failures keep
the original grass drawing. Native Cut pruning remains authoritative.

Six matched Emerald scene windows improve from185/211→211/211 grass cells on
Route101,195/215→215/215 on102,166/180→180/180 on103,51/57→57/57 on104,
119/138→138/138 on116 and272/325→325/325 in PetalburgWoods. All138 skipped
cells now receive models. Before/after overview and first-person captures were
inspected; native map hashes are unchanged. These counts describe those windows.

A separate read-only audit of all519 Emerald maps identified still-unclassified
grass sources: JaggedPass General/Lavaridge206 (18 cells) and General/Fortree015
(1381 cells across its maps). Their source/material review remains pending;
this does not claim every grass cell in every game is finished. Final coastal
boundary GPU acceptance and additional fences/Gyms are also tracked separately.
All current source work is included at the user's prompt-release request.
