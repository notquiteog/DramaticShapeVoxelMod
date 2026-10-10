-- Ruby/Sapphire Birch roof equipment: a stepped rectangular metal extractor.
-- Emerald's circular drum is deliberately a separate shape.
local V=...
local A=V.require('ArchitecturalDetails')
local M={}
function M.append(g,p,face,uv)
 local x,z=g.cx*16,g.cy*16
 local v=g.custom.roofVent;local cx=x+(v[1]+v[3])/2
 local back=z+(p.roofBack or p.back)+7;local y=p.wall+p.bevel
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local metal,dark,light=sw(23,17),sw(20,25),sw(26,5)
 -- Closed plinth, raised equipment casing and projecting cap.
 A.box(face,cx-14,y,back-2,cx+14,y+4,back+23,dark)
 A.box(face,cx-11,y+4,back,cx+11,y+13,back+19,metal)
 A.box(face,cx-12,y+13,back-1,cx+12,y+15,back+20,light)
 -- Recessed rectangular grille with solid slats; no see-through bottom.
 A.box(face,cx-9,y+15,back+2,cx+9,y+15.2,back+17,dark)
 for dz=3,15,3 do A.box(face,cx-8,y+15.2,back+dz,cx+8,y+15.9,back+dz+1,metal)end
end
return M
