-- Issue #54: Lavender/Fuchsia city turf has its own Battle Art/Legendary
-- switch instead of inheriting the broad GRASS setting.
-- ROM/GPU-free: luajit tests/city_ground_option_test.lua

local checks = 0
local function check(value, message)
  checks = checks + 1
  assert(value, message)
end
local function same(a, b)
  if #a ~= #b then return false end
  for i = 1, #a do
    if a[i] ~= b[i] then return false end
  end
  return true
end

package.loaded['src.render.Assets'] = { register = function() end }
package.loaded['src.core.Version'] = { engine = '0.2.53' }
package.loaded['src.core.Platform'] = { detect = function() return { os = 'Windows' } end }
package.loaded['src.render.TileRenderer'] = {
  animFrame = function() return 0 end,
  defaultAnimatedTiles = function() return nil end,
}
package.loaded['src.render.PaletteFX'] = {}

local Setting = {}
function Setting.new(key, label, values, labels, defaultIndex)
  return {
    key = key, label = label, values = values, labels = labels,
    value = values[defaultIndex or 1],
    get = function(self) return self.value end,
    row = function()
      return { step = function() return true end }
    end,
  }
end

local Community = assert(loadfile('lib/CommunityVisuals.lua'))({
  require = function(name)
    if name == 'ModSetting' then return Setting end
    return { invalidate = function() end }
  end,
})

check(Community.cityGround:get() == 'default', 'CITY GROUND defaults to Battle Art')
check(not Community.customCityGround(), 'Battle Art city ground is opt-out safe')
check(Community.cityGround.label == 'CITY GROUND'
    and Community.cityGround.values[1] == 'default'
    and Community.cityGround.values[2] == 'n64memory',
  'CITY GROUND uses the established Battle Art/Legendary value ladder')
check(Community.isCityGroundMap({ id = 'LAVENDER_TOWN', tileset = { id = 'OVERWORLD' } }),
  'Lavender is owned by CITY GROUND')
check(Community.isCityGroundMap({ id = 'FUCHSIA_CITY', tileset = { id = 'OVERWORLD' } }),
  'Fuchsia is owned by CITY GROUND')
check(not Community.isCityGroundMap({ id = 'PALLET_TOWN', tileset = { id = 'OVERWORLD' } }),
  'ordinary Overworld maps remain owned by GRASS')
check(not Community.isCityGroundMap({ id = 'FUCHSIA_CITY', tileset = { id = 'FOREST' } }),
  'map name cannot leak CITY GROUND into another tileset')

local analysis
local directionShade = { [1]=.84, [2]=.72, [3]=1, [4]=.55, [5]=.9, [6]=.68 }
local modules = {
  Structures = { forMap = function() return analysis end },
  TileShape = {},
  BuildBudget = { tick = function() end },
  LoadTimings = {
    wrap = function(_, fn) return fn end,
    resume = coroutine.resume,
    cancel = function() end,
    jobError = function() end,
  },
  VoxelMeshDisk = {},
  Voxel3D = {
    FACE_SHADE = directionShade,
    pushQuad = function(indices, n)
      for _, i in ipairs({1, 2, 3, 1, 3, 4}) do
        indices[#indices + 1] = n * 4 + i
      end
    end,
  },
  CommunityVisuals = Community,
}
-- The `modules` table is the deliberate fixture set. Anything else resolves
-- off disk: asserting on the table made this fail on Gen2CaveSurface, a
-- sibling ChunkMesher has needed for some time and the fixture never listed.
-- See tests/modload.lua.
local MODLOAD = assert(loadfile('tests/modload.lua'))()
local C = assert(loadfile('lib/ChunkMesher.lua'))({
  require = function(name)
    return modules[name] or MODLOAD.load(name)
  end,
})
modules.TowerGarden = assert(loadfile('lib/TowerGarden.lua'))({
  require = function() return Community end,
})

local function key(x, z) return (z + 64) * 4096 + x + 64 end
local function fixture(id, tile, claimed, tileY, mapHeight, towerLandscape,
                       tileX, mapWidth)
  tile = tile or 44
  tileX = tileX or 1
  tileY = tileY or 1
  mapWidth = mapWidth or 1
  mapHeight = mapHeight or 1
  analysis = {
    shapeAt = {}, tileAt = {}, runs = {}, skip = {}, ground = {}, doorFold = {},
    objectQuads = {}, roundStamps = {},
  }
  analysis.shapeAt[key(tileX, tileY)] = { h = 0, class = 'ground', art = 'top', flat = true }
  analysis.tileAt[key(tileX, tileY)] = tile
  if claimed then
    analysis.skip[key(tileX, tileY)] = true
    analysis.ground[key(tileX, tileY)] = towerLandscape and false or tile
  end
  if towerLandscape then
    analysis.lavenderFlowerbed = {
      minX = tileX, maxX = tileX, minY = tileY, maxY = tileY,
    }
  end
  return {
    id = id,
    def = { width = mapWidth, height = mapHeight },
    tileset = { id = 'OVERWORLD', tilesPerRow = 16, imageWidth = 128, imageHeight = 48 },
    tileAt = function(_, x, z) return analysis.tileAt[key(x, z)] or 90 end,
  }
end

local function signature(id, city, grass, tile, claimed, tileY, mapHeight,
                         roads, towerLandscape, tileX, mapWidth)
  Community.cityGround.value = city and 'n64memory' or 'default'
  Community.grass.value = grass and 'n64memory' or 'default'
  Community.roads.value = roads and 'n64memory' or 'default'
  local vertices = C.geometry(fixture(id, tile, claimed, tileY, mapHeight,
    towerLandscape, tileX, mapWidth), true)
  local out = {}
  for _, vertex in ipairs(vertices) do
    -- Geometry positions/topology must stay fixed; only UV/material shading is
    -- expected to change when a Legendary ground treatment owns this cell.
    out[#out + 1] = vertex[4]
    out[#out + 1] = vertex[5]
    out[#out + 1] = vertex[6]
  end
  return out, #vertices
end

local fuchsiaBattle, fuchsiaN = signature('FUCHSIA_CITY', false, false)
local fuchsiaGlobalGrass, fuchsiaGlobalN = signature('FUCHSIA_CITY', false, true)
local fuchsiaLegendary, fuchsiaLegendaryN = signature('FUCHSIA_CITY', true, false)
check(fuchsiaN == fuchsiaGlobalN and same(fuchsiaBattle, fuchsiaGlobalGrass),
  'Fuchsia Battle Art ground ignores the broad Legendary GRASS row')
check(fuchsiaLegendaryN == fuchsiaN and not same(fuchsiaBattle, fuchsiaLegendary),
  'Fuchsia CITY GROUND Legendary selects the tiled turf treatment')

local lavenderBattle, lavenderN = signature('LAVENDER_TOWN', false, false)
local lavenderGlobalGrass, lavenderGlobalN = signature('LAVENDER_TOWN', false, true)
local lavenderLegendary, lavenderLegendaryN = signature('LAVENDER_TOWN', true, false)
check(lavenderN == lavenderGlobalN and same(lavenderBattle, lavenderGlobalGrass),
  'Lavender Battle Art ground ignores the broad Legendary GRASS row')
check(lavenderLegendaryN == lavenderN and same(lavenderLegendary, lavenderBattle),
  'Lavender Battle Art snapshots the current Legendary lawn geometry exactly')

local palletBattle, palletN = signature('PALLET_TOWN', false, false)
local palletGrass, palletGrassN = signature('PALLET_TOWN', false, true)
check(palletN == palletGrassN and not same(palletBattle, palletGrass),
  'GRASS still controls ordinary Overworld turf outside the two city maps')
local connectorPath, connectorPathN = signature('ROUTE_8', false, false, 35,
  false, 1, 1, true)
local lavenderBattlePath35, lavenderBattlePath35N = signature('LAVENDER_TOWN', false, false, 35)
local lavenderBattlePath57, lavenderBattlePath57N = signature('LAVENDER_TOWN', false, false, 57)
-- Upstream 1.11.1 changes opt-in ROADS to cobblestones. CITY GROUND's
-- default Lavender path must retain its established material independently.
local legacyPath={.62484375,.66625,1.0257067482363,.56265625,.66625,1.0124705531807,
 .56265625,.50041666666667,1.0179000899942,.62484375,.50041666666667,1.0239400936435}
check(lavenderBattlePath35N==4 and #lavenderBattlePath35==#legacyPath,
 'Lavender default path retains its single flat quad')
for i,v in ipairs(legacyPath)do check(math.abs(lavenderBattlePath35[i]-v)<1e-10,
 'Lavender default path retains pre-merge UV/shading '..i)end
check(not same(lavenderBattlePath35,connectorPath),
 'opt-in route cobblestones do not replace the default Lavender material')
check(lavenderBattlePath57N == lavenderBattlePath35N
    and same(lavenderBattlePath57, lavenderBattlePath35),
  'Lavender source $23/$39 path cells resolve to one continuous path material')
check(lavenderN == lavenderBattlePath35N and not same(lavenderBattle, lavenderBattlePath35),
  'Lavender Battle Art keeps surrounding town ground visually distinct from its authored paths')

local lavenderLegendaryPath35, lavenderLegendaryPath35N = signature('LAVENDER_TOWN', true, false, 35)
local lavenderLegendaryPath57, lavenderLegendaryPath57N = signature('LAVENDER_TOWN', true, false, 57)
check(lavenderLegendaryN == lavenderN and same(lavenderLegendary, lavenderBattle)
    and same(lavenderLegendary, palletGrass),
  'Both Lavender CITY GROUND modes use the current shared natural turf geometry')
check(lavenderLegendaryPath57N == lavenderLegendaryN
    and same(lavenderLegendaryPath57, lavenderLegendary),
  'Legendary outer map margin keeps turf instead of interior plaza paving')
check(lavenderLegendaryPath35N == lavenderLegendaryN
    and not same(lavenderLegendaryPath35, lavenderLegendary),
  'Lavender Legendary paths stay visibly distinct from the surrounding ground')

local battleGround90, battleGround90N = signature('LAVENDER_TOWN', false, false, 90)
local legendaryGround90, legendaryGround90N = signature('LAVENDER_TOWN', true, false, 90)
check(battleGround90N == lavenderN and same(battleGround90, lavenderBattle),
  'alternate Lavender flat ground donors cannot become bald Battle Art slabs')
check(legendaryGround90N == lavenderLegendaryN and same(legendaryGround90, lavenderLegendary),
  'alternate Lavender flat ground donors cannot become bald Legendary slabs')

local claimedLavenderGround, claimedLavenderGroundN = signature('LAVENDER_TOWN', false, false, 90, true)
local claimedLavenderPath, claimedLavenderPathN = signature('LAVENDER_TOWN', false, false, 35, true)
local claimedLavenderLegendaryGround, claimedLavenderLegendaryGroundN = signature('LAVENDER_TOWN', true, false, 90, true)
local claimedLavenderLegendaryPath, claimedLavenderLegendaryPathN = signature('LAVENDER_TOWN', true, false, 35, true)
check(claimedLavenderGroundN == lavenderN and same(claimedLavenderGround, lavenderBattle)
    and claimedLavenderPathN == lavenderBattlePath35N
    and same(claimedLavenderPath, lavenderBattlePath35),
  'Lavender Battle Art synthesized floors preserve ground versus path membership')
check(claimedLavenderLegendaryGroundN == lavenderLegendaryN
    and same(claimedLavenderLegendaryGround, lavenderLegendary)
    and claimedLavenderLegendaryPathN == lavenderLegendaryPath35N
    and same(claimedLavenderLegendaryPath, lavenderLegendaryPath35),
  'Lavender Legendary synthesized floors preserve ground versus path membership')

-- The screenshot's bald square is the synthesized floor under Lavender's
-- Silph Scope sign at engine cell (9,3), i.e. source tiles tx18..19 / ty6..7.
-- It is a claimed non-path square, so Battle Art must now resolve it through
-- exactly the same plain grass treatment as current Legendary, while the
-- checker/path material remains separate beside it.
local signBattle, signBattleN = signature(
  'LAVENDER_TOWN', false, false, 48, true, 6, 9, false, false, 18, 10)
local signLegendary, signLegendaryN = signature(
  'LAVENDER_TOWN', true, false, 48, true, 6, 9, false, false, 18, 10)
local signGrass, signGrassN = signature(
  'PALLET_TOWN', false, true, 44, false, 6, 9, false, false, 18, 10)
local signPath, signPathN = signature(
  'LAVENDER_TOWN', false, false, 57, false, 6, 9, false, false, 18, 10)
check(signBattleN == signGrassN and same(signBattle, signGrass),
  'Battle Art retains the approved grass under the Lavender sign')
check(signLegendaryN > signBattleN and not same(signLegendary, signBattle),
  'Legendary claimed plaza floor receives the new slab geometry')
check(signPathN == signBattleN and not same(signPath, signBattle),
  'Lavender cell (9,3) grass remains distinct from the adjacent authored checker/path material')

local route10NorthGround, route10NorthGroundN = signature('ROUTE_10', false, false, 90, false, 99, 36)
local route10BattleApproach, route10BattleApproachN = signature('ROUTE_10', false, false, 90, false, 100, 36)
local route10BattleApproachPath, route10BattleApproachPathN = signature('ROUTE_10', false, false, 57, false, 100, 36)
check(route10NorthGroundN == route10BattleApproachN
    and not same(route10NorthGround, route10BattleApproach),
  'Battle Art starts the cave-to-Lavender sand field at Route 10 block row 25')
check(route10BattleApproachN == route10BattleApproachPathN
    and same(route10BattleApproach, route10BattleApproachPath),
  'Battle Art Route 10 approach replaces alternate flat donors with the same sandy material')
local route10LegendaryApproach, route10LegendaryApproachN = signature('ROUTE_10', false, true, 90, false, 100, 36)
local route10LegendaryGrass, route10LegendaryGrassN = signature('ROUTE_10', false, true, 44, false, 100, 36)
check(route10LegendaryApproachN == route10LegendaryGrassN
    and same(route10LegendaryApproach, route10LegendaryGrass)
    and not same(route10LegendaryApproach, route10BattleApproach),
  'Legendary GRASS makes every Route 10 approach ground donor the same bright lawn')
local route10CityToggle, route10CityToggleN = signature('ROUTE_10', true, false, 90, false, 100, 36)
check(route10CityToggleN == route10BattleApproachN
    and same(route10CityToggle, route10BattleApproach),
  'Route 10 approach remains independent of the CITY GROUND setting')

-- Route 10's bottom block (block x4/y35, tiles x16..19/y140..143) is the
-- exact Lavender north-exit apron seen as the isolated bald square in-engine.
-- Its source is all $39 path art, but both visual modes intentionally render
-- this one seam block as the same plain grass donor used by Lavender's lawn.
local route10ExitBattle, route10ExitBattleN = signature(
  'ROUTE_10', false, false, 57, false, 140, 36, false, false, 16, 10)
local route10ExitLegendary, route10ExitLegendaryN = signature(
  'ROUTE_10', false, true, 57, false, 140, 36, false, false, 16, 10)
local route10ExitGrass, route10ExitGrassN = signature(
  'PALLET_TOWN', false, true, 44, false, 140, 36, false, false, 16, 10)
local route10ExitWestPath, route10ExitWestPathN = signature(
  'ROUTE_10', false, false, 57, false, 140, 36, false, false, 15, 10)
check(route10ExitBattleN == route10ExitLegendaryN
    and route10ExitBattleN == route10ExitGrassN
    and same(route10ExitBattle, route10ExitLegendary)
    and same(route10ExitBattle, route10ExitGrass),
  'Route 10 Lavender exit block is plain grass in both visual modes')
check(route10ExitWestPathN == route10ExitBattleN
    and not same(route10ExitWestPath, route10ExitBattle),
  'Route 10 exit-lawn override is limited to the authored 4x4 seam block')

local route10BattleTowerLawn, route10BattleTowerLawnN = signature(
  'ROUTE_10', false, false, 90, true, 132, 36, false, true)
local route10LegendaryTowerLawn, route10LegendaryTowerLawnN = signature(
  'ROUTE_10', false, true, 90, true, 132, 36, false, true)
local route10ReferenceLawn, route10ReferenceLawnN = signature(
  'ROUTE_10', false, true, 44, false, 132, 36)
check(route10BattleTowerLawnN == route10ReferenceLawnN
    and route10LegendaryTowerLawnN == route10ReferenceLawnN
    and same(route10BattleTowerLawn, route10LegendaryTowerLawn)
    and same(route10BattleTowerLawn, route10ReferenceLawn),
  'Pokemon Tower landscaping fills donorless claimed cells with the same Route 10 grass in both modes')

local Disk = assert(loadfile('lib/VoxelMeshDisk.lua'))({
  require = function(name)
    if name == 'CommunityVisuals' then return Community end
    if name=='ForestTrees' or name=='CinnabarCoast' or name=='VermilionHarbor' or name=='CityStreets' then return {enabled=function()return false end,themes={}}end
    if name == 'StaticGeometry' then return { source = function(map) return map end } end
    if name == 'LoadTimings' then return { wrap = function(_, fn) return fn end } end
    return {}
  end,
})
local function cacheMap(id)
  return {
    id = id,
    def = { tileset = 'OVERWORLD', width = 1, height = 1, blocks = {} },
    tileset = {
      id = 'OVERWORLD', image = 'overworld.png', imageWidth = 128,
      imageHeight = 48, tilesPerRow = 16, blocks = {},
    },
  }
end
local function fingerprint(id, city, grass)
  Community.cityGround.value = city and 'n64memory' or 'default'
  Community.grass.value = grass and 'n64memory' or 'default'
  return Disk.fingerprint(cacheMap(id), 'body', nil, 'terrain')
end
local fuchsiaCache = fingerprint('FUCHSIA_CITY', false, false)
check(fuchsiaCache == fingerprint('FUCHSIA_CITY', false, true),
  'Fuchsia cache identity ignores unrelated GRASS changes')
check(fuchsiaCache ~= fingerprint('FUCHSIA_CITY', true, false),
  'Fuchsia CITY GROUND choice owns its persistent mesh identity')
local lavenderCache = fingerprint('LAVENDER_TOWN', false, false)
check(lavenderCache == fingerprint('LAVENDER_TOWN', false, true),
  'Lavender cache identity ignores unrelated GRASS changes')
check(lavenderCache ~= fingerprint('LAVENDER_TOWN', true, false),
  'Lavender CITY GROUND modes have distinct persistent mesh identities')
Community.cityGround.value = 'default'
Community.grass.value = 'default'
Community.tower.value = 'default'
local lavenderBattleTower = Disk.fingerprint(cacheMap('LAVENDER_TOWN'), 'body', nil, 'terrain')
Community.tower.value = 'n64memory'
local lavenderLegendaryTower = Disk.fingerprint(cacheMap('LAVENDER_TOWN'), 'body', nil, 'terrain')
check(lavenderBattleTower ~= lavenderLegendaryTower,
  'Lavender Battle Art and Legendary Tower body geometry keep distinct fingerprints')
check(Disk.variantId(lavenderBattleTower) ~= Disk.variantId(lavenderLegendaryTower),
  'Lavender Battle Art and Legendary Tower resolve to distinct FORMAT 3 variant paths')
Community.tower.value = 'default'
check(lavenderCache:find('lavender-battle-parity-v5', 1, true) ~= nil,
  'Lavender body cache invalidates the pre-parity sandy Battle Art mesh')
local route10Cache = fingerprint('ROUTE_10', false, false)
check(route10Cache ~= fingerprint('ROUTE_10', true, false),
  'Route 10 garden geometry now keys on CITY GROUND')
check(route10Cache ~= fingerprint('ROUTE_10', false, true),
  'Route 10 interior terrain remains a global GRASS cache dependency')
check(route10Cache:find('route10-lavender-approach-v3-exit-lawn', 1, true) ~= nil,
  'Route 10 body cache fingerprints the Lavender exit-lawn seam override')
local route10Aux = Disk.fingerprint(cacheMap('ROUTE_10'), 'aux', nil, 'aux')
check(route10Aux:find('route10-tower-flowerbed-v2-baseline', 1, true) ~= nil,
  'Route 10 auxiliary cache fingerprints the baseline Tower flowerbed geometry')
local palletCache = fingerprint('PALLET_TOWN', false, false)
check(palletCache == fingerprint('PALLET_TOWN', true, false),
  'CITY GROUND does not invalidate unrelated Overworld maps')
check(palletCache ~= fingerprint('PALLET_TOWN', false, true),
  'ordinary Overworld caches still follow GRASS')

-- The static community atlas and the immutable animated atlas have separate
-- caches. Both must be map-scoped for the two cities or visit order can make
-- Lavender reuse Fuchsia's baked turf (or vice versa) while water animates.
local TerrainAtlas = assert(loadfile('lib/TerrainAtlas.lua'))({
  require = function(name)
    if name == 'CommunityVisuals' then return Community end
    if name=='ForestTrees' or name=='CinnabarCoast' or name=='VermilionHarbor' or name=='CityStreets' then return {enabled=function()return false end,themes={}}end
    if name == 'TowerGarden' then return modules.TowerGarden end
    return {}
  end,
})
local function replaceUpvalue(fn, wanted, replacement)
  for i = 1, 100 do
    local name = debug.getupvalue(fn, i)
    if not name then break end
    if name == wanted then
      debug.setupvalue(fn, i, replacement)
      return
    end
  end
  error('missing TerrainAtlas test seam: ' .. wanted)
end
local built = 0
replaceUpvalue(TerrainAtlas.animate, 'newEntry', function(map)
  built = built + 1
  local image = { id = map.id, release = function() end }
  return {
    specs = { { kind = 'frames', sequence = { 1 }, period = 20 } },
    frames = { ['0'] = image },
  }
end)
local function animatedMap(id)
  return {
    id = id,
    renderer = {},
    tileset = { id = 'OVERWORLD', image = 'overworld.png' },
  }
end
Community.cityGround.value = 'default'
Community.grass.value = 'default'
local fuchsiaAnimated = TerrainAtlas.animate(animatedMap('FUCHSIA_CITY'), nil, {}, false)
local lavenderAnimated = TerrainAtlas.animate(animatedMap('LAVENDER_TOWN'), nil, {}, false)
check(fuchsiaAnimated and fuchsiaAnimated.id == 'FUCHSIA_CITY'
    and lavenderAnimated and lavenderAnimated.id == 'LAVENDER_TOWN'
    and built == 2,
  'animated city atlases stay isolated regardless of shared OVERWORLD source')
check(TerrainAtlas.animate(animatedMap('FUCHSIA_CITY'), nil, {}, false) == fuchsiaAnimated
    and built == 2,
  'revisiting a city reuses only its own animated atlas')
Community.cityGround.value = 'n64memory'
local lavenderLegendaryAnimated = TerrainAtlas.animate(animatedMap('LAVENDER_TOWN'), nil, {}, false)
check(lavenderLegendaryAnimated and lavenderLegendaryAnimated ~= lavenderAnimated
    and built == 3,
  'Lavender Battle Art and Legendary modes cannot reuse the same animated atlas')
Community.cityGround.value = 'default'
local routeAnimated = TerrainAtlas.animate(animatedMap('ROUTE_1'), nil, {}, false)
local routeShared = TerrainAtlas.animate(animatedMap('ROUTE_2'), nil, {}, false)
check(routeAnimated == routeShared and built == 4,
  'ordinary OVERWORLD maps retain the bounded shared animated cache')
-- Exercise actual atlas pixels: geometry signatures alone missed the default
-- road donor retaining Lavender's green source palette when ROADS was off.
local function upvalue(fn, wanted)
  for i = 1, 100 do
    local name, value = debug.getupvalue(fn, i)
    if not name then break end
    if name == wanted then return value end
  end
  error('missing atlas seam: ' .. wanted)
end
local function pixels()
  local p = { values = {} }
  function p:getDimensions() return 128, 48 end
  function p:getPixel(x, y)
    return unpack(self.values[y * 128 + x] or {.1, .8, .1, 1})
  end
  function p:setPixel(x, y, ...) self.values[y * 128 + x] = {...} end
  function p:paste(src)
    for y = 0, 47 do for x = 0, 127 do
      self:setPixel(x, y, src:getPixel(x, y))
    end end
  end
  return p
end
love = {
  image = { newImageData = pixels },
  graphics = { newImage = function(data)
    return { data = data, setFilter = function() end, release = function() end }
  end },
}
local atlas = upvalue(TerrainAtlas.forMap, 'communityAtlas')
local function material(id, city, grass)
  Community.cityGround.value = city and 'n64memory' or 'default'
  Community.grass.value = grass and 'n64memory' or 'default'
  Community.roads.value = 'default'
  local _, data = atlas(cacheMap(id), {}, {}, pixels())
  return data
end
local lavenderBattleAtlas = material('LAVENDER_TOWN', false, false)
local lavenderLegendaryAtlas = material('LAVENDER_TOWN', true, false)
local br, bg, bb = lavenderBattleAtlas:getPixel(9 * 8, 3 * 8) -- $39 path donor
local lrPath, lgPath, lbPath = lavenderLegendaryAtlas:getPixel(9 * 8, 3 * 8)
check(br ~= lrPath or bg ~= lgPath or bb ~= lbPath,
  'Legendary lawn donor stays separate from Battle Art Lavender path')
local pbr, pbg, pbb = lavenderBattleAtlas:getPixel(3 * 8, 2 * 8)
local plr, plg, plb = lavenderLegendaryAtlas:getPixel(3 * 8, 2 * 8)
check(br == pbr and bg == pbg and bb == pbb
    and pbr == plr and pbg == plg and pbb == plb,
  'Battle Art retains its path palette and Legendary retains the authored path donor')
local rr, rg, rb = lavenderBattleAtlas:getPixel(8, 0)
check(rr == .1 and rg == .8 and rb == .1, 'Lavender material paint leaves unrelated roof pixels intact')
local routeGrass = material('ROUTE_10', false, true)
local ordinaryGrass = material('ROUTE_1', false, true)
local _, bright = routeGrass:getPixel(12 * 8, 2 * 8)
local _, ordinary = ordinaryGrass:getPixel(12 * 8, 2 * 8)
check(bright > ordinary, 'Route 10 grass is visibly brighter without changing other routes')
local lr, lg, lb = lavenderLegendaryAtlas:getPixel(12 * 8, 2 * 8)
local brg, bgg, bbg = lavenderBattleAtlas:getPixel(12 * 8, 2 * 8)
local rr10, rg10, rb10 = routeGrass:getPixel(12 * 8, 2 * 8)
check(brg == rr10 and bgg == rg10 and bbg == rb10,
  'Battle Art Lavender retains the bright-green Route 10 palette')
check(lr ~= brg or lg ~= bgg or lb ~= bbg,
  'Legendary Lavender uses its separate lawn palette')
check(routeGrass ~= ordinaryGrass, 'Route 10 static atlas cannot leak its palette into ordinary routes')
local route10Animated = TerrainAtlas.animate(animatedMap('ROUTE_10'), nil, {}, false)
check(route10Animated ~= routeShared, 'Route 10 animated atlas is isolated from other routes')
print(checks .. ' checks passed (city ground option)')
