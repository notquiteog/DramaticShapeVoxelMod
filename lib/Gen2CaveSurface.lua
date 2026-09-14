-- A continuous fracture displacement for native Dark Cave wall vertices.
-- Shared coordinates produce identical seams; floor contact stays fixed.
local M={}
function M.enabled(map)
 return map and map.def and map.def.environment=='CAVE'
  and map.tileset and map.tileset.id=='TILESET_DARK_CAVE'
end
function M.vertex(p)
 local x,y,z=p[1],p[2],p[3]
 local gain=math.min(1,math.max(0,y)/8)
 return {x+math.sin(x*.31+z*.17+y*.23)*.7*gain,
  y+math.sin(x*.23-z*.29)*.6*gain,
  z+math.sin(z*.27-x*.19+y*.21)*.7*gain}
end
function M.face(c)
 local out={}
 for i=1,4 do out[i]=M.vertex(c[i]) end
 return out
end
return M
