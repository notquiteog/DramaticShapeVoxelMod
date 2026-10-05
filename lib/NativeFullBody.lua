-- Reuse the integrated full-body atlas provider for native Gen3 world cards.
-- This never owns a second draw layer or replaces the unstaged battle UI.
local V=...
local M={setting=V.require('CrystalSprites').fullBody}
local resolve,frames
function M.install()
 if resolve then return end
 resolve=V.require('Crystal/full_body')(V.mod,function(dex)return tonumber(dex)end,
  function(mon)return V.require('BattleArt').isShiny({mon=mon})end)
 frames={}
 require('src.render.Assets').register({release=function()
  for _,atlas in pairs(frames)do for _,image in pairs(atlas)do image:release()end end
  frames={}
 end})
end
function M.image(mon)
 if not resolve or M.setting:get()~=true then return nil end
 local pic=resolve(mon,true);if not pic then return nil end
 local atlas=frames[pic.image]
 if not atlas then atlas={};frames[pic.image]=atlas end
 if not atlas[pic.frame]then
  local g=love.graphics;local canvas=g.newCanvas(pic.width,pic.height,{dpiscale=1})
  g.push('all')
  local ok,err=pcall(function()
   g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode()
   g.setBlendMode('alpha');g.clear(0,0,0,0);g.setColor(1,1,1,1)
   g.draw(pic.image,pic.quad,0,0)
  end)
  g.pop();if not ok then canvas:release();error(err,0)end
  canvas:setFilter('nearest','nearest');atlas[pic.frame]=canvas
 end
 return atlas[pic.frame]
end
return M
