-- Source-textured flights, open wells and solid ladders. Only presentation is
-- owned here: native warps, collision, actor height and scripted movement stay
-- with the game. Assemblies require their complete original four-cell drawing.
local V=...
local recipes=V.data('gen3_stairs')
local M={}
table.sort(recipes,function(a,b)return #a.rows*#a.rows[1]>#b.rows*#b.rows[1] end)
function M.prepare(cells)
 local count=0
 local ordered={}
 for _,c in pairs(cells)do ordered[#ordered+1]=c end
 table.sort(ordered,function(a,b)return a.cy==b.cy and a.cx<b.cx or a.cy<b.cy end)
 for _,c in ipairs(ordered)do
  if not c.stairs then for _,r in ipairs(recipes)do
   if c.pair==r.pair and c.mid==r.rows[1][1] then
    local width=#r.rows[1]
    local group={r=r,cx=c.cx,cy=c.cy,ts=c.ts,cells={},width=width}
    local match=true
    for z=0,#r.rows-1 do for x=0,width-1 do
     local q=cells[(c.cx+x)..':'..(c.cy+z)]
     if not q or q.pair~=c.pair or q.mid~=r.rows[z+1][x+1] or q.stairs or q.prop
      or (r.permissions and q.collision~=nil and q.collision~=r.permissions[z+1][x+1])then match=false end
     group.cells[z*width+x+1]=q
    end end
    local landing=group.cells[r.landing and (r.landing[2]*width+r.landing[1]+1) or ((#r.rows-1)*width+(r.east and 1 or 2))]
    local expected=r.expectedBehavior or (r.down and (r.east and 0x6E or 0x6F)or(r.east and 0x6C or 0x6D))
    if landing and (landing.collision==7 or landing.behavior and landing.behavior~=expected)then match=false end
    if match then
     group.landing=landing
     for _,q in ipairs(group.cells)do q.stairs=group end
     group.owner=c;count=count+1;break
    end
   end
  end end
 end
 -- The Museum's last native row combines the arch base with two stone
 -- stair bands. It has ordinary floor behavior, not the semantic stair rise.
 -- Claim only a complete native Museum and its exact three approach cells.
 for _,c in ipairs(ordered)do
  local museum=c.civic
  if museum and museum.custom and museum.custom.geometry=='pewter_museum'
   and museum.pair=='pewter_outdoor' and c.cx==museum.cx+4 and c.cy==museum.cy+6 then
   local group={r={design='pewter_museum_approach'},cx=museum.cx+4,cy=museum.cy+7,cells={},museum=museum}
   local match=true
   for x=0,2 do
    local q=cells[(group.cx+x)..':'..group.cy]
    local arch=cells[(group.cx+x)..':'..(group.cy-1)]
    if not q or q.pair~=museum.pair or q.mid~=0x2ba+x or q.collision~=0
     or q.stairs or q.prop or q.civic or q.boundary or q.shape.kind~='flat'
     or not arch or arch.civic~=museum or arch.mid~=0x2b2+x then match=false end
    group.cells[x+1]=q
   end
   if match then group.owner=group.cells[1];for _,q in ipairs(group.cells)do q.stairs=group end;count=count+1 end
  end
 end
 return count
end
-- An emitter with source-pixel materials. Faces remain small enough for the
-- shared world curvature; vertical sides close each step from every angle.
local function builder(c,emit,uvFor)
 local ox,oz=c.cx*16,c.cy*16
 local function tex(mid,x,y)
  local t=assert(uvFor(c.ts,mid))
  local u=t[1][1]+(t[2][1]-t[1][1])*math.max(.03,math.min(.97,x/16))
  local v=t[1][2]+(t[3][2]-t[1][2])*math.max(.03,math.min(.97,y/16))
  return {u,v}
 end
 local function face(points,uv,shade)emit(points,uv,shade)end
 local function solid(mid,x,y)
  local u=tex(mid,x,y);return {u,u,u,u}
 end
 local function box(x0,y0,z0,x1,y1,z1,uv)
  -- Boxes are open underneath only when their underside is buried in the floor.
  local a,b,c,d=ox+x0,ox+x1,oz+z0,oz+z1
  face({{a,y1,c},{b,y1,c},{b,y1,d},{a,y1,d}},uv,1)
  face({{a,y0,d},{b,y0,d},{b,y1,d},{a,y1,d}},uv,.85)
  face({{b,y0,c},{a,y0,c},{a,y1,c},{b,y1,c}},uv,.7)
  face({{a,y0,c},{a,y0,d},{a,y1,d},{a,y1,c}},uv,.72)
  face({{b,y0,d},{b,y0,c},{b,y1,c},{b,y1,d}},uv,.8)
  if y0>0 then face({{a,y0,d},{b,y0,d},{b,y0,c},{a,y0,c}},uv,.6)end
 end
 return tex,solid,box,face,ox,oz
end
function M.append(c,emit,uvFor)
 if c.shape.museumStep then return V.require('Gen3MuseumApproach').appendStep(c,emit,uvFor)end
 if c.stairs and c.stairs.r.design=='museum_apron'then return V.require('Gen3MuseumApproach').appendRail(c,emit,uvFor)end
 local tex,solid,box,face,ox,oz=builder(c,emit,uvFor)
 local g=c.stairs
 if g then
  if g.owner~=c then return end
  local r=g.r
  if r.design=='pewter_museum_approach' then
   -- Measured existing source threshold: .003962818 * 255.5 = 1.0125.
   -- Two shallow steps meet it without moving the source/portal or native
   -- support. The landing reaches the source front two pixels north of this
   -- row; native facade pixels never become horizontal tread paint.
   local rise=1.0125;local stone=solid(0x2bb,8,10.5)
   local tread=solid(0x2bb,8,9.5);local riser=solid(0x2bb,8,11.5)
   for _,band in ipairs{{-2,8,rise,stone},{8,12,rise,tread},{12,16,rise/2,tread}}do
    local z0,z1,h,paint=unpack(band)
    for x=0,47,8 do face({{ox+x,h,oz+z0},{ox+x+8,h,oz+z0},{ox+x+8,h,oz+z1},{ox+x,h,oz+z1}},paint,1)end
   end
   for _,step in ipairs{{12,rise/2,rise},{16,0,rise/2}}do
    local z,low,high=unpack(step)
    for x=0,47,8 do face({{ox+x,low,oz+z},{ox+x+8,low,oz+z},{ox+x+8,high,oz+z},{ox+x,high,oz+z}},riser,.85)end
   end
   for _,band in ipairs{{-2,12,rise},{12,16,rise/2}}do
    local a,b,h=unpack(band)
    face({{ox,0,oz+a},{ox,0,oz+b},{ox,h,oz+b},{ox,h,oz+a}},stone,.72)
    face({{ox+48,0,oz+b},{ox+48,0,oz+a},{ox+48,h,oz+a},{ox+48,h,oz+b}},stone,.8)
   end
   face({{ox+48,0,oz-2},{ox,0,oz-2},{ox,rise,oz-2},{ox+48,rise,oz-2}},stone,.7)
   return
  end
  if r.design=='hoenn_house' then
   return V.require('Gen3HoennStairs').append(g,emit,uvFor)
  end
  if r.design=='house' then
   return V.require('Gen3HouseStairs').append(g,emit,uvFor)
  end
  local depth=#r.rows*16
  local function source(x,y)
   local q=g.cells[math.floor(y/16)*2+math.floor(x/16)+1]
   return q.mid,x%16,y%16
  end
  local landing=g.landing.mid
  local floor=solid(landing,8,12)
  -- Native landings surround the flight; the well itself stays open.
  local x0=r.east and 8 or 0
  local x1=r.east and 32 or 24
  local function horizontal(a,b,z0,z1,h,uv)
   for x=a,b-1,8 do for z=z0,z1-1,8 do
    face({{ox+x,h,oz+z},{ox+math.min(b,x+8),h,oz+z},{ox+math.min(b,x+8),h,oz+math.min(z1,z+8)},{ox+x,h,oz+math.min(z1,z+8)}},uv,1)
   end end
  end
  horizontal(0,32,0,8,0,floor)
  horizontal(0,32,depth-8,depth,0,floor)
  if x0>0 then horizontal(0,x0,8,depth-8,0,floor)end
  if x1<32 then horizontal(x1,32,8,depth-8,0,floor)end
  for i=0,5 do
   local a=r.east and x0+i*4 or x1-(i+1)*4
   local h=(i+1)*20/6*(r.down and -1 or 1)
   local sx=r.east and 16+i*2.4 or 15-i*2.4
   local sy=r.down and 18+i*2 or 29-i*3
   local material=solid(source(sx,sy))
   if r.down then
    horizontal(a,a+4,8,depth-8,h,material)
    -- Well walls and each vertical drop leave the center unobstructed.
    box(a,h,7,a+4,0,8,material);box(a,h,depth-8,a+4,0,depth-7,material)
    local edge=r.east and a or a+4
    face({{ox+edge,h,oz+8},{ox+edge,h,oz+depth-8},{ox+edge,h+20/6,oz+depth-8},{ox+edge,h+20/6,oz+8}},material,.8)
   else
    for z=8,depth-9,8 do box(a,0,z,a+4,h,z+8,material)end
   end
  end
  local rail=solid(source(r.east and 29 or 2,15))
  if not r.down then
   for i=0,5 do
    local a=r.east and x0+i*4 or x1-(i+1)*4;local h=(i+1)*20/6
    for _,z in ipairs({7,depth-8})do
     box(a,h,z,a+1,h+5,z+1,rail)
     box(a,h+4,z,a+4,h+5,z+1,rail)
    end
   end
  else
   local edge=r.east and x1 or x0
   face({{ox+edge,-20,oz+depth-8},{ox+edge,-20,oz+8},{ox+edge,0,oz+8},{ox+edge,0,oz+depth-8}},rail,.5)
  end
  return
 end
 local s=c.shape
 if s.kind=='steps' then
  -- Emit the exposed union: one top per band, outer cheeks and only the
  -- visible height difference at each riser. No buried box caps or shared
  -- half-box walls remain to compete at the same depth.
  local rise=c.floor and c.floor.high and (c.floor.high-c.floor.low)or 6
  local reverse=c.floor and c.floor.reverse
  local function height(n)return rise*(reverse and (n+1)/4 or (1-n/4))end
  for n=0,3 do
   local z=n*4;local h=height(n);local material=solid(c.mid,8,z+2)
   local uv={tex(c.mid,0,z),tex(c.mid,16,z),tex(c.mid,16,z+4),tex(c.mid,0,z+4)}
   face({{ox,h,oz+z},{ox+16,h,oz+z},{ox+16,h,oz+z+4},{ox,h,oz+z+4}},uv,1)
   face({{ox,0,oz+z},{ox,0,oz+z+4},{ox,h,oz+z+4},{ox,h,oz+z}},material,.72)
   face({{ox+16,0,oz+z+4},{ox+16,0,oz+z},{ox+16,h,oz+z},{ox+16,h,oz+z+4}},material,.8)
   local previous=n==0 and 0 or height(n-1)
   if h>previous then face({{ox+16,previous,oz+z},{ox,previous,oz+z},{ox,h,oz+z},{ox+16,h,oz+z}},material,.7)end
   local following=n==3 and 0 or height(n+1)
   if h>following then face({{ox,following,oz+z+4},{ox+16,following,oz+z+4},{ox+16,h,oz+z+4},{ox,h,oz+z+4}},material,.85)end
  end
 elseif s.kind=='ladder' then
  local down=s.down
  local y0,y1=down and -16 or 0,down and 2 or 19
  local rail=solid(c.mid,7,9);local shade=solid(c.mid,8,3)
  if down then
   box(1,-16,1,3,0,15,shade);box(13,-16,1,15,0,15,shade)
   box(3,-16,1,13,0,3,shade);box(3,-16,13,13,0,15,shade)
   box(3,-17,3,13,-16,13,shade)
  end
  for _,x in ipairs({4,11})do box(x,y0,5,x+1.5,y1,7,rail)end
  for y=y0+2,y1-1,4 do box(5.5,y,5,11,y+1,7,rail)end
 end
end
return M
