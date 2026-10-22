local edition='emerald';package.loaded['src.core.GameVersion']={get=function()return edition end}
local native={{0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x20d},{0x211,0x212,0x213,0x214,0x215},{0x219,0x21a,0x21b,0x21c,0x21d},{0x221,0x222,0x223,0x224,0x220}}
local def={id='EM_INSIDE_OF_TRUCK',width=5,height=5,midLayout={pair='general__inside_of_truck',midAt=function(_,x,y)return native[y+1]and native[y+1][x+1]end}}
package.loaded['src.core.game3.map']={currentDef=function()return def end}
local enabled={props=true,interiors=true};local textureAvailable=true;local image={};local uploaded,released,reads=0,0,0
local source=dofile('lib/ImportedTruckInteriorData.lua')
local modules={SceneryModelData={},ImportedTreeData={},ImportedTruckInteriorData=source,BuildBudget={check=function()end},
 VisualStyles={modern=function(c)return enabled[c]end},Mat4=dofile('lib/Mat4.lua'),Water={CAST_RAISE=.02}}
local calls={};local Shadow={snug=function(m)return m end,draw=function(...)calls[#calls+1]={...}end};modules.ShadowMap=Shadow
modules.Voxel3D={newMesh=function(v,i)uploaded=uploaded+1;return{setTexture=function()end,release=function()released=released+1 end}end}
local V={mod={read=function()return nil end}}
function V.require(n)
 if modules[n]then return modules[n]end
 local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m
end
local Models=V.require('SceneryModels');Models.image=function()reads=reads+1;if textureAvailable then return image end;return nil,'source missing'end
local Truck=V.require('Gen3TruckCargo');local T=V.require('Gen3ImportedTruckRoom');local I=V.require('Gen3ImportedInteriors')
local r={name='hoenn_truck_cargo',design='em_truck_cargo',family='rse',primary='general',pair=Truck.pair,rows={
 {0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x208},{0x211,0x212,0x213,0x214,0x210},{0x219,0x21a,0x21b,0x21c,0x218},{0x221,0x222,0x223,0x224,0x220}}}
local p={recipe=r,pair=Truck.pair,cx=0,cy=0,w=80,d=80,groundHeight=0}
local mask={'11111','10000','10000','11100','11111'};local cells={}
for y,row in ipairs(native)do for x,mid in ipairs(row)do local b=mask[y]:sub(x,x)=='1';cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,base=0,primary='general',pair=Truck.pair,collision=b and 7 or 0,prop=b and p or nil}end end
local function blocked(x,y)return mask[y+1]and mask[y+1]:sub(x+1,x+1)=='1'end
for ed,pre in pairs{emerald='EM_',ruby='RU_',sapphire='SA_'}do
 edition=ed;def.id=pre..'INSIDE_OF_TRUCK';assert(T.eligible(p,cells))
 local placements=T.placements(p,cells);assert(#placements==15)
 for _,q in ipairs(placements)do
  assert(q.marker==T.marker and q.source==p)
  local parts=assert(Models.vertices(q.model,q.fit));local x0,z0,x1,z1=math.huge,math.huge,-math.huge,-math.huge
  for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
   local x,z=q.x+v[1],q.z+v[3];x0,z0,x1,z1=math.min(x0,x),math.min(z0,z),math.max(x1,x),math.max(z1,z)
   assert(x>0 and x<80 and z>0 and z<80,'cargo exceeds native room')
  end end
  for y=0,4 do for x=0,4 do if x0<(x+1)*16 and x1>x*16 and z0<(y+1)*16 and z1>y*16 then
   assert(blocked(x,y),'static source geometry crosses a native walking/warp cell')
   assert(not(x==0 and(y==0 or y==3)or x==2 and y==3),'native moving-box object was duplicated')
  end end end
 end
end
local before={};for k,c in pairs(cells)do before[k]={c.mid,c.collision,c.base,c.prop}end
local parts,err,count=I.build(cells,modules.Voxel3D.newMesh,{})
assert(parts and not err and count==15 and p.importedInterior==T.marker)
for k,c in pairs(cells)do local b=before[k];assert(c.mid==b[1]and c.collision==b[2]and c.base==b[3]and c.prop==b[4],'presentation changed native topology')end
Models.releaseBatches(parts);p.importedInterior=nil
textureAvailable=false;parts,err,count=I.build(cells,modules.Voxel3D.newMesh,{})
assert(not parts and err and count==0 and not p.importedInterior,'partial source replaced complete native fallback');textureAvailable=true
for y,mid in ipairs{0x208,0x210,0x218}do cells['4:'..y].mid=mid;cells['4:'..y].collision=0x72;native[y+1][5]=mid end
assert(T.eligible(p,cells),'native open door lost source cargo')
for _,key in ipairs{'collision','base','mid','prop'}do
 local c=cells['1:0'];local old=c[key];c[key]=key=='prop'and{}or key=='collision'and 0 or key=='base'and 8 or 0
 assert(not T.eligible(p,cells),'changed native body '..key..' accepted');c[key]=old
end
local c=cells['4:2'];c.collision=7;assert(not T.eligible(p,cells),'native exit blocked by source recipe');c.collision=0x72
local room={truckRoom=def,bounds={0,0,80,80}};local v,ix=T.floorGeometry(room)
assert(#v==4 and #ix==6);for _,q in ipairs(v)do assert(q[2]==.025 and q[4]>=source.floorUv[1]and q[4]<=source.floorUv[3])end
room.bounds[4]=64;assert(not T.floorGeometry(room),'partial floor footprint accepted');room.bounds[4]=80
local function draw(...)calls[#calls+1]={...}end
assert(T.drawFloor(room,draw)and calls[#calls][2]==image);assert(T.wallpaper().source=='oras_gr653'and T.wallpaper().wallpaperWidth>27)
local spr={image={},width=16,height=16,frameCount=1}
assert(T.drawCargo(113,3.5,48,2,spr,0,draw));local matrix=calls[#calls][3]
assert(matrix[4]==11.5 and matrix[8]==2 and matrix[12]==56,'live native offsets discarded')
local uploads=uploaded;assert(T.drawCargo(113,4,49,3,spr,0,Shadow.draw)and uploaded==uploads,'animation rebuilt physical source box')
assert(T.drawCargo(113,4,49,3,spr,0,draw,-4));assert(math.abs(calls[#calls][3][8]+10.98)<1e-8)
enabled.props=false;assert(not T.drawCargo(113,0,0,0,spr,0,draw));enabled.props=true
edition='firered';assert(not T.drawCargo(113,0,0,0,spr,0,draw));edition='emerald'
def.id='EM_LITTLEROOT_TOWN';assert(not T.drawCargo(113,0,0,0,spr,0,draw));def.id='EM_INSIDE_OF_TRUCK'
enabled.interiors=false;assert(not T.wallpaper()and not T.drawFloor(room,draw));enabled.interiors=true
T.clear();textureAvailable=false;assert(not T.drawCargo(113,0,0,0,spr,0,draw));local attempts=reads
assert(not T.drawCargo(113,0,0,0,spr,0,draw)and reads==attempts,'missing source retried every actor frame')
T.clear();textureAvailable=true;assert(T.drawCargo(113,0,0,0,spr,0,draw));T.clear()
local sourceTriangles=0
for id,model in pairs(source.models)do
 for _,part in ipairs(model.parts)do
  for _,color in ipairs(part.colors)do assert(color[1]==1 and color[2]==1 and color[3]==1,'baked source tint retained')end
  if id~='oras_truck_room_materials'then sourceTriangles=sourceTriangles+#part.indices/3 end
 end
end
assert(sourceTriangles==612 and source.wallRepeatAt40>27 and source.wallRepeatAt40<29)
print('PASS authentic ORAS truck cargo/clean finishes, all15 blocked-only static placements, native moving-box offsets, exact open/closed topology, unchanged scripts/warps, styles and atomic source failure')
