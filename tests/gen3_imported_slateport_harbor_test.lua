local modules={SceneryModelData={},ImportedTreeData={},ImportedSlateportHarborData=dofile('lib/ImportedSlateportHarborData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedSlateportHarbor.lua'))(V);modules.Gen3ImportedSlateportHarbor=M
local D=assert(loadfile('lib/Gen3HarborDoors.lua'))(V);modules.Gen3HarborDoors=D
local function mesh(vertices,indices)if vertices and #vertices==30 and #indices==30 then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
for _,ed in ipairs{'EM_','RU_','SA_'}do
 local region={x=0,y=0,def={id=ed..'SLATEPORT_CITY'}};local g={cx=25,cy=7,kind='harbor',width=7,depth=6,pair='general__slateport',groundHeight=0,custom={family='rse',name='slateport_harbor',geometry=ed=='RU_'and'landmark'or'harbor'}};local cells={}
 for y=0,5 do for x=0,6 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=M.rows[y+1][x+1],collision=y==5 and x==3 and 113 or 7}end end
 assert(M.eligible(g,cells));local parts={};local ok,why=M.build(g,cells,mesh,parts);assert(ok,why);assert(#parts==5 and #g.importedHarborDoors.parts==12);local fit=g.importedHoenn;assert(fit.model==M.id and fit.anchors.door[1]==56 and fit.anchors.door[3]==74.25)
 for state=0,2 do local tris,contacts=0,0;local data=modules.ImportedSlateportHarborData.door
  for i,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3
   for j,v in ipairs(p.vertices)do local raw=data.poses[state+1][i][j];local bind=data.poses[1][i][j];local dx=v[1]-(g.cx*16+raw[1]*fit.scale+fit.x);local dz=v[3]-((g.cy+1)*16+raw[3]*fit.scale+fit.z)
    if math.abs(bind[1]-data.meetingPlane)<1e-6 then contacts=contacts+1;assert(math.abs(math.sqrt(dx*dx+dz*dz)-.05)<1e-8)else assert(math.abs(dx)+math.abs(dz)<1e-8,'non-contact source pose moved')end
    assert(v[2]==raw[2]*fit.scale and v[4]==raw[4]and v[5]==raw[5],'source entrance height or paint changed')
   end
  end;assert(tris==68 and contacts>0)
 end
 assert(D.ownsDoor(g,28,12)and not D.ownsDoor(g,29,12)and not D.ownsDoor(g,40,7));assert(D.state(g,{x=28,y=12,frame=2})==2 and D.state(g,{x=27,y=12,frame=2})==2 and D.state(g,nil)==2)
 D.release(g);S.releaseBatches(parts);g.importedHoenn=nil
 local c=cells['25:8'];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7;c.mid=0;assert(not M.eligible(g,cells));c.mid=M.rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedHarborDoors);missing=false;S.retryImages(D.id);S.retryImages(M.id)
end
assert(released>0 and caps==3);print('PASS3 exact Harbor candidates,68-triangle paired original slider states, closed original side/rear profiles, triangle clearance and atomic missing-source rollback')
