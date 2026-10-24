local modules={SharedModelMesh=dofile('lib/SharedModelMesh.lua'),SceneryModelData={},ImportedTreeData={},ImportedLittlerootHomesData=dofile('lib/ImportedLittlerootHomesData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedLittlerootHomes.lua'))(V);modules.Gen3ImportedLittlerootHomes=M
local D=assert(loadfile('lib/Gen3LittlerootDoors.lua'))(V);modules.Gen3LittlerootDoors=D
local function mesh(vertices,indices)if vertices and (#vertices==12 and #indices==12) then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local west={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x222,0x232,0x230,0x240,0x221},{0x22a,0x23a,0x238,0x248,0x229}}
local east={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x220,0x240,0x231,0x232,0x223},{0x228,0x248,0x239,0x23a,0x22b}}
local fixtures={{'littleroot_player_house','LITTLEROOT_TOWN','oras_littleroot_home_west',2,4,'general__petalburg',{0,0,0,0,0},west,5,3},{'littleroot_rival_house','LITTLEROOT_TOWN','oras_littleroot_home_east',13,4,'general__petalburg',{0,0,0,0,0},east,5,1}}
for _,ed in ipairs{'EM_','RU_','SA_'}do for _,f in ipairs(fixtures)do
 local rows=f[8]
 local region={x=0,y=0,def={id=ed..f[2]}};local g={cx=f[4],cy=f[5],kind='house',width=f[9],depth=5,pair=f[6],groundHeight=0,custom={family='rse',name=f[1]}};local cells={}
 for y=0,4 do for x=0,g.width-1 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and f[7][x+1]or(y==4 and x==f[10] and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==f[3] and #parts==5 and #g.importedLittlerootDoors.parts==6)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-(f[10]*16+8))<1e-6 and math.abs(fit.anchors.door[3]-54)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>59 and fit.bounds[6]-fit.bounds[3]>44)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3 end;assert(tris==66)end
 assert(D.ownsDoor(g,g.cx+f[10],g.cy+4)and not D.ownsDoor(g,g.cx+f[10]+1,g.cy+4));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedLittlerootDoors);missing=false;S.retryImages(D.id);S.retryImages(f[3])
end end
assert(released>0 and caps==6);print('PASS6 own Littleroot home candidates, exact blocked-footprint source closures and66-triangle original hinged states, native clearance and atomic rollback')
