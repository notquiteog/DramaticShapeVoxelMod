-- Reviewed source furniture only; extraction, native walls and interactions
-- remain owned by the existing interior adapters.
local V=...
local Models=V.require('SceneryModels')
local PCFrames=V.require('Gen3PublicPCFrames')
local M={id='oras_center_pc'}
local registered=false
-- These complete drawings describe a freestanding public PC, including the
-- wall above and the walkable perspective apron. Home desks and lab consoles
-- have different identities and must not be substituted by this object.
local families={
 hoenn_center_pc={pair='building__pokemon_center',family='rse',design='fr_center_pc',rows={{0x20c},{4},{0x224}}},
 center_terminal={pair='network',design='fr_center_pc',rows={{0x285},{0x62},{0x295}}},
}
function M.register()
 if registered and Models.info(M.id)then return true end
 local ok,data=pcall(V.require,'ImportedInteriorData')
 if not ok or type(data)~='table'or not data[M.id]then return nil,'imported interior source unavailable'end
 local result,err=Models.register(M.id,data[M.id],{read=function(path)return V.mod:read(path)end})
 if not result then return nil,err end
 registered=true;return true
end
function M.eligible(p,cells)
 local r=p and p.recipe;local f=r and families[r.name]
 if not f or r.design~=f.design or r.family~=f.family or p.pair~=f.pair
  or p.w~=16 or p.d~=48 or p.stageHidden then return false end
 local base
 for row=1,3 do
  if not r.rows[row]or #r.rows[row]~=1 or r.rows[row][1]~=f.rows[row][1]then return false end
  local c=cells[p.cx..':'..(p.cy+row-1)]
  if not c or c.prop~=p or c.pair~=f.pair or c.primary~='building'
   or not PCFrames.matches(r,c.mid,f.rows[row][1])or not(row==2 and(c.collision==0x93 or c.collision==7)or row~=2 and c.collision==({7,0x93,0})[row])
   or c.boundary or c.stageHidden or c.stairs or c.civic then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end
 return true
end
function M.placements(cells)
 local list,seen={},{}
 for _,c in pairs(cells)do local p=c.prop
  if p and not seen[p]then
   seen[p]=true
   if M.eligible(p,cells)then
    list[#list+1]={model=M.id,x=p.cx*16,y=p.groundHeight or 0,z=(p.cy+1)*16,
     fit={width=16,depth=16,height=24,padding=.25},source=p}
   end
  end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells)
 if #list==0 then return parts,nil,0 end
 local ok,err=M.register();if not ok then return nil,err,0 end
 local result,why=Models.buildBatches(list,newMesh,{parts=parts})
 -- Mark only after every texture and mesh uploads. A failed source load keeps
 -- the complete native furniture, including its existing wall/ground handling.
 if result then for _,p in ipairs(list)do p.source.importedInterior=M.id end end
 return result,why,result and #list or 0
end
return M
