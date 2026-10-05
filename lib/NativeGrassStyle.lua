-- Share Gen1's Legendary tuft variation with native GB/GBA artwork. Only the
-- upright card changes; its original ground drawing and collision stay intact.
local V=...
local M={}
function M.transform(x,z,span)
 if not V.require('CommunityVisuals').customGrass()then return end
 local C=V.require('SurfaceCraft');local tx,tz=x/span,z/span
 local angle=(C.hash(tx,tz,501)-.5)*.48
 local ca,sa=math.cos(angle),math.sin(angle)
 local scale=.72+C.hash(tx,tz,502)*.06
 local height=.84+C.hash(tx,tz,503)*.32
 local jx=(C.hash(tx,tz,504)-.5)*.24
 local jz=(C.hash(tx,tz,505)-.5)*.24
 local cx,cz=x+span/2,z+span/2
 return function(p)
  local px,pz=p[1]-cx,p[3]-cz
  return {cx+(px*ca-pz*sa)*scale+jx,p[2]*height,cz+(px*sa+pz*ca)*scale+jz}
 end,{cx+jx,cz+jz,.001}
end
return M
