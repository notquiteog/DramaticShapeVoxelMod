-- Keep native pickup scripts and object lifetimes; replace only their draw.
local V=...
local M={}
function M.draw(gid,x,z,height,draw,reflection)
 local Items=V.require('ItemPokeballs')
 if not Items.enabled() then return false end
 local constants=require('src.core.game3.constants').active()
 local item=constants:id('event_objects','OBJ_EVENT_GFX_ITEM_BALL')
 if not item or tonumber(gid)~=item then return false end
 local Shadow=V.require('ShadowMap')
 return Items.draw({spriteId='SPRITE_POKE_BALL',px=x,py=z,groundHeight=height,
  reflectionPlane=reflection,reflectionRaise=V.require('Water').CAST_RAISE},
  draw==Shadow.draw and Shadow or nil)
end
return M
