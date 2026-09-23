-- Integrated Crystal presentation. One sprite owner is selected at boot;
-- the Crystal runtime also owns menus, evolution and trainer presentation.
local V = ...
local Setting = V.require('ModSetting')
local M = {}
M.setting = Setting.new('spritePack', 'SPRITE PACK (RESTART)',
  {'crystal', 'selected'}, {'CRYSTAL', 'SELECTED ART'})
M.fullBody = Setting.new('full_body_backs', 'FULL-BODY BATTLE BACKS',
  {false, true}, {'OFF', 'ON'}, 2)

function M.install()
  if V.require('Generation').isGen3() or M.setting:get() ~= 'crystal' then return end
  V.crystalSpritesActive = true
  local exports = {}
  -- Keep legacy helper names out of Battle Art's public export namespace.
  -- Asset reads and registration still belong to this one mod ID.
  local options = {
    get = function(_, key) return V.mod.options:get(key) end,
    define = function() end, -- already included in the parent schema
  }
  V.crystalContext = setmetatable({exports=exports, options=options}, {__index=V.mod})
  function V.crystalContext:read(path) return V.mod:read(path) end
  V.mod.exports.crystalSprites = exports
  V.require('Crystal/main')()

  -- Gen 1's staged renderer consumes an image; Gen 2 accepts a quad directly.
  -- Cache each decoded atlas frame rather than adding a second draw layer.
  local frames = {}
  exports.fullBodyImage = function(mon)
    local pic = exports.stagedPokemonSprite and exports.stagedPokemonSprite(mon, true)
    if not pic then return nil end
    local atlas = frames[pic.image]
    if not atlas then atlas={}; frames[pic.image]=atlas end
    if atlas[pic.frame] then return atlas[pic.frame] end
    local g=love.graphics
    local canvas=g.newCanvas(pic.width,pic.height)
    g.push('all');g.setCanvas(canvas);g.origin();g.setShader();g.setScissor()
    g.setDepthMode();g.setBlendMode('alpha');g.clear(0,0,0,0);g.setColor(1,1,1,1)
    g.draw(pic.image,pic.quad,0,0);g.pop();canvas:setFilter('nearest','nearest')
    atlas[pic.frame]=canvas
    return canvas
  end
  require('src.render.Assets').register({release=function()
    for _,atlas in pairs(frames) do for _,image in pairs(atlas) do image:release() end end
    frames={}
  end})
end
return M
