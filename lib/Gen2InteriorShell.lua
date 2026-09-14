-- Ground-level cameras need a room above the cutaway map's low perimeter.
-- This presentation-only enclosure sits outside the playable floor; it never
-- changes the map, collisions, warps or the ordinary diorama camera.
local V=...
local M={}
local cache=setmetatable({},{__mode='k'})
local texture
function M.geometry(map)
  if not (map and map.def and map.def.environment=='INDOOR') then return nil end
  local w,h=map.def.width*32,map.def.height*32
  if w<=0 or h<=0 then return nil end
  local ceiling=48
  local structures=V.require('Structures').forMap(map)
  for _,f in ipairs(structures.furniture or {}) do
    ceiling=math.max(ceiling,(f.height or 0)+16)
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
  face({{x0,0,z0},{x1,0,z0},{x1,ceiling,z0},{x0,ceiling,z0}},.75,.92)
  face({{x1,0,z1},{x0,0,z1},{x0,ceiling,z1},{x1,ceiling,z1}},.75,.92)
  face({{x0,0,z1},{x0,0,z0},{x0,ceiling,z0},{x0,ceiling,z1}},.75,.86)
  face({{x1,0,z0},{x1,0,z1},{x1,ceiling,z1},{x1,ceiling,z0}},.75,.86)
  face({{x0,ceiling,z0},{x1,ceiling,z0},{x1,ceiling,z1},{x0,ceiling,z1}},.25,1)
  return verts,indices,ceiling
end
function M.draw(map)
  if not V.require('FirstPerson').engaged() then return end
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
