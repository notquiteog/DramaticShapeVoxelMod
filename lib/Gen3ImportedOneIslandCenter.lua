-- Wider native One Island Center; genuine HGSS proportions and exact portal.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_kanto_center'}
local rows={{704,706,706,707,708,708,710},{712,714,714,715,716,716,718},{720,714,722,723,724,716,726},{728,729,730,731,732,733,734},{736,737,738,739,740,741,742},{744,745,746,747,748,749,750}}
function M.eligible(g,cells)
 if not(g and g.kind=='center'and g.family=='one_island_center'and g.custom and g.custom.name=='one_island_center'and g.pair=='sevii_outdoor'and g.width==7 and g.depth==6 and not g.stageHidden)then return false end
 local first=cells[g.cx..':'..g.cy];local r=first and first.region
 if not(r and r.def and r.def.id=='SEVII_ONE_ISLAND'and g.cx-(r.x or 0)==11 and g.cy-(r.y or 0)==0)then return false end
 local base
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==(y==6 and x==4 and 113 or 7)and not(c.boundary or c.prop or c.stageHidden))then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 local extra=cells[(g.cx+2)..':'..(g.cy+6)]
 if not(extra and extra.civic==g and extra.pair==g.pair and extra.mid==721 and extra.collision==0 and not(extra.prop or extra.stageHidden or extra.boundary)and math.abs((extra.base or 0)-base)<.001)then return false end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,why=V.require('Gen3ImportedKantoCenters').register();if not ok then return false,why end
 local fit={width=112,depth=96,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=83}
 local geometry,fitted=Models.vertices(M.id,fit);if not geometry then return false,fitted end;fitted.model=M.id
 local doors=V.require('Gen3KantoCenterDoors');local safe,why=doors.clearance(g,cells,geometry);if not safe then return false,why end
 local ready,why=doors.build(g,fitted,newMesh,cells);if not ready then return false,why end
 local result,why=Models.buildBatches({{model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=g.cy*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,why end
 g.importedOneIslandCenter=fitted;doors.commit(g);return true
end
function M.doorSurface(g,x,y)
 local f=g.importedOneIslandCenter;if not(f and x==g.cx+3 and y==g.cy+5)then return end
 local a=f.anchors.door;local sx,sz=g.cx*16+a[1],g.cy*16+a[3]+.025
 local half,height=10.00879*f.scale/90,30*f.scale/90
 return{w=14,h=16,sourceX=g.cx*16+49,sourceY=(g.cy+5)*16,base=g.groundHeight or 0,
  vertices={{sx-half,a[2]+height,sz},{sx+half,a[2]+height,sz},{sx+half,a[2],sz},{sx-half,a[2],sz}}}
end
return M
