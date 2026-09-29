-- Ground-level cameras need a room above the cutaway map's low perimeter.
-- This presentation-only enclosure sits outside the playable floor; it never
-- changes the map, collisions, warps or the ordinary diorama camera.
local V=...
local M={}
local cache=setmetatable({},{__mode='k'})
local texture

-- Enclosed places that owe the eye a lid. INDOOR was the only one recognised
-- until the full 388-map sweep: all 39 DUNGEON maps (Tin Tower, Burned Tower,
-- Sprout Tower, Olivine Lighthouse, Goldenrod Underground) returned nil here
-- and rendered a black void over the wall tops in BOTH camera modes. The
-- image metric and the environment census matched 1:1 at 39, which is how
-- this was pinned down rather than guessed at.
-- CAVE is deliberately absent: CaveAtmosphere3D owns those ceilings, and the
-- sweep shows they already render. ROUTE/TOWN stay open to the sky.
local ENCLOSED = { INDOOR = true, DUNGEON = true }

function M.geometry(map)
  if not (map and map.def and ENCLOSED[map.def.environment]) then return nil end
  local w,h=map.def.width*32,map.def.height*32
  if w<=0 or h<=0 then return nil end
  local ceiling=48
  -- draw() is called directly (not pcall'd) from VoxelScene, so a tileset the
  -- Structures module cannot resolve must not be able to break the frame.
  local ok, structures = pcall(function() return V.require('Structures').forMap(map) end)
  if ok and structures then
    for _,f in ipairs(structures.furniture or {}) do
      ceiling=math.max(ceiling,(f.height or 0)+16)
    end
  end
  local verts,indices={},{}
  local function face(points,u,shade)
    local k=#verts
    for _,p in ipairs(points) do verts[#verts+1]={p[1],p[2],p[3],u,.5,shade} end
    for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
  end
  -- Move the four faces just beyond the existing perimeter to avoid coplanar
  -- flicker. The existing source walls and furnishings stay in front.
  local x0,z0,x1,z1=-.5,-.5,w+.5,h+.5
  -- A lid faces DOWN, away from the sky, so it should not be the brightest
  -- surface in the room. The shipped INDOOR value is 1 and 208 maps are
  -- approved against it, so only DUNGEON is dimmed here: at full brightness the
  -- new towers and lighthouses read as one flat white card filling the top of
  -- the frame, which is the same "printed plane" look the room is meant to avoid.
  local lidShade = map.def.environment == 'DUNGEON' and .58 or 1
  face({{x0,0,z0},{x1,0,z0},{x1,ceiling,z0},{x0,ceiling,z0}},.75,.92)
  face({{x1,0,z1},{x0,0,z1},{x0,ceiling,z1},{x1,ceiling,z1}},.75,.92)
  face({{x0,0,z1},{x0,0,z0},{x0,ceiling,z0},{x0,ceiling,z1}},.75,.86)
  face({{x1,0,z0},{x1,0,z1},{x1,ceiling,z1},{x1,ceiling,z0}},.75,.86)
  face({{x0,ceiling,z0},{x1,ceiling,z0},{x1,ceiling,z1},{x0,ceiling,z1}},.25,lidShade)
  return verts,indices,ceiling
end
-- ThirdPerson has a third rung: the boom can be out behind the shoulder, or
-- collapsed into the head when the player backs against a wall. showsPlayer()
-- is false in the collapsed case, and that is the only moment a boomed-out
-- camera is genuinely first person again -- so it genuinely wants the lid
-- back. While the camera is genuinely outside the room the lid is suppressed,
-- because a ceiling would slam shut across the view. Same reasoning, and the
-- same signal, as CommunityFlora.boomedOut().
local function thirdPersonCollapsed()
  local ok, ThirdPerson = pcall(V.require, 'ThirdPerson')
  if not (ok and ThirdPerson and ThirdPerson.showsPlayer) then return false end
  local ran, shows = pcall(ThirdPerson.showsPlayer)
  return (ran and not shows) and true or false
end

function M.draw(map)
  local engaged = false
  local okFP, FirstPerson = pcall(V.require, 'FirstPerson')
  if okFP and FirstPerson and FirstPerson.engaged then
    local ran, on = pcall(FirstPerson.engaged)
    engaged = (ran and on) and true or false
  end
  if not (engaged or thirdPersonCollapsed()) then return end
  local entry=cache[map]
  if not entry then
    local verts,indices=M.geometry(map)
    if not verts then return end
    entry=V.require('Voxel3D').newMesh(verts,indices)
    cache[map]=entry
  end
  if not texture then
    local data=love.image.newImageData(2,1)
    data:setPixel(0,0,.84,.83,.78,1)
    data:setPixel(1,0,.69,.70,.67,1)
    texture=love.graphics.newImage(data);texture:setFilter('nearest','nearest')
    data:release()
  end
  V.require('Voxel3D').draw(entry,texture)
end
return M
