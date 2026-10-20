-- Native-mask placement, cached AUX, real upload fallback and Cut lifecycle.
local Assets={register=function()end}
package.loaded['src.render.Assets']=Assets
package.loaded['src.world.Map']={isOutdoor=function()return true end}
local shapes={};local classified={}
local propMode='modeled'
local shapeModule={forMap=function()return shapes end,at=function(_,_,tile)return classified[tile]end}
local sourceV={require=function(name)
 if name=='TileShape'then return shapeModule end
 if name=='BuildBudget'then return{tick=function()end}end
 if name=='TreePresentation'then return{props={get=function()return propMode end}}end
 if name=='SafariReserve'then return{enabled=function(map)return map.authored end}end
 if name=='Gen2Elevation'then return{at=function(_,x,z)return x<8 and 6 or 12 end}end
 return{}
end}
local S=assert(loadfile('lib/Structures.lua'))(sourceV)
classified[0]={art='ground'};classified[1]={art='grass'};classified[2]={art='flower'}
local map={id='MASK',def={width=1,height=1},tileset={id='TEST'}}
function map:tileAt(x,y)
 if x==0 and y==0 or x==1 and y==0 or x==0 and y==1 or x==3 and y==3 then return 1 end
 if x==1 and y==1 then return 2 end
 return 0
end
function map:isGrassCell(x,y)return x==0 and y==0 end
for _,gen2 in ipairs{false,true}do
 shapes.gen2Classes=gen2 and{}or nil
 local p=S.grassPlacements(map);assert(#p==3,'mask scan filled decorative grass or flowers')
 for _,v in ipairs(p)do
  assert(v.extent==8 and v.model=='oras_green'and v.x<16 and v.z<16)
  assert(v.y==.025+(gen2 and(v.x<8 and 6 or 12)or 0),'native local height changed')
 end
 assert(p[1].x==0 and p[1].z==0 and p[2].x==8 and p[3].z==8,'source subtile positions changed')
end
map.authored=true;assert(S.grassPlacements(map)==nil,'authored reserve was replaced');map.authored=nil
propMode='cards';assert(S.grassPlacements(map)==nil,'native grass option retained imported models');propMode='modeled'
local meshes,draws={},{};local failModel=false;local checks,forceYield=0,false
local function mesh(vertices)
 local m={vertices=vertices}
 function m:release()assert(not self.released,'double release');self.released=true end
 function m:setTexture(image)self.texture=image end
 function m:attachAttribute(_,offsets)self.offsets=offsets end
 function m:detachAttribute()self.offsets=nil end
 function m:setVertices(vertices)self.vertices=vertices end
 function m:setVertexMap(indices)self.indices=indices end
 meshes[#meshes+1]=m;return m
end
local texture={setFilter=function()end,setWrap=function()end,release=function(self)self.released=true end}
love={filesystem={newFileData=function()return{release=function()end}end},graphics={
 getSupported=function()return{instancing=true}end,drawInstanced=function()end,
 newMesh=function(_,positions)return mesh(positions)end,newImage=function()return texture end}}
local placements={{model='oras_green',extent=8,rotation=0,x=0,y=.025,z=0},
 {model='oras_green',extent=8,rotation=0,x=8,y=.025,z=0},
 {model='oras_green',extent=8,rotation=0,x=32,y=9.025,z=0}}
local function quad(shade)
 return{{0,0,0},{1,0,0},{1,1,0},{0,1,0},u=0,v=0,shade=shade,canopy={.5,.5,0}}
end
local analyses=0;local imported={}
local modules={BuildBudget={tick=function()end,check=function()
 checks=checks+1;if forceYield and checks%2==0 then coroutine.yield()end
 end,begin=function()end,finish=function()end,cancel=function()end},
 Structures={grassPlacements=function()return placements end,forMap=function()
 analyses=analyses+1;return{grassQuads={quad(.37)},flowerQuads={quad(.91)},figures={}}
 end,invalidate=function()end},TileShape=shapeModule,
 LoadTimings={wrap=function(_,f)return f end,resume=coroutine.resume,jobError=function()error('unexpected async error')end},
 CommunityVisuals={crystalDepth=function()return false end,customRoads=function()return false end},
 CinnabarCoast={enabled=function()return false end},
 Voxel3D={TREE_FORMAT={'native-card-anchors'},newMesh=function(v,i,format)
 if failModel and #v>4 then return nil end
 local m=mesh(v);m.indices=i;m.format=format;return m
 end,pushQuad=function(indices,n)for _,i in ipairs{1,2,3,1,3,4}do indices[#indices+1]=n*4+i end end,
 draw=function(m,image,model,pull)if m then draws[#draws+1]={m,image,model,pull}end end},
 VoxelMeshDisk={available=function()return false end,loadTerrain=function()return{terrain={n=0},water={n=0},registry=''}end}}
local V={mod={read=function()return'original PNG'end}}
function V.require(name)
 if modules[name]then return modules[name]end
 if not imported[name]then
  local f=loadfile('lib/'..name..'.lua');imported[name]=f and f(V)or{}
 end
 return imported[name]
end
local G=V.require('GrassModels')
-- Unrelated scene helpers are deliberately inert; their production code is
-- covered separately. Mesh/cut/batch ownership uses the real shared modules.
for _,n in ipairs{'VoxelVisualObjects','CommunityFlora','CacheTrace'}do modules[n]={}end
local M=assert(loadfile('lib/ChunkMesher.lua'))(V)
M.build=function()return mesh({})end
local a={id='IMPORTED',def={width=1,height=1},tileset={id='TEST'}}
assert(M.get(a));local parts=assert(M.grassModels(a));assert(#parts==1 and parts[1].count==3)
assert(not M.grass(a),'native card duplicated imported geometry')
for _,m in ipairs(meshes)do assert(not(m.vertices[1]and m.vertices[1][6]==.37),'unused native grass buffer uploaded')end
local flower=M.flowers(a);assert(flower and flower.format==modules.Voxel3D.TREE_FORMAT,'flower anchor format lost')
M.drawGrass(a,'atlas','neighbor-matrix',46);assert(draws[1][2]==texture and draws[1][3]=='neighbor-matrix'and draws[1][4]==0,'model grass pulled through camera')
assert(M.dropBlock(a.id,0,0)==2 and parts[1].count==1,'Cut failed to remove source rectangle')
assert(parts[1].positions[1][1]==32 and parts[1].mesh.offsets.vertices[1][2]==9.025,'surviving native elevation changed')
assert(M.dropBlock(a.id,1,0)==1 and parts[1].count==0)
local n=#draws;M.drawGrass(a,'atlas',nil,46);assert(#draws==n,'empty Cut batch drawn or native cards resurrected')
M.evictRuntime(a.id);assert(parts[1].mesh==nil and not texture.released,'scene eviction released shared texture')
failModel=true
local b={id='FALLBACK',def={width=1,height=1},tileset={id='TEST'}}
assert(M.get(b));assert(not M.grassModels(b));local native=assert(M.grass(b))
assert(native.format==modules.Voxel3D.TREE_FORMAT,'fallback lost native card anchor attributes')
M.drawGrass(b,'atlas',nil,7);assert(draws[#draws][1]==native and draws[#draws][4]==7,'fallback ordering changed')
M.invalidate(b.id);assert(native.released);failModel=false
-- A persistent AUX hit carries its existing six-float grass stream. Imported
-- placements must come from the native mask and must not upload that stream.
modules.VoxelMeshDisk.available=function()return true end
modules.VoxelMeshDisk.loadAux=function()return{grass={n=99,chunks={'must not be uploaded'}},flowers={n=0},figures={}}end
local c={id='DISK_HIT',def={width=1,height=1},tileset={id='TEST'}}
local oldAnalyses=analyses;M.request(c,false,nil,true);M.pump()
assert(M.grassModels(c)and analyses==oldAnalyses,'cached AUX rebuilt Structures or lost model placements')
assert(not M.takeJobFailure(c.id));M.invalidate(c.id)
-- FULL and BODY may interleave. Cancelling one pending owner must leave the
-- other's uploads alive, and invalidation must then free the second owner.
local d={id='CANCEL',def={width=1,height=1},tileset={id='TEST'}}
forceYield=true;checks=0;local start=#meshes
M.request(d,false,nil,false);M.pump();local first=#meshes;assert(first>=start+2)
M.request(d,true,nil,true);M.pump();local second=#meshes;assert(second>=first+2)
assert(M.cancelSpeculative(d.id,false))
for i=start+1,first do assert(meshes[i].released,'cancelled FULL leaked uploaded grass')end
for i=first+1,second do assert(not meshes[i].released,'FULL cancellation released pending BODY')end
M.invalidate(d.id)
for i=first+1,second do assert(meshes[i].released,'invalidation leaked pending BODY')end
assert(not texture.released,'per-scene cleanup freed shared imported material')
-- Bank sidecars own their own mesh, and the complete explicit water policy
-- must invalidate them even when ordinary -2 water answers are identical.
forceYield=false
local W=V.require('GBWater');local bankTexture={}
modules.BankMaterials={image=function()return bankTexture end}
local builds=0
W.bankGeometry=function(map)
 builds=builds+1;local h=W.relative(map,-20)
 return{{0,h,0,0,0,1},{8,h,0,1,0,1},{8,0,0,1,1,1},{0,0,0,0,1,1}},{1,2,3,1,3,4}
end
local banks={id='BANK_POLICY',def={width=1,height=1,tileset='OVERWORLD'},tileset={id='TEST'}}
assert(M.get(banks));M.drawBanks(banks,'bank-neighbor')
local oldBank=draws[#draws][1]
assert(draws[#draws][2]==bankTexture and draws[#draws][3]=='bank-neighbor'and builds==1)
M.drawBanks(banks,'bank-neighbor');assert(builds==1,'unchanged bank geometry rebuilt every frame')
banks.def.voxelWater={waterline=-8};M.drawBanks(banks,'bank-neighbor')
local newBank=draws[#draws][1]
assert(oldBank.released and oldBank~=newBank and builds==2,'same ordinary level reused differently authored pool bank')
M.invalidate(banks.id);assert(newBank.released,'bank scene invalidation leaked mesh')
G.release();assert(texture.released)
print('PASS native8px masks/elevation, no flowers, no duplicate/native fallback anchors, cached AUX, immediate Cut, physical depth, neighbor placement, eviction and interleaved FULL/BODY cancellation')
