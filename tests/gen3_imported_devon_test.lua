local modules={SceneryModelData={},ImportedTreeData={},ImportedRustboroDevonData=dofile('lib/ImportedRustboroDevonData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedDevon.lua'))(V);modules.Gen3ImportedDevon=M
local D=assert(loadfile('lib/Gen3DevonDoors.lua'))(V);modules.Gen3DevonDoors=D
local function mesh(vertices,indices)return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
for _,ed in ipairs{'EM_','RU_','SA_'}do
 local region={x=0,y=0,def={id=ed..'RUSTBORO_CITY'}};local g={cx=7,cy=7,kind='devon',width=10,depth=9,pair='general__rustboro',groundHeight=0,custom={family='rse',name='rustboro_devon_corporation',geometry=ed=='RU_'and'landmark'or'devon',preserveWalkableFloor=true}};local cells={}
 for y=0,8 do for x=0,9 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=M.rows[y+1][x+1],collision=y<8 and 7 or(x==3 or x==6)and 7 or(x==4 or x==5)and 113 or 0}end end
 assert(M.eligible(g,cells));local parts={};local ok,why=M.build(g,cells,mesh,parts);assert(ok,why);assert(#parts==5 and #g.importedDevonDoors.parts==6);local fit=g.importedHoenn;assert(fit.model==M.id and fit.anchors.door[1]==80 and fit.anchors.door[3]==118)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3 end;assert(tris==46)end
 assert(D.ownsDoor(g,11,15)and D.ownsDoor(g,12,15)and not D.ownsDoor(g,13,15));assert(D.state(g,{x=12,y=15,frame=2})==2 and D.state(g,{x=10,y=15,frame=2})==0)
 D.release(g);S.releaseBatches(parts);g.importedHoenn=nil
 local c=cells['7:8'];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7;c.mid=0;assert(not M.eligible(g,cells));c.mid=M.rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedDevonDoors);missing=false;S.retryImages(D.id);S.retryImages(M.id)
end
assert(released>0);print('PASS3 exact Devon candidates,46-triangle paired original hinge states, preserved native walkable strip, triangle clearance and atomic missing-source rollback')
