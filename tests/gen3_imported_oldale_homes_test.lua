local modules={SharedModelMesh=dofile('lib/SharedModelMesh.lua'),SceneryModelData={},ImportedTreeData={},ImportedOldaleHomesData=dofile('lib/ImportedOldaleHomesData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedOldaleHomes.lua'))(V);modules.Gen3ImportedOldaleHomes=M
local D=assert(loadfile('lib/Gen3OldaleDoors.lua'))(V);modules.Gen3OldaleDoors=D
local function mesh(vertices,indices)if vertices and #vertices==28 and #indices==78 then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local rows={{0x26c,0x26d,0x26d,0x26e},{0x274,0x275,0x275,0x276},{0x27c,0x27f,0x27d,0x27e},{0x284,0x287,0x28f,0x286}}
local fixtures={{'oldale_house','OLDALE_TOWN','oras_oldale_home_northwest',4,4,'general__petalburg',{0,0,0,0},rows},{'oldale_house','OLDALE_TOWN','oras_oldale_home_southeast',14,13,'general__petalburg',{0,0,0,0},rows}}
for _,ed in ipairs{'EM_','RU_','SA_'}do for _,f in ipairs(fixtures)do
 local rows=f[8]
 local region={x=0,y=0,def={id=ed..f[2]}};local g={cx=f[4],cy=f[5],kind='house',width=4,depth=4,pair=f[6],groundHeight=0,custom={family='rse',name=f[1]}};local cells={}
 for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and f[7][x+1]or(y==3 and x==1 and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==f[3] and #parts==3 and #g.importedOldaleDoors.parts==6)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-24)<1e-6 and math.abs(fit.anchors.door[3]-41)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>55 and fit.bounds[6]-fit.bounds[3]>46)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3 end;assert(tris==84)end
 assert(D.ownsDoor(g,g.cx+1,g.cy+3)and not D.ownsDoor(g,g.cx+2,g.cy+3));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedOldaleDoors);missing=false;S.retryImages(D.id);S.retryImages(f[3])
end end
assert(released>0 and caps==6);print('PASS6 own original Oldale home candidates, exact26-triangle underside caps and84-triangle original hinged states, native clearance and atomic rollback')
