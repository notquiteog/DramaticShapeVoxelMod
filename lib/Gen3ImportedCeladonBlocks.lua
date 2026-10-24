-- Genuine two-storey Celadon balcony block. Vented/tall/enterable art is separate.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_celadon_balcony_block'}
local specs={
 celadon_low_roof_block={{729,730,730,774},{736,737,737,740},{744,745,747,748},{752,753,755,756},{760,761,763,764}},
 celadon_small_block={{749,750,750,758},{736,737,737,740},{744,745,747,748},{752,753,755,756},{760,761,763,764}},
}
function M.eligible(g,cells)
 local rows=g and specs[g.family]
 if not(rows and g.width==4 and g.depth==#rows and g.pair=='general__rom_082d4b3c'and not g.stageHidden)then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==(y==1 and 0 or 7)and not(c.boundary or c.stageHidden or c.prop))then return false end
  if y>1 then if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 return Models.register(M.id,V.require('CeladonBlockData')[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=64,depth=(g.depth-1)*16,padding=.25,groundInset=.05};local fitted,why=Models.fit(M.id,fit);if not fitted then return false,why end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,message end
 fitted.model=M.id;g.importedCeladonBlock=fitted;return true
end
return M
