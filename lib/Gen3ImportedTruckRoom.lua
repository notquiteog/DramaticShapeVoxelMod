-- Physical ORAS GR653 cargo, adapted to the exact native RSE truck footprint.
-- Every solid placement stays in the existing blocked cells. The engine owns
-- live moving-box offsets, room state, shutter timing, scripts and warps.
local V=...
local Models=V.require('SceneryModels')
local M={marker='oras_truck_cargo'}
local source,failed,dynamic,dynamicFailed,floorMesh,material
local prefix='oras_truck_'
local mask={'11111','10000','10000','11100','11111'}
local rows={{0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x208},
 {0x211,0x212,0x213,0x214,0x210},{0x219,0x21a,0x21b,0x21c,0x218},{0x221,0x222,0x223,0x224,0x220}}
local function data()
 if source~=nil then return source or nil end
 local ok,d=pcall(V.require,'ImportedTruckInteriorData')
 if not ok or type(d)~='table'or type(d.models)~='table'then source=false;M.lastError='original ORAS truck room unavailable';return end
 source=d;return d
end
function M.isModel(id)return id==prefix..'north_dresser'or id==prefix..'south_dresser'or id==prefix..'cardboard_box'or id==prefix..'room_materials'end
function M.register(id)
 if not M.isModel(id)then return nil,'unreviewed ORAS truck component'end
 if Models.info(id)then return true end
 local d=data();if not d or not d.models[id]then return nil,M.lastError or'original ORAS truck component unavailable'end
 return Models.register(id,d.models[id],{read=function(path)return V.mod:read(path)end})
end
function M.eligible(p,cells)
 local r=p and p.recipe
 if not(r and r.name=='hoenn_truck_cargo'and r.design=='em_truck_cargo'and r.family=='rse'and r.primary=='general'
  and p.pair=='general__inside_of_truck'and p.cx==0 and p.cy==0 and p.w==80 and p.d==80 and not p.stageHidden)then return false end
 local Truck=V.require('Gen3TruckCargo');local base
 for y,row in ipairs(rows)do
  if not r.rows[y]or #r.rows[y]~=5 then return false end
  for x,mid in ipairs(row)do
   local c=cells[(x-1)..':'..(y-1)];local blocked=mask[y]:sub(x,x)=='1'
   if r.rows[y][x]~=mid or not c or c.primary~='general'or c.pair~=p.pair
    or c.mid~=mid and not Truck.matches(r,c.mid,mid)or c.stageHidden or c.stairs or c.civic or c.boundary
    or blocked and(c.prop~=p or c.collision~=7)or not blocked and(c.prop~=nil or c.collision~=0 and c.collision~=0x72)then return false end
   if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
  end
 end
 return true
end
function M.placements(p,cells)
 if not M.eligible(p,cells)then return{}end
 for _,id in ipairs{prefix..'north_dresser',prefix..'south_dresser',prefix..'cardboard_box'}do
  local ok,err=M.register(id);if not ok then M.lastError=err;return{}end
 end
 local boxFit={width=16,depth=16,padding=.25}
 local box=assert(Models.fit(prefix..'cardboard_box',boxFit))
 local list={}
 local function add(id,x,z,w,d,y)
  list[#list+1]={model=prefix..id,x=x,y=(p.groundHeight or 0)+(y or 0),z=z,
   fit={width=w,depth=d,padding=.25},source=p,marker=M.marker}
 end
 add('north_dresser',32,0,32,16);add('south_dresser',16,64,32,16)
 -- The original source cardboard box fills corresponding native cargo cells.
 -- The three native113 moving boxes own(0,0),(0,48),(32,48); never duplicate them.
 for _,q in ipairs{{16,0,2},{64,0,2},{0,16,2},{0,32,2},{0,64,2},{48,64,1},{64,64,1},{16,48,1}}do
  for level=0,q[3]-1 do add('cardboard_box',q[1],q[2],16,16,level*(box.bounds[5]+.15))end
 end
 return list
end
local function modern(category)return V.require('VisualStyles').modern(category)end
function M.wallpaper()
 if not modern('interiors')then return end
 if material then return material end
 if failed then return end
 local id=prefix..'room_materials';local ok,err=M.register(id)
 if not ok then failed=true;M.lastError=err;return end
 local wall,why=Models.image(id,'assets/scenery/oras-truck-interior/wall01.png','repeat','repeat')
 local floor,reason=Models.image(id,'assets/scenery/oras-truck-interior/yuka.png','repeat','repeat')
 if not wall or not floor then failed=true;M.lastError=why or reason;return end
 material={wall=wall,door=wall,floor=floor,wallpaperWidth=data().wallRepeatAt40,source='oras_gr653'}
 return material
end
function M.floorGeometry(p)
 if not(p and p.truckRoom and p.bounds and p.bounds[1]==0 and p.bounds[2]==0 and p.bounds[3]==80 and p.bounds[4]==80)then return end
 local d=data();if not d then return end
 local uv=d.floorUv;local y=.025
 return{{0,y,0,uv[1],uv[4],1},{80,y,0,uv[3],uv[4],1},{80,y,80,uv[3],uv[2],1},{0,y,80,uv[1],uv[2],1}},{1,2,3,1,3,4}
end
function M.drawFloor(p,draw)
 if not modern('interiors')or not p or not V.require('Gen3TruckCargo').room(p.truckRoom)then return false end
 local m=M.wallpaper();if not m then return false end
 if not floorMesh then local v,i=M.floorGeometry(p);if not v then return false end;floorMesh=V.require('Voxel3D').newMesh(v,i)end
 if not floorMesh then return false end
 draw(floorMesh,m.floor);return true
end
function M.drawCargo(gid,x,z,height,spr,frame,draw,reflection)
 if not modern('props')or tonumber(gid)~=113 or frame~=0 or not(spr and spr.image and spr.width==16 and spr.height==16 and spr.frameCount==1)then return false end
 local Truck=V.require('Gen3TruckCargo')
 local def=require('src.core.game3.map').currentDef()
 if not Truck.eligible(gid,def,require('src.core.GameVersion').get())or not Truck.room(def)or dynamicFailed then return false end
 if not dynamic then
  local id=prefix..'cardboard_box';local ok,err=M.register(id);if not ok then dynamicFailed=true;M.lastError=err;return false end
  local result,why=Models.buildBatches({{model=id,x=-7,y=0,z=-7,fit={width=14,depth=14,padding=.25}}},V.require('Voxel3D').newMesh)
  if not result then dynamicFailed=true;M.lastError=why;return false end;dynamic=result
 end
 local Mat,Shadow=V.require('Mat4'),V.require('ShadowMap');local model=Mat.translate(x+8,height,z+8);local caster=Shadow.snug(model)
 if reflection then model=Mat.mul(Mat.translate(x+8,2*reflection-height+V.require('Water').CAST_RAISE,z+8),Mat.scale(1,-1,1))end
 for _,part in ipairs(dynamic)do
  if draw==Shadow.draw then draw(part.mesh,part.image,caster)else draw(part.mesh,part.image,model,nil,caster)end
 end
 return true
end
function M.clear()
 if dynamic then Models.releaseBatches(dynamic)end
 if floorMesh then floorMesh:release()end
 dynamic,floorMesh,material,failed,source,dynamicFailed=nil,nil,nil,nil,nil,nil
end
return M
