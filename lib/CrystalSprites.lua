-- Integrated Crystal presentation. One sprite owner is selected at boot;
-- the Crystal runtime also owns menus, evolution and trainer presentation.
local V = ...
local Setting = V.require('ModSetting')
local M = {}
M.setting = Setting.new('spritePack', 'SPRITE PACK (RESTART)',
  {'crystal', 'selected'}, {'CRYSTAL', 'SELECTED ART'})
M.fullBody = Setting.new('full_body_backs', 'FULL-BODY BATTLE BACKS',
  {false, true}, {'OFF', 'ON'}, 2)

function M.schemas()
  return {
    {key='crystalFront',label='CRYSTAL PLAYER FRONT',type='toggle',default=false},
    {key='crystalTrainers',label='CRYSTAL CUSTOM SPRITES',type='choice',default='both',
      choices={{'NONE','none'},{'PLAYER','player'},{'TRAINER','trainers'},
        {'PLAYER + TRAINER','both'},{'OVERWORLD','overworld'},{'ALL','all'}}},
    {key='crystalPlayerSprite',label='CRYSTAL PLAYER PORTRAIT',type='choice',
      default=V.require('Generation').isGen2() and 'gold_flip.png' or 'red.png',
      choices={{'DEFAULT','default'},{'BLUE','blue_flip.png'},{'GOLD','gold_flip.png'},
        {'JAMES','james.png'},{'JESSIE','jessie.png'},{'KRIS','kris_flip.png'},
        {'LEAF','leaf.png'},{'RED','red.png'},{'SILVER','silver_flip.png'}}},
    {key='crystalBattlePic',label='CRYSTAL TRAINER VIEW',type='choice',default='front',
      choices={{'FRONT','front'},{'BACK','back'}}},
    {key='crystalAnimations',label='CRYSTAL ANIMATIONS',type='choice',default='loop',
      choices={{'LOOP','loop'},{'PLAY ONCE','once'}}},
  }
end

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

  -- Both the legacy Crystal submenu and the mod manager write the same
  -- options. Import old save preferences only when no new value is stored.
  local currentGame
  local apply = exports.applyOption
  local keys = {}
  for _,row in ipairs(M.schemas()) do keys[row.key]=true end
  local function store(game,key,value)
    if not game then return end
    local save=game.save and game.save.options
    if save then
      save[key]=value
      save.modOptions=save.modOptions or {}
      save.modOptions[V.mod.id]=save.modOptions[V.mod.id] or {}
      save.modOptions[V.mod.id][key]=value
    end
    if game.mods then
      local buckets=game.mods.modOptions
      buckets[V.mod.id]=buckets[V.mod.id] or {}
      buckets[V.mod.id][key]=value
    end
  end
  exports.applyOption=function(key,value)
    if keys[key] then store(currentGame,key,value) end
    return apply(key,value)
  end
  local function sync(event)
    currentGame=(event and event.game) or currentGame
    local game=currentGame
    if not game then return end
    local save=(event and event.save) or game.save
    local old=save and save.options or {}
    local bucket=game.mods.modOptions[V.mod.id] or {}
    for _,row in ipairs(M.schemas()) do
      local value=bucket[row.key]
      if value==nil then value=old[row.key] end
      if value==nil then value=row.default end
      store(game,row.key,value);apply(row.key,value)
    end
  end
  for _,event in ipairs({'game.ready','save.loaded','save.created'}) do
    V.mod.events:on(event,sync)
  end
  V.mod.events:on('mod.options_changed',function(event)
    if event and event.mod==V.mod.id and keys[event.key] then
      exports.applyOption(event.key,event.value)
    end
  end)

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
