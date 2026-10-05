-- Optional shared Gothic tower, aligned with the native podium and elevation.
local V=...
local M={};local mesh,detail
function M.transform(g,p)
 local Mat=V.require('Mat4')
 return Mat.mul(Mat.translate(g.cx*16,g.groundHeight or 0,g.cy*16+p.back),
  Mat.scale(p.w/96,(p.wall+50)/170,(p.front-p.back)/64))
end
function M.draw(g,draw)
 if not(g and g.custom and g.custom.geometry=='tower'and V.require('CommunityVisuals').customTower())then return false end
 local ok,result=pcall(function()
  local Source=V.require('LegendaryTowerExterior')
  local texture=Source.texture();if not texture then return false end
  local mode=V.require('CommunityVisuals').referenceBuildings()
  if not mesh or detail~=mode then
   local vertices,indices=Source.geometry()
   -- Lower buttresses must meet the authored blocking boundary. Roof
   -- overhangs remain above head clearance, as in the original shared model.
   for _,p in ipairs(vertices)do if p[2]<24 then
    p[1]=math.max(0,math.min(96,p[1]));p[3]=math.max(0,math.min(64,p[3]))
   end end
   local candidate=V.require('Voxel3D').newMesh(vertices,indices)
   if not candidate then return false end
   if mesh then mesh:release()end;mesh,detail=candidate,mode
  end
  draw(mesh,texture,M.transform(g,V.require('Gen3Civic').profile(g)))
  return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
function M.clear()if mesh then mesh:release()end;mesh,detail=nil,nil end
return M
