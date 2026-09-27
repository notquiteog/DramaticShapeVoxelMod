local active,time,height=true,0,1
local uploads,draws,releases=0,{},0
local shader={send=function()end,release=function()end}
package.loaded['src.render.Assets']={register=function()end}
love={timer={getTime=function()return time end},image={newImageData=function()return {setPixel=function()end}end},graphics={}}
local g=love.graphics
for _,n in ipairs({'push','pop','setDepthMode','setBlendMode','setMeshCullMode','setColor','setShader'})do g[n]=function()end end
g.newImage=function()return {setFilter=function()end,setWrap=function()end,release=function()end}end
g.newShader=function()return shader end
g.draw=function(mesh)draws[#draws+1]=mesh end
local R={vp={},eye={0,0,0},lighting=function()end,seams=function()end,glass=function()end}
function R.newMesh(verts,indices,format)
 if #verts==0 then return end
 uploads=uploads+1;assert(format[4][1]=='MistGround')
 for _,v in ipairs(verts)do assert(v[7]==12 and v[2]>=v[7],'bank sunk through raised floor')end
 return {setTexture=function()end,release=function()releases=releases+1 end}
end
local modules={Voxel3D=R,Mat4=dofile('lib/Mat4.lua'),Structures={forMap=function()error('native mist asked Gen1 structures')end},
 TowerFogSettings={active=function()return active end,speedMultiplier=function()return 1 end,thicknessMultipliers=function()return 1,height end}}
local M=assert(loadfile('lib/TowerGraveMist.lua'))({require=function(n)return assert(modules[n],n)end})
local map={def={width=4,height=4}}
local layout={anchors={{2,2},{4,4}},walk=function()return true end,ground=function()return 12 end}
active=false;assert(not M.drawNative(map,layout)and uploads==0)
active=true;assert(M.drawNative(map,layout));local n=uploads;assert(n>0 and #draws>0)
height=1.5;time=.1;assert(M.drawNative(map,layout)and uploads==n,'live settings rebuilt geometry')
M.invalidate();assert(releases==n,'mist meshes leaked')
print('PASS native mist raised-floor vertices, OFF allocation, live thickness cache and disposal')
