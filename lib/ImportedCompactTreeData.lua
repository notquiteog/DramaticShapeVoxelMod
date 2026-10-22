-- Designed compact woodland trees, using authentic ORAS Route104 foliage,
-- vertex colors, UVs, closed bark and completed radial canopy. No new pixels.
local V=...
local source=V.require('ImportedTreeData').oras_route104_broadleaf
local function copy(t)
 if type(t)~='table'then return t end
 local q={};for k,v in pairs(t)do q[k]=copy(v)end;return q
end
local function model(depth)
 local d=copy(source);local bounds={math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge}
 for _,part in ipairs(d.parts)do
  assert(part.role=='tree_canopy'or part.role=='tree_trunk','compact tree needs reviewed source roles')
  for _,v in ipairs(part.vertices)do
   if part.role=='tree_canopy'then
    local base=source.anchors.canopyBottom[2]
    v[2]=base+(v[2]-base)*1.25+.20;v[3]=v[3]*depth
   else v[2]=v[2]*1.25 end
   for i=1,3 do bounds[i]=math.min(bounds[i],v[i]);bounds[i+3]=math.max(bounds[i+3],v[i])end
  end
  part.bounds=nil
 end
 d.bounds=bounds
 d.anchors.canopyBottom[2]=d.anchors.canopyBottom[2]+.20
 d.anchors.canopyBottom[3]=d.anchors.canopyBottom[3]*depth
 return d
end
return{oras_compact_broadleaf=model(1),oras_compact_broadleaf_narrow=model(2)}
