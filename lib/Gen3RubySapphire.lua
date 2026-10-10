-- Independently reviewed Ruby/Sapphire source families. Do not dispatch the
-- entire Emerald catalogue: several identical IDs draw different objects.
local M={}
local exteriorNames={oldale_house=true,oldale_mart=true,oldale_center=true}
local trees={}
for _,id in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1e4,0x1e5,0x1e6,0x1e7}do trees[id]=true end
local roots={[0x1dc]=true,[0x1e4]=true,[0x1e6]=true}
function M.exteriors(source)
 local out={}
 for _,r in ipairs(source)do if exteriorNames[r.name]then
  local copy={};for k,v in pairs(r)do copy[k]=v end
  copy.header=#r.rows -- require every native source cell, including facade
  out[#out+1]=copy
 end end
 return out
end
function M.shape(primary,secondary,mid,behavior,collision)
 if primary=='general' then
  if trees[mid]then return {kind='tree',ground=1,root=roots[mid],anchorX=16,anchorZ=8,
   treeRows={{0x1d4,0x1d5},{0x1dc,0x1dd}},treeFamily='round',treeTrim=0}end
  if mid==3 then return {kind='sign',height=12,ground=1,hoenn=true}end
  if mid==4 then return {kind='flowers',height=6,ground=1}end
  if mid==1 then return {kind='flat',reviewedSurface=true}end
 end
 return {kind='flat'}
end
return M
