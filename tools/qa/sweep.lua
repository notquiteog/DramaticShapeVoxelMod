-- FULL coverage sweep: every imported map, first-person AND third-person.
--
-- The audit so far sampled ~40 scenes out of 814, which is not coverage. This
-- walks every map the game knows about, stands on walkable cells spread across
-- it, and captures both camera modes at each -- the two the renderer actually
-- has, so "looks right in first and third person" is something a reviewer can
-- answer from the output rather than something the sweep asserts.
--
-- It is resumable: SHARD/NSHARDS split the work, and a map that already has its
-- three captures is skipped. Every capture is written to its own file and
-- indexed in sweep-index.txt, so a crash costs one map, not the run.
--
-- Env:
--   QA_SHARD / QA_NSHARDS   process maps i where i % N == shard
--   QA_MAX_MAPS             stop after N maps (smoke test)
--   QA_CELL_MODE            walkable (default) | census
local viewLock
return function(game)
  assert(love.filesystem.getIdentity():match('%-qa$'), 'refusing non-QA profile')
  local U = dofile('tests/drivers/util.lua')
  local dir = assert(os.getenv('SHOT_DIR'))
  local V = assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
  local gen = V.require('Generation').number()
  local Zoom = require('src.render.Zoom')
  -- The driver's util has no fileExists, and love's is sandboxed away inside a
  -- mod, so read the directory once and use that for resume.
  local have = {}
  do
    local names = love.filesystem.getDirectoryItems and love.filesystem.getDirectoryItems(dir)
    for _, n in ipairs(names or {}) do have[n] = true end
  end
  local function exists(n) return have[n] == true end

  love.window.setMode(1280, 720)
  local update = game.update
  -- Installed only AFTER boot. Wrapping game.update to zero input and re-apply
  -- the view lock is what the sweep needs, but doing it during boot kept the
  -- Gen 3 opening from ever advancing: Boot.update stopped being reached, the
  -- movie stayed in phase "intro" for 9000 frames, and forcing isDone changed
  -- nothing because nothing was reading it. Running boot on the engine's own
  -- update path lets the opening finish normally; the wrapper goes on after.
  local function installWrapper()
    game.update = function(self, dt)
      -- The sweep pins yaw/pitch for a stable framing. The mod's own first/third
      -- person rigs rewrite them every frame from the held input, which this
      -- driver zeroes -- so without re-applying the lock here the camera drifts
      -- back to its default heading within a few frames and an unknown share of
      -- the "3p" captures were not the 3p view at all.
      self.input:reset()
      if viewLock then viewLock() end
      return require('src.mods.Runtime').call('core.update', update, self, dt)
    end
  end

  -- Reach the overworld before capturing anything.
  --
  -- Gen 3 boots into an opening movie whose sub-state counter parks at state=0
  -- in the star scene. It runs at exactly GBA rate but never reports isDone on
  -- its own here, so the game sat in phase="boot" forever and every
  -- FireRed/LeafGreen/Emerald "capture" was the opening presentation -- black.
  -- Map.current is correct throughout, which is exactly why the scene-graph
  -- gate passed them: it validates state, not the screen.
  --
  -- tests/drivers/util.lua owns this as U.newGame, but that helper needs
  -- game.stack and Gen 3 has no stack at all -- it fails with "attempt to index
  -- field 'stack'". Driving the boot state machine directly does work, and the
  -- detail that matters is tapping EVERY frame rather than every 30th:
  --
  --   intro -> title -> title_cry -> menu -> controls -> pikachu -> oak
  --
  -- "start" skips the movie, "a" walks the menus, then the Oak speech needs
  -- the same mash. Directly setting movie.pendingSkip, forcing isDone, and
  -- game:keypressed were all tried first and none of them advanced it.
  if game.phase == 'boot' then
    local last, taps = nil, 0
    for _ = 1, 6000 do
      local b = game.boot
      if game.phase ~= 'boot' then break end
      if (b and b.phase) ~= last then
        print(('[sweep] boot %s -> %s after %d taps')
          :format(tostring(last), tostring(b and b.phase), taps))
        last = b and b.phase
      end
      if b and b.introMovie then
        pcall(function() U.tap(game, 'start') end)
      else
        pcall(function() U.tap(game, 'a') end)
      end
      taps = taps + 1
      U.wait(1)
    end
    print(('[sweep] boot exit after %d taps, phase=%s boot.phase=%s')
      :format(taps, tostring(game.phase), tostring(game.boot and game.boot.phase)))
    if game.phase == 'boot' then
      print('[sweep] WARNING never left phase=boot; Gen 3 captures will be unusable')
    end
  end
  installWrapper()
  V.require('TreePresentation').props:setIndex(1, game)

  -- Map ids, in a stable order so sharding is reproducible.
  local ids = {}
  -- Gen 1 and Gen 3 read game.data.maps. Only Gen 2 has a game.world object,
  -- and treating Gen 1 as if it did indexed a nil field and swept nothing.
  if gen == 2 then
    for id in pairs(game.world.maps) do ids[#ids + 1] = id end
  else
    for id in pairs(game.data.maps) do ids[#ids + 1] = id end
  end
  table.sort(ids)
  -- QA_MAPS restricts the run to an explicit id list (one per line). Used to
  -- re-shoot a targeted set -- e.g. the 39 DUNGEON maps -- without redoing
  -- the whole 388-map sweep.
  local listFile = os.getenv('QA_MAPS')
  if listFile and listFile ~= '' then
    local want, n = {}, 0
    for line in io.lines(listFile) do
      local id = line:match('^%s*(%S+)%s*$')
      if id and #id > 0 then n = n + 1; want[id] = true end
    end
    local kept = {}
    for _, id in ipairs(ids) do
      if want[id] then kept[#kept + 1] = id end
    end
    local missing = n - #kept
    if missing > 0 then
      print(('[sweep] QA_MAPS: %d of %d ids not present in this game'):format(missing, n))
    end
    ids = kept
  end
  print(('[sweep] generation %d, %d maps total'):format(gen, #ids))

  local shard = math.max(0, math.floor(tonumber(os.getenv('QA_SHARD')) or 0))
  local nshards = math.max(1, math.floor(tonumber(os.getenv('QA_NSHARDS')) or 1))
  local maxMaps = tonumber(os.getenv('QA_MAX_MAPS'))

  local index = assert(io.open(dir .. '/sweep-index.txt', 'w'))
  index:write(('map\tcamera\tx\ty\tfile\n'))

  local P, C, F
  if gen == 3 then C = V.require('Gen3Integration') end
  if gen == 1 or gen == 2 then
    P = require('src.render.Pipelines')
    F = V.require('FirstPerson')
  end

  -- Walkable cells, spread across the map, in a deterministic order.
  local function cells(map)
    local out, W, H = {}, map.widthCells, map.heightCells
    if not W or not H or W < 1 or H < 1 then return out end
    local seen, n = {}, 0
    for _, fy in ipairs({ 0.5, 0.25, 0.75 }) do
      for _, fx in ipairs({ 0.5, 0.2, 0.8, 0.35, 0.65 }) do
        local cx = math.floor(W * fx + 0.5)
        local cy = math.floor(H * fy + 0.5)
        local k = cx .. ':' .. cy
        if not seen[k] then
          seen[k] = true
          local ok, walk = pcall(function()
            if gen == 3 then
              local Perm = require('src.core.game3.permissions')
              return Perm.isWalkable(map.midLayout:collAt(cx, cy))
            end
            if gen == 1 then
              local Map = require('src.world.Map')
              return Map.defIsWalkableCell(map.def, map.tileset, cx, cy)
            end
            local Perm = require('src.world.gen2.Permissions')
            return Perm.of(tonumber(map:cellCollision(cx, cy)) or -1)
              == Perm.LAND
          end)
          if ok and walk then out[#out + 1] = { cx, cy }; n = n + 1 end
        end
      end
    end
    return out
  end

  -- Trustworthy post-capture gate. Pixel heuristics were tried first and were
  -- worthless: one flagged the location-banner text as a "failure screen" and
  -- invented a 47% black-void defect that did not exist, while a second missed
  -- real battle splashes entirely. The only sound check is the live scene
  -- graph -- is the requested map actually the thing loaded?
  -- Probed per generation, because the two engines expose this differently:
  --   gen 2  -> game.world.map.id, and the scene stack is EMPTY (size 0)
  --   gen 3  -> src.core.game3.map.current, with no stack at all
  -- Returns true, false (definitely wrong), or nil (shape unknown).
  local function overworldIs(id)
    if gen == 3 then
      local ok, Map = pcall(require, 'src.core.game3.map')
      if ok and Map and Map.current ~= nil then
        return tostring(Map.current) == tostring(id)
      end
      return nil
    end
    if gen == 1 then
      -- Gen 1 lives on the scene stack (OverworldController), unlike Gen 2's
      -- bare game.world and Gen 3's Map.current.
      if game.stack and type(game.stack.top) == 'function' then
        local ok, top = pcall(function() return game.stack:top() end)
        if ok and top then
          local got, v = pcall(function() return top.map and top.map.id end)
          if got and v ~= nil then return tostring(v) == tostring(id) end
        end
      end
      return nil
    end
    if game.world and game.world.map then
      local m = game.world.map
      local v = type(m) == 'table' and (m.id or m.mapId) or m
      if v ~= nil then return tostring(v) == tostring(id) end
    end
    if game.world and (game.world.mapId or game.world.currentMap) then
      return tostring(game.world.mapId or game.world.currentMap) == tostring(id)
    end
    return nil
  end

  local done, skipped, refused, blankShots = 0, 0, 0, 0
  for index_i, id in ipairs(ids) do
    if (index_i - 1) % nshards == shard then
      if maxMaps and done >= maxMaps then break end
      -- `idx` is the STABLE capture index for a camera, not its position in
      -- the pending list. Deriving it from `pending` meant a resumed run
      -- renumbered its files (1p landed on -1p-1.png instead of -1p-2.png),
      -- so the resume check never matched a file that actually existed and
      -- 1p was silently recaptured on every single run.
      local wanted = {
        { name = '3p', idx = 1, level = 7, yaw = 1.2, pitch = .22, zoom = 2 },
        { name = '1p', idx = 2, level = 6, yaw = math.pi, pitch = .04, zoom = 2 },
      }
      local pending = {}
      for _, v in ipairs(wanted) do
        if not exists(id .. '-' .. v.name .. '-' .. v.idx .. '.png') then
          pending[#pending + 1] = v
        end
      end
      if #pending == 0 then skipped = skipped + 1
      else
        U.wait(1)
        local ok, map = pcall(function()
          if gen == 3 then
            local Map = require('src.core.game3.map')
            Map.ensureMidLayout(game, id, game.data.maps[id])
            return game.data.maps[id]
          end
          if gen == 1 then
            local def = game.data.maps[id]
            local ts = (game.data.tilesets or {})[def.tileset]
            -- Walkability for gen 1 is a def+tileset question
            -- (Map.defIsWalkableCell), not a collision read on a live object,
            -- so hand the cell picker the two pieces it needs.
            return { def = def, tileset = ts, id = id,
                     widthCells = def.width * 2, heightCells = def.height * 2 }
          end
          local Map = require('src.world.gen2.Map')
          return Map.new(game.world.maps[id], game.world.tilesets[game.world.maps[id].tileset])
        end)
        if ok and map then
          local cs = cells(map)
          for _, v in ipairs(pending) do
            local cell = cs[(((v.idx - 1)) % math.max(1, #cs)) + 1] or { 1, 1 }
            local cx, cy = cell[1], cell[2]
            local loaded = pcall(function()
              -- Wild encounters, scene scripts and any leftover battle/UI state
              -- must be off BEFORE the load. Gen 2 already did this; Gen 3 did
              -- not, so 18% of FireRed/LeafGreen maps rolled an encounter during
              -- the settle below and the "capture" was a battle splash
              -- (Gengar vs Nidorin on FR_POKEMON_TOWER_2F) rather than the map.
              if game.world then
                game.world.noWildEncounters = true
                game.world.trySceneScript = function() return false end
                game.world.rollEncounter = function() return nil end
              end
              if game.data then
                game.data.noWildEncounters = true
                game.data.trySceneScript = function() return false end
                game.data.rollEncounter = function() return nil end
              end
              if gen == 3 then
                local Map = require('src.core.game3.map')
                if game.stack then pcall(function() game.stack:clear() end) end
                assert(Map.load(nil, game, id, { x = cx, y = cy, facing = 'up' }))
                require('src.ui.game3.map_preview_screen').reset()
              elseif gen == 2 then
                local w = game.world
                w.noWildEncounters = true
                w.trySceneScript = function() return false end
                w.rollEncounter = function() return nil end
                assert(w:setMap(id, cx, cy, 'up'))
                w.vm, w.textbox, w.mapSign = nil, nil, nil
              else
                if game.stack then game.stack:clear() end
                game.stack:push(require('src.world.OverworldController'),
                  id, cx, cy, 'up')
              end
            end)
            if not loaded then break end
            viewLock = nil
            if gen == 3 then
              C.setLevel(v.level, game)
              C.yaw, C.pitch = v.yaw, v.pitch
              local cyaw, cpitch = C.yaw, C.pitch
              viewLock = function() C.yaw, C.pitch = cyaw, cpitch end
            else
              P.setLevel('voxel', v.level)
              F.yaw, F.pitch = v.yaw, v.pitch
              local fyaw, fpitch = F.yaw, F.pitch
              viewLock = function() F.yaw, F.pitch = fyaw, fpitch end
            end
            Zoom.offset = v.zoom
            for _ = 1, 1800 do
              if V.require('ChunkMesher').pending() == 0 and V.require('VoxelState').ready then
                break
              end
              U.wait(1)
            end
            U.wait(v.name == '3p' and 45 or 30)
            local file = id .. '-' .. v.name .. '-' .. v.idx .. '.png'
            local live = overworldIs(id)
            if live == false then
              refused = refused + 1
              print(('[sweep] REFUSED %s %s: scene graph is not this map'):format(id, v.name))
              viewLock = nil
              break
            end
            if live == nil then
              print(('[sweep] UNVERIFIED %s %s: could not read the scene graph'):format(id, v.name))
            end
            -- Blank captures: a uniform frame still passes the scene-graph gate
            -- because Map.current is right while nothing has been drawn yet. It
            -- showed up as ~24 maps across Gen 1 (CELADON_CITY, CERULEAN_CITY,
            -- POWER_PLANT, ROUTE_11/13 ...) rendering as an empty frame in one
            -- camera only, intermittently, which is a timing race and not a
            -- render defect. A blank PNG compresses to a few hundred bytes, so
            -- re-shoot on size rather than trusting one attempt.
            local written = false
            for attempt = 1, 3 do
              if not U.shot(game, dir .. '/' .. file) then break end
              local bytes = 0
              local fh = io.open(dir .. '/' .. file, 'rb')
              if fh then bytes = fh:seek('end') or 0; fh:close() end
              if bytes > 6000 then written = true; break end
              blankShots = blankShots + 1
              if attempt < 3 then
                print(('[sweep] blank capture %s %s (attempt %d, %dB) -- resettling')
                  :format(id, v.name, attempt, bytes))
                for _ = 1, 90 do U.wait(1) end
              end
            end
            if not written then
              print(('[sweep] BLANK %s %s: no non-empty frame after 3 attempts')
                :format(id, v.name))
              viewLock = nil
              break
            end
            do
              have[file] = true
              index:write(('%s\t%s\t%d\t%d\t%s\n'):format(id, v.name, cx, cy, file))
              index:flush()
            end
          end
          done = done + 1
          if done % 10 == 0 then
            print(('[sweep] %d maps captured, %d already complete, %d views refused'):format(done, skipped, refused))
          end
        end
      end
    end
  end
  index:close()
  print(('[sweep] DONE gen=%d shard=%d/%d captured=%d already=%d refused=%d blank_retries=%d')
    :format(gen, shard, nshards, done, skipped, refused, blankShots))
  love.event.quit()
end
