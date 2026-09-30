-- Object census: every distinct OBJECT TYPE a game places, with how many
-- instances and on how many maps.
--
--   env CENSUS_OUT   output TSV (required)
--
-- WHY THIS IS SEPARATE FROM drawing-census.lua
--
-- Authoring scales by distinct OBJECT TYPE, not by instance and not by tile
-- drawing. A Pokemon Center's counter is one model used on three floors of
-- three games; the tileset it sits on is hundreds of drawings. The drawing
-- census answers "is this tile drawn correctly", which is a rendering question.
-- This one answers "how many things do I actually have to model", which is the
-- authoring question, and it is the number that makes the work plannable.
--
-- Per generation:
--   gen 3  def.objects[] -> { kind, graphicsId, sprite, movement, ... }
--   gen 1  def.objects[] -> { name, movement, x, y, ... }   name is the script
--   gen 2  def.objects[] -> { name / label, ... }
--
-- The key is deliberately cart-local: graphicsId is a ROM object id, so the same
-- table cannot be shared between FRLG and Emerald.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local V = game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
  local okGV, GameVersion = pcall(require, "src.core.GameVersion")
  local version = okGV and GameVersion.get() or "?"
  local okGen, Generation = pcall(function() return V.require("Generation") end)
  local gen = Generation.number()

  if game.phase == "boot" then
    for _ = 1, 6000 do
      if game.phase ~= "boot" then break end
      local b = game.boot
      pcall(function() U.tap(game, (b and b.introMovie) and "start" or "a") end)
      U.wait(1)
    end
  end

  local store, tilesets
  if gen == 2 then
    store = game.world and game.world.maps
    tilesets = game.world and game.world.tilesets
  else
    store = game.data and game.data.maps
    tilesets = game.data and game.data.tilesets
  end
  if type(store) ~= "table" then
    print("[oc] no map store for gen " .. tostring(gen))
    return
  end

  -- key -> { instances = n, maps = {id=true}, sprites = {} }
  local kinds, mapCount, instanceTotal = {}, 0, 0

  for id, def in pairs(store) do
    mapCount = mapCount + 1
    local objs = def and def.objects
    if type(objs) == "table" then
      for _, o in ipairs(objs) do
        if type(o) == "table" then
          -- Gen 3 identifies an object by graphicsId (the ROM object graphic).
          -- Gen 1 identifies it by SCRIPT name, and those embed the map
          -- ("AGATHASROOM_AGATHA"), so every instance looks unique and the
          -- count came out as one type per object -- 916 for Red, which is the
          -- object count, not the type count. Gen 1's sprite name is the stable
          -- type key.
          local key
          if gen == 1 then
            key = o.sprite or o.name
          else
            key = o.graphicsId or o.name or o.kind or o.sprite
          end
          local kindLabel = tostring(o.kind or "?")
          local spriteLabel = tostring(o.sprite or "?")
          if key ~= nil then
            local k = tostring(key)
            local rec = kinds[k]
            if not rec then rec = { instances = 0, maps = {}, kinds = {} }; kinds[k] = rec end
            rec.instances = rec.instances + 1
            rec.maps[id] = true
            rec.kinds[kindLabel] = true
            rec.kinds["sprite=" .. spriteLabel] = true
            instanceTotal = instanceTotal + 1
          end
        end
      end
    end
  end

  local out = assert(os.getenv("CENSUS_OUT"))
    or ("object-census-" .. tostring(version) .. ".tsv")
  local f = assert(io.open(out, "w"))
  local distinct = 0
  for _ in pairs(kinds) do distinct = distinct + 1 end
  f:write("# version\t", tostring(version), "\tgen\t", tostring(gen),
          "\tmaps\t", tostring(mapCount),
          "\tobject_instances\t", tostring(instanceTotal),
          "\tdistinct_object_types\t", tostring(distinct), "\n")
  f:write("object\tmap_count\tinstance_count\tkinds\tmaps\n")

  local keys = {}
  for k in pairs(kinds) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    local na, nb = 0, 0
    for _ in pairs(kinds[a].maps) do na = na + 1 end
    for _ in pairs(kinds[b].maps) do nb = nb + 1 end
    if na ~= nb then return na > nb end
    return a < b
  end)
  for _, k in ipairs(keys) do
    local r = kinds[k]
    local mc = 0
    for _ in pairs(r.maps) do mc = mc + 1 end
    local ks = {}
    for kk in pairs(r.kinds) do ks[#ks + 1] = kk end
    table.sort(ks)
    f:write(k, "\t", mc, "\t", r.instances, "\t", table.concat(ks, "|"), "\t", "", "\n")
  end
  f:close()
  print(("[oc] %s gen=%d maps=%d objects=%d distinct_types=%d -> %s")
    :format(tostring(version), gen, mapCount, instanceTotal, distinct, out))
  return
end