local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end},ImportedHoennShopData=dofile('lib/ImportedHoennShopData.lua'),ImportedHoennFlowerData=dofile('lib/ImportedHoennFlowerData.lua')}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local C=assert(loadfile('lib/Gen3ImportedFlowerCards.lua'))(V);modules.Gen3ImportedFlowerCards=C
local F=assert(loadfile('lib/Gen3ImportedFlowers.lua'))(V);modules.Gen3ImportedFlowers=F
local H=assert(loadfile('lib/Gen3ImportedHoenn.lua'))(V)
assert(F.style()=='hd2d','missing style module changed the flower default')
local preference='hd2d';modules.VisualStyles={get=function(category)assert(category=='flowers');return preference end}
for _,mode in ipairs{'modern','voxel','hd2d'}do preference=mode;assert(F.style()==mode)end
preference='unknown';assert(F.style()=='hd2d');modules.VisualStyles.get=function()error('unavailable')end;assert(F.style()=='hd2d')
modules.VisualStyles.get=function()return preference end
local r=H.recipes[2];local g={cx=3,cy=15,width=6,depth=4,kind='house',pair=r.pair,custom=r,groundHeight=6}
assert(H.register(H.shopId));local fit=assert(S.fit(H.shopId,{width=96,depth=48,padding=.25,anchor='door',targetX=40,targetZ=39.8}))
local original,allIndices,allCount=C.geometry(g,fit);assert(allCount==19 and #allIndices==624)
local png={};S.image=function(id,texture)assert(id==H.shopId and texture=='assets/scenery/oras-route104-shop/r104_dif03.png');return png end
local freed,uploads=0,0
local function mesh()return{release=function()freed=freed+1 end,setTexture=function(_,image)assert(image==png)end}end
local calls={}
local function upload(v,i,format)uploads=uploads+1;calls[#calls+1]={vertices=v,indices=i,format=format};return mesh()end
local parts={};preference='hd2d';local ok,err,info=F.build(g,fit,H.shopId,upload,parts)
assert(ok and not err and info.style=='hd2d'and #parts==1 and parts[1].count==19 and parts[1].role=='hd2d_flower_cards')
for i,v in ipairs(calls[1].vertices)do for k,n in ipairs(v)do assert(n==original[i][k],'default HD2D geometry changed')end end
parts={};calls={};preference='modern';ok,err,info=F.build(g,fit,H.shopId,upload,parts)
assert(ok and not err and info.style=='modern'and info.modernFlowers==3 and info.hd2dComponents==16 and #parts==2)
assert(parts[1].role=='source_flower_faces'and parts[1].count==3 and parts[2].count==16)
assert(calls[1].format==S.COLOR_FORMAT and #calls[1].indices==72 and #calls[2].indices==552,'duplicate or missing floral triangles')
local source=modules.ImportedHoennFlowerData[F.id];local at=0
for _,component in ipairs(source.components)do
 assert(component.identity=='pink_flower_yellow_center'and source.excludedHd2dCards[component.sourceComponent])
 for j,v in ipairs(component.vertices)do at=at+1;local q=calls[1].vertices[at]
  assert(#q==10 and math.abs(q[1]-(g.cx*16+v[1]*fit.scale+fit.x))<1e-8 and math.abs(q[2]-(6+v[2]*fit.scale))<1e-8 and math.abs(q[3]-((g.cy+1)*16+v[3]*fit.scale+fit.z))<1e-8,'authored flower geometry changed')
  assert(q[4]==v[4]and q[5]==v[5]and q[6]==v[6]);for k=1,4 do assert(q[6+k]==component.colors[j][k],'source flower RGBA changed')end
  local x,y=math.floor(q[1]/16)-g.cx,math.floor(q[3]/16)-g.cy
  assert(r.permissions[y+1][x+1]==7,'source blossom enters native walking/warp tile')
 end
end
local prior={mesh={release=function()error('released preexisting scene object')end}}
-- A modern upload failure atomically restores every HD2D component.
parts={prior};local attempts=0;local before=freed
ok,err,info=F.build(g,fit,H.shopId,function(v,i,format)attempts=attempts+1;if attempts==2 then error('HD2D remainder upload failed')end;return upload(v,i,format)end,parts)
assert(ok and not err and info.style=='hd2d'and info.fallbackReason:find('remainder upload failed',1,true)and #parts==2 and parts[1]==prior and parts[2].count==19 and freed==before+1)
-- Missing modern data retains HD2D. Unsupported native-voxel families fail
-- so the Hoenn caller restores its complete native-art Civic building.
local d=modules.ImportedHoennFlowerData;modules.ImportedHoennFlowerData=nil;parts={}
assert(F.build(g,fit,H.shopId,upload,parts)and #parts==1 and parts[1].count==19);modules.ImportedHoennFlowerData=d
parts={};preference='voxel';ok,err,info=F.build(g,fit,H.shopId,upload,parts);assert(not ok and err:find('native source unavailable',1,true)and #parts==0)
parts={prior};before=freed
ok,err,info=F.build(g,fit,H.shopId,upload,parts,{nativeVoxelBuild=function(_,_,_,_,out)out[#out+1]={mesh=mesh()};return false,'native sprite unavailable'end})
assert(not ok and err:find('native source unavailable',1,true)and #parts==1 and parts[1]==prior and freed==before+1)
parts={};ok,err,info=F.build(g,fit,H.shopId,upload,parts,{nativeVoxelBuild=function(_,_,_,_,out)out[#out+1]={mesh=mesh(),count=3,role='native_flower_voxels'};return true end})
assert(ok and info.style=='voxel'and #parts==1)
local bad={};for k,v in pairs(fit)do bad[k]=v end;bad.x=bad.x+200;assert(not F.geometry(g,bad),'walking overlap accepted')
local cells={};for y=0,3 do for x=0,5 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,pair=r.pair,mid=r.rows[y+1][x+1],collision=r.permissions[y+1][x+1],base=6}end end
local nativeBefore={};for k,c in pairs(cells)do nativeBefore[k]={c.mid,c.collision}end
S.buildBatches=function(_,_,options)options.parts[#options.parts+1]={mesh=mesh()};return options.parts end
parts={prior};before=freed;preference='voxel'
local built,why=H.build(g,cells,upload,parts)
assert(not built and why:find('native source unavailable',1,true)and #parts==1 and parts[1]==prior and freed==before+1 and not g.importedHoenn,'unsupported voxel flowers failed to restore native building fallback')
for k,c in pairs(cells)do assert(c.mid==nativeBefore[k][1]and c.collision==nativeBefore[k][2],'native map changed')end
g.custom={name='other',family='rse'};assert(not F.build(g,fit,H.shopId,upload,{}),'unrelated flower family substituted')
print('PASS HD2D default, original pink source flower identity/XYZ/UV/RGBA, planter+walking bounds, complete mixed coverage and atomic modern/native-voxel provider fallback')
