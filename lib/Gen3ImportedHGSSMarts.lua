-- Genuine shared HGSS Mart with explicit native right-door/left-sign layout.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_kanto_mart'}
local locations={
 FR_CERULEAN_CITY={27,25,'general__rom_082d4af4'},FR_CINNABAR_ISLAND={17,8,'general__rom_082d4b6c'},FR_FOUR_ISLAND={20,23,'general__rom_082d5064'},FR_FUCHSIA_CITY={9,12,'general__rom_082d4b54'},FR_LAVENDER_TOWN={18,12,'general__rom_082d4b0c'},FR_PEWTER_CITY={26,15,'pewter_outdoor'},FR_SAFFRON_CITY={38,18,'general__rom_082d4b9c'},FR_SAFFRON_CITY_CONNECTION={28,11,'general__rom_082d4b9c',true},FR_SIX_ISLAND={18,8,'general__rom_082d507c'},FR_THREE_ISLAND={16,9,'sevii_outdoor'},FR_VERMILION_CITY={27,14,'general__rom_082d4b24'},FR_VIRIDIAN_CITY={34,16,'viridian_outdoor'},
}
local regular={{40,41,42,43},{48,49,50,51},{56,57,58,59},{64,65,98,99}}
local saffron={{760,761,762,763},{48,49,50,51},{56,57,58,59},{758,65,98,759}}
function M.eligible(g,cells)
 if not(g and g.kind=='mart'and not g.custom and g.width==4 and g.depth==4 and not g.stageHidden)then return false end
 local first=cells[g.cx..':'..g.cy];local r=first and first.region;local id=r and r.def and r.def.id;local loc=locations[id]
 if not(loc and g.cx-(r.x or 0)==loc[1]and g.cy-(r.y or 0)==loc[2]and g.pair==loc[3])then return false end
 local rows=(id=='FR_SAFFRON_CITY'or loc[4])and saffron or regular;local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)];local permission=y==1 and 0 or y==4 and(x<=2 and 130 or x==3 and(not loc[4]and 113 or 7)or 7)or 7
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  if y>1 then if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end end
 end end
 return true
end
--0x82 is the engine's solid WALL permission on the two original front-left
-- tiles. Normalize only this temporary read-only clearance mask; native cells
-- and their interaction/collision bytes remain untouched.
function M.clearance(g,cells,parts)
 local copies={};local mask=setmetatable({},{__index=function(_,k)
  local c=cells[k];if not c or c.collision~=130 then return c end
  if not copies[k]then local q={};for k,v in pairs(c)do q[k]=v end;q.collision=7;copies[k]=q end;return copies[k]
 end})
 return V.require('Gen3ImportedGyms').clearance(g,mask,parts)
end
function M.register()
 if Models.info(M.id)then return true end
 return Models.register(M.id,V.require('HGSSMartData')[M.id],{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=64,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=40,targetZ=40};local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end
 local safe,why=M.clearance(g,cells,geometry);if not safe then return false,why end;fitted.model=M.id
 local doors=V.require('Gen3HGSSMartDoors');local ready,reason=doors.build(g,fitted,newMesh,cells);if not ready then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHGSSMart=fitted;doors.commit(g);return true
end
return M
