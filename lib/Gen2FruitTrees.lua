-- Native fruit-tree actors retain their event/harvest identity and borrow the
-- illustrated forest's low, trunkless shrub layers in 2.5D presentation.
local V=...
local M={}
local leaves
function M.accepts(c)
 if V.require("TreePresentation").original() then return false end
 local map=c and c.state and c.state.map
 local d=c and c.sprite and c.sprite.def
 return map and V.require('CommunityVisuals').crystalDepth(map) and d
  and d.id=='SPRITE_FRUIT_TREE' and d.image=='assets/generated/sprites/fruit_tree.png'
  and not d.trueColor and not d.walker and (d.frameWidth or 16)==16
  and (d.frameHeight or 16)==16
end
function M.draw(c,shadow)
 if not M.accepts(c) then return false end
 local voxel=V.require('Voxel3D')
 if not leaves then
  local lv,li={},{}
  V.require('Gen2DepthTrees').append(lv,li,0,0,0,0,3,42,'shrub')
  leaves=voxel.newMesh(lv,li)
 end
 if not leaves then return false end
 local _,crown=V.require('CommunityFlora').crystalTreeMaterials()
 if not crown then return false end
 local transform=V.require('ItemPokeballs').transform(c,not shadow)
 if shadow then
  shadow.draw(leaves,crown,transform)
 else
  voxel.draw(leaves,crown,transform)
 end
 return true
end
function M.invalidate()
 if leaves then leaves:release() end
 leaves=nil
end
return M
