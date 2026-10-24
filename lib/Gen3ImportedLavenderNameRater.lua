-- Actual HGSS Name Rater tent on its exact native FR/LG header variant.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_lavender_name_rater'}
local rows={{648,641,642,643,652},{656,657,657,657,660},{664,665,666,667,668},{672,673,674,675,676}}
function M.eligible(g,cells)
 if not(g and g.family=='lavender_name_rater'and g.pair=='general__rom_082d4b0c'and g.width==5 and g.depth==4 and not g.stageHidden)then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)];local permission=y==1 and 0 or(y==4 and x==3 and 113 or 7)
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 local source=V.require('LavenderNameRaterData')[M.id]
 return Models.register(M.id,{parts=source.parts,anchors=source.anchors},{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=80,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=40,targetZ=34.5}
 local fitted,why=Models.fit(M.id,fit);if not fitted then return false,why end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,message end
 g.importedLavenderNameRater=fitted;return true
end
return M
