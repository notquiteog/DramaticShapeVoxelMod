-- Genuine Cerulean closed-window house, only its complete native short drawing.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_cerulean_closed_house'}
local rows={{672,673,665,673,674},{680,681,681,681,682},{688,689,689,689,690},{696,694,704,703,698}}
function M.eligible(g,cells)
 if not(g and g.family=='cerulean_house_short'and g.pair=='general__rom_082d4af4'and g.width==5 and g.depth==4 and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local r=c and c.region
 if not(r and r.def and r.def.id=='FR_CERULEAN_CITY'and g.cx-(r.x or 0)==31 and g.cy-(r.y or 0)==25)then return false end
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
 return Models.register(M.id,V.require('CeruleanClosedHouseData')[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,why=M.register();if not ok then return false,why end
 local fit={width=80,depth=48,padding=.25,groundInset=.05}
 local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,geometry);if not safe then return false,why end
 local result,why=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,why end
 fitted.model=M.id;g.importedCeruleanClosedHouse=fitted;return true
end
return M
