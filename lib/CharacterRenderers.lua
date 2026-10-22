-- Sandbox-safe character renderer bridge.
--
-- Gen1Recomp 0.2.53 gives every mod a private _G and no debug upvalue API.
-- Character mods therefore register callbacks through this exported surface
-- instead of reaching into VoxelScene or exchanging process globals.

local V = ...

local CharacterRenderers = {
  API_VERSION = 1,
  entries = {},
  byId = {},
  serial = 0,
  generation = 0,
  battle = { active = false, state = nil, handWorld = nil },
}

local CALLBACKS = {
  drawEntity = true,
  drawReflection = true,
  drawShadow = true,
  suppressGhost = true,
  afterActors = true,
  drawBattleTrainer = true,
  drawBattleTrainerShadow = true,
}

-- A missing declaration identifies a legacy 3D provider, never an HD2D or
-- native-voxel implementation. Providers may advertise a style list/set, or
-- separate lists under supportedStyles.characters / supportedStyles.pokemon.
local styleNames = { modern=true, voxel=true, hd2d=true }
local function styleSet(raw)
  if type(raw) ~= 'table' then return nil end
  local out = {}
  for key, value in pairs(raw) do
    if type(key)=='number' and key%1==0 and key>=1 and styleNames[value] then out[value]=true
    elseif styleNames[key] and type(value)=='boolean' then out[key]=value
    else return nil end
  end
  return out
end
local function providerStyles(raw)
  if raw==nil then return {characters={modern=true},pokemon={modern=true}} end
  if type(raw)~='table' then return nil end
  if raw.characters~=nil or raw.pokemon~=nil then
    for key in pairs(raw)do if key~='characters'and key~='pokemon'then return nil end end
    local characters=styleSet(raw.characters or {})
    local pokemon=styleSet(raw.pokemon or {})
    if characters and pokemon then return {characters=characters,pokemon=pokemon}end
  else
    local styles=styleSet(raw)
    if styles then return {characters=styles,pokemon=styles}end
  end
end

local creatureIcons={SPRITE_MONSTER=true,SPRITE_FAIRY=true,SPRITE_BIRD=true,
 SPRITE_PIKACHU=true,SPRITE_SEEL=true,SPRITE_SLOWBRO=true,SPRITE_CHANSEY=true,
 SPRITE_LAPRAS=true,SPRITE_SNORLAX=true,SPRITE_OMANYTE=true,SPRITE_KABUTO=true,
 SPRITE_AERODACTYL=true}
function CharacterRenderers.category(context,method)
  if method and method:match('^drawBattleTrainer')then return 'characters'end
  context=context or {}
  if context.isPlayer or context.role=='player'then return 'characters'end
  local category=context.visualCategory or context.category
  if category=='pokemon'or category=='characters'then return category end
  if context.isPokemon or context.role=='pokemon'or context.role=='companion'then return 'pokemon'end
  local entity=context.entity or context.actor or context.pose and context.pose.entity
  local def=entity and(entity.def or entity.spriteDef)or context.sprite and context.sprite.def
  if entity and(entity.isPokemon or entity.pikachuFollower or entity.pokemon)
   or def and(def.isPokemon or def.species or def.category=='pokemon')then return 'pokemon'end
  local id=context.spriteId or def and(def.sprite or def.id)
  if creatureIcons[id]then return 'pokemon'end
  local species=type(id)=='string'and id:match('^SPRITE_(.+)$')
  local state=context.state
  local data=state and(state.data or state.game and state.game.data)
  if species and data and data.pokemon and data.pokemon[species]then return 'pokemon'end
  return 'characters'
end
local function styleSupports(entry,method,context)
  local category=CharacterRenderers.category(context,method)
  local style=V.require('VisualStyles').get(category)
  return entry.styles[category][style]==true
end

local function logError(entry, method, err)
  entry.failed = entry.failed or {}
  if entry.failed[method] then return end
  entry.failed[method] = true
  local log = V.mod and V.mod.log
  if log and log.error then
    log:error("character renderer %s %s failed: %s", entry.id, method,
              tostring(err))
  end
end

local function sortEntries()
  table.sort(CharacterRenderers.entries, function(a, b)
    if a.priority ~= b.priority then return a.priority > b.priority end
    return a.serial < b.serial
  end)
end

local function remove(entry)
  if not entry or entry.removed then return false end
  entry.removed = true
  CharacterRenderers.byId[entry.id] = nil
  for i, candidate in ipairs(CharacterRenderers.entries) do
    if candidate == entry then
      table.remove(CharacterRenderers.entries, i)
      break
    end
  end
  CharacterRenderers.generation = CharacterRenderers.generation + 1
  local ok, ShadowMap = pcall(V.require, "ShadowMap")
  if ok and ShadowMap and ShadowMap.invalidate then pcall(ShadowMap.invalidate) end
  return true
end

function CharacterRenderers.register(spec)
  if type(spec) ~= "table" then return nil, "renderer spec must be a table" end
  if spec.apiVersion ~= nil
      and tonumber(spec.apiVersion) ~= CharacterRenderers.API_VERSION then
    return nil, "unsupported character renderer API version"
  end
  local id = tostring(spec.id or "")
  if id == "" or #id > 128 then return nil, "renderer id is required" end
  if CharacterRenderers.byId[id] then
    return nil, ("character renderer %s is already registered"):format(id)
  end
  local hasCallback = false
  for name in pairs(CALLBACKS) do
    if type(spec[name]) == "function" then hasCallback = true end
  end
  if not hasCallback then return nil, "renderer has no supported callbacks" end

  local styles = providerStyles(spec.supportedStyles)
  if not styles then return nil, "supportedStyles must declare modern, voxel or hd2d" end

  CharacterRenderers.serial = CharacterRenderers.serial + 1
  local entry = {
    id = id,
    name = tostring(spec.name or id),
    priority = tonumber(spec.priority) or 0,
    serial = CharacterRenderers.serial,
    spec = spec,
    styles = styles,
    failed = {},
  }
  CharacterRenderers.byId[id] = entry
  CharacterRenderers.entries[#CharacterRenderers.entries + 1] = entry
  sortEntries()
  CharacterRenderers.generation = CharacterRenderers.generation + 1

  local handle = {}
  function handle:release() return remove(entry) end
  function handle:status()
    return { id = entry.id, active = not entry.removed, failed = entry.failed }
  end
  return handle
end

-- Consumers normally register during their own entry chunk. A launcher-side
-- reload can nevertheless publish the consumer only after Battle Art's first
-- registration attempt. Recover from that harmless ordering window by also
-- discovering the renderer specs the two companion mods export. This lookup
-- is data/API-only: Battle Art never reads either mod's files.
local DISCOVERY_IDS = {
  "gen1_true_3d_characters",
  "red_3d_player",
}

local discovering = false
local function discoverExports()
  if discovering or not (V.mod and type(V.mod.find) == "function") then return end
  discovering = true
  for _, modId in ipairs(DISCOVERY_IDS) do
    local okFind, other = pcall(V.mod.find, modId)
    local exports = okFind and other and other.exports or nil
    local spec = exports and exports.characterRenderer or nil
    local id = type(spec) == "table" and tostring(spec.id or "") or ""
    if id ~= "" and not CharacterRenderers.byId[id] then
      local handle, err = CharacterRenderers.register(spec)
      if handle then
        local log = V.mod.log
        if log and log.info then
          log:info("discovered character renderer %s from %s", id, modId)
        end
      elseif err then
        local log = V.mod.log
        if log and log.warn then
          log:warn("character renderer discovery from %s failed: %s",
                   modId, tostring(err))
        end
      end
    end
  end
  discovering = false
end

-- Existing providers predate native Gen2/3 battle state. They remain Gen1-only
-- for battle callbacks unless they explicitly advertise supported generations.
local function supports(entry,method,generation)
  if not generation or generation==1 or not method:match('^drawBattleTrainer') then return true end
  local supported=entry.spec.battleGenerations
  if type(supported)~='table' then return false end
  for _,gen in ipairs(supported)do if gen==generation then return true end end
  return false
end

function CharacterRenderers.has(method,generation,context)
  discoverExports()
  if not CALLBACKS[method] then return false end
  for _, entry in ipairs(CharacterRenderers.entries) do
    if not entry.removed and supports(entry,method,generation) and styleSupports(entry,method,context) and type(entry.spec[method]) == "function" then
      return true
    end
  end
  return false
end

-- First callback returning exactly true owns this object/pass.
function CharacterRenderers.first(method, context)
  -- Own live item rendering here as well as in VoxelScene: companion mods
  -- can rebuild the scene loops while preserving this public renderer bridge.
  if method=='drawEntity' or method=='drawReflection' or method=='drawShadow' then
    local Items=V.require('ItemPokeballs')
    if Items.accepts(context) then
      return Items.draw(context,method=='drawShadow' and V.require('ShadowMap') or nil)
    end
  end
  discoverExports()
  if not CALLBACKS[method] then return false end
  for _, entry in ipairs(CharacterRenderers.entries) do
    local fn = not entry.removed and supports(entry,method,context and context.generation or (method:match('^drawBattleTrainer') and CharacterRenderers.battle.generation)) and styleSupports(entry,method,context) and entry.spec[method] or nil
    if type(fn) == "function" then
      local ok, claimed = pcall(fn, context)
      if not ok then logError(entry, method, claimed)
      elseif claimed == true then return true end
    end
  end
  return false
end

function CharacterRenderers.all(method, context)
  discoverExports()
  if not CALLBACKS[method] then return end
  for _, entry in ipairs(CharacterRenderers.entries) do
    local fn = not entry.removed and supports(entry,method,context and context.generation) and styleSupports(entry,method,context) and entry.spec[method] or nil
    if type(fn) == "function" then
      local ok, err = pcall(fn, context)
      if not ok then logError(entry, method, err) end
    end
  end
end

local lastStyleRevision
function CharacterRenderers.revision()
  discoverExports()
  local styles=V.require('VisualStyles')
  local revision=tostring(styles.get('characters'))..':'..tostring(styles.get('pokemon'))
  if lastStyleRevision and revision~=lastStyleRevision then
    CharacterRenderers.generation=CharacterRenderers.generation+1
  end
  lastStyleRevision=revision
  return CharacterRenderers.generation
end

function CharacterRenderers.setBattle(active, state, generation)
  CharacterRenderers.battle.generation = active and (generation or 1) or nil
  CharacterRenderers.battle.active = active and true or false
  CharacterRenderers.battle.state = active and state or nil
  if not active then CharacterRenderers.battle.handWorld = nil end
end

function CharacterRenderers.battleActive()
  return CharacterRenderers.battle.active
    and CharacterRenderers.has("drawBattleTrainer",CharacterRenderers.battle.generation)
end

function CharacterRenderers.battleState()
  return CharacterRenderers.battle.state
end

function CharacterRenderers.setBattleHand(value)
  if type(value) == "table" then
    CharacterRenderers.battle.handWorld = {
      tonumber(value[1]) or 0,
      tonumber(value[2]) or 0,
      tonumber(value[3]) or 0,
    }
  else
    CharacterRenderers.battle.handWorld = nil
  end
end

function CharacterRenderers.battleHandWorld()
  return CharacterRenderers.battleActive() and CharacterRenderers.battle.handWorld or nil
end

function CharacterRenderers.export()
  return {
    apiVersion = CharacterRenderers.API_VERSION,
    source = "BATTLE_ART_VOXEL_FORK",
    visualStyles = { "modern", "voxel", "hd2d" },
    visualStyleCategories = { "characters", "pokemon" },
    register = function(spec) return CharacterRenderers.register(spec) end,
    refresh = function() discoverExports(); return CharacterRenderers.generation end,
  }
end

return CharacterRenderers
