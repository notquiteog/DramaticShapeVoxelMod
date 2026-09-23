-- Source-textured flights, open wells and solid ladders. Only presentation is
-- owned here: native warps, collision, actor height and scripted movement stay
-- with the game. Assemblies require their complete original four-cell drawing.
local V=...
local recipes=V.data('gen3_stairs')
local M={}
function M.prepare(cells)
 local count=0
 for _,c in pairs(cells)do
  if not c.stairs then for _,r in ipairs(recipes)do
   if c.pair==r.pair and c.mid==r.rows[1][1] then
    local group={r=r,cx=c.cx,cy=c.cy,ts=c.ts,cells={}}
    local match=true
    for z=0,1 do for x=0,1 do
     local q=cells[(c.cx+x)..':'..(c.cy+z)]
     if not q or q.pair~=c.pair or q.mid~=r.rows[z+1][x+1] or q.stairs or q.prop then match=false end
     group.cells[z*2+x+1]=q
    end end
    if match then
     group.landing=group.cells[r.east and 3 or 4]
     for _,q in ipairs(group.cells)do q.stairs=group end
     group.owner=c;count=count+1;break
    end
   end
  end end
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
 local tex,solid,box,face,ox,oz=builder(c,emit,uvFor)
 local g=c.stairs
 if g then
  if g.owner~=c then return end
  local r=g.r
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
  horizontal(0,32,24,32,0,floor)
  if x0>0 then horizontal(0,x0,8,24,0,floor)end
  if x1<32 then horizontal(x1,32,8,24,0,floor)end
  for i=0,5 do
   local a=r.east and x0+i*4 or x1-(i+1)*4
   local h=(i+1)*20/6*(r.down and -1 or 1)
   local sx=r.east and 16+i*2.4 or 15-i*2.4
   local sy=r.down and 18+i*2 or 29-i*3
   local material=solid(source(sx,sy))
   if r.down then
    horizontal(a,a+4,8,24,h,material)
    -- Well walls and each vertical drop leave the center unobstructed.
    box(a,h,7,a+4,0,8,material);box(a,h,24,a+4,0,25,material)
    local edge=r.east and a or a+4
    face({{ox+edge,h,oz+8},{ox+edge,h,oz+24},{ox+edge,h+20/6,oz+24},{ox+edge,h+20/6,oz+8}},material,.8)
   else
    for z=8,23,8 do box(a,0,z,a+4,h,z+8,material)end
   end
  end
  local rail=solid(source(r.east and 29 or 2,15))
  if not r.down then
   for i=0,5 do
    local a=r.east and x0+i*4 or x1-(i+1)*4;local h=(i+1)*20/6
    for _,z in ipairs({7,24})do
     box(a,h,z,a+1,h+5,z+1,rail)
     box(a,h+4,z,a+4,h+5,z+1,rail)
    end
   end
  else
   local edge=r.east and x1 or x0
   face({{ox+edge,-20,oz+24},{ox+edge,-20,oz+8},{ox+edge,0,oz+8},{ox+edge,0,oz+24}},rail,.5)
  end
  return
 end
 local s=c.shape
 if s.kind=='steps' then
  -- Rock terrace stair bands keep their short native rise, not a full story.
  for n=0,3 do
   local z=n*4;local h=6-n*1.5
   local uv={tex(c.mid,0,z),tex(c.mid,16,z),tex(c.mid,16,z+4),tex(c.mid,0,z+4)}
   for x=0,15,8 do box(x,0,z,x+8,h,z+4,solid(c.mid,x+4,z+2))end
   face({{ox,h,oz+z},{ox+16,h,oz+z},{ox+16,h,oz+z+4},{ox,h,oz+z+4}},uv,1)
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
