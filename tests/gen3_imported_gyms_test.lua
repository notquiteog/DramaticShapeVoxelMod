local definitions=dofile('data/gen3_hoenn_exteriors.lua')
local modules={SceneryModelData={},ImportedTreeData={},ImportedHoennGymData=dofile('lib/ImportedHoennGymData.lua'),ImportedHoennGymDoorData=dofile('lib/ImportedHoennGymDoorData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local D=assert(loadfile('lib/Gen3GymDoors.lua'))(V);modules.Gen3GymDoors=D
local function mesh()return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local recipes={};for _,r in ipairs(definitions)do recipes[r.name]=r end
local count=0
for _,edition in ipairs{'RU_','SA_','EM_'}do for _,f in ipairs{{'petalburg_city_gym','PETALBURG_CITY',12,4,'general__petalburg',{7,7,7,7,7,7}},{'dewford_town_gym','DEWFORD_TOWN',5,13,'general__dewford',{0,0,0,0,0,0}},{'rustboro_city_gym','RUSTBORO_CITY',24,15,'general__rustboro',{7,0,0,0,0,0}}}do
 local recipe=assert(recipes[f[1]]);local custom={family='rse',name=recipe.name,rows=recipe.rows};local g={cx=f[3],cy=f[4],pair=f[5],width=6,depth=5,kind='gym',groundHeight=2,custom=custom};local region={x=0,y=0,def={id=edition..f[2]}};local cells={}
 for y=0,4 do for x=0,5 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,cx=g.cx+x,cy=g.cy+y,mid=recipe.rows[y+1][x+1],pair=g.pair,region=region,base=2,collision=y==0 and f[6][x+1]or(y==4 and({0,0,7,113,7,0})[x+1]or 7)}end end
 assert(G.eligible(g,cells));local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not G.eligible(g,cells));c.collision=7
 local parts={};assert(G.build(g,cells,mesh,parts));assert(g.importedHoenn.model==G.id and #parts==6 and #g.importedGymDoors.parts==9)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-56)<1e-6 and math.abs(fit.anchors.door[3]-54)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>79 and fit.bounds[6]-fit.bounds[3]>56)
 assert(D.ownsDoor(g,g.cx+3,g.cy+4)and not D.ownsDoor(g,g.cx+2,g.cy+4))
 for state=0,2 do local rows=assert(D.geometry(g,fit,state));local tris=0;for _,p in ipairs(rows)do tris=tris+#p.indices/3;for _,v in ipairs(p.vertices)do assert(v[6]==1 and v[1]>g.cx*16 and v[1]<(g.cx+6)*16)end end;assert(tris==60);local draws=0;assert(D.draw(g,{x=g.cx+3,y=g.cy+4,frame=state},function()draws=draws+1 end));assert(draws==3)end
 assert(D.state(g,{x=g.cx,y=g.cy,frame=2})==0)
 D.release(g);S.releaseBatches(parts);assert(not g.importedGymDoors)
 -- A rejected per-cell source/owner must keep the native fallback.
 c.mid=0;assert(not G.build(g,cells,mesh,{}));c.mid=recipe.rows[2][1]
 -- Missing source PNG rolls back all door states before claiming the building.
 S.release();missing=true;g.importedHoenn=nil;assert(not G.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedGymDoors);missing=false;S.retryImages(D.id);S.retryImages(G.id)
 count=count+1
end end
-- A source triangle with blocked endpoints can still cross a walking cell.
local g={cx=0,cy=0};local cells={['0:1']={civic=g,collision=7},['2:1']={civic=g,collision=7},['0:3']={civic=g,collision=7}}
assert(not G.clearance(g,cells,{{vertices={{1,0,1},{47,0,1},{1,0,47}},indices={1,2,3}}}),'triangle crossed walking cells')
local data=modules.ImportedHoennGymData;assert(#data.oras_hoenn_gym.parts==6 and #data.oras_hoenn_gym_notice.parts==2)
local sourceTris=0;for _,p in ipairs(data.oras_hoenn_gym.parts)do sourceTris=sourceTris+#p.indices/3 end;assert(sourceTris==1056)
assert(released>0);print('PASS '..count..' guarded source Gym candidates, original hinged states, exact warp anchor, full triangle walk clearance, source closures and atomic missing-texture rollback')
