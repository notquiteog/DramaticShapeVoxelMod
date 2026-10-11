local M=assert(loadfile('lib/KfpAmbientDetails.lua'))({require=function(n)
 if n=='ModSetting'then return{new=function()return{}end}end
 if n=='VoxelScene'then return{groundAt=function()return 16 end}end
 if n=='Gen3Elevation'then return{at=function()return 24 end}end
 error(n)
end})
local function cell(x,z)
 if x<0 or z<0 or x>10 or z>10 then return end
 return{water=x<5,walk=true,y=8}
end
local foam=M.anchors(cell,80,80,'foam');assert(#foam==11)
for _,a in ipairs(foam)do assert(a.x==78 and a.dx==1 and a.dz==0 and a.y==8,'foam off native water edge')end
assert(#M.anchors(function(x,z)local c=cell(x,z);if c then c.walk=false end;return c end,80,80,'foam')==0,'walls emit foam')
assert(#M.anchors(function(x,z)local c=cell(x,z);if c and not c.water then c.y=24 end;return c end,80,80,'foam')==0,'cliffs emit foam')
assert(#M.anchors(function()return{water=true,walk=true,y=0}end,80,80,'foam')==0,'all-water invented shore')
local dust=M.anchors(cell,80,80,'dust');assert(#dust>0 and #dust<=48)
for _,a in ipairs(dust)do assert(a.x>=88 and a.y==8,'dust in water')end
local rng=math.random;math.random=function()error('game RNG used')end
for frame=1,100 do
 local v=M.vertices(foam,frame/30,'foam');assert(#v<=M.MAX_VERTICES)
 for _,p in ipairs(v)do assert(p[1]<80 and p[2]>=7.8 and p[2]<10,'spray leaves water/correct elevation')end
 local dv=M.vertices(dust,frame/30,'dust');assert(#dv<=M.MAX_VERTICES)
 for _,p in ipairs(dv)do assert(p[2]>12 and p[2]<23,'dust escapes room height')end
end
math.random=rng
local map={widthCells=2,heightCells=2,isWaterCell=function()return false end,isWalkableCell=function()return true end}
assert(M.surface(map)(1,1).y==16);assert(M.surface(map)(2,1)==nil)
package.preload['src.core.game3.collision']=function()return{isWater=function()return true end,isWalkable=function()return false end}end
local g3={nativeGeneration=3,nativeDef={midLayout={width=2,height=2}}}
assert(M.surface(g3)(1,1).y==24 and M.surface(g3)(1,1).water)
print('PASS KFP native shore/room particles: boundaries, cliffs, solids, native elevations, bounded geometry, isolated RNG')
