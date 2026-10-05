-- Native cell semantics for the shared ambient wildlife renderer. Sampling is
-- bounded around the viewer and never fabricates lawn from arbitrary pavement.
local V=...
local M={}
function M.native(map)return map and (map.nativeGeneration==3 or type(map.cellCollision)=='function')end
function M.profile(map)
 if not M.native(map)then return end
 local d=map.nativeDef or map.def or {}
 local outside
 if map.nativeGeneration==3 then outside=V.require('Gen3Tilesets').outdoor(d)
 else outside=d.outdoor==true or d.environment=='TOWN' or d.environment=='ROUTE' or d.environment=='FOREST'end
 if not outside then return end
 local id=tostring(map.id or '')
 local forest=V.require('NativeAtmosphere').kind(map)=='forest'
 local coast=id:find('SEAFOAM')or id:find('CIANWOOD')or id:find('OLIVINE')or id:find('PACIFIDLOG')or id:find('SLATEPORT')
 local kind=forest and 'woodland' or coast and 'coast' or id:find('SAFARI')and 'wetland' or (id:find('CITY')or id:find('TOWN'))and 'garden' or 'woodland'
 return {kind=kind,insects=coast and .45 or .85,native=true,legacy=forest and V.require('CommunityVisuals').customForest()or false}
end
function M.scan(map,px,pz)
 local out={green={},water=0,greenLevel=0}
 local d=map.nativeDef or map.def;local native=map.nativeGeneration==3
 local layout=native and d.midLayout
 if native and not layout then return out end
 local w,h=native and layout and layout.width or d.width*2,native and layout and layout.height or d.height*2
 if not w or not h then return out end
 local C=native and require('src.core.game3.collision')
 local function valid(x,y)return x>=0 and y>=0 and x<w and y<h end
 local function grass(x,y)return valid(x,y)and(native and C.isGrass(x,y)or not native and map:isGrassCell(x,y))end
 local function walk(x,y)return valid(x,y)and(native and C.isWalkable(x,y)or not native and map:isWalkableCell(x,y))end
 local function water(x,y)return valid(x,y)and(native and C.isWater(x,y)or not native and map:isWaterCell(x,y))end
 local function height(x,y)
  if native then return V.require('Gen3Elevation').at(d,x,y)end
  return V.require('Gen2Elevation').at(map,x,y)
 end
 local bestG,bestW=1e9,1e9
 local gx,gz=math.floor(px/32),math.floor(pz/32)
 for iz=gz-3,gz+3 do for ix=gx-3,gx+3 do
  local tx,tz=ix*2+1,iz*2+1;local x,z=tx*16+8,tz*16+8
  if valid(tx,tz)then
   local dist=(x-px)^2+(z-pz)^2
   if water(tx,tz)then bestW=math.min(bestW,dist)end
   if grass(tx,tz)and walk(tx,tz)then
    local y=height(x,z);local clear=true
    for dz=-1,1 do for dx=-1,1 do
     if not walk(tx+dx,tz+dz) or math.abs(height(x+dx*16,z+dz*16)-y)>.5 then clear=false end
    end end
    if clear then
     out.green[#out.green+1]={x=x,z=z,y=y,seed=(ix*53+iz*97)%997};bestG=math.min(bestG,dist)
    end
   end
  end
 end end
 table.sort(out.green,function(a,b)return(a.x-px)^2+(a.z-pz)^2<(b.x-px)^2+(b.z-pz)^2 end)
 out.greenLevel=math.max(0,1-math.sqrt(bestG)/100);out.water=math.max(0,1-math.sqrt(bestW)/110)
 return out
end
return M
