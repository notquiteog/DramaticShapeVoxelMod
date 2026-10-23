-- Littleroot's north-facing flights and enclosed descending wells.
-- The native warp, collision and actor movement remain engine-owned.
local M={}
-- Emit the exposed surface of joined rectangular solids once. Separate closed
-- boxes left coincident internal faces, including visible wood/gold risers.
local function joined(boxes,face)
 local cuts={{},{},{}}
 for _,b in ipairs(boxes)do for axis=1,3 do
  cuts[axis][#cuts[axis]+1]=b[axis];cuts[axis][#cuts[axis]+1]=b[axis+3]
 end end
 for axis=1,3 do
  table.sort(cuts[axis]);local unique={}
  for _,n in ipairs(cuts[axis])do if #unique==0 or n-unique[#unique]>1e-7 then unique[#unique+1]=n end end
  cuts[axis]=unique
 end
 local cells={};local function key(x,y,z)return x..':'..y..':'..z end
 for x=1,#cuts[1]-1 do for y=1,#cuts[2]-1 do for z=1,#cuts[3]-1 do
  local mid={(cuts[1][x]+cuts[1][x+1])/2,(cuts[2][y]+cuts[2][y+1])/2,(cuts[3][z]+cuts[3][z+1])/2}
  for _,b in ipairs(boxes)do
   if mid[1]>b[1]and mid[1]<b[4]and mid[2]>b[2]and mid[2]<b[5]and mid[3]>b[3]and mid[3]<b[6]then cells[key(x,y,z)]=b[7]end
  end
 end end end
 for x=1,#cuts[1]-1 do for y=1,#cuts[2]-1 do for z=1,#cuts[3]-1 do
  local uv=cells[key(x,y,z)]
  if uv then
   local l,r,b,h,n,s=cuts[1][x],cuts[1][x+1],cuts[2][y],cuts[2][y+1],cuts[3][z],cuts[3][z+1]
   if not cells[key(x,y+1,z)]then face({{l,h,n},{r,h,n},{r,h,s},{l,h,s}},uv,1)end
   if not cells[key(x,y-1,z)]then face({{l,b,s},{r,b,s},{r,b,n},{l,b,n}},uv,.6)end
   if not cells[key(x,y,z+1)]then face({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.85)end
   if not cells[key(x,y,z-1)]then face({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.7)end
   if not cells[key(x-1,y,z)]then face({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.76)end
   if not cells[key(x+1,y,z)]then face({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)end
  end
 end end end
end
function M.append(g,emit,uvFor)
 local ox,oz=g.cx*16,g.cy*16
 local function color(x,y)
  local mid=g.r.rows[math.floor(y/16)+1][math.floor(x/16)+1]
  local uv=assert(uvFor(g.ts,mid))
  local u=uv[1][1]+(uv[2][1]-uv[1][1])*(x%16+.5)/16
  local v=uv[1][2]+(uv[3][2]-uv[1][2])*(y%16+.5)/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local function face(q,uv,shade)
  for _,p in ipairs(q)do p[1],p[3]=p[1]+ox,p[3]+oz end
  emit(q,uv,shade or 1)
 end
 local function box(l,b,n,r,h,s,uv)
  face({{l,h,n},{r,h,n},{r,h,s},{l,h,s}},uv)
  face({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.85)
  face({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.7)
  face({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.76)
  face({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)
  face({{l,b,s},{l,b,n},{r,b,n},{r,b,s}},uv,.6)
 end
 -- A reviewed home has one flat wall plane. Only the tread flight projects
 -- into the room: the jambs/lintel sit flush in its actual wall opening.
 if g.homeWall then
  -- homeWall is the attachment plane .04 in front of the actual wallpaper.
  -- This integrated frame belongs in the wall aperture, on that wall plane.
  local n=(g.homeWallPlane or g.homeWall-.04)-oz;local bottom=g.r.down and -16 or 0
  local trim,wood,dark=color(16,11),color(24,g.r.down and 29 or 31),color(17,14)
  local floor=assert(uvFor(g.ts,g.r.floor or 0x201))
  local function floorRect(l,r,north,south)
   local xs,zs={l,r},{north,south}
   for x=16,32,16 do if x>l and x<r then xs[#xs+1]=x end end
   for z=16,16,16 do if z>north and z<south then zs[#zs+1]=z end end
   table.sort(xs);table.sort(zs)
   for i=1,#xs-1 do for j=1,#zs-1 do
    local x,z,xx,zz=xs[i],zs[j],xs[i+1],zs[j+1]
    local tx,tz=math.floor(x/16)*16,math.floor(z/16)*16
    local function uv(px,pz)return{floor[1][1]+(floor[2][1]-floor[1][1])*(px-tx)/16,floor[1][2]+(floor[3][2]-floor[1][2])*(pz-tz)/16}end
    face({{x,0,z},{xx,0,z},{xx,0,zz},{x,0,zz}},{uv(x,z),uv(xx,z),uv(xx,zz),uv(x,zz)})
   end end
  end
  floorRect(0,12,0,32);floorRect(36,48,0,32)
  floorRect(12,g.r.down and 14 or 15,n,31.8)
  floorRect(g.r.down and 34 or 33,36,n,31.8)
  local solids={
   {12,0,n-2,14,28,n,trim},{34,0,n-2,36,28,n,trim},{14,26,n-2,34,28,n,trim},
   {14,bottom,n-7,34,26,n-6,dark},
   {14,bottom,n-6,15,26,n,dark},{33,bottom,n-6,34,26,n,dark},
   {15,bottom-1,n-6,33,bottom,31.8,wood},
  }
  if g.r.down then
   solids[#solids+1]={14,bottom,n,15,0,31.8,dark}
   solids[#solids+1]={33,bottom,n,34,0,31.8,dark}
  end
  local start=n-6;local run=(31.8-start)/5
  for i=0,4 do
   local z=start+i*run;local h=g.r.down and(-15+i*3)or(15-i*3)
   solids[#solids+1]={15,bottom,z,33,h,z+run,wood}
   solids[#solids+1]={15,h-.5,z+run-.6,33,h+.05,z+run,trim}
  end
  if g.r.down then solids[#solids+1]={15,-.5,31.6,33,0,31.8,wood}end
  joined(solids,face)
  -- The last .2 pixel belongs to the native landing, not a floor gap.
  floorRect(12,36,31.8,32)
  return
 end
 -- The native drawing is a framed opening in the wall, not an exposed
 -- staircase with full-height solid banisters. Sample the gold trim, wood
 -- and dark recess separately; the old samples both hit the purple outline.
 local trim=color(16,11)
 local wood=color(24,g.r.down and 29 or 31)
 local dark=color(17,14)
 local wall=color(4,14)
 local floor=assert(uvFor(g.ts,g.r.floor or 0x201))
 for _,a in ipairs{{0,12},{36,48}}do
  face({{a[1],0,0},{a[2],0,0},{a[2],0,32},{a[1],0,32}},floor)
  box(a[1],0,7,a[2],32,30,wall)
  box(a[1],0,30,a[2],6,30.1,color(4,28))
 end
 -- Closed jambs and lintel surround a real opening; the tread flight is
 -- behind its front plane. Both floors use the same native portal silhouette.
 box(12,26,7,36,32,30,wall)
 box(12,0,28,15,26,31,wood)
 box(33,0,28,36,26,31,wood)
 box(12,24,28,36,27,31,wood)
 box(12.5,0,31,13.3,26,31.5,trim)
 box(34.7,0,31,35.5,26,31.5,trim)
 box(13,26,31,35,27,31.5,trim)
 local bottom=g.r.down and -16 or 0
 box(14,bottom,7,34,26,8,dark)
 box(14,bottom,8,15,26,30,dark)
 box(33,bottom,8,34,26,30,dark)
 box(15,bottom-1,8,33,bottom,32,wood)
 -- Five native golden treads rise into the recess; a descending flight
 -- begins flush at the threshold and drops away into the same opening.
 for i=0,4 do
  local z=10+i*4.4
  local h=g.r.down and (-15+i*3) or (15-i*3)
  box(15,bottom,z,33,h,z+4.4,wood)
  box(15,h-.5,z+3.7,33,h+.05,z+4.4,trim)
 end
 if g.r.down then box(15,-.5,31.6,33,0,32,wood)end
end
return M
