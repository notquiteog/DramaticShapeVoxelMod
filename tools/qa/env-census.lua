-- Environment census: which env values exist, and does the ceiling shell
-- cover them? Cross-referenced with the >60% dark-upper-band maps.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  for _ = 1, 120 do U.wait(1) end
  local store = game.data and game.data.maps or (game.world and game.world.maps)
  local counts, indoorish, total = {}, {}, 0
  for id, def in pairs(store) do
    total = total + 1
    local e = tostring(def.environment)
    counts[e] = (counts[e] or 0) + 1
  end
  local keys = {}
  for e in pairs(counts) do keys[#keys + 1] = e end
  table.sort(keys, function(a, b) return counts[a] > counts[b] end)
  for _, e in ipairs(keys) do
    print(('[env] %-14s %d'):format(e, counts[e]))
  end
  print(('[env] TOTAL %d'):format(total))

  -- Per-map env for the maps the image metric flagged, so the fix can be
  -- confirmed against the exact failing set.
  local f = io.open(os.getenv("ENV_OUT") or "env.txt", "w")
  local list = {}
  for id, def in pairs(store) do
    list[#list + 1] = ('%s\t%s\t%s'):format(id, tostring(def.environment), tostring(def.tileset))
  end
  table.sort(list)
  for _, l in ipairs(list) do f:write(l, "\n") end
  f:close()
  print("[env] wrote " .. #list .. " rows")
  return
end
