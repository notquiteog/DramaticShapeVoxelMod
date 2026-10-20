-- Optional real scenery trees. Native adapters retain collision, ground,
-- source ownership and the complete older solid model on any standdown.
local V=...
local M={model='oras_route104_broadleaf'}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function enabled()
 local T=V.require('TreePresentation');local C=V.require('CommunityVisuals')
 return T.voxel()and not C.customTrees()
end
local function customForest(mapId)
 local C=V.require('CommunityVisuals')
 return (mapId=='FR_VIRIDIAN_FOREST'or mapId=='VIRIDIAN_FOREST'or mapId=='ILEX_FOREST')and C.customForest()
  or type(mapId)=='string'and mapId:find('SAFARI',1,true)and C.customSafari()
end
local function blocked(c)
 return c and(c.collision==7 or c.collision==nil and c.boundary=='forest')
end
local function fitPlacement(bounds,y,rotation,source,model)
 if not(enabled()and type(bounds)=='table'and #bounds==4 and finite(y))then return end
 for _,n in ipairs(bounds)do if not finite(n)then return end end
 local w,d=bounds[3]-bounds[1],bounds[4]-bounds[2]
 -- One-cell fragments from a cropped border retain their original solid
 -- family instead of shrinking a mature broadleaf into a miniature bush.
 if w<23.9 or d<15.9 or math.max(w/d,d/w)>2.1 then return end
 model=model or M.model
 local Models=V.require('SceneryModels');if not Models.info(model)then return end
 local opts={width=w,depth=d,padding=.25,rotation=rotation or 0}
 local fitted=Models.fit(model,opts);if not fitted then return end
 if fitted.bounds[5]<20 then return end
 return{model=model,x=bounds[1],y=y,z=bounds[2],fit=opts,source=source,
  treeInfo={height=fitted.bounds[5],canopyBottom=fitted.anchors.canopyBottom and fitted.anchors.canopyBottom[2]or nil,
   bounds={bounds[1]+fitted.bounds[1],bounds[2]+fitted.bounds[3],bounds[1]+fitted.bounds[4],bounds[2]+fitted.bounds[6]}}}
end
function M.gen3Placement(c,cells,options)
 local s=c and c.shape
 local def=c and(c.def or c.region and c.region.def)
 local id=def and def.id or c and c.region and c.region.mapId or options and options.mapId or ''
 if not(s and s.kind=='tree'and s.root and not(c.prop or c.civic or c.stageHidden)
  and blocked(c)and not customForest(id))then return end
 -- Specialized volcanic/golden/sapling art has no matching imported source.
 if s.treeFamily=='ash'or s.treePalette or s.treeFamily=='sapling'then return end
 local hoenn=options and options.region=='hoenn'or id:match('^EM_')or id:match('^RU_')or id:match('^SA_')
 if not s.importedTreeModel and not hoenn and s.treeFamily~='broad'and s.treeFamily~='round'then return end
 local b=s.treeBounds;if not b then return end
 -- Verify the complete native owner rectangle; corners and projected crowns
 -- cannot borrow a walkable tile just because their center is blocked.
 for y=math.floor(b[2]/16),math.ceil(b[4]/16)-1 do for x=math.floor(b[1]/16),math.ceil(b[3]/16)-1 do
  local q=cells[x..':'..y]
  if not(blocked(q)and q.shape and q.shape.kind=='tree'and not(q.prop or q.civic or q.stageHidden)
   and q.shape.treeBounds==b and math.abs((q.base or 0)-(c.base or 0))<.01)then return end
 end end
 return fitPlacement(b,c.base or 0,(c.cx*17+c.cy*29)%4,c,s.importedTreeModel)
end
function M.gen3Placements(cells,options)
 local list={};if not enabled()then return list end
 for _,c in pairs(cells)do local p=M.gen3Placement(c,cells,options);if p then list[#list+1]=p end end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
-- Caller must own options.parts before entering this potentially yielding
-- operation. Only a completely built replacement hides the old tree model.
function M.buildGen3(cells,newMesh,parts,options)
 local list=M.gen3Placements(cells,options)
 local Models=V.require('SceneryModels')
 if Models.retryImages then local seen={};for _,p in ipairs(list)do
  if not seen[p.model]then Models.retryImages(p.model);seen[p.model]=true end
 end end
 local out,err=Models.buildBatches(list,newMesh,{parts=parts})
 if out then for _,p in ipairs(list)do p.source.importedTree=p.treeInfo end end
 return out,err,#list
end
-- GSC's existing wide-tree registry is the lower-left cell of the original
-- complete 2x2 drawing. Ordinary conifers and one-cell round trees keep their
-- reviewed original solid families; no new registry/collision is invented.
function M.gbPossible(map)
 return enabled()and map and type(map.cellCollision)=='function'
  and not customForest(map.id)and V.require('SceneryModels').info(M.model)~=nil or false
end
function M.gbPlacement(map,cx,cy,lift,base)
 if lift~=20 or not M.gbPossible(map)then return end
 local x0,z0=cx*16,(cy-1)*16
 local w=map.width and map.width*2 or map.def and map.def.width*2
 local h=map.height and map.height*2 or map.def and map.def.height*2
 if not(w and h and cx>=0 and cy>=1 and cx+1<w and cy<h)then return end
 local P=require('src.world.gen2.Permissions')
 for y=cy-1,cy do for x=cx,cx+1 do
  local coll=map:cellCollision(x,y)
  if coll==nil or P.of(coll)~=P.WALL or map:isWalkableCell(x,y)then return end
  if math.abs(V.require('Gen2Elevation').at(map,x*16+8,y*16+8)-V.require('Gen2Elevation').at(map,cx*16+8,cy*16+8))>.01 then return end
 end end
 return fitPlacement({x0,z0,x0+32,z0+32},base,(cx*17+cy*29)%4)
end
function M.queueGB(part,map,cx,cy,lift,base,card,x,z)
 local placement=M.gbPlacement(map,cx,cy,lift,base)
 if not(placement and card)then return false end
 part.importedTreePlacements=part.importedTreePlacements or{}
 placement.fallback={card=card,x=x,y=base,z=z,map=map}
 part.importedTreePlacements[#part.importedTreePlacements+1]=placement
 return true
end
function M.buildGB(part,newMesh,resources)
 local list=part.importedTreePlacements
 if not list then return end
 local Models=V.require('SceneryModels');if Models.retryImages then Models.retryImages(M.model)end
 local out={};local owner={parts=out}
 function owner:release()
  if self.parts then Models.releaseBatches(self.parts);self.parts=nil end
 end
 part.importedTreeOwner=owner
 -- The owner enters the scheduler's cancellation ledger before buildBatches
 -- can yield or upload any prototype/instance mesh.
 if resources then resources[owner]=true end
 local built,err=Models.buildBatches(list,newMesh,{parts=out})
 part.importedTreeError=err
 if built then
  part.importedTreeParts=built
  for _,p in ipairs(list)do local f=p.fallback;local b=p.treeInfo.bounds
   V.require('KfpTreeDetails').record(f.map,(b[1]+b[3])/2,p.y,(b[2]+b[4])/2,p.y+p.treeInfo.height-4,p.treeInfo.canopyBottom and p.y+p.treeInfo.canopyBottom)
  end
 else
  owner:release();if resources then resources[owner]=nil end;part.importedTreeOwner=nil
  local native=V.require('NativeTreeArt')
  for _,p in ipairs(list)do local f=p.fallback
   native.appendModel(f.card,part.dV,part.dI,0,f.x,f.y,f.z)
   V.require('KfpTreeDetails').record(f.map,f.x,f.y,f.z,f.y+f.card.h-(f.card.bottom or 0)-4,f.y+(native.foliageFloor(f.card)or 0))
  end
 end
 part.importedTreePlacements=nil
end
function M.releaseGB(part,resources)
 if part.importedTreeOwner then
  part.importedTreeOwner:release();if resources then resources[part.importedTreeOwner]=nil end
  part.importedTreeOwner=nil
 end
 part.importedTreeParts=nil
end
function M.drawGB(part,draw,model)
 for _,p in ipairs(part.importedTreeParts or{})do if p.count>0 then draw(p.mesh,p.image,model)end end
end
M.enabled=enabled
M.fitPlacement=fitPlacement
return M
