local source=assert(loadfile('lib/ImportedPineTreeData.lua'))()
local seen={};local available=true
local V={mod={read=function()end}}
V.require=function(n)
 if n=='ImportedPineTreeData'then return source end
 if n=='SceneryModels'then return{info=function(id)return seen[id]end,register=function(id,data)if not available then return false end;seen[id]=data;return true end}end
 error(n)
end
local P=assert(loadfile('lib/HoennTreePalette.lua'))(V)
for _,id in ipairs{'oras_evergreen_tree','oras_evergreen_foreground'}do
 local dest=P.register(id);assert(dest==P.ids[id]);local d=seen[dest]
 local depth=id=='oras_evergreen_foreground'and 2 or 1
 for i,p in ipairs(d.parts)do
  local original=source.oras_evergreen_tree.parts[i]
  for j,v in ipairs(p.vertices)do
   local o=original.vertices[j];assert(v[1]==o[1]and v[2]==o[2]and v[3]==o[3]*depth and v[4]==o[4]and v[5]==o[5])
   if p.role=='tree_canopy'then assert(p.vertexColorRole=='paint'and p.colors[j][1]==1 and p.colors[j][2]==.84 and p.colors[j][3]==.54)else assert(p.colors==original.colors)end
  end
  for j,n in ipairs(p.indices)do assert(n==original.indices[j])end
  assert(p.texture==original.texture and original.colors==nil,'mutated original regional source')
 end
end
local list={{model='hgss_kanto_tree'},{model='oras_evergreen_tree'}};P.prepare(list)
assert(list[1].model=='hgss_kanto_tree'and list[2].model==P.ids.oras_evergreen_tree)
seen={};available=false;assert(P.register('oras_evergreen_tree')=='oras_evergreen_tree','resource failure must retain original model')
print('PASS Hoenn-only source foliage paint, original geometry/UV/alpha and regional isolation')
