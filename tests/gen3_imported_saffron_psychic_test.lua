local modules={SceneryModelData={},SaffronPsychicData=dofile('lib/SaffronPsychicData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local H=assert(loadfile('lib/Gen3ImportedSaffronPsychic.lua'))(V)
local E=assert(loadfile('lib/Gen3SaffronPsychicDoors.lua'))(V);modules.Gen3SaffronPsychicDoors=E
local rows={{661,662,662,663},{669,670,670,671},{677,678,655,679},{702,703,687,668},{686,644,652,676}}
local function fixture(id)
 local connection=id=='FR_SAFFRON_CITY_CONNECTION';local x,y=connection and 36 or 46,connection and 10 or 17
 local region={x=9,y=11,def={id=id}}
 local g={cx=x+9,cy=y+11,width=4,depth=5,pair='general__rom_082d4b9c',family='saffron_door_house',groundHeight=3}
 local cells={};for yy,row in ipairs(rows)do for xx,mid in ipairs(row)do
  cells[(g.cx+xx-1)..':'..(g.cy+yy-1)]={cx=g.cx+xx-1,cy=g.cy+yy-1,mid=mid,region=region,pair=g.pair,civic=g,base=yy==1 and 9 or 3,collision=yy==1 and 0 or(yy==5 and xx==2 and not connection and 113 or 7)}
 end end
 return g,cells,region
end
for _,id in ipairs{'FR_SAFFRON_CITY','FR_SAFFRON_CITY_CONNECTION'}do
 local g,cells,region=fixture(id);assert(H.eligible(g,cells),'exact translated native landmark rejected')
 local header=cells[g.cx..':'..g.cy];local body=cells[g.cx..':'..(g.cy+1)]
 for _,k in ipairs{'boundary','stageHidden','prop'}do body[k]=true;assert(not H.eligible(g,cells),k);body[k]=nil end
 for k,v in pairs{mid=0,collision=0,base=4,pair='viridian_outdoor',civic=false}do local old=body[k];body[k]=v;assert(not H.eligible(g,cells),k);body[k]=old end
 local old=region.def.id;region.def.id='FR_CELADON_CITY';assert(not H.eligible(g,cells));region.def.id=old
 header.region=nil;assert(not H.eligible(g,cells),'never guess a landmark from bare repeated tiles');header.region=region
 local permission=cells[(g.cx+1)..':'..(g.cy+4)].collision
 cells[(g.cx+1)..':'..(g.cy+4)].collision=permission==7 and 113 or 7;assert(not H.eligible(g,cells),'connection native no-warp state changed');cells[(g.cx+1)..':'..(g.cy+4)].collision=permission
 assert(H.register());assert(not H.build(g,cells,function()error('missing source PNG upload')end,{}));assert(not g.importedSaffronPsychic)
 local image=S.image;S.image=function()return{}end
 local function newMesh()return{setTexture=function()end,release=function()end}end
 local build=S.buildBatches;S.buildBatches=function(placements,_,opts)
  local p=assert(placements[1]);assert(p.x==g.cx*16 and p.y==3 and p.z==(g.cy+1)*16)
  local parts,fit=assert(S.vertices(p.model,p.fit));assert(fit.bounds[4]-fit.bounds[1]>62,'uniform source must substantially fill native width')
  assert(math.abs(fit.anchors.door[1]-24)<1e-6 and math.abs(fit.anchors.door[3]-59.25)<1e-6)
  local seen={};for _,part in ipairs(parts)do seen[part.name]=true
   assert(part.role~='source_shading'and part.role~='source_door','no baked shadow or invented panel')
   for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=63.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=63.75+1e-6 and v[2]>=-.05-1e-6)end
  end
  for _,part in ipairs(parts)do if part.name=='authored_roof_soffit'then
   local low=math.huge;for _,v in ipairs(part.vertices)do low=math.min(low,v[2])end
   for n=1,#part.indices,3 do local allLow=true;for j=0,2 do if math.abs(part.vertices[part.indices[n+j]][2]-low)>1e-6 then allLow=false end end;assert(not allLow,'flat soffit cuts across upper facade/window heads')end
  end end
  for _,n in ipairs{'rear_siding','rear_inner_gable','rear_barrel_fascia','roof_soffit','closed_foundation'}do assert(seen['authored_'..n],n)end
  assert(modules.Gen3ImportedGyms.clearance(g,cells,parts),'physical triangles must stay on original blocked body')
  return opts.parts
 end
 assert(H.build(g,cells,newMesh,{}));assert(g.importedSaffronPsychic.model==H.id)
 assert(E.ownsDoor(g,g.cx+1,g.cy+4)and not E.ownsDoor(g,g.cx+2,g.cy+4));assert(E.draw(g,nil,function()end));E.release(g)
 assert(body.civic==g and body.base==3 and body.collision==7 and header.base==9,'native data/support changed')
 local fresh,other=fixture(id);S.buildBatches=function()return nil,'late body upload failure'end
 local ok,why=H.build(fresh,other,newMesh,{});assert(not ok and why=='late body upload failure'and not fresh.importedSaffronPsychic and not fresh.importedSaffronPsychicDoors,'body failure leaks source door pose meshes')
 S.buildBatches=build;S.image=image
end
local g,cells,region=fixture('FR_SAFFRON_CITY');region.x=region.x+25;region.y=region.y+7
assert(not H.eligible(g,cells),'identical Copycat drawing must not become Mr Psychic house')
print('PASS Psychic exact map/native variant/triangle masks, substantial uniform fit, genuine source panel/hinge, closures and fallback')
