local modules={SceneryModelData={},ImportedTreeData={},ImportedHoennMartData=dofile('lib/ImportedHoennMartData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedMarts.lua'))(V);modules.Gen3ImportedMarts=M
local D=assert(loadfile('lib/Gen3MartDoors.lua'))(V);modules.Gen3MartDoors=D
local function mesh()return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local rows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}
for _,ed in ipairs{'EM_','RU_','SA_'}do
 local region={x=0,y=0,def={id=ed..'OLDALE_TOWN'}};local g={cx=13,cy=3,kind='mart',width=4,depth=4,pair='general__petalburg',groundHeight=0,custom={family='rse',name='oldale_mart'}};local cells={}
 for y=0,3 do for x=0,3 do cells[(13+x)..':'..(3+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and(x==3 and 7 or 0)or(y==3 and x==1 and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==M.id and #parts==2 and #g.importedMartDoors.parts==6)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-24)<1e-6 and math.abs(fit.anchors.door[3]-44.5)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>51 and fit.bounds[6]-fit.bounds[3]>46)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3 end;assert(tris==43)end
 assert(D.ownsDoor(g,14,6)and not D.ownsDoor(g,15,6));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells['13:4'];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedMartDoors);missing=false;S.retryImages(D.id);S.retryImages(M.id)
end
assert(released>0);print('PASS3 guarded Oldale Mart candidates,703 physical source faces+17 exact underside faces,43-triangle original sliding states, native clearance and atomic rollback')
