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
