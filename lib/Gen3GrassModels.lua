-- Bind imported grass to reviewed native grass cells. Native maps still own
-- encounters, Cut, ground, elevation and permissions; flowers stay HD-2D.
local V=...
local Models=V.require('GrassModels')
local M={}
local okStyles,Styles=pcall(V.require,'VisualStyles')
-- These native encounter-grass cells also contain a projected tree tip. The
-- tree adapter removes the tip, but the walkable grass still needs its model.
local function grassCap(c)
 return c.primary=='general'and(c.mid==0x1c6 or c.mid==0x1c7)
  and c.collision==24 and c.shape.projectedTreeCap==true and c.shape.ground==0xd
end
function M.ground(c)
 if c.importedGrass and grassCap(c)then return 1 end
 return c.shape.ground
end
function M.placements(cells)
 local list={}
 if okStyles and not Styles.modern('props')then return list end
 for _,c in pairs(cells)do
  if(c.shape.kind=='grass'or grassCap(c))and not(c.stageHidden or c.boundary)and c.collision~=7 then
   list[#list+1]={model=c.shape.grassModel or'oras_green',extent=16,
    rotation=(c.cx+c.cy*3)%4,x=c.cx*16,y=c.base or 0,z=c.cy*16,source=c}
  end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
function M.build(cells,newMesh,parts)
 if V.require('TreePresentation').props:get()~='modeled'then return nil,nil,0 end
 local list=M.placements(cells)
 local result,err=Models.buildBatches(list,newMesh,{parts=parts})
 if result then for _,p in ipairs(list)do p.source.importedGrass=true end end
 return result,err,#list
end
-- Sparse native edits can arrive while a replacement scene streams. Remove
-- changed old tufts immediately; never edit the native source to achieve it.
function M.prune(parts,cells,regions)
 local removed=0
 for _,c in pairs(cells or{})do if c.importedGrass then
  for _,r in ipairs(regions or{})do
   local x,y=c.cx-r.x,c.cy-r.y
   if x>=0 and y>=0 and x<r.w and y<r.h then
    local layout=r.def.midLayout
    if layout:midAt(x,y)~=c.mid or layout:collAt(x,y)~=c.collision then
     removed=removed+Models.hideRect(parts,c.cx*16,c.cy*16,(c.cx+1)*16,(c.cy+1)*16)
     c.importedGrass=nil
    end
    break
   end
  end
 end end
 return removed
end
return M
