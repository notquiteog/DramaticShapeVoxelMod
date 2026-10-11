local enabled,mode,draws=false,'clear',0
local V={require=function(n)
 if n=='ModSetting'then return{new=function()return{get=function()return enabled end}end}end
 if n=='Weather'then return{mode=function()return mode end}end
 if n=='Voxel3D'then return{pushQuad=function()end,newMesh=function()return{release=function()end}end,draw=function()draws=draws+1 end}end
 if n=='Mat4'then return{mul=function()return{}end,translate=function()return{}end,rotateY=function()return{}end,scale=function()return{}end}end
end}
love={image={newImageData=function()return{setPixel=function()end,release=function()end}end},graphics={newImage=function()return{setFilter=function()end,release=function()end}end,push=function()end,pop=function()end,setDepthMode=function()end}}
local M=assert(loadfile('lib/KfpRainProps.lua'))(V)
local actors={{human=true,x=1,z=1},{human=true,player=true,x=2,z=2},{human=false,x=3,z=3},{x=4,z=4}}
assert(M.draw(actors,{})==0);enabled=true;assert(M.draw(actors,{})==0)
mode='rain';assert(M.draw(actors,{})==1 and draws==1,'only known human NPCs carry umbrellas')
for i=1,60 do actors[#actors+1]={human=true,x=i,z=i}end
assert(M.draw(actors,{})==32,'bounded draw cost');assert(not M.error)
M.invalidate();print('PASS KFP optional rain props / human filter / draw bound')
