-- Native RSE truck cargo only. The engine owns the sequence, locks, sounds,
-- moving object offsets and live doorway; this module only supplies geometry.
local V=...
local M={pair='general__inside_of_truck'}
local editions={ruby=true,sapphire=true,emerald=true}
local blocked={'11111','10000','10000','11100','11111'}
local closed={[0x208]=0x20d,[0x210]=0x215,[0x218]=0x21d}
local meshes={}
local roomMaterials=setmetatable({},{__mode='k'})
local shutterMeshes={}
local nativeRows={{0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x208},
 {0x211,0x212,0x213,0x214,0x210},{0x219,0x21a,0x21b,0x21c,0x218},{0x221,0x222,0x223,0x224,0x220}}
local floorArt={}
for _,row in ipairs(nativeRows)do for _,mid in ipairs(row)do floorArt[mid]=true;if closed[mid]then floorArt[closed[mid]]=true end end end
-- Scene-only floor policy: use the same clean native gray floor everywhere,
-- including beneath separate cargo and across live exit-light drawings. The
-- caller also suppresses middle/over ground paint; padded black cells stay void.
function M.floor(c)
 if c and c.pair==M.pair and floorArt[c.mid]then return 0x214 end
end
local function recipe(r)
 return r and r.name=='hoenn_truck_cargo' and r.pair==M.pair
  and r.family=='rse' and r.primary=='general' and r.design=='em_truck_cargo'
end
function M.claimCells()
 local out={}
 for y,row in ipairs(blocked)do for x=1,#row do
  if row:sub(x,x)=='1'then out[x..':'..y]=true end
 end end
 return out
end
function M.matches(r,actual,expected)
 return recipe(r) and closed[expected]~=nil and actual==closed[expected]
end
-- Exact artwork identifies the room; known native permissions still veto
-- any static cargo whose blocked footprint was changed by another provider.
function M.footprint(r,cells,x,y)
 if not recipe(r)then return true end
 for dy,row in ipairs(blocked)do for dx=1,#row do if row:sub(dx,dx)=='1'then
  local c=cells[(x+dx-1)..':'..(y+dy-1)]
  if not c or c.collision~=nil and c.collision~=7 then return false end
 end end end
 return true
end
function M.eligible(gid,def,edition)
 return editions[edition]==true and tonumber(gid)==113
  and def and def.midLayout and def.midLayout.pair==M.pair or false
end
function M.roomState(def)
 local layout=def and def.midLayout
 if not(layout and layout.pair==M.pair and layout.midAt)then return end
 local open,shut=true,true
 for row,mid in ipairs{0x208,0x210,0x218}do
  local actual=layout:midAt(4,row)
  open=open and actual==mid;shut=shut and actual==closed[mid]
 end
 return shut and 'closed' or open and 'open' or nil
end
function M.room(def)
 local id=def and def.id or ''
 if not(id=='RU_INSIDE_OF_TRUCK'or id=='SA_INSIDE_OF_TRUCK'or id=='EM_INSIDE_OF_TRUCK')or not M.roomState(def)then return end
 for y,row in ipairs(nativeRows)do for x,mid in ipairs(row)do
  local actual=def.midLayout:midAt(x-1,y-1)
  if actual~=mid and not(closed[mid]and actual==closed[mid])then return end
 end end
 return def
end
-- Compose the live native three BG layers. Closed floor/shutter drawings
-- provide the corrugated gray metal finish; no source pixels ship in Git.
function M.panelPixels(ts,ids,put)
 if not(ts and ts.imageData and ts.cols and ts.midToSlot)then return false end
 for _,mid in ipairs(ids)do if ts.midToSlot[mid]==nil then return false end end
 for y=0,#ids*16-1 do for x=0,15 do
  local slot=ts.midToSlot[ids[math.floor(y/16)+1]]
  local px,py=slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y%16
  local r,g,b,a=ts.imageData:getPixel(px,py)
  for _,data in ipairs{ts.midImageData or false,ts.overImageData or false}do if data then
   local rr,gg,bb,aa=data:getPixel(px,py)
   r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
  end end
  put(x,y,r,g,b,a)
 end end
 return true
end
function M.roomMaterial(ts)
 local old=roomMaterials[ts]
 if old and old.under==ts.imageData and old.middle==ts.midImageData and old.over==ts.overImageData then return old end
 local function image(ids)
  local pixels=love.image.newImageData(16,#ids*16)
  if not M.panelPixels(ts,ids,function(...)pixels:setPixel(...)end)then pixels:release();return end
  local result=love.graphics.newImage(pixels);pixels:release()
  result:setFilter('nearest','nearest');result:setWrap('repeat','repeat');return result
 end
 local wall=image{0x20d,0x215};if not wall then return end
 local door=image{0x20d,0x215,0x21d};if not door then wall:release();return end
 if old then old.wall:release();old.door:release()end
 local out={wall=wall,door=door,under=ts.imageData,middle=ts.midImageData,over=ts.overImageData}
 roomMaterials[ts]=out;return out
end
function M.wallpaper()
 local ok,result=pcall(function()
  local ts=require('src.core.game3.tileset_native').get(M.pair)
  return ts and M.roomMaterial(ts)
 end)
 if not ok then M.lastError=tostring(result);return end
 return result
end
function M.shutterGeometry(width,height)
 local v,i={},{}
 local function face(points,tex)
  local base=#v
  for k,p in ipairs(points)do v[#v+1]={p[1],p[2],p[3],tex[k][1],tex[k][2],.9}end
  for _,n in ipairs{1,2,3,1,3,4}do i[#i+1]=base+n end
 end
 local source={{0,0},{1,0},{1,1},{0,1}}
 local rim={{.5,.5},{.5,.5},{.5,.5},{.5,.5}}
 face({{0,height,0},{0,height,width},{0,0,width},{0,0,0}},source)
 face({{3,height,width},{3,height,0},{3,0,0},{3,0,width}},source)
 face({{0,height,0},{3,height,0},{3,height,width},{0,height,width}},rim)
 face({{0,0,width},{3,0,width},{3,0,0},{0,0,0}},rim)
 face({{3,height,0},{0,height,0},{0,0,0},{3,0,0}},rim)
 face({{0,height,width},{3,height,width},{3,0,width},{0,0,width}},rim)
 return v,i
end
-- The panel is wholly outside the room at its real east warp aperture. Its
-- presence follows live metatiles, never a parallel timer or gameplay lock.
function M.drawShutter(p,draw)
 if not(p and p.truckRoom and M.roomState(p.truckRoom)=='closed')then return false end
 local ok,result=pcall(function()
  local material=M.wallpaper();if not material then return false end
  local door=p.doorways and p.doorways[2]and p.doorways[2][1]
  if not door then return false end
  local width,height=door[2]-door[1],math.min(30,p.height-4)
  local key=width..':'..height;local mesh=shutterMeshes[key]
  if not mesh then
   local v,i=M.shutterGeometry(width,height);mesh=V.require('Voxel3D').newMesh(v,i)
   if not mesh then return false end;shutterMeshes[key]=mesh
  end
  draw(mesh,material.door,V.require('Mat4').translate(p.bounds[3]+.02,0,door[1]))
  return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
-- The reviewed native single-frame 16px moving-box drawing has a top in
-- rows1..4 and a front in rows5..14. Unproject those onto a closed box,
-- excluding the drawing's outer background border. Reuse its crate panels
-- on the hidden sides/rear; never project the perspective top down a wall.
-- Coordinates are local to the native cell centre; camera yaw is irrelevant.
function M.geometry(spr,frame)
 if not(spr and spr.image and spr.quads and spr.quads[frame])then return nil,'moving-box source unavailable' end
 local qx,qy,qw,qh=spr.quads[frame]:getViewport()
 if qw~=16 or qh~=16 or frame~=0 or spr.frameCount~=1 then return nil,'unreviewed moving-box drawing' end
 local iw,ih=spr.image:getDimensions()
 local function uv(l,t,r,b)
  return {{(qx+l+.01)/iw,(qy+t+.01)/ih},{(qx+r-.01)/iw,(qy+t+.01)/ih},
   {(qx+r-.01)/iw,(qy+b-.01)/ih},{(qx+l+.01)/iw,(qy+b-.01)/ih}}
 end
 local top,front=uv(1,1,15,5),uv(1,5,15,15)
 local u,v=(qx+8.5)/iw,(qy+14.5)/ih
 local bottom={{u,v},{u,v},{u,v},{u,v}}
 local vertices,indices={},{}
 local function face(points,tex,shade)
  local base=#vertices
  for k,p in ipairs(points)do vertices[#vertices+1]={p[1],p[2],p[3],tex[k][1],tex[k][2],shade}end
  for _,n in ipairs{1,2,3,1,3,4}do indices[#indices+1]=base+n end
 end
 face({{-7,10,-7},{7,10,-7},{7,10,7},{-7,10,7}},top,.95)
 face({{-7,10,7},{7,10,7},{7,0,7},{-7,0,7}},front,.85)
 face({{7,10,-7},{-7,10,-7},{-7,0,-7},{7,0,-7}},front,.8)
 face({{-7,10,-7},{-7,10,7},{-7,0,7},{-7,0,-7}},front,.82)
 face({{7,10,7},{7,10,-7},{7,0,-7},{7,0,7}},front,.88)
 face({{-7,0,7},{7,0,7},{7,0,-7},{-7,0,-7}},bottom,.7)
 return vertices,indices
end
-- actor() passes native raiseX in x and -raiseY in height already. A pure
-- world translation preserves those offsets in opaque, shadow and reflection
-- passes, without consuming player/character style or mutating any object.
function M.draw(gid,x,z,height,spr,frame,draw,reflection)
 local ok,result=pcall(function()
  local GV=require('src.core.GameVersion')
  local Map=require('src.core.game3.map')
  if not M.eligible(gid,Map.currentDef(),GV.get()) or V.require('VisualStyles').hd2d('props')then return false end
  local byFrame=meshes[spr and spr.image]
  local mesh=byFrame and byFrame[frame]
  if not mesh then
   local vertices,indices=M.geometry(spr,frame)
   if not vertices then return false end
   mesh=V.require('Voxel3D').newMesh(vertices,indices)
   if not mesh then return false end
   byFrame=byFrame or {};meshes[spr.image]=byFrame;byFrame[frame]=mesh
  end
  local Mat,Shadow=V.require('Mat4'),V.require('ShadowMap')
  local model=Mat.translate(x+8,height,z+8)
  local caster=Shadow.snug(model)
  if reflection then
   model=Mat.mul(Mat.translate(x+8,2*reflection-height+V.require('Water').CAST_RAISE,z+8),Mat.scale(1,-1,1))
  end
  if draw==Shadow.draw then draw(mesh,spr.image,caster)
  else draw(mesh,spr.image,model,nil,caster)end
  return true
 end)
 if not ok then M.lastError=tostring(result);return false end
 return result
end
function M.clear()
 for _,frames in pairs(meshes)do for _,mesh in pairs(frames)do mesh:release()end end
 for _,mesh in pairs(shutterMeshes)do mesh:release()end
 for _,material in pairs(roomMaterials)do material.wall:release();material.door:release()end
 shutterMeshes={};roomMaterials=setmetatable({},{__mode='k'})
 meshes={}
end
return M
