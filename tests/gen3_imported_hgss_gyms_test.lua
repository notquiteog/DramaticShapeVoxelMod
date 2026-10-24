local modules={SceneryModelData={},HGSSKantoGymData=dofile('lib/HGSSKantoGymData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);modules.Gen3ImportedGyms=G
local H=assert(loadfile('lib/Gen3ImportedHGSSGyms.lua'))(V);modules.Gen3ImportedHGSSGyms=H
local D=assert(loadfile('lib/Gen3HGSSGymDoors.lua'))(V);modules.Gen3HGSSGymDoors=D
for _,pair in ipairs{'viridian_outdoor','pewter_outdoor','general__rom_082d4af4','general__rom_082d4b9c','general__rom_082d4b24','general__rom_082d4b54'}do
 local spec=H.selection{pair=pair};local g={pair=pair,kind='gym',width=spec.width,depth=5,cx=12,cy=12,groundHeight=0};local cells={};if spec.nativePlacement then g.cx,g.cy=43,8 elseif spec.location then g.cx,g.cy=spec.location[2],spec.location[3]end
 for y,row in ipairs(spec.rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,pair=pair,mid=mid,collision=y==1 and((spec.headerBlocked or spec.headerLastBlocked and x==spec.width)and 7 or 0)or y==5 and(x>=3 and x<=5 and(x==4 and 113 or 7)or 0)or 7,base=0,region=spec.nativePlacement and{def={id='FR_SAFFRON_CITY'},x=0,y=0}or spec.location and{def={id=spec.location[1]},x=0,y=0}or nil}end end
 assert(H.eligible(g,cells));if spec.location then
  local c=cells[g.cx..':'..g.cy];local id=c.region.def.id;c.region.def.id='THIRD_PARTY_CITY';assert(not H.eligible(g,cells));c.region.def.id=id
  c.region.x=1;assert(not H.eligible(g,cells));c.region.x=0
 end;local c=cells[g.cx..':'..g.cy];c.mid=0;assert(not H.eligible(g,cells));c.mid=spec.rows[1][1]
 c.boundary=true;assert(not H.eligible(g,cells));c.boundary=nil
 local door=cells[(g.cx+3)..':'..(g.cy+4)];door.collision=7;assert(not H.eligible(g,cells));door.collision=113
 if spec.nativePlacement then
  for _,c in pairs(cells)do c.region={def={id='FR_SAFFRON_CITY_CONNECTION'},x=10,y=7}end
  door.collision=7;assert(H.eligible(g,cells),'exact closed connection projection');door.collision=113;assert(not H.eligible(g,cells),'connection has no native warp permission')
  for _,c in pairs(cells)do c.region={def={id='FR_SAFFRON_CITY'},x=0,y=0}end
  assert(H.eligible(g,cells))
 end
 assert(H.register(spec.id))
 local rearFaces=0
 for _,p in ipairs(modules.HGSSKantoGymData[spec.id].parts)do
  if p.texture:match('/kn_gym_a%.png$')then for start=1,#p.indices,3 do
   local rear=true
   for j=0,2 do local v=p.vertices[p.indices[start+j]];rear=rear and v[3]<-.30 and v[2]>.30 and v[2]<.40 end
   if rear then for j=0,2 do local v=p.vertices[p.indices[start+j]];assert(v[4]==25.5/32 and v[5]==.5,'rear tower must continue neutral source paint rather than wrap the facade atlas')end;rearFaces=rearFaces+1 end
  end end
 end
 assert(rearFaces==2,'exact original rear tower quad retained')
 local opts={width=g.width*16,depth=64,padding=.25,anchor='door',targetX=56,targetZ=49}
 local geometry,fit=assert(S.vertices(spec.id,opts));fit.model=spec.id;assert(G.clearance(g,cells,geometry))
 assert(fit.bounds[4]-fit.bounds[1]>75 and math.abs(fit.anchors.door[3]-49)<1e-6)
 opts.targetZ=54;local unsafe=S.vertices(spec.id,opts);assert(not G.clearance(g,cells,unsafe),'walkable front corners must reject a deeper facade')
 for state=0,2 do
  local pieces=assert(D.geometry(g,fit,state));local n=0
  for _,p in ipairs(pieces)do
   n=n+#p.indices/3;local localPart={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do localPart.vertices[#localPart.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end
   assert(G.clearance(g,cells,{localPart}),'source panels leave native mask')
  end
  assert(n==8,'all source door triangles retained')
 end
 assert(not D.geometry(g,fit,3))
 local old=S.image;S.image=function()return nil end;assert(not H.build(g,cells,function()error('image failure must precede mesh upload')end,{}));assert(not g.importedHGSSGym);S.image=old
 local live=0;S.image=function()return {}end;local calls=0
 local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1 end}end
 assert(not D.build(g,fit,function()calls=calls+1;if calls==2 then return nil end;return mesh()end,cells));assert(live==0 and not g.importedHGSSGymDoors,'late door upload must unwind all previous poses')
 assert(D.build(g,fit,mesh,cells));assert(live==3 and D.ownsDoor(g,g.cx+3,g.cy+4));D.release(g);assert(live==0);S.image=old
end
print('PASS regional Gym exact drawings/permissions, full-triangle native mask, safe49/rejected54 facade, bounded paired source doors and missing-image fallback')
