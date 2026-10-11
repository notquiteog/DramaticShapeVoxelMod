-- KFP foam/dust particle families, with native collision/elevation adapters.
-- Stable bounded sampling replaces the donor's whole-map scan and shared RNG.
local V=...
local M={MAX_ANCHORS=48,MAX_VERTICES=48*24}
local S=V.require('ModSetting')
M.foam=S.new('kfpShoreFoam','SHORE FOAM',{'off','subtle'},{'OFF','SUBTLE'})
M.dust=S.new('kfpRoomDust','ROOM DUST',{'off','subtle'},{'OFF','SUBTLE'})
M.smoke=S.new('kfpChimneySmoke','CHIMNEY SMOKE',{'off','subtle'},{'OFF','SUBTLE'})
M.settings={M.foam,M.dust,M.smoke}
local function hash(x,z,k)return((x*73856093+z*19349663+k*83492791)%104729)/104729 end
function M.surface(map)
 local native=map.nativeGeneration==3
 local def=map.nativeDef or map.def or{}
 local layout=def.midLayout or{}
 local w=map.widthCells or layout.width or(def.width and def.width*(native and 1 or 2))or 0
 local h=map.heightCells or layout.height or(def.height and def.height*(native and 1 or 2))or 0
 local C=native and require('src.core.game3.collision')
 return function(x,z)
  if x<0 or z<0 or x>=w or z>=h then return end
  local water,walk
  if native then water=C.isWater(x,z);walk=C.isWalkable(x,z)
  else
   if not(map.isWaterCell and map.isWalkableCell)then return end
   water=map:isWaterCell(x,z);walk=map:isWalkableCell(x,z)
  end
  if not water and not walk then return end
  local y
  if native then y=V.require('Gen3Elevation').at(def,x*16+8,z*16+8)
  else y=V.require('VoxelScene').groundAt(map,x,z,x*16,z*16)end
  if type(y)~='number'or y~=y then return end
  return{water=water,walk=walk,y=y}
 end
end
function M.anchors(surface,px,pz,kind)
 local out={};local cx,cz=math.floor(px/16),math.floor(pz/16)
 for z=cz-5,cz+5 do for x=cx-5,cx+5 do
  local c=surface(x,z)
  if c then
   if kind=='foam'and c.water then
    for _,d in ipairs({{-1,0},{1,0},{0,-1},{0,1}})do
     local n=surface(x+d[1],z+d[2])
     -- No spray through cliffs, walls, map seams, or furniture. Stay inside water.
     if n and n.walk and not n.water and math.abs(n.y-c.y)<1 then
      out[#out+1]={x=x*16+8+d[1]*6,z=z*16+8+d[2]*6,y=c.y,seed=hash(x,z,d[1]*3+d[2]+7),dx=d[1],dz=d[2]}
     end
    end
   elseif kind=='dust'and c.walk and not c.water and hash(x,z,13)<.3 then
    out[#out+1]={x=x*16+8,z=z*16+8,y=c.y,seed=hash(x,z,19)}
   end
  end
 end end
 table.sort(out,function(a,b)return(a.x-px)^2+(a.z-pz)^2<(b.x-px)^2+(b.z-pz)^2 end)
 while #out>M.MAX_ANCHORS do out[#out]=nil end
 return out
end
function M.vertices(anchors,t,kind)
 local out={}
 for _,a in ipairs(anchors)do
  local phase=(t*(kind=='foam'and .55 or .09)+a.seed*7)%1
  local x,z,y,r
  if kind=='foam'then
   -- Small source disc spray; its entire arc stays on the water side.
   if phase<.4 then
    local age=phase/.4
    x=a.x+a.dz*math.sin(a.seed*43)*3;z=a.z-a.dx*math.sin(a.seed*43)*3
    y=a.y+.18+math.sin(age*math.pi)*1.4;r=.35*math.sin(age*math.pi)
   end
  else
   x=a.x+math.sin(t*.18+a.seed*29)*2;z=a.z+math.cos(t*.13+a.seed*17)*2
   y=a.y+5+phase*9;r=.14*math.sin(phase*math.pi)
  end
  if x and r>.01 then
   for _,axis in ipairs({{1,0},{0,1}})do
    local dx,dz=axis[1]*r,axis[2]*r
    local q={{x-dx,y-r,z-dz,0,1,1},{x+dx,y-r,z+dz,1,1,1},{x+dx,y+r,z+dz,1,0,1},{x-dx,y+r,z-dz,0,0,1}}
    for _,i in ipairs({1,2,3,1,3,4,3,2,1,4,3,1})do out[#out+1]=q[i]end
   end
  end
 end
 return out
end
local mesh,textures,cache,lastTick=nil,{},nil,nil
local function texture(kind)
 if textures[kind]then return textures[kind]end
 -- Original donor makeTex.dot art, including its stepped opaque pixel rim.
 local c=kind=='foam'and{.92,.96,1}or kind=='smoke'and{.72,.72,.70}or{.95,.92,.80}
 local d=love.image.newImageData(8,8)
 for y=0,7 do for x=0,7 do
  local r=math.sqrt(((x-3.5)/3.5)^2+((y-3.5)/3.5)^2)
  local k=r<.45 and 1 or r<.75 and .72 or .42
  local alpha=kind=='smoke'and math.max(0,1-r)*.38 or(r<.95 and 1 or 0)
  d:setPixel(x,y,c[1]*k,c[2]*k,c[3]*k,alpha)
 end end
 local tx=love.graphics.newImage(d);tx:setFilter('nearest','nearest');d:release();textures[kind]=tx;return tx
end
function M.draw(state)
 local map=state and state.map;local p=state and state.player
 if not(map and p)then return end
 local outside=V.require('KantoFirstPerson').outdoor(map)
 local kind=outside and 'foam'or 'dust'
 -- Forest/cave effects already have owners; room dust is for genuine rooms.
 local def=map.def or{};local ts=def.tileset or(map.tileset and map.tileset.id)
 local indoor=not outside and not V.require('NativeAtmosphere').kind(map)and ts~='CAVERN'and ts~='FOREST'and def.environment~='CAVE'and def.environment~='FOREST'
 if (outside and M.foam:get()=='off')or(not outside and(M.dust:get()=='off'or not indoor))then M.lastCount=0;return end
 local x,z=(p.px or p.x or 0)+8,(p.py or p.y or 0)+8
 local now=love.timer.getTime();local key=kind..':'..math.floor(x/32)..':'..math.floor(z/32)
 if not cache or cache.map~=map or cache.key~=key then
  cache={map=map,key=key,anchors=M.anchors(M.surface(map),x,z,kind)};lastTick=nil
 end
 local tick=math.floor(now*30)
 if tick~=lastTick then
  local verts=M.vertices(cache.anchors,now,kind);M.lastCount=#verts/24
  if #verts==0 then lastTick=nil;return end
  mesh=mesh or love.graphics.newMesh(V.require('Voxel3D').FORMAT,M.MAX_VERTICES,'triangles','dynamic')
  mesh:setVertices(verts,1,#verts);mesh:setDrawRange(1,#verts);lastTick=tick
 end
 if mesh and M.lastCount>0 then V.require('Voxel3D').draw(mesh,texture(kind))end
end
-- Callers provide actual modeled chimney outlets, never a guessed solid tile.
-- This public seam also lets added regions opt in without a companion dependency.
local smokeMesh
function M.drawChimneys(anchors,px,pz,t)
 if M.smoke:get()=='off'then return end
 local out={};local count=0
 for _,a in ipairs(anchors or{})do
  if count<12 and(a.x-px)^2+(a.z-pz)^2<160*160 then
   count=count+1
   for i=0,3 do
    local age=(t*.23+i*.25+hash(a.x,a.z,31))%1
    local x=a.x+math.sin(age*2+a.x)*age*3;local z=a.z+math.cos(age*2+a.z)*age*3
    local y=a.y+.4+age*14;local r=(1.2+age*3)*math.sin(age*math.pi)
    for _,axis in ipairs({{1,0},{0,1}})do
     local dx,dz=axis[1]*r,axis[2]*r
     local q={{x-dx,y-r,z-dz,0,1,1},{x+dx,y-r,z+dz,1,1,1},{x+dx,y+r,z+dz,1,0,1},{x-dx,y+r,z-dz,0,0,1}}
     for _,n in ipairs({1,2,3,1,3,4,3,2,1,4,3,1})do out[#out+1]=q[n]end
    end
   end
  end
 end
 M.lastChimneys=count
 if #out==0 then return end
 local R=V.require('Voxel3D')
 smokeMesh=smokeMesh or love.graphics.newMesh(R.FORMAT,12*4*24,'triangles','dynamic')
 smokeMesh:setVertices(out,1,#out);smokeMesh:setDrawRange(1,#out)
 R.withEffect('alpha',function()R.draw(smokeMesh,texture('smoke'))end)
end
function M.invalidate()
 if mesh then mesh:release()end
 if smokeMesh then smokeMesh:release();smokeMesh=nil end
 for _,t in pairs(textures)do t:release()end
 mesh,textures,cache,lastTick=nil,{},nil,nil;M.lastCount=0
end
return M
