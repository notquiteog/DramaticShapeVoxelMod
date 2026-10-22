-- Reviewed source furniture only; extraction, native walls and interactions
-- remain owned by the existing interior adapters.
local V=...
local Models=V.require('SceneryModels')
local PCFrames=V.require('Gen3PublicPCFrames')
local M={id='oras_center_pc',tvId='oras_home_tv'}
local registered={}
local dataFiles={oras_center_pc='ImportedInteriorData',oras_home_tv='ImportedInteriorTVData'}
-- Complete public-PC and genuine TV drawings include the wall above and
-- walkable perspective apron. TV identity additionally requires native 0x86
-- behavior; similarly named cupboards, home desks and labs are not substitutes.
local families={
 hoenn_center_pc={pair='building__pokemon_center',family='rse',design='fr_center_pc',rows={{0x20c},{4},{0x224}}},
 center_terminal={pair='network',design='fr_center_pc',rows={{0x285},{0x62},{0x295}}},
 hoenn_home_small_tv={pair='building__generic_building',family='rse',design='em_home_small_tv',rows={{0x230},{0x21e},{0x238}},model='oras_home_tv',cabinet=6},
 living_television={pair='player_house',design='fr_living_tv',rows={{0x2d},{0x35},{0x3d}},model='oras_home_tv',cabinet=6,note=true},
 neighbor_living_television={pair='house',design='fr_living_tv',rows={{0x2d},{0x35},{0x3d}},model='oras_home_tv',cabinet=6,note=true},
}
function M.register(id)
 id=id or M.id
 if registered[id]and Models.info(id)then return true end
 local file=dataFiles[id];if not file then return nil,'unknown imported interior'end
 local ok,data=pcall(V.require,file)
 if not ok or type(data)~='table'or not data[id]then return nil,'imported interior source unavailable'end
 local result,err=Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
 if not result then return nil,err end
 registered[id]=true;return true
end
function M.eligible(p,cells)
 local r=p and p.recipe;local f=r and families[r.name]
 if not f or r.design~=f.design or r.family~=f.family or p.pair~=f.pair
  or p.w~=16 or p.d~=48 or p.stageHidden then return false end
 local base
 for row=1,3 do
  if not r.rows[row]or #r.rows[row]~=1 or r.rows[row][1]~=f.rows[row][1]then return false end
  local c=cells[p.cx..':'..(p.cy+row-1)]
  local collision=c and(row==2 and(f.model=='oras_home_tv'and c.collision==7 or f.model==nil and(c.collision==0x93 or c.collision==7))or row~=2 and c.collision==({7,7,0})[row])
  if not c or c.prop~=p or c.pair~=f.pair or c.primary~='building'
   or not PCFrames.matches(r,c.mid,f.rows[row][1])or not collision
   or f.model=='oras_home_tv'and row==2 and c.behavior~=0x86
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
    local f=families[p.recipe.name]
    list[#list+1]={model=f.model or M.id,x=p.cx*16,y=(p.groundHeight or 0)+(f.cabinet or 0),z=(p.cy+1)*16,
     fit={width=16,depth=16,height=f.model and 17 or 24,padding=.25},source=p}
   end
  end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells)
 if #list==0 then return parts,nil,0 end
 for _,p in ipairs(list)do local ok,err=M.register(p.model);if not ok then return nil,err,0 end end
 local result,why=Models.buildBatches(list,newMesh,{parts=parts})
 -- Mark only after every texture and mesh uploads. A failed source load keeps
 -- the complete native furniture, including its existing wall/ground handling.
 if result then for _,p in ipairs(list)do p.source.importedInterior=p.model end end
 return result,why,result and #list or 0
end
-- Retain the exact native cabinet and wall note as separate components.
-- The parent supplies its ordinary elevation/wall-attachment emit callback.
function M.remainder(p,emit,uvFor)
 local f=families[p.recipe.name]
 if p.importedInterior~=M.tvId or not f or not f.cabinet then return false end
 V.require('Gen3Furniture').append(p,function(vertices,uv,shade,anchor)
  local low,high=math.huge,-math.huge
  for _,v in ipairs(vertices)do low=math.min(low,v[2]);high=math.max(high,v[2])end
  if high<=f.cabinet+.05 or f.note and low>=23 then emit(vertices,uv,shade,anchor)end
 end,uvFor)
 return true
end
return M
