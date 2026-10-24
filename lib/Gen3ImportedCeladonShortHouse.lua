-- Genuine regional single-floor closed house; original flowers remain HD2D.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_celadon_short_house'}
local rows={{729,730,730,774},{736,737,737,740},{744,745,747,748},{784,785,786,787}}
function M.eligible(g,cells)
 if not(g and g.family=='celadon_short_block'and g.pair=='general__rom_082d4b3c'and g.width==4 and g.depth==4 and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region
 if not(r and r.def and r.def.id=='FR_CELADON_CITY'and g.cx-(r.x or 0)==20 and g.cy-(r.y or 0)==26)then return false end
 local level
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local q=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  if not(q and q.civic==g and q.pair==g.pair and q.mid==mid and q.collision==(y==1 and 0 or 7)and not(q.boundary or q.prop or q.stageHidden))then return false end
  if y>1 then if level==nil then level=q.base or 0 elseif math.abs((q.base or 0)-level)>.001 then return false end end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 return Models.register(M.id,V.require('CeladonShortHouseData')[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,why=M.register();if not ok then return false,why end
 local fit={width=64,depth=48,padding=.25,groundInset=.05}
 local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,geometry);if not safe then return false,why end
 local first=#parts+1
 local result,why=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,why end
 local complete,why=V.require('Gen3CeladonShortHouseFlowers').build(g,fitted,newMesh,parts)
 if not complete then for i=#parts,first,-1 do Models.releaseBatches({parts[i]});parts[i]=nil end;return false,why end
 fitted.model=M.id;g.importedCeladonShortHouse=fitted;return true
end
return M
