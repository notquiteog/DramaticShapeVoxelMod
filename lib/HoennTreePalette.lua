-- One regional foliage treatment for the genuine ORAS evergreen variants.
-- The PNG/UVs, original geometry and alpha stay untouched. Other regions keep
-- their original registered sources, even after switching games in one session.
local V=...
local M={tint={1,.84,.54},ids={oras_evergreen_tree='oras_evergreen_tree_hoenn',oras_evergreen_foreground='oras_evergreen_foreground_hoenn'}}
local function copy(t)
 if type(t)~='table'then return t end
 local out={};for k,v in pairs(t)do out[k]=copy(v)end;return out
end
function M.register(source)
 local id=M.ids[source];if not id then return source end
 local Models=V.require('SceneryModels');if Models.info(id)then return id end
 local ok,data=pcall(V.require,'ImportedPineTreeData')
 if not ok or not(data and data.oras_evergreen_tree)then return source end
 local model=copy(data.oras_evergreen_tree)
 local depth=source=='oras_evergreen_foreground'and 2 or 1
 for _,part in ipairs(model.parts)do
  for _,v in ipairs(part.vertices)do v[3]=v[3]*depth end
  if part.bounds then part.bounds[3],part.bounds[6]=part.bounds[3]*depth,part.bounds[6]*depth end
  if part.role=='tree_canopy'then
   part.vertexColorRole='paint';part.colors=part.colors or{}
   for i in ipairs(part.vertices)do
    local alpha=part.colors[i]and part.colors[i][4]or 1
    part.colors[i]={M.tint[1],M.tint[2],M.tint[3],alpha}
   end
  end
 end
 for _,p in pairs(model.anchors or{})do p[3]=p[3]*depth end
 if model.bounds then model.bounds[3],model.bounds[6]=model.bounds[3]*depth,model.bounds[6]*depth end
 local registered=Models.register(id,model,{read=function(path)return V.mod:read(path)end})
 return registered and id or source
end
function M.prepare(placements)
 local ids={}
 for _,p in ipairs(placements)do
  if M.ids[p.model]then ids[p.model]=ids[p.model]or M.register(p.model);p.model=ids[p.model]end
 end
end
return M
