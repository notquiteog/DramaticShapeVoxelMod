local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local T=V.require('Gen3TruckCargo')
local rows={{0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x20d},
 {0x211,0x212,0x213,0x214,0x215},{0x219,0x21a,0x21b,0x21c,0x21d},{0x221,0x222,0x223,0x224,0x220}}
local layout={pair=T.pair,midAt=function(_,x,y)return rows[y+1]and rows[y+1][x+1]or 0 end}
local def={id='EM_INSIDE_OF_TRUCK',width=6,height=6,mapType=8,midLayout=layout,warps={{x=4,y=1},{x=4,y=2},{x=4,y=3}}}
for _,id in ipairs{'EM_INSIDE_OF_TRUCK','RU_INSIDE_OF_TRUCK','SA_INSIDE_OF_TRUCK'}do
 def.id=id;assert(T.room(def)==def and T.roomState(def)=='closed')
end
def.id='CUSTOM_HOME';assert(not T.room(def));def.id='EM_INSIDE_OF_TRUCK'
local keep=rows[1][2];rows[1][2]=0;assert(not T.room(def),'unrelated modified context gained truck walls');rows[1][2]=keep

local under={getPixel=function()return .2,.4,.6,1 end}
local middle={getPixel=function()return .6,.2,.4,.5 end}
local over={getPixel=function()return 1,.8,.4,.25 end}
local ts={cols=4,imageData=under,midImageData=middle,overImageData=over,midToSlot={[0x20d]=0,[0x215]=1,[0x21d]=2}}
local pixels=0
assert(T.panelPixels(ts,{0x20d,0x215,0x21d},function(x,y,r,g,b,a)
 pixels=pixels+1;assert(x>=0 and x<16 and y>=0 and y<48)
 assert(math.abs(r-.55)<1e-8 and math.abs(g-.425)<1e-8 and math.abs(b-.475)<1e-8 and a==1,'native BG composition changed')
end));assert(pixels==768)
assert(not T.panelPixels(ts,{1},function()error('missing source emitted')end))
local images,released=0,0
love={image={newImageData=function()return{setPixel=function()end,release=function()end}end},graphics={newImage=function()
 images=images+1;return{setFilter=function()end,setWrap=function()end,release=function()released=released+1 end}
end}}
package.loaded['src.core.game3.tileset_native']={get=function(pair)assert(pair==T.pair);return ts end}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
local D=V.require('InteriorDiorama');local room=D.forMap(def,3)
assert(room and room.truckRoom==def and room.nativeWallFinish and room.noInteriorTrim)
assert(room.theme=='truck' and room.wallpaper and room.shellTexture==room.wallpaper)
assert(images==2 and D.forMap(def,3)==room and images==2,'live room rebuilt source images every frame')
assert(#room.doorways[2]==1 and room.doorways[2][1][1]==16 and room.doorways[2][1][2]==64)
local wall=D.geometry(room,2,false)
for _,v in ipairs(wall)do
 -- The native gray wallpaper is flush with the existing boundary and has
 -- one unbroken vertical repeat, including at the bottom of the wall.
 assert(v[1]>=80,'truck wall enters native warp approach')
 assert(v[5]>=0 and v[5]<=1,'wallpaper repeated its top frame at floor level')
end
local uploads,draws=0,0
cache.Voxel3D={newMesh=function(v,i)uploads=uploads+1;assert(#v==24 and #i==36);return{release=function()end}end}
cache.Mat4=dofile('lib/Mat4.lua')
local function draw(mesh,image,model)
 draws=draws+1;assert(model[4]>80 and model[8]==0 and model[12]==16,'shutter obstructs original warp cells')
end
assert(T.drawShutter(room,draw)and draws==1 and uploads==1)
assert(T.drawShutter(room,draw)and draws==2 and uploads==1)
for y,mid in ipairs{0x208,0x210,0x218}do rows[y+1][5]=mid end
assert(T.roomState(def)=='open'and not T.drawShutter(room,draw)and draws==2,'open native exit retained a shutter')
assert(D.forMap(def,3)==room,'native door state rebuilt the whole room')
rows[2][5]=0x20d;assert(not T.roomState(def)and not T.drawShutter(room,draw),'partial/custom exit state was invented')
for y,mid in ipairs{0x20d,0x215,0x21d}do rows[y+1][5]=mid end
assert(T.drawShutter(room,draw)and uploads==1,'closed state did not restore cached shutter')
T.clear();assert(released==2,'native panel textures leaked')
assert(D.forMap(def,3)==room and images==4,'room retained released wallpaper after scene cleanup')
-- A closed shutter participates in the ordinary near-wall camera cutaway;
-- an outside east boom must still see into the room, while an inside eye
-- sees the physically closed native door.
local oldDraw=T.drawShutter;local panels=0
T.drawShutter=function()panels=panels+1 end
cache.KfpInterior={prepare=function()end,cutaway={get=function()return true end},
 ceiling={get=function()return false end},dressing={get=function()return false end}}
cache.Voxel3D={eye={40,20,40},interiorClip=function()end,draw=function()end,
 newMesh=function()return{release=function()end}end}
D.draw(room);assert(panels==1,'inside view lost native closed shutter')
cache.Voxel3D.eye={115,20,40};D.draw(room);assert(panels==1,'east camera cutaway retained obstructing shutter')
T.drawShutter=oldDraw
print('PASS native RSE truck wall layers, continuous finish, exact closed/open shutter and original warp clearance')
