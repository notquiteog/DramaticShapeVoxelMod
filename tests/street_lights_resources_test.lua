local translated, released, models=0,0,{}
local R={glassMaskNow=function()end,glass=function()end,newMesh=function()return {}end,
 draw=function(mesh,texture,model)models[#models+1]=model end}
local Mat={translate=function(x,y,z)translated=translated+1;return {x,y,z}end}
local V={require=function(n)if n=='Voxel3D'then return R elseif n=='Mat4'then return Mat else return {customCityGround=function()return true end}end end}
love={image={newImageData=function()return {setPixel=function()end,release=function()released=released+1 end}end},
 graphics={newImage=function()return {setFilter=function()end}end}}
local M=assert(loadfile('lib/StreetLights.lua'))(V)
M.geometry=function()return {},{}end
M.configure{map={id='OTHER'},neighbors={{map={id='LAVENDER_TOWN'},ox=80,oy=-16}}}
M.draw();M.draw()
assert(models[1]==models[2]and models[1][1]==80 and models[1][3]==-16,'draw rebuilt or misplaced model')
assert(translated==2 and released==2,'transient transforms or image data retained')
M.configure{map={id='LAVENDER_TOWN'}};M.draw()
assert(models[3][1]==0 and models[3][3]==0,'configure did not refresh transform')
assert(released==2,'static resources rebuilt')
print('PASS street light cached transforms, neighbor origin refresh and upload data release')
