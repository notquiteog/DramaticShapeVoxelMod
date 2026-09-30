return function(game)
  local U = dofile("tests/drivers/util.lua")
  for _ = 1, 120 do U.wait(1) end
  local out = assert(io.open(assert(os.getenv("PAIR_OUT")), "w"))
  local by = {}
  for id, def in pairs(game.data.maps or {}) do
    local L = def.midLayout
    local p = L and L.pair
    if p then
      by[p] = by[p] or { n = 0, maps = {}, mids = {} }
      by[p].n = by[p].n + 1
      by[p].maps[#by[p].maps + 1] = id
      for y = 0, (L.height or 0) - 1 do
        for x = 0, (L.width or 0) - 1 do
          local ok, m = pcall(function() return L:midAt(x, y) end)
          if ok and m ~= nil then by[p].mids[m] = true end
        end
      end
    end
  end
  local keys = {}
  for k in pairs(by) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local r = by[k]
    local mn = 0
    for _ in pairs(r.mids) do mn = mn + 1 end
    local first = r.maps[1]; table.sort(r.maps); first = r.maps[1]
    out:write(string.format("%s\t%d\t%d\t%s\n", k, r.n, mn, first))
  end
  out:close(); return
end
