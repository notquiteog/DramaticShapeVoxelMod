-- Regional HGSS Viridian/Pewter/Cerulean Gyms. Native exact drawings and permission
-- masks own eligibility; the source doorway stays inside its native warp tile.
local V=...
local Models=V.require('SceneryModels')
local M={}
local specs={
 viridian_outdoor={id='hgss_viridian_gym',width=6,rows={{685,686,686,686,686,687},{321,322,322,322,322,323},{329,330,330,330,330,331},{336,337,338,339,340,342},{344,345,346,347,348,350}}},
 pewter_outdoor={id='hgss_pewter_gym',width=7,rows={{313,314,314,314,314,314,315},{321,322,322,322,322,322,323},{329,330,330,330,330,330,331},{336,337,338,339,340,341,342},{344,345,346,347,348,349,350}}},
 ['general__rom_082d4af4']={id='hgss_cerulean_gym',width=7,headerLastBlocked=true,rows={{313,314,314,314,314,314,315},{321,322,322,322,322,322,323},{329,330,330,330,330,330,331},{336,337,338,339,340,341,342},{344,345,346,347,348,349,350}}},
}
function M.selection(g)return g and specs[g.pair]end
function M.register(id)
 if Models.info(id)then return true end
 local d=V.require('HGSSKantoGymData')[id];if not d then return nil,'unknown regional HGSS Gym'end
 return Models.register(id,d,{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 local spec=M.selection(g)
 if not(spec and g.kind=='gym'and g.width==spec.width and g.depth==5 and not g.stageHidden)then return false end
 local base
 for y,row in ipairs(spec.rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)]
  local permission=y==1 and(spec.headerLastBlocked and x==spec.width and 7 or 0)or y==5 and(x>=3 and x<=5 and(x==4 and 0x71 or 7)or 0)or 7
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  if y>1 and permission~=0 then if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local id=M.selection(g).id;local ok,err=M.register(id);if not ok then return false,err end
 -- Door front lies1px inside the native entrance tile. Raising Z to54 lets
 -- the full-width front columns occupy the native walkable corner cells.
 local fit={width=g.width*16,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=49}
 local geometry,placed=Models.vertices(id,fit);if not geometry then return false,placed end
 local safe,why=V.require('Gen3ImportedGyms').clearance(g,cells,geometry);if not safe then return false,why end
 placed.model=id
 local doors=V.require('Gen3HGSSGymDoors');local ready,reason=doors.build(g,placed,newMesh,cells);if not ready then return false,reason end
 local result,message=Models.buildBatches({{model=id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHGSSGym=placed;doors.commit(g);return true
end
return M
