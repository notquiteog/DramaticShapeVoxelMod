-- Tree-local KFP leaf fall / hanging vines. Explicit model observations replace
-- the donor's Gen1-only stitched atlas roof. No new canopy covers a walk lane.
local V=...;local M={MAX_TREES=24,MAX_VERTICES=24*12*24}
local S=V.require('ModSetting')
M.leaves=S.new('kfpLeafFall','LEAF FALL',{'off','subtle'},{'OFF','SUBTLE'})
M.vines=S.new('kfpVines','HANGING VINES',{'off','subtle'},{'OFF','SUBTLE'})
M.settings={M.leaves,M.vines}
local maps=setmetatable({},{__mode='k'})
function M.record(map,x,y,z,crown,underside)
 if not map or crown<=y+5 then return end
 local key=map.nativeDef or map.def or map;local set=maps[key]
 if not set then set={};maps[key]=set end
 set[x..':'..z]={x=x,y=y,z=z,crown=crown,underside=underside or crown,seed=((x*73+z*139)%997)/997}
end
function M.select(map,px,pz)
 local out={};local set=maps[map.nativeDef or map.def or map]or{}
 local C=map.nativeGeneration==3 and require('src.core.game3.collision')
 for _,a in pairs(set)do
  local x,z=math.floor(a.x/16),math.floor(a.z/16)
  local blocked=C and not C.isWalkable(x,z)or not C and map.isWalkableCell and not map:isWalkableCell(x,z)
  if blocked and(a.x-px)^2+(a.z-pz)^2<112*112 then out[#out+1]=a end
 end
 table.sort(out,function(a,b)return(a.x-px)^2+(a.z-pz)^2<(b.x-px)^2+(b.z-pz)^2 end)
 while #out>M.MAX_TREES do out[#out]=nil end
 return out
end
function M.vertices(anchors,t,leaves,vines)
 local out={}
 local function quad(x,y,z,w,h,yaw)
  local dx,dz=math.cos(yaw)*w*.5,math.sin(yaw)*w*.5
  local q={{x-dx,y-h/2,z-dz,0,1,1},{x+dx,y-h/2,z+dz,1,1,1},{x+dx,y+h/2,z+dz,1,0,1},{x-dx,y+h/2,z-dz,0,0,1}}
  for _,i in ipairs({1,2,3,1,3,4,3,2,1,4,3,1})do out[#out+1]=q[i]end
 end
 for _,a in ipairs(anchors)do
  local cx,cz=math.floor(a.x/16)*16+8,math.floor(a.z/16)*16+8
  if leaves then
   local phase=(t*.12+a.seed*7)%1;local f=math.sin(phase*math.pi)
   -- Falling inside the actual blocked tree cell; no foreign ground decal.
   quad(cx+math.sin(t*.9+a.seed*23)*2,a.y+1+(a.crown-a.y-1)*(1-phase),cz+math.cos(t*.6+a.seed*17)*2,1.2*f,1.8*f,t*.8+a.seed*17)
  end
  if vines then
   local attachment=a.underside or a.crown
   local length=math.min(8,math.max(0,attachment-a.y-5))
   if length>1 then
   for strand=0,1 do
    local side=strand==0 and -1 or 1
    for n=1,4 do
     local sway=math.sin(t*.7+a.seed*11+n*.15)*.25*n/4
     local x=cx+side*3+sway;local z=cz+side*2
     local y=attachment-length*n/4
     quad(x,y,z,.65,length/4+.2,0);quad(x,y,z,.65,length/4+.2,math.pi/2)
     if n%2==0 then quad(x+side*.45,y,z,1.5,1.2,side*.5)end
    end
   end
   end
  end
 end
 return out
end
local mesh,texture,lastTick,lastMap,anchors,scanTime
local function art()
 -- Donor pointed leaf shape, center vein, dark rim and asymmetric fold.
 local d=love.image.newImageData(16,16)
 for y=0,15 do for x=0,15 do
  local ny=(y-6.5)/6.5;local dx=x-7.5;local width=math.max(0,5.25*(1-math.abs(ny)^1.45))
  local alpha=math.abs(ny)<=1 and math.abs(dx)<=width
  local k=dx<0 and 1.14 or .82
  if math.abs(dx)/math.max(width,.01)>.76 then k=k*.68 end
  if math.abs(dx)<.58 then k=.56 end
  if y>=13 and x>=7 and x<=8 then alpha=true;k=.4 end
  d:setPixel(x,y,.36*k,.66*k,.26*k,alpha and 1 or 0)
 end end
 local tx=love.graphics.newImage(d);tx:setFilter('nearest','nearest');d:release();return tx
end
function M.draw(state)
 local leaves,vines=M.leaves:get()~='off',M.vines:get()~='off'
 if not leaves and not vines then M.lastCount=0;return end
 local map=state and state.map;local p=state and state.player;if not map or not p then return end
 -- Existing Gen1 custom forest owns its own donor leaf/canopy dispatch.
 if not map.nativeGeneration and not map.cellCollision and(map.def or{}).tileset=='FOREST'and V.require('CommunityVisuals').customForest()then return end
 local x,z=(p.px or 0)+8,(p.py or 0)+8;local t=love.timer.getTime()
 if lastMap~=map or not scanTime or t-scanTime>.25 then anchors=M.select(map,x,z);lastMap=map;scanTime=t;lastTick=nil end
 local tick=math.floor(t*30)
 if tick~=lastTick then
  local v=M.vertices(anchors,t,leaves,vines);M.lastCount=#v
  if #v==0 then return end
  local R=V.require('Voxel3D');mesh=mesh or love.graphics.newMesh(R.FORMAT,M.MAX_VERTICES,'triangles','dynamic')
  mesh:setVertices(v,1,#v);mesh:setDrawRange(1,#v);lastTick=tick
 end
 texture=texture or art();if M.lastCount>0 then V.require('Voxel3D').draw(mesh,texture)end
end
function M.invalidate()
 if mesh then mesh:release()end;if texture then texture:release()end
 mesh,texture,lastTick,lastMap,anchors,scanTime=nil,nil,nil,nil,nil,nil
end
return M
