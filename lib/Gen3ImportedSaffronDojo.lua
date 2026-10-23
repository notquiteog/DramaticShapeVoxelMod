-- Genuine regional Fighting Dojo; keep its original open portal and plaques.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_saffron_dojo'}
local rows={{816,817,799,817,799,818},{824,825,825,825,825,826},{832,833,833,833,833,834},{821,822,823,811,812,827},{829,830,831,819,820,835}}
function M.eligible(g,cells)
 if not(g and g.kind=='gym'and g.width==6 and g.depth==5 and g.pair=='general__rom_082d4b9c'and not g.stageHidden)then return false end
 local first=cells[g.cx..':'..g.cy];local r=first and first.region;local id=r and r.def and r.def.id;local x,y=g.cx-(r and r.x or 0),g.cy-(r and r.y or 0)
 if not(id=='FR_SAFFRON_CITY'and x==37 and y==8 or id=='FR_SAFFRON_CITY_CONNECTION'and x==27 and y==1)then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  local permission=y==5 and(x>=3 and x<=5 and(x==4 and 113 or 7)or 0)or 7
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  -- The native entrance/corner elevation3 is a drawing convention, not part
  -- of the body datum. Preserve it while requiring the real blocked body flat.
  if y>1 and not(y==5 and(x==4 or permission==0))then if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end end
 end end
 return true
end
function M.register()
 if Models.info(M.id)then return true end
 return Models.register(M.id,V.require('SaffronDojoData')[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=96,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=49}
 local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,geometry);if not safe then return false,why end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,message end
 fitted.model=M.id;g.importedSaffronDojo=fitted;return true
end
return M
