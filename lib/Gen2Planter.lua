-- Closed ceramic pots and curved, solid leaves. Positions stay inside the
-- complete native drawing; every colour comes from that plant's own atlas.
local V=...
local M={}
local Mask=V and V.require('SceneryMask') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/SceneryMask.lua')
-- Indoor plants can straddle striped wallpaper and checkerboard flooring.
-- Remove the border-connected background per row, retaining green leaves
-- and the native dark outline instead of using a single floor colour.
function M.cutout(width,height,pixel,ground)
 local pixels,edges={},{}
 local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
 for y=0,height-1 do
  edges[y]={}
  for x=0,width-1 do
   local c={pixel(x,y)};pixels[y*width+x]=c
   if x==0 or x==width-1 then edges[y][key(c[1],c[2],c[3])]=true end
  end
 end
 local floor={}
 if ground then for y=0,15 do for x=0,15 do floor[key(ground(x,y))]=true end end end
 local mask=Mask.mask(width,function(x,y)
  local c=pixels[y*width+x]
  if c[4]<.5 then return true end
  if c[2]>c[1]+.02 and c[2]>c[3]+.02 and not floor[key(c[1],c[2],c[3])] then return false end
  -- Dark native leaf outlines remain beside their green pixels.
  if (c[1]+c[2]+c[3])/3<.5 and not (c[2]>c[1]+.02 and c[2]>c[3]+.02) then
   for dy=-1,1 do for dx=-1,1 do
    local n=x+dx>=0 and x+dx<width and pixels[(y+dy)*width+x+dx]
    if n and n[2]>n[1]+.02 and n[2]>n[3]+.02 then return false end
   end end
  end
  return edges[y][key(c[1],c[2],c[3])]==true or floor[key(c[1],c[2],c[3])]==true
 end,height)
 return function(x,y)
  local c=pixels[y*width+x]
  return c[1],c[2],c[3],mask[y*width+x] and c[4] or 0,c[5],c[6]
 end
end
function M.card(width,height,pixel)
 local bottom=height
 for y=0,height-1 do for x=0,width-1 do
  local _,_,_,a=pixel(x,y);if a>.5 then bottom=math.min(bottom,height-y-1)end
 end end
 local faces=V.require('VoxelHull').card(width,height,pixel,bottom)
 for _,q in ipairs(faces)do
  local uv={q.u,q.v};q.uv={uv,uv,uv,uv};q.cardZ=height-8
  for i=1,4 do q[i][1]=q[i][1]+width/2;q[i][3]=height-8 end
 end
 return faces
end
function M.build(t,data,perRow,aw,ah)
 local width,height=#t.tiles[1]*8,#t.tiles*8
 local pixel=M.cutout(width,height,function(x,y)
  local tile=t.tiles[math.floor(y/8)+1][math.floor(x/8)+1]
  local ax,ay=tile%perRow*8+x%8,math.floor(tile/perRow)*8+y%8
  local r,g,b,a=data:getPixel(ax,ay)
  return r,g,b,a,(ax+.5)/aw,(ay+.5)/ah
 end,t.groundTiles and function(x,y)
  local row=t.groundTiles[math.floor(y/8)%#t.groundTiles+1]
  local tile=row[math.floor(x/8)%#row+1]
  return data:getPixel(tile%perRow*8+x%8,math.floor(tile/perRow)*8+y%8)
 end)
 if V and V.require('TreePresentation').props:get()=='cards' then
  return M.card(width,height,pixel)
 end
 return M.fromDrawing(width,height,pixel)
end
function M.fromDrawing(width,height,pixel)
 local leaf,pot,green={},{},{}
 local last=0
 for y=0,height-1 do for x=0,width-1 do
  local _,_,_,a=pixel(x,y);if a>.5 then last=y end
 end end
 for y=0,height-1 do for x=0,width-1 do
  local r,g,b,a,u,v=pixel(x,y)
  local tone=(r+g+b)/3
  if a>.5 and tone>.025 and tone<.94 then
   local swatch={u,v,tone}
   local isGreen=g>r+.02 and g>b+.02
   if y<height-8 then
    leaf[#leaf+1]=swatch
    if isGreen then green[#green+1]=swatch end
   elseif y>=last-3 and x>=width*.25 and x<width*.75 and not isGreen then
    pot[#pot+1]=swatch
   end
  end
 end end
 if #green>0 then leaf=green end
 if #leaf==0 then leaf=pot end
 if #pot==0 then pot=leaf end
 if #leaf==0 then return {} end
 table.sort(pot,function(a,b)return a[3]<b[3] end)
 table.sort(leaf,function(a,b)return a[3]<b[3] end)
 local function tone(group,t)return group[math.max(1,math.ceil(#group*t))]end
 local out={}
 local function q(a,b,c,d,uv,light)
  out[#out+1]={a,b,c,d,uv={{uv[1],uv[2]},{uv[1],uv[2]},
    {uv[1],uv[2]},{uv[1],uv[2]}},shade=light or 1}
 end
 local cx,cz=width*.5,height-8
 local radius=math.min(4.6,width*.3)
 local potHeight=math.min(7,height*.28)
 local function p(r,y,i)
  local a=i*math.pi/5
  return {cx+r*math.cos(a),y,cz+r*math.sin(a)}
 end
 local rim,body,soil=tone(pot,.85),tone(pot,.6),pot[1]
 for i=0,9 do
  local n=i+1
  q(p(radius*.7,0,i),p(radius*.7,0,n),p(radius,potHeight-1,n),p(radius,potHeight-1,i),body,.86+i%3*.045)
  q(p(radius,potHeight-1,i),p(radius,potHeight-1,n),p(radius,potHeight,n),p(radius,potHeight,i),rim,.93)
  q(p(radius,potHeight,i),p(radius,potHeight,n),p(radius*.78,potHeight,n),p(radius*.78,potHeight,i),rim,1)
  q(p(radius*.78,potHeight,i),p(radius*.78,potHeight,n),p(radius*.78,potHeight-1,n),p(radius*.78,potHeight-1,i),body,.75)
  q({cx,potHeight-1,cz},p(radius*.78,potHeight-1,i),p(radius*.78,potHeight-1,n),{cx,potHeight-1,cz},soil,.62)
  q({cx,0,cz},p(radius*.7,0,n),p(radius*.7,0,i),{cx,0,cz},body,.7)
 end
 -- A compact rosette, with petioles separate from the broad leaf blades.
 -- Curved oval sections keep their volume from the side and below.
 local leaves={
  {0,1,.64},{1.05,.94,.72},{2.1,1,.62},
  {3.15,.96,.70},{4.2,1,.66},{5.25,.93,.68},
  {.5,.55,.91},{2.6,.48,1},{4.7,.52,.87},
 }
 local rise=math.min(height-potHeight-1,height<=16 and 9 or 18)
 local spread=math.min(width*.44,7)
 for index,s in ipairs(leaves)do
  local dx,dz=math.cos(s[1]),math.sin(s[1])
  local reach=spread*s[2];local peak=rise*s[3]
  local half=math.min(width*.15,2.4)*(index>6 and .85 or 1)
  local base=potHeight+peak*.28
  local rings={}
  for j,k in ipairs({{.12,.28,0},{.27,.63,.65},{.46,.88,1},{.65,1,.95},{.85,.94,.65},{1,.74,0}})do
   local x,z=cx+dx*reach*k[1],cz+dz*reach*k[1]
   local y=potHeight+peak*k[2]
   local w=half*k[3];local ridge=.38*k[3]
   rings[j]={{x-dz*w,y,z+dx*w},{x,y+ridge,z},
    {x+dz*w,y,z-dx*w},{x,y-ridge*.65,z}}
  end
  local light=tone(leaf,.55+(index%3)*.10)
  local dark=tone(leaf,.18+(index%2)*.12)
  for j=1,5 do for side=1,4 do
   local nextSide=side%4+1
   q(rings[j][side],rings[j+1][side],rings[j+1][nextSide],rings[j][nextSide],
    side<=2 and light or dark,side==1 and 1 or side==2 and .9 or .82)
  end end
  local ends={}
  for j,k in ipairs({{cx,potHeight-1,cz},{cx+dx*reach*.12,base,cz+dz*reach*.12}})do
   ends[j]={}
   for side=0,3 do local a=side*math.pi*.5
    ends[j][side+1]={k[1]+math.cos(a)*.16,k[2],k[3]+math.sin(a)*.16}
   end
  end
  for side=1,4 do local n=side%4+1
   q(ends[1][side],ends[2][side],ends[2][n],ends[1][n],dark,.86)
  end
 end
 return out
end
return M
