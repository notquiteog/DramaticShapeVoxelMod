-- Genuine regional Copycat landmark, never the identically drawn Psychic home.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_saffron_copycat'}
local rows={{661,662,662,663},{669,670,670,671},{677,678,655,679},{702,703,687,668},{686,644,652,676}}
local placements={FR_SAFFRON_CITY={21,10,113},FR_SAFFRON_CITY_CONNECTION={11,3,7}}
function M.eligible(g,cells)
 if not(g and g.family=='saffron_door_house'and g.pair=='general__rom_082d4b9c'and g.width==4 and g.depth==5 and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local region=c and c.region;local spec=region and region.def and placements[region.def.id]
 if not(spec and g.cx-(region.x or 0)==spec[1]and g.cy-(region.y or 0)==spec[2])then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local q=cells[(g.cx+x-1)..':'..(g.cy+y-1)];local permission=y==1 and 0 or(y==5 and x==2 and spec[3]or 7)
  if not(q and q.civic==g and q.pair==g.pair and q.mid==mid and q.collision==permission and not(q.boundary or q.prop or q.stageHidden))then return false end
  if y>1 then if base==nil then base=q.base or 0 elseif math.abs((q.base or 0)-base)>.001 then return false end end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 local source=V.require('SaffronCopycatData')[M.id]
 return Models.register(M.id,{parts=source.parts,anchors=source.anchors},{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,why=M.register();if not ok then return false,why end
 local fit={width=64,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=24,targetZ=59.25}
 local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,geometry);if not safe then return false,why end
 local doors=V.require('Gen3SaffronCopycatDoors');local ready,why=doors.build(g,fitted,newMesh);if not ready then return false,why end
 local result,why=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,why end
 doors.commit(g);fitted.model=M.id;g.importedSaffronCopycat=fitted;return true
end
return M
