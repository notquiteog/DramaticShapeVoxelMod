-- KFP's hashed, irregular rain puddles adapted to native surface callbacks.
-- The donor assumed y=1.6 everywhere. Every vertex here uses the caller's
-- actual ground plane, and rejects stairs, ledges, furniture and height seams.
local V=...
local M={}
M.setting=V.require('ModSetting').new('kfpWetGround','RAIN GROUND',{'off','splashes','puddles'},{'OFF','SPLASHES','PUDDLES + SPLASHES'})
M.settings={M.setting}
local function hash(x,z,k)return ((x*73856093+z*19349663+k*83492791)%104729)/104729 end
function M.anchors(px,pz,surface)
 local out={};local bx,bz=math.floor(px/64)*4,math.floor(pz/64)*4
 for z=bz-8,bz+8,2 do for x=bx-8,bx+8,2 do
  if hash(x,z,7)<.43 then
   local wx,wz=x*16+5+hash(x,z,11)*6,z*16+5+hash(z,x,13)*6
   local h=surface(wx,wz)
   if type(h)=='number'and h==h then
    local flat=true
    for _,p in ipairs({{-4,-4},{-4,4},{4,-4},{4,4}})do
     local edge=surface(wx+p[1],wz+p[2]);if type(edge)~='number'or math.abs(edge-h)>.05 then flat=false end
    end
    if flat then out[#out+1]={x=wx,z=wz,h=h,seed=hash(x,z,17)}end
   end
  end
 end end
 return out
end
local cache,ring,water,foam=nil,nil,nil,nil
local function texture(color)
 local d=love.image.newImageData(1,1);d:setPixel(0,0,unpack(color))
 local t=love.graphics.newImage(d);d:release();return t
end
local function puddles(anchors)
 local v,i={},{}
 for _,a in ipairs(anchors)do
  local radius=2.1+a.seed*1.1
  for n=0,9 do
   local theta,other=n*math.pi/5,(n+1)*math.pi/5
   local r0=radius*(.8+hash(a.x,n,19)*.3)
   local r1=radius*(.8+hash(a.x,n+1,19)*.3)
   local base=#v
   v[#v+1]={a.x,a.h+.075,a.z,.5,.5,1}
   v[#v+1]={a.x+math.cos(theta)*r0,a.h+.075,a.z+math.sin(theta)*r0,.5,.5,1}
   v[#v+1]={a.x+math.cos(other)*r1,a.h+.075,a.z+math.sin(other)*r1,.5,.5,1}
   i[#i+1]=base+1;i[#i+1]=base+2;i[#i+1]=base+3
  end
 end
 return #v>0 and V.require('Voxel3D').newMesh(v,i)or nil
end
local function ringMesh()
 local v,i={},{}
 for n=0,11 do
  local a,b=n*math.pi/6,(n+1)*math.pi/6;local base=#v
  for _,p in ipairs({{a,.8},{a,1},{b,1},{b,.8}})do v[#v+1]={math.cos(p[1])*p[2],0,math.sin(p[1])*p[2],.5,.5,1}end
  for _,index in ipairs({1,2,3,1,3,4})do i[#i+1]=base+index end
 end
 return V.require('Voxel3D').newMesh(v,i)
end
function M.draw(map,px,pz,surface,t)
 local selected=M.setting:get();if selected=='off'then return end
 local mode=V.require('Weather').mode(map)
 if mode~='rain'and mode~='storm'then return end
 local key=tostring(map.id)..':'..math.floor(px/64)..':'..math.floor(pz/64)
 if not cache or cache.key~=key then
  if cache and cache.mesh then cache.mesh:release()end
  local anchors=M.anchors(px,pz,surface)
  cache={key=key,anchors=anchors,mesh=puddles(anchors)}
 end
 local R=V.require('Voxel3D');local T=V.require('Mat4')
 water=water or texture({.42,.48,.52,.20});foam=foam or texture({.77,.85,.88,.45});ring=ring or ringMesh()
 love.graphics.push('all')
 local ok,err=pcall(function()
  R.withEffect('alpha',function()
  if selected=='puddles'and cache.mesh then R.draw(cache.mesh,water)end
  for _,a in ipairs(cache.anchors)do
   local phase=((t or 0)*1.7+a.seed*7)%1
   if phase<.35 then
    local radius=.35+phase*6
    R.draw(ring,foam,T.mul(T.translate(a.x,a.h+.09,a.z),T.scale(radius,1,radius)))
   end
  end
  end)
 end)
 love.graphics.pop();M.error=not ok and tostring(err)or nil;M.lastCount=#cache.anchors
end
function M.invalidate()
 if cache and cache.mesh then cache.mesh:release()end
 for _,asset in ipairs({ring,water,foam})do if asset then asset:release()end end
 cache,ring,water,foam=nil,nil,nil,nil
end
return M
