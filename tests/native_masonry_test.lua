local active=false;local color='granite';local palette
local modules={CommunityVisuals={customWalls=function()return active end,wallColor=function()return color end},Gen3Tilesets={outdoor=function(d)return d.outdoor end}}
local V={require=function(k)if not modules[k]then modules[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return modules[k]end}
local M=assert(loadfile('lib/NativeMasonry.lua'))(V)
assert(not M.new({outdoor=true}));active=true;assert(not M.new({outdoor=false}));assert(not M.new({outdoor=true,id='FR_SSANNE_EXTERIOR'}))
for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}}do
 local r=assert(M.new({outdoor=true}));local c={cx=2,cy=3}
 assert(M.append(r,c,d,4,36));assert(#r.vertices>100)
 for _,p in ipairs(r.vertices)do
  assert(p[1]>=32 and p[1]<=48 and p[3]>=48 and p[3]<=64,'masonry protrudes beyond owner cell')
  assert(p[2]>=4 and p[2]<=36,'native elevations changed')
 end
 local r2=M.new({outdoor=true});M.append(r2,c,d,4,36)
 for i,p in ipairs(r.vertices)do for j,v in ipairs(p)do assert(v==r2.vertices[i][j],'unstable courses')end end
end
local r=M.new({outdoor=true});assert(not M.append(r,{stageHidden=true},{1,0},0,16))
assert(not M.append(r,{floor={underpass=true}},{1,0},0,16));assert(not M.append(r,{floor={behavior=0x170}},{1,0},0,16));assert(not M.finish(r))
love={image={newImageData=function()palette={};return{setPixel=function(_,x,y,...)palette[x]={...}end,release=function()end}end},graphics={newImage=function()return{setFilter=function()end}end}}
modules.Voxel3D={newMesh=function(v,i)return {count=#v}end}
for _,name in ipairs{'granite','red','sandstone','slate'}do
 color=name;local r=M.new({outdoor=true});M.append(r,{cx=0,cy=0},{1,0},0,8)
 assert(M.finish(r).mesh.count>0);assert(palette[2][1]==V.require('MasonryPalette')[name].body[1])
end
print('PASS native retaining courses, all four directions, inset ownership, elevations, deterministic geometry, native fallback and shared palettes')
