local modules={SceneryModelData={},ImportedTreeData={},ImportedRustboroHomesData=dofile('lib/ImportedRustboroHomesData.lua'),ModelInstances={new=function()return{release=function()end}end},BuildBudget={check=function()end}}
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local missing=false;local released=0;local caps=0
local V={mod={read=function()if not missing then return png end end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local M=assert(loadfile('lib/Gen3ImportedRustboroHomes.lua'))(V);modules.Gen3ImportedRustboroHomes=M
local D=assert(loadfile('lib/Gen3RustboroDoors.lua'))(V);modules.Gen3RustboroDoors=D
for _,case in ipairs{{'oras_rustboro_school',4},{'oras_rustboro_flat1',36}}do
 local model=modules.ImportedRustboroHomesData[case[1]];local clipped=0
 for _,part in ipairs(model.parts)do if part.name=='kanazumi_komono'then
  for i=1,#part.indices,3 do local rows={};for j=0,2 do rows[#rows+1]=part.vertices[part.indices[i+j]]end;local a=rows[1]
   local target=math.abs(math.abs(a[1]*131)-37.5)<1e-5
   if case[2]==36 then target=false;for _,x in ipairs{-73,-64.5,-46,-37.5,37.5,46,64.5,73}do if math.abs(a[1]*131-x)<1e-5 then target=true end end end
   for _,v in ipairs(rows)do if math.abs(v[1]-a[1])>1e-7 or v[3]*131>7+1e-5 or v[3]*131<6.5-1e-5 then target=false end end
   if target then clipped=clipped+1 end
  end
 end end
 assert(clipped==case[2],'source window return overlaps original column side')
end
local function mesh(vertices,indices)if vertices and (#vertices==20 and #indices==54)or(vertices and #vertices==16 and #indices==42)or(vertices and #vertices==22 and #indices==60) then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8)end;caps=caps+1 end;return{setTexture=function()end,release=function()released=released+1 end}end
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local o=mesh();o.getDimensions=function()return 8,8 end;o.setFilter=function()end;o.setWrap=function()end;return o end}}
local tan={{0x220,0x221,0x221,0x222,0x223},{0x228,0x229,0x229,0x22a,0x22b},{0x230,0x231,0x231,0x231,0x233},{0x238,0x23a,0x227,0x23a,0x23b},{0x240,0x241,0x22f,0x241,0x243}}
local white={{0x224,0x225,0x225,0x225,0x226},{0x236,0x23e,0x23e,0x23e,0x237},{0x22c,0x22d,0x22d,0x22d,0x22e},{0x214,0x242,0x217,0x242,0x216},{0x21c,0x21d,0x21f,0x21d,0x21e}}
local school={{0x220,0x221,0x221,0x221,0x221,0x222,0x223},{0x228,0x229,0x229,0x229,0x229,0x22a,0x22b},{0x230,0x231,0x231,0x231,0x231,0x231,0x233},{0x238,0x23a,0x23a,0x227,0x23a,0x23a,0x23b},{0x240,0x241,0x241,0x22f,0x241,0x241,0x243}}
local flat={{0x220,0x221,0x221,0x221,0x221,0x221,0x221,0x222,0x223},{0x228,0x229,0x229,0x229,0x229,0x229,0x229,0x22a,0x22b},{0x230,0x231,0x231,0x231,0x231,0x231,0x231,0x231,0x233},{0x238,0x23a,0x239,0x23a,0x239,0x23a,0x239,0x23a,0x23b},{0x238,0x23a,0x239,0x239,0x227,0x239,0x239,0x23a,0x23b},{0x240,0x241,0x241,0x241,0x22f,0x241,0x241,0x241,0x243}}
local south={{0x220,0x221,0x221,0x221,0x221,0x23f},{0x228,0x229,0x229,0x229,0x229,0x247},{0x230,0x231,0x231,0x231,0x231,0x233},{0x238,0x23a,0x227,0x23a,0x23a,0x23b},{0x240,0x241,0x22f,0x241,0x241,0x243}}
local fixtures={{'rustboro_small_tan','RUSTBORO_CITY','oras_rustboro_cutters',7,34,'general__rustboro',{0,0,0,0,0},tan,5,2,4},{'rustboro_white_small','RUSTBORO_CITY','oras_rustboro_house1',31,15,'general__rustboro',{0,0,0,0,0},white,5,2,4},{'rustboro_white_small','RUSTBORO_CITY','oras_rustboro_house2',28,24,'general__rustboro',{0,0,0,0,0},white,5,2,4},{'rustboro_east_tan','RUSTBORO_CITY','oras_rustboro_school',24,30,'general__rustboro',{7,0,0,0,0,0,0},school,7,3,5},{'rustboro_wide_tan','RUSTBORO_CITY','oras_rustboro_flat1',9,25,'general__rustboro',{0,0,0,0,0,0,0,0,0},flat,9,4,5,6},{'rustboro_south_tan','RUSTBORO_CITY','oras_rustboro_house3',24,42,'general__rustboro',{0,0,0,0,0,0},south,6,2,4,5}}
for _,ed in ipairs{'EM_','RU_','SA_'}do for _,f in ipairs(fixtures)do
 local rows=f[8]
 local region={x=0,y=0,def={id=ed..f[2]}};local g={cx=f[4],cy=f[5],kind='urban_house',width=f[9],depth=f[12]or 5,pair=f[6],groundHeight=0,custom={family='rse',name=f[1]}};local cells={}
 for y=0,g.depth-1 do for x=0,g.width-1 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,base=0,mid=rows[y+1][x+1],collision=y==0 and f[7][x+1]or(y==g.depth-1 and x==f[10] and 113 or 7)}end end
 assert(M.eligible(g,cells));local parts={};local ok,err=M.build(g,cells,mesh,parts);assert(ok,err);assert(g.importedHoenn.model==f[3] and #parts==f[11]+1 and #g.importedRustboroDoors.parts==6)
 local blend=0;for _,part in ipairs(parts)do if part.opacity<1 then assert(part.opacity==.6 and part.alphaMode=='blend');blend=blend+1 end end;assert(blend==(f[11]==5 and 1 or 0))
 local fit=g.importedHoenn;assert(math.abs(fit.anchors.door[1]-(f[10]*16+8))<1e-6 and math.abs(fit.anchors.door[3]-((g.depth-1)*16-10))<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>70 and fit.bounds[6]-fit.bounds[3]>61)
 for state=0,2 do local tris=0;for _,p in ipairs(assert(D.geometry(g,fit,state)))do tris=tris+#p.indices/3;for _,v in ipairs(p.vertices)do assert(v[2]<fit.anchors.doorTop[2]-.0499,'original door top overlaps lintel')end end;assert(tris==150)end
 assert(D.ownsDoor(g,g.cx+f[10],g.cy+g.depth-1)and not D.ownsDoor(g,g.cx+f[10]+1,g.cy+g.depth-1));D.release(g);S.releaseBatches(parts)
 g.importedHoenn=nil;local c=cells[g.cx..':'..(g.cy+1)];c.collision=0;assert(not M.build(g,cells,mesh,{}));c.collision=7
 c.mid=0;assert(not M.eligible(g,cells));c.mid=rows[2][1]
 S.release();missing=true;assert(not M.build(g,cells,mesh,{}));assert(not g.importedHoenn and not g.importedRustboroDoors);missing=false;S.retryImages(D.id);S.retryImages(f[3])
end end
assert(released>0 and caps==18);print('PASS18 own Rustboro home/school candidates, exact blocked-footprint source closures and150-triangle original hinged states, native clearance and atomic rollback')
