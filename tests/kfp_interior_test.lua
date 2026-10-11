local mods={}
local V={require=function(name)return assert(mods[name],name)end}
mods.ModSetting=assert(loadfile('lib/ModSetting.lua'))(V)
local K=assert(loadfile('lib/KfpInterior.lua'))(V);mods.KfpInterior=K
local released=0
local p={height=40,meshes={old={release=function()released=released+1 end}}}
K.prepare(p);assert(p.height==40 and released==0)
K.headroom.index=3;K.prepare(p);assert(p.height==64 and released==1)
K.headroom.index=1;K.prepare(p);assert(p.height==40)
assert(K.height(96)==96,'cave clearance shrank')
local draws={}
mods.Voxel3D={eye={40,12,40},interiorClip=function()end,
 newMesh=function(v,i)return{count=#v,release=function()end}end,
 draw=function(mesh)draws[#draws+1]=mesh end}
love={image={newImageData=function()return{setPixel=function()end,release=function()end}end},
 graphics={newImage=function()return{setFilter=function()end}end}}
local Room=assert(loadfile('lib/InteriorDiorama.lua'))(V)
local room={height=40,bounds={0,0,80,80},theme='home',meshes={}}
Room.draw(room);assert(#draws==6,'first person lost ceiling')
draws={};K.ceiling.index=2;Room.draw(room);assert(#draws==5,'ceiling OFF ignored')
K.ceiling.index=1;mods.Voxel3D.eye={40,70,100}
draws={};Room.draw(room);assert(#draws==5,'orbit ceiling blocks room')
K.cutaway.index=2;draws={};Room.draw(room);assert(#draws==6,'closed room option ignored')
local Shell=assert(loadfile('lib/Gen2InteriorShell.lua'))(V)
local map={def={environment='DUNGEON',width=4,height=4}}
local v,_,h=Shell.geometry(map,K);assert(#v==20 and h==48)
K.headroom.index=3;K.ceiling.index=2
v,_,h=Shell.geometry(map,K);assert(#v==16 and h==64,'dungeon policy differs')
print('PASS KFP shared interior policy, shell cache, camera and dungeon fallback')
local Decor=assert(loadfile('lib/KfpInteriorDecor.lua'))(V)
local v,i=Decor.pendant(40,40,40)
assert(#v==20 and #i==30,'upstream pendant faces changed')
for _,a in ipairs(v)do assert(a[2]>=29.8 and a[1]>=35 and a[1]<=45)end
local p={bounds={0,0,160,160},height=40,doorways={{{16,32}},{},{},{}}}
v,i=Decor.posters(p,1,19)
assert(#v==4,'poster covers door/adjacent wall')
for _,a in ipairs(v)do assert(a[2]>26 and a[2]<36 and a[4]>=0 and a[4]<=1)end
p.northFront=16
v,i=Decor.posters(p,1,19);assert(#v==0,'poster crosses stair recess')
assert(not K.dressing:get(),'native art default overridden')
print('PASS original KFP pendant and atlas decal dimensions, doorway and stair exclusion')
local cave={bounds={0,0,320,320},height=96}
v,i=Decor.stalactites(cave);assert(#v>0 and #v<=4096)
for _,a in ipairs(v)do assert(a[2]>=81 and a[2]<=96 and a[1]>=16 and a[1]<=320 and a[3]>=16 and a[3]<=320)end
print('PASS deterministic original ceiling spikes retain native traversal clearance')
local room={bounds={0,0,80,80},height=40,doorways={{{20,36}},{},{},{}},openings={{24,24,56,56}}}
v,i=Decor.lightGeometry(room)
assert(#v==0,'light plane covers a stair opening')
room.openings=nil;v,i=Decor.lightGeometry(room);assert(#v==8)
for _,a in ipairs(v)do assert(a[1]>=0 and a[1]<=80 and a[3]>=0 and a[3]<=80)end
print('PASS doorway spill/pool bounds and stair-void exclusion')
