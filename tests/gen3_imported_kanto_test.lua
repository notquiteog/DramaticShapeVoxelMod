local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),PalletBuildingData=dofile('lib/PalletBuildingData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local K=assert(loadfile('lib/Gen3ImportedKanto.lua'))(V)
local cells={}
for _,r in ipairs(K.recipes)do for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
 local cx,cy=r.sourceX+x-1,r.sourceY+y-1
 cells[cx..':'..cy]={cx=cx,cy=cy,mid=mid,pair='pallet_outdoor',secondary='pallet_town',collision=y==1 and 0 or(y==5 and x==r.doorX+1 and 0x71 or 7),base=4}
end end end
local regions={{x=0,y=0,w=24,h=20,def={id='FR_PALLET_TOWN'}}}
local groups=K.prepare(cells,regions);assert(#groups==3);assert(#K.prepare(cells)==0)
for _,c in pairs(cells)do assert(not c.civic,'discovery claimed a native cell')end
local original=S.buildBatches
for _,g in ipairs(groups)do
 assert(K.eligible(g,cells));local r=g.kantoRecipe;local key=g.cx..':'..g.cy;local c=cells[key]
 c.collision=7;assert(not K.eligible(g,cells));c.collision=0
 c.base=5;assert(not K.eligible(g,cells));c.base=4
 c.boundary='forest';assert(not K.eligible(g,cells));c.boundary=nil
 c.mid=1;assert(not K.eligible(g,cells));c.mid=r.rows[1][1]
 g.stageHidden=true;assert(not K.eligible(g,cells));g.stageHidden=nil
 assert(not K.build(g,cells,function()error('must not reach GPU with missing PNG')end,{}));assert(not g.importedKanto and not c.civic)
 S.buildBatches=function(placements,_,opts)
  local p=assert(placements[1]);local parts,fit=assert(S.vertices(p.model,p.fit));assert(p.y==4 and fit.groundInset==.05,'building datum moved instead of source contact ring')
  assert(math.abs(fit.anchors.door[1]-(r.doorX*16+8))<1e-6)
  local shade,door,closure=false,false,false
  for i,part in ipairs(parts)do
   shade=shade or(part.lightingOnly and part.role=='source_shading')
   door=door or part.role=='source_door';closure=closure or part.name:find('authored_closed_underside')
   for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=g.width*16-.25+1e-6 and v[3]>=.25-1e-6 and v[3]<=63.75+1e-6 and v[2]>=-.05)end
   local source=modules.PalletBuildingData[r.model].parts[i]
   local flat=source.role=='source_shading';for _,v in ipairs(source.vertices)do if math.abs(v[2])>1e-8 then flat=false end end
   for j,v in ipairs(part.vertices)do
    local raw=source.vertices[j];assert(v[4]==raw[4]and v[5]==raw[5]and v[6]==1,'source UV changed or baked shade retained')
    assert(math.abs(v[2]-(math.abs(raw[2])<1e-7 and -.05 or raw[2]*fit.scale))<1e-8,'upper geometry changed or contact ring remained coplanar')
    if flat then assert(part.lightingOnly and raw[2]==0,'lighting overlay not excluded or original source mutated')end
    if part.name=='authored_closed_underside'and raw[2]==0 then assert(v[2]+p.y<4,'closure cap still fights native ground')end
   end
  end
  assert(shade and door and closure,'source alpha/door/foundation dropped')
  return opts.parts
 end
 assert(K.build(g,cells,function()end,{}));assert(c.civic==g and g.importedKanto)
 local d=assert(K.doorSurface(g,g.cx+r.doorX,g.cy+4));assert(d.base==4 and d.base==g.importedKantoY and g.groundHeight==4 and d.w==14 and d.h==16)
 assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-(g.cx+r.doorX)*16-8)<1e-6)
 assert(d.vertices[1][2]>d.vertices[4][2]);assert(not K.doorSurface(g,g.cx+r.doorX+1,g.cy+4))
 S.buildBatches=original
end
-- Exact native source signatures also work through connected-map translations.
local translated={};for key,c in pairs(cells)do local q={};for k,v in pairs(c)do if k~='civic'then q[k]=v end end;q.cx,q.cy=q.cx+50,q.cy-30;translated[q.cx..':'..q.cy]=q end
assert(#K.prepare(translated,{{x=50,y=-30,w=24,h=20,def={id='FR_PALLET_TOWN'}}})==3)
assert(#K.prepare(translated,{{x=50,y=-30,w=24,h=20,def={id='HOENN_COPY'}}})==0)
-- Oak's tall vertical shade is source lighting too; retain its provenance only.
local vertical=false
for _,p in ipairs(modules.PalletBuildingData.hgss_pallet_oak.parts)do if p.role=='source_shading' then
 local low,high=math.huge,-math.huge;for _,v in ipairs(p.vertices)do low=math.min(low,v[2]);high=math.max(high,v[2])end;vertical=high-low>.1
end end
assert(vertical)
print('PASS Pallet exact drawing/collision/base guards, source alpha/door preservation, connected mapping, bounded placement, native fallback and portal alignment')
