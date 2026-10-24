local mods={SceneryModelData={},CeladonBlockData=dofile('lib/CeladonBlockData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(mods[n],n)end
mods.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);mods.SceneryModels=S;local H=assert(loadfile('lib/Gen3ImportedCeladonBlocks.lua'))(V)
local rows={celadon_small_block={{749,750,750,758},{736,737,737,740},{744,745,747,748},{752,753,755,756},{760,761,763,764}},celadon_low_roof_block={{729,730,730,774},{736,737,737,740},{744,745,747,748},{752,753,755,756},{760,761,763,764}}}
for family,drawing in pairs(rows)do
 local g={family=family,pair='general__rom_082d4b3c',cx=10,cy=10,width=4,depth=#drawing,groundHeight=0};local cells={}
 for y,row in ipairs(drawing)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,mid=mid,collision=y==1 and 0 or 7,base=y==1 and 16 or 0,pair=g.pair}end end
 assert(H.eligible(g,cells));local c=cells['10:11'];c.mid=0;assert(not H.eligible(g,cells));c.mid=drawing[2][1];c.collision=113;assert(not H.eligible(g,cells));c.collision=7;c.base=1;assert(not H.eligible(g,cells));c.base=0;c.prop={};assert(not H.eligible(g,cells));c.prop=nil
 assert(H.register());assert(not H.build(g,cells,function()error('missing PNG before mesh upload')end,{}));assert(not g.importedCeladonBlock)
 local original=S.buildBatches;S.buildBatches=function(p,_,o)
  assert(p[1].x==160 and p[1].y==0 and p[1].z==176);local geometry,fit=assert(S.vertices(H.id,p[1].fit));assert(fit.bounds[4]-fit.bounds[1]>63,'full-width two-storey source fit')
  local names={};for _,q in ipairs(geometry)do names[q.name]=true;assert(q.role~='source_shading'and q.role~='source_door');for _,v in ipairs(q.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=63.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=(g.depth-1)*16-.25+1e-6 and v[2]>=-.05-1e-6)end end
  for _,n in ipairs{'authored_rear_siding','authored_rear_chamfer_returns','authored_rear_barrel_cut','authored_rear_eave_return','authored_eave_soffit','authored_balcony_undersides','authored_closed_foundation'}do assert(names[n],n)end
  return o.parts
 end
 assert(H.build(g,cells,function()end,{}));assert(g.importedCeladonBlock.model==H.id);S.buildBatches=original
 g.family='celadon_short_block';assert(not H.eligible(g,cells),'one-storey native drawing cannot use a two-storey source');g.family='celadon_vent_block';assert(not H.eligible(g,cells),'no vent omitted from a different native drawing')
end
print('PASS exact Celadon plain-block variants, source balconies/closures, full blocked fit/inset, no invented vent/door and PNG fallback')
