local modules={SceneryModelData={},ImportedTreeData={},ImportedPetalburgHomesData=dofile('lib/ImportedPetalburgHomesData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedPetalburgHomes.lua'))(V);modules.Gen3ImportedPetalburgHomes=M
local D=assert(loadfile('lib/Gen3PetalburgDoors.lua'))(V);modules.Gen3PetalburgDoors=D
local function mesh(vertices,indices)if vertices and (#vertices==26 and #indices==72)or(vertices and #vertices==24 and #indices==66) then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local narrow={{8,9,9,10},{16,17,17,18},{24,25,11,26},{32,33,19,34}}
local wide={{8,9,9,9,10},{16,17,17,17,18},{24,11,25,11,26},{32,19,33,19,34}}
local fixtures={{'petalburg_city_wide_home','PETALBURG_CITY','oras_petalburg_home_wide',5,2,'general__petalburg',{7,7,7,7,7},wide,5,2},{'petalburg_city_home','PETALBURG_CITY','oras_petalburg_home_west',9,16,'general__petalburg',{0,0,0,0},narrow,4,1},{'petalburg_city_home','PETALBURG_CITY','oras_petalburg_home_east',19,21,'general__petalburg',{7,7,7,7},narrow,4,1}}
for _,ed in ipairs{'EM_','RU_','SA_'}do for _,f in ipairs(fixtures)do
 local rows=f[8]
 local region={x=0,y=0,def={id=ed..f[2]}};local g={cx=f[4],cy=f[5],kind='house',width=f[9],depth=4,pair=f[6],groundHeight=0,custom={family='rse',name=f[1]}};local cells={}
 for y=0,3 do for x=0,g.width-1 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and f[7][x+1]or(y==3 and x==f[10] and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==f[3] and #parts==4 and #g.importedPetalburgDoors.parts==6)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-(f[10]*16+8))<1e-6 and math.abs(fit.anchors.door[3]-41)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>55 and fit.bounds[6]-fit.bounds[3]>46)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3 end;assert(tris==76)end
 assert(D.ownsDoor(g,g.cx+f[10],g.cy+3)and not D.ownsDoor(g,g.cx+f[10]+1,g.cy+3));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedPetalburgDoors);missing=false;S.retryImages(D.id);S.retryImages(f[3])
end end
assert(released>0 and caps==9);print('PASS9 own Petalburg home candidates, exact blocked-footprint source closures and76-triangle original hinged states, native clearance and atomic rollback')
