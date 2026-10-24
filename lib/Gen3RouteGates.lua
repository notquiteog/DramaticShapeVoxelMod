-- Source-matched Route2/Forest gates. Complete shells have solid undersides;
-- their entrance porch and body respect every native walking corner.
local V=...
local M={recipes={}}
-- Spell out each drawing; the forest's partial off-map roof is deliberately
-- left to its existing renderer rather than claiming incomplete surroundings.
local fore={
 {0x44,0x45,0x45,0x45,0x45,0x45,0x45,0x46},
 {0x4c,0x4d,0x4d,0x4d,0x4d,0x4d,0x4d,0x4e},
 {0x4c,0x4d,0x4d,0x4d,0x4d,0x4d,0x4d,0x4e},
 {0x183,0x184,0x184,0x184,0x184,0x184,0x184,0x185},
 {0x1b6,0x1b5,0x1b5,0x1b5,0x1b5,0x1b5,0x1b5,0x1b7},
 {0x5c,0x5d,0x188,0x189,0x189,0x18a,0x5d,0x5e},
 {0x64,0x65,0x190,0x191,0x191,0x192,0x65,0x66},
}
local reverse={{0xe6,0xe6,0x178,0x179,0x179,0x17a,0xe6,0xe6}};for i=1,5 do reverse[i+1]=fore[i]end
reverse[7]={0x2b8,0x2b9,0x2ba,0x2b9,0x2ba,0x2b9,0x2ba,0x2bb}
for _,v in ipairs{{'forest_south',fore,true},{'forest_north',reverse,false}}do
 local permissions={};for y,row in ipairs(v[2])do permissions[y]={};for x=1,#row do permissions[y][x]=v[3]and y==1 and 0 or 7 end end
 if v[3]then permissions[6][2]=0;permissions[6][7]=0;permissions[7][4]=113;permissions[7][5]=113 end
 if not v[3]then permissions[1]={7,7,0,113,113,0,7,7}end
 M.recipes[#M.recipes+1]={name='route2_'..v[1],pair='viridian_outdoor',kind='route_gate',geometry='route_gate',header=#v[2],rows=v[2],permissions=permissions,
  forward=v[3],reverse=not v[3],ground=1,preserveWalkableFloor=true,wallSample={24,v[3]and 78 or 94},trimSample=v[3]and{48,85}or{2,85},openings=v[3]and{{48,96,80,112,door=true}}or{},
  claimRanges=not v[3]and{{2,5},{0,7},{0,7},{0,7},{0,7},{0,7},{0,7}}or nil,groundPreserve=not v[3]and{{2,0},{3,0},{4,0},{5,0}}or nil}
end
-- The8x6 brown General drawing formerly called east_checkpoint is Diglett's
-- Cave north entrance (native warp17,11), not a gate. Terrain/entrance owns it.
function M.profile(g)
 local d=g.depth*16;return{w=128,h=d,back=0,front=d-1,wall=32,roofEnd=g.custom.east and 64 or 64,wallTop=64,wallBottom=d,
 doorLeft=g.custom.east and 64 or 48,doorRight=80,doorTop=d-16,doorBottom=d,doorHeight=24,bevel=0,projection=0}
end
function M.doorSurface(g,tx,ty)
 if not(g.custom.forward or g.custom.east)then return end
 local l=g.custom.east and 64 or 48;local r=80;local d=g.depth*16;local sx,sy=(tx-g.cx)*16,(ty-g.cy)*16
 if sx>=r or sx+16<=l or sy<d-16 then return end
 local x,z=g.cx*16,g.cy*16
 return{w=r-l,h=16,sourceX=x+l,sourceY=z+d-16,base=g.groundHeight or 0,vertices={{x+l,24,z+d-1.95},{x+r,24,z+d-1.95},{x+r,0,z+d-1.95},{x+l,0,z+d-1.95}}}
end
function M.append(g,emit)
 local C=V.require('Gen3DepartmentStores').context(g,emit);local d=g.depth*16
 local wall,trim=C.sw(unpack(g.custom.wallSample)),C.sw(unpack(g.custom.trimSample))
 local east,forward=g.custom.east,g.custom.forward
 local n=(forward or g.custom.reverse)and 16.2 or .2;local f=forward and 79.8 or d-.2;local h=east and 32 or 26
 local doorL=east and 64 or 48;local holes={}
 if not forward and east then holes={{l=doorL-.2,r=80-.2,b=0,t=24,source={64.05,d-15.95,79.95,d-.05},door=true,trim=trim}}end
 local function facade(l,front,r,holes,sy,ey)
  C.elevation({l,front},{r,front},h,holes,wall,function(a,b,c,t)return C.uv(l+a+.02,sy+(h-t)/h*(ey-sy)+.02,l+c-.02,sy+(h-b)/h*(ey-sy)-.02)end)
 end
 local function cladding()
  -- Original brick courses continue around elevations without projecting
  -- the roof/window/grass portions of the top-down drawing onto those walls.
  if east then return C.uv(16.05,80.05,31.95,95.95)end
  return C.uv(g.custom.reverse and 24.05 or 16.05,96.05,31.95,103.95)
 end
 if g.custom.reverse then
  -- The native last drawing row contains tree fringe in front of the wall.
  -- Reuse only its clean brick crop below the uninterrupted window band.
  C.elevation({.2,f},{127.8,f},h,{},wall,function(a,b,c,t)return C.uv(.2+a+.02,80+(h-t)/(h-8)*16+.02,.2+c-.02,80+(h-b)/(h-8)*16-.02)end,8)
  C.elevation({.2,f},{127.8,f},8,{},wall,cladding)
 else facade(.2,f,127.8,holes,64,forward and 80 or d)end
 -- Matching masonry is carried around both sides and rear; no giant blank
 -- billboard, open back, or unsupported roof remains in an orbit.
 C.elevation({.2,n},{.2,f},h,{},wall,cladding)
 C.elevation({127.8,f},{127.8,n},h,{},wall,cladding)
 if g.custom.reverse then
  C.elevation({127.8,n},{80,n},h,{},wall,cladding);C.elevation({48,n},{.2,n},h,{},wall,cladding)
  C.box(48,24,n,80,h,n+1.2,wall)
  C.box(46.8,0,n,48,24,n+2,trim);C.box(80,0,n,81.2,24,n+2,trim)
  C.box(48,23,n,80,24,n+2,trim)
  -- A native arrow passage is open rather than a painted door billboard.
  -- Close its short reveals and floor without sealing the opening.
  C.face({{48,0,n},{80,0,n},{80,0,n+2},{48,0,n+2}},trim,.65)
 else C.elevation({127.8,n},{.2,n},h,{},wall,cladding)end
 -- A closed shallow floor slab covers the original lawn beneath a doorway.
 -- Its top is separated from native ground to prevent coplanar gray/grass
 -- triangles in first person; the complete underside remains below it.
 C.box(.2,-.2,n,127.8,.06,f,trim)
 local ridge=(n+f)/2;local roofY=h+16
 local tex=C.uv(.05,g.custom.reverse and 16.05 or .05,127.95,g.custom.reverse and 79.95 or 63.95)
 -- True pitched volume: two broad roof slopes, gable ends, and underside.
 C.face({{.2,h,n},{127.8,h,n},{127.8,roofY,ridge},{.2,roofY,ridge}},tex)
 C.face({{.2,roofY,ridge},{127.8,roofY,ridge},{127.8,h,f},{.2,h,f}},tex)
 C.face({{.2,h,f},{.2,h,n},{.2,roofY,ridge},{.2,h,f}},trim,.8)
 C.face({{127.8,h,n},{127.8,h,f},{127.8,roofY,ridge},{127.8,h,n}},trim,.9)
 C.face({{.2,h,f},{127.8,h,f},{127.8,h,n},{.2,h,n}},trim,.65)
 if forward then
  -- Only the central porch projects beyond the wall; native walking corner
  -- cells at x1/x6 remain empty. The warp doorway has a recessed closed reveal.
  local ph=24;local front=d-.2;local l,r=32.2,95.8
  local hs={{l=48-l,r=80-l,b=0,t=ph,source={48.05,96.05,79.95,111.95},door=true,trim=trim}}
  C.elevation({l,front},{r,front},ph,hs,trim,function(a,b,c,t)return C.uv(l+a+.02,96+(ph-t)/ph*16+.02,l+c-.02,96+(ph-b)/ph*16-.02)end)
  C.elevation({l,f},{l,front},ph,{},trim,false);C.elevation({r,front},{r,f},ph,{},trim,false)
  C.box(l,ph,f,r,ph+2,front,trim)
  C.face({{l,0,front},{r,0,front},{r,0,f},{l,0,f}},trim,.65)
 end
 return true
end
return M
