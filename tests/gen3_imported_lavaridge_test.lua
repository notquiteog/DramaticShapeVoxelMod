local data=dofile('lib/ImportedLavaridgeData.lua')
local modules={SceneryModelData={},ImportedLavaridgeData=data,ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local L=assert(loadfile('lib/Gen3ImportedLavaridge.lua'))(V);modules.Gen3ImportedLavaridge=L
local H=assert(loadfile('lib/Gen3ImportedHoenn.lua'))(V)
local recipe;for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do if r.name=='lavaridge_town_home'then recipe=r end end
recipe.family='rse';local build=S.buildBatches;local last
for _,ed in ipairs{'RU','SA','EM'}do for _,west in ipairs{true,false}do
 local id=west and L.ids.herb or L.ids.home;local source=data[west and'oras_lavaridge_herb_shop'or'oras_lavaridge_home']
 local original=source.parts[1].vertices[1][3];assert(L.register(id));assert(source.parts[1].vertices[1][3]==original,'source data mutated')
 local region={x=0,y=0,def={id=ed..'_LAVARIDGE_TOWN'}}
 local g={custom=recipe,pair=recipe.pair,cx=west and 11 or 15,cy=12,width=4,depth=4,kind='house'}
 local cells={};for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,region=region,pair=g.pair,mid=recipe.rows[y+1][x+1],base=0,collision=y==0 and 0 or(y==3 and x==1 and 113 or 7)}end end
 assert(L.modelFor(g,cells)==id and L.eligible(g,cells)and H.eligible(g,cells))
 local c=cells[(g.cx+3)..':'..(g.cy+2)]
 for _,field in ipairs{'mid','collision','region','pair','civic'}do local old=c[field];c[field]=nil;assert(not L.eligible(g,cells),field);c[field]=old end
 c.base=1;assert(not L.eligible(g,cells));c.base=0;c.boundary=true;assert(not L.eligible(g,cells));c.boundary=nil
 local map=region.def.id;region.def.id=ed..'_PETALBURG_CITY';assert(not L.eligible(g,cells),'unrelated city substituted');region.def.id=map
 local before={};assert(not H.build(g,cells,function()error('unexpected upload')end,before));assert(#before==0 and not g.importedHoenn)
 S.buildBatches=function(placements,_,opts)
  local p=placements[1];assert(p.model==id and p.x==g.cx*16 and p.z==(g.cy+1)*16)
  local parts,fit=assert(S.vertices(id,p.fit));last=fit
  assert(fit.bounds[4]-fit.bounds[1]>52 and fit.bounds[4]-fit.bounds[1]<53)
  assert(fit.bounds[6]-fit.bounds[3]>47 and fit.bounds[6]-fit.bounds[3]<=47.5+1e-6)
  for i,part in ipairs(parts)do for j,v in ipairs(part.vertices)do
   local old=source.parts[i].vertices[j]
   assert(v[1]>=.25-1e-6 and v[1]<=63.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6,'walkable cell overlap')
   assert(math.abs((v[1]-fit.x)/fit.scale-old[1])<1e-6 and math.abs(v[2]/fit.scale-old[2])<1e-6)
   assert(math.abs((v[3]-fit.z)/fit.scale-L.depthShift(old[3],source.nativeDepthBays))<1e-6)
   assert(v[4]==old[4]and v[5]==old[5]and v[6]==old[6]);assert(v[7]==1 and v[8]==1 and v[9]==1 and v[10]==source.parts[i].colors[j][4])
  end end
  local b=source.nativeDepthBays
  -- Source side glass/bars fit between the two edited bays, so every
  -- vertex of that entire window assembly receives the same translation.
  for _,part in ipairs(source.parts)do for _,v in ipairs(part.vertices)do
   if v[3]>b[1].finish and v[3]<b[2].start then assert(math.abs(L.depthShift(v[3],b)-v[3]-b[2].shorten)<1e-8)end
   if v[3]>=b[2].finish then assert(L.depthShift(v[3],b)==v[3],'front facade/portal/vent moved')end
   if v[3]<=b[1].start then assert(math.abs(L.depthShift(v[3],b)-v[3]-b[1].shorten-b[2].shorten)<1e-8)end
  end end
  return opts.parts
 end
 assert(H.build(g,cells,function()end,{}));local door=assert(H.doorSurface(g,g.cx+1,g.cy+3));assert(not H.doorSurface(g,g.cx+2,g.cy+3))
 assert(math.abs((door.vertices[1][1]+door.vertices[2][1])/2-((g.cx+1)*16+8))<1e-6)
 -- Connected-map coordinates select the same local building, even when
 -- its scene placement is translated. A random same-art map is rejected.
 local translated={};for key,c in pairs(cells)do local x,y=key:match('([^:]+):([^:]+)');translated[(tonumber(x)-30)..':'..(tonumber(y)+40)]=c end
 g.cx=g.cx-30;g.cy=g.cy+40;region.x=-30;region.y=40
 assert(L.modelFor(g,translated)==id and L.eligible(g,translated))
 region.def.id='CUSTOM_LAVARIDGE';assert(not L.eligible(g,translated));region.def.id=map
 S.buildBatches=build
end end
print(('PASS six edition/variant placements, original region-local identities, connected-map offsets, untouched UV/alpha/rigid fixtures and fitted%.4fx%.4f inside64x48; missing-resource fallback'):format(last.bounds[4]-last.bounds[1],last.bounds[6]-last.bounds[3]))
