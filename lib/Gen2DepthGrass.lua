-- Broad bent blades in the engine's encounter-grass footprint. The flat
-- meadow donor supplies colour; each blade owns its silhouette and depth.
local M={}
local donors={TILESET_JOHTO=5,TILESET_JOHTO_MODERN=5,TILESET_FOREST=5,
  TILESET_PARK=1,TILESET_KANTO=44,TILESET_BATTLE_TOWER_OUTSIDE=5}
function M.groundTile(map)
  return donors[map.tileset.id]
end
function M.append(out,map,tx,ty)
  local ts=map.tileset
  local tile=donors[ts.id]
  if not tile then return false end
  local pr=ts.tilesPerRow or 16
  local w,h=ts.imageWidth or 128,ts.imageHeight or 128
  local u,v=(tile%pr*8+4)/w,(math.floor(tile/pr)*8+4)/h
  local function rand(i)
    return (math.sin(tx*12.9898+ty*78.233+i*17.17)*43758.5453)%1
  end
  for i=1,16 do
    local x,z=tx*8+1+rand(i)*6,ty*8+1+rand(i+9)*6
    local a=rand(i+18)*math.pi*2
    local dx,dz=math.cos(a),math.sin(a)
    local height=3.8+rand(i+27)*3.6
    local half=.55+rand(i+36)*.30
    out[#out+1]={{x-dz*half,0,z+dx*half},{x+dz*half,0,z-dx*half},
      {x+dx*.7,height,z+dz*.7},{x+dx*.3,height*.67,z+dz*.3},
      uv={{u,v},{u,v},{u,v},{u,v}},shade=.72+rand(i+45)*.34}
  end
  return true
end
return M
