-- Whole Crystal drawings: the roof occupies the top, the facade occupies the
-- front. The native 2D rectangle is not a stack of independent wall columns.
local V=...
local M={}
local Eaves=V and V.require("RoofEaves") or assert(loadfile("lib/RoofEaves.lua"))()
local function key(x,y)return (y+64)*4096+x+64 end
local function row(map,x,y,w,left,middle,right)
 for dx=0,w-1 do
  if map:tileAt(x+dx,y)~=(dx==0 and left or dx==w-1 and right or middle) then return false end
 end
 return true
end
function M.placements(map)
 local id=map.tileset.id
 if id=='TILESET_KANTO' then return M.kanto(map) end
 if id~='TILESET_JOHTO' and id~='TILESET_JOHTO_MODERN' then return {} end
 local out={};local w,h=map.def.width*4,map.def.height*4
 for y=0,h-1 do for x=0,w-1 do
  local first=map:tileAt(x,y);local timber=first==49
  if first==16 or timber then
   local width=1;local mid,last=timber and 83 or 17,timber and 52 or 18
   while width<32 and x+width<w and map:tileAt(x+width,y)==mid do width=width+1 end
   width=width+1
   if width>=4 and width<=32 and x+width<=w and map:tileAt(x+width-1,y)==last then
    local roof=1
    while y+roof<h and roof<12 and row(map,x,y+roof,width,timber and 65 or 13,timber and 83 or 14,timber and 68 or 15)do roof=roof+1 end
    if row(map,x,y+roof,width,timber and 81 or 10,timber and 82 or 11,timber and 84 or 12)then
     roof=roof+1
     local bottom
     for yy=y+roof,math.min(h-1,y+24) do
      local l,r=map:tileAt(x,yy),map:tileAt(x+width-1,yy)
      if (not timber and l==1 and r==22) or (timber and l==151 and r==153)then bottom=yy;break end
      if l~=26 or r~=28 then break end
     end
     if bottom then
      local brick=false
      for yy=y+roof,bottom do for xx=x+1,x+width-2 do brick=brick or map:tileAt(xx,yy)==7 end end
      out[#out+1]={x=x,y=y,width=width,depth=bottom-y+1,roofRows=roof,
       style=timber and 'timber_eaves' or brick and 'flat_brick' or 'flat_plaster',
       wallTile=brick and 7 or 27,roofTile=timber and 83 or 14}
     end
    end
   end
  end
 end end
 return out
end
function M.kanto(map)
 local out={};local w,h=map.def.width*4,map.def.height*4
 for y=0,h-1 do for x=0,w-1 do
  if map:tileAt(x,y)==5 and map:tileAt(x+1,y)==6 then
   local width=2
   while width<24 and x+width<w and map:tileAt(x+width,y)==7 do width=width+1 end
   if map:tileAt(x+width,y)==8 and map:tileAt(x+width+1,y)==9 then
    width=width+2
    local valid=map:tileAt(x,y+1)==21 and map:tileAt(x+width-1,y+1)==25
    for yy=y+2,math.min(y+14,h-1)do
     local l,r=map:tileAt(x,yy),map:tileAt(x+width-1,yy)
     if l==29 and r==60 then
      if valid then out[#out+1]={x=x,y=y,width=width,depth=yy-y+1,roofRows=4,
       style='kanto_hip',wallTile=34,roofTile=5,baseTile=26,groundTile=44}end
      break
     end
     if not ((l==37 and r==41)or(l==92 and r==93)or(l==15 and r==31))then break end
    end
   end
  end
  if map:tileAt(x,y)==76 then
   local width=1
   while width<32 and x+width<w and map:tileAt(x+width,y)==78 do width=width+1 end
   width=width+1
   if width>=4 and x+width<=w and map:tileAt(x+width-1,y)==77 then
    local roof=1
    while roof<8 and row(map,x,y+roof,width,90,94,90)do roof=roof+1 end
    if row(map,x,y+roof,width,92,95,93)then
     roof=roof+1
     for yy=y+roof,math.min(y+30,h-1)do
      local l,r=map:tileAt(x,yy),map:tileAt(x+width-1,yy)
      if l==29 and r==60 then
       out[#out+1]={x=x,y=y,width=width,depth=yy-y+1,roofRows=roof,
        style='kanto_flat_brick',wallTile=75,roofTile=94,baseTile=26,groundTile=44}
       break
      end
      if l~=15 or r~=31 then break end
     end
    end
   end
  end
 end end
 return out
end
function M.build(S,map)
 if not S.gen2 or not S.outdoor then return end
 local list=M.placements(map);S.exteriors={}
 local ts=map.tileset;local aw,ah=ts.imageWidth or 128,ts.imageHeight or 128
 local per=ts.tilesPerRow or 16
 local function uv(tile)
  local x,y=tile%per*8,math.floor(tile/per)*8
  return {{(x+.03)/aw,(y+.03)/ah},{(x+7.97)/aw,(y+.03)/ah},
   {(x+7.97)/aw,(y+7.97)/ah},{(x+.03)/aw,(y+7.97)/ah}}
 end
 local function face(v,tile,shade)
  v.uv=uv(tile);v.shade=shade or 1;S.objectQuads[#S.objectQuads+1]=v
 end
 for _,g in ipairs(list)do
  local free=true
  for y=g.y,g.y+g.depth-1 do for x=g.x,g.x+g.width-1 do if S.skip[key(x,y)]then free=false end end end
  if free then
   S.exteriors[#S.exteriors+1]=g
   local x0,z0=g.x*8,g.y*8;local W,D=g.width*8,g.depth*8
   local H=(g.depth-g.roofRows)*8
   for y=g.y,g.y+g.depth-1 do for x=g.x,g.x+g.width-1 do
    S.skip[key(x,y)]=true;S.ground[key(x,y)]=g.groundTile or 5
   end end
   -- Front artwork is kept in source order, including brick, doors, signage.
   for by=0,H/8-1 do for bx=0,g.width-1 do
    local x,t=x0+bx*8,map:tileAt(g.x+bx,g.y+g.roofRows+by)
    local top=H-by*8;local z=z0+D
    -- The native POKE/MART plates sit just in front of the brickwork.
    if t==8 or t==9 or t==24 or t==25 then z=z+.18 end
    face({{x,top,z},{x+8,top,z},{x+8,top-8,z},{x,top-8,z}},t)
   end end
   -- Repeat the actual wall material around both sides and the back. No
   -- mirrored doors, huge stretched trim or roof artwork on vertical walls.
   for by=0,H/8-1 do
    local top=H-by*8;local tile=by==H/8-1 and (g.baseTile or 2) or g.wallTile
    for dz=0,g.depth-1 do local z=z0+dz*8
     face({{x0,top,z},{x0,top,z+8},{x0,top-8,z+8},{x0,top-8,z}},tile,.84)
     face({{x0+W,top,z+8},{x0+W,top,z},{x0+W,top-8,z},{x0+W,top-8,z+8}},tile,.88)
    end
    for bx=0,g.width-1 do local x=x0+bx*8
     face({{x+8,top,z0},{x,top,z0},{x,top-8,z0},{x+8,top-8,z0}},tile,.8)
    end
   end
   if g.style=='kanto_hip' then
    -- The two rows below the roof cap are the dormer and eave, not another
    -- floor. Keep the source window band centered inside its roof profile.
    for bx=0,g.width-1 do
     local x=x0+bx*8
     face({{x,H+8,z0+D},{x+8,H+8,z0+D},{x+8,H,z0+D},{x,H,z0+D}},map:tileAt(g.x+bx,g.y+3))
     if bx>=2 and bx<g.width-2 then
      face({{x,H+16,z0+D},{x+8,H+16,z0+D},{x+8,H+8,z0+D},{x,H+8,z0+D}},map:tileAt(g.x+bx,g.y+2))
     else
      local a=H+8+math.min(8,bx*4,(g.width-bx)*4)
      local b=H+8+math.min(8,(bx+1)*4,(g.width-bx-1)*4)
      face({{x,a,z0+D},{x+8,b,z0+D},{x+8,H+8,z0+D},{x,H+8,z0+D}},g.roofTile)
     end
    end
   end
   -- Original rectangular colored roofs are flat slabs, not gables. Timber
   -- roofs retain their source edge treatment with a shallow perimeter bevel.
   local function height(x,z)
    if g.style=='kanto_hip' then return H+8+math.min(8,x/2,(W-x)/2,z/2) end
    if g.style=='timber_eaves' then return H+2+math.min(3,x,W-x,z,D-z) end
    return H+1.2
   end
   for dz=0,g.depth-1 do for bx=0,g.width-1 do
    local x,z=bx*8,dz*8
    local a,b,c,d=height(x,z),height(x+8,z),height(x+8,z+8),height(x,z+8)
    local sourceRow=math.min(g.roofRows-1,math.floor(dz/g.depth*g.roofRows))
    local roofTile=map:tileAt(g.x+bx,g.y+sourceRow)
    -- Map each roof source row continuously across its world depth, so
    -- stretched cap/eave rows do not repeat as a stack of parallel bands.
    local tex=uv(roofTile)
    local sy=dz/g.depth*g.roofRows-sourceRow
    local ey=math.min(1,sy+g.roofRows/g.depth)
    local top,bottom=tex[1][2],tex[3][2]
    tex[1][2],tex[2][2]=top+(bottom-top)*sy,top+(bottom-top)*sy
    tex[3][2],tex[4][2]=top+(bottom-top)*ey,top+(bottom-top)*ey
    local q={{x0+x,d,z0+z+8},{x0+x+8,c,z0+z+8},{x0+x+8,b,z0+z},{x0+x,a,z0+z}}
    q.uv={tex[4],tex[3],tex[2],tex[1]};q.shade=.96;S.objectQuads[#S.objectQuads+1]=q
    local function edge(A,B,dx,dz)
     Eaves.edge(A,B,dx,dz,uv(roofTile),function(p,t,shade)
      p.uv=t;p.shade=shade;S.objectQuads[#S.objectQuads+1]=p
     end)
    end
    local xx,zz=x0+x,z0+z
    if dz==0 then edge({xx,a,zz},{xx+8,b,zz},0,-2)end
    if dz==g.depth-1 then edge({xx+8,c,zz+8},{xx,d,zz+8},0,2)end
    if bx==0 then edge({xx,d,zz+8},{xx,a,zz},-2,0)end
    if bx==g.width-1 then edge({xx+8,b,zz},{xx+8,c,zz+8},2,0)end
    for _,corner in ipairs({{0,0,xx,a,zz,-2,-2},
      {g.width-1,0,xx+8,b,zz,2,-2},{0,g.depth-1,xx,d,zz+8,-2,2},
      {g.width-1,g.depth-1,xx+8,c,zz+8,2,2}})do
     if bx==corner[1] and dz==corner[2] then
      Eaves.corner({corner[3],corner[4],corner[5]},corner[6],corner[7],uv(roofTile),function(p,t,shade)
       p.uv=t;p.shade=shade;S.objectQuads[#S.objectQuads+1]=p
      end)
     end
    end
    if dz==0 then face({{x0+x+8,b,z0},{x0+x,a,z0},{x0+x,H,z0},{x0+x+8,H,z0}},g.roofTile,.7)end
    if dz==g.depth-1 and g.style~='kanto_hip' then face({{x0+x,d,z0+D},{x0+x+8,c,z0+D},{x0+x+8,H,z0+D},{x0+x,H,z0+D}},g.roofTile,.8)end
    if bx==0 then face({{x0,a,z0+z},{x0,d,z0+z+8},{x0,H,z0+z+8},{x0,H,z0+z}},g.roofTile,.75)end
    if bx==g.width-1 then face({{x0+W,c,z0+z+8},{x0+W,b,z0+z},{x0+W,H,z0+z},{x0+W,H,z0+z+8}},g.roofTile,.8)end
   end end
  end
 end
end
return M
