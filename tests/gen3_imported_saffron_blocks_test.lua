local modules={SceneryModelData={},SaffronBlockData=dofile('lib/SaffronBlockData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local H=assert(loadfile('lib/Gen3ImportedSaffronBlocks.lua'))(V)
for _,family in ipairs{'saffron_house','saffron_tall_house'}do
 local spec=H.selection{family=family};local g={cx=19,cy=25,family=family,pair='general__rom_082d4b9c',width=spec.width,depth=spec.depth,groundHeight=3}
 local cells={};for y,row in ipairs(spec.rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,pair=g.pair,civic=g,base=3,collision=y==1 and 0 or 7}end end
 assert(H.eligible(g,cells));local c=cells['19:26']
 if family=='saffron_tall_house'then local c=cells['23:25'];c.collision=7;c.base=16;assert(H.eligible(g,cells),'exact elevated northeast roof-header variant');local west=cells['19:25'];west.collision=7;assert(not H.eligible(g,cells),'unreviewed two-edge header');c.collision=0;assert(H.eligible(g,cells),'exact northwest roof-header variant');west.collision=0;c.collision=113;assert(not H.eligible(g,cells));c.collision=0;c.base=3 end
 for _,k in ipairs{'boundary','stageHidden','prop'}do c[k]=true;assert(not H.eligible(g,cells),k);c[k]=nil end
 for k,v in pairs{mid=0,collision=0,base=4,pair='viridian_outdoor',civic=false}do local old=c[k];c[k]=v;assert(not H.eligible(g,cells),k);c[k]=old end
 local body=cells['19:26'];body.collision=113;assert(not H.eligible(g,cells),'never claim an enterable variant');body.collision=7
 assert(H.register(spec.id));assert(not H.build(g,cells,function()error('missing PNG must prevent upload')end,{}));assert(not g.importedSaffronBlock)
 local old=S.buildBatches
 S.buildBatches=function(placements,_,opts)
  local p=assert(placements[1]);assert(p.x==304 and p.y==3 and p.z==416)
  local parts,fit=assert(S.vertices(p.model,p.fit));assert(fit.bounds[4]-fit.bounds[1]>g.width*16-1,'source must substantially fill original width')
  local rear,soffit,base=false,false,false
  for _,part in ipairs(parts)do
   assert(part.role~='source_shading'and part.role~='ground_shadow'and part.role~='source_door')
   rear=rear or part.name=='authored_rear_wall';soffit=soffit or part.name=='authored_roof_soffit';base=base or part.name=='authored_closed_foundation'
   for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=g.width*16-.25+1e-6 and v[3]>=.25-1e-6 and v[3]<=(g.depth-1)*16-.25+1e-6 and v[2]>=-.05-1e-6)end
  end
  assert(rear and soffit and base);return opts.parts
 end
 assert(H.build(g,cells,function()end,{}));assert(g.importedSaffronBlock.model==spec.id);assert(c.civic==g and body.collision==7)
 S.buildBatches=old
end
assert(not H.selection{family='saffron_low_house'},'do not substitute a two-storey source for the one-storey family')
print('PASS exact nonenterable Saffron two/three-storey source guards, full-width blocked fit, original fixtures, closed/unbaked geometry and unavailable-image fallback')
