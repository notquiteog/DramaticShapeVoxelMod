local modules={SceneryModelData={},ImportedTreeData={},ImportedSlateportMartData=dofile('lib/ImportedSlateportMartData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedSlateportMart.lua'))(V);modules.Gen3ImportedSlateportMart=M
local D=assert(loadfile('lib/Gen3SlateportMartDoors.lua'))(V);modules.Gen3SlateportMartDoors=D
local function mesh(vertices,indices)if vertices then for _,v in ipairs(vertices)do assert(math.abs(v[2])>.0001,'Mart source contact remains on native ground plane')end end;if vertices and #vertices==36 and #indices==36 then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local rows={{0x28,0x29,0x29,0x2b},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}
local fixtures={{'slateport_city_mart','SLATEPORT_CITY','oras_slateport_mart',12,23,'general__slateport',{0,0,0,0},rows}}
for _,ed in ipairs{'EM_','RU_','SA_'}do for _,f in ipairs(fixtures)do
 local rows=f[8]
 local region={x=0,y=0,def={id=ed..f[2]}};local g={cx=f[4],cy=f[5],kind='mart',width=4,depth=4,pair=f[6],groundHeight=0,custom={family='rse',name=f[1]}};local cells={}
 for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and f[7][x+1]or(y==3 and x==1 and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==f[3] and #parts==3 and #g.importedMartDoors.parts==6)
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-24)<1e-6 and math.abs(fit.anchors.door[3]-41)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>51 and fit.bounds[6]-fit.bounds[3]>46)
 for state=0,2 do local tris,contacts=0,0;local data=modules.ImportedSlateportMartData.door
  for i,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3
   for j,v in ipairs(p.vertices)do local raw=data.poses[state+1][i][j];local bind=data.poses[1][i][j];local inset=0
    if math.abs(bind[1]-data.jambs[1])<1e-6 then inset=.05 elseif math.abs(bind[1]-data.jambs[2])<1e-6 then inset=-.05 end
    if inset~=0 then contacts=contacts+1 end
    assert(math.abs(v[1]-(g.cx*16+raw[1]*fit.scale+fit.x)-inset)<1e-8,'source slider jamb contact remains coplanar or travel changed')
    assert(v[3]==(g.cy+1)*16+raw[3]*fit.scale+fit.z and v[4]==raw[4]and v[5]==raw[5],'door anchor or source paint changed')
   end
  end;assert(tris==43 and contacts>0)
 end
 assert(D.ownsDoor(g,g.cx+1,g.cy+3)and not D.ownsDoor(g,g.cx+2,g.cy+3));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedMartDoors);missing=false;S.retryImages(D.id);S.retryImages(f[3])
end end
assert(released>0 and caps==3);print('PASS3 guarded own Slateport Mart candidates,703 physical source faces+12 exact underside faces,43-triangle original sliding states, native clearance and atomic rollback')
