-- Shared loader for the tests that pull mod modules off disk directly.
--
-- Dozens of suites do `assert(loadfile("lib/X.lua"))()` to exercise a module
-- without the engine. That works only while the module's own dependencies are
-- satisfied, and they are NOT satisfied: the installed loader always passes the
-- mod namespace as the module's first argument, so `V.require` works there and
-- is nil when a test calls loadfile bare. A module that later acquires a new
-- dependency therefore breaks every test that loads it, one file at a time, and
-- the suite's own error is about the wrong thing entirely.
--
-- `V` here behaves the way the real loader's does -- a resolver over the mod's
-- own lib/ and data/ -- so a test that uses this is testing the same wiring the
-- game runs rather than a hand-kept list of stubs. A suite that needs a module
-- BEHAVIOURALLY different from the real one (a fixture tileset, a fake elevation
-- field) should still stub that one module explicitly; this covers the rest.
local M = {}

local loaded = {}

-- The mod namespace, or nil so a caller can build its own.
function M.namespace(overrides)
  local V
  V = {
    require = function(name)
      if overrides and overrides[name] ~= nil then return overrides[name] end
      if loaded[name] ~= nil then return loaded[name] end
      local value = assert(loadfile("lib/" .. name .. ".lua"))(V)
      loaded[name] = value
      return value
    end,
    data = function(name)
      if overrides and overrides[name] ~= nil then return overrides[name] end
      if loaded[name] ~= nil then return loaded[name] end
      local value = assert(loadfile("data/" .. name .. ".lua"))(V)
      loaded[name] = value
      return value
    end,
  }
  -- Some modules read V.mod at load time: ModSetting keeps it as its owner and
  -- TreePresentation builds its settings rows on require, so a bare log table is
  -- the minimum one of them accepts.
  V.mod = { log = { warn = function() end, info = function() end } }
  return V
end

-- load("ChunkMesher") -- a real module, with real dependencies.
function M.load(name, overrides)
  return assert(loadfile("lib/" .. name .. ".lua"))(M.namespace(overrides))
end

-- A namespace whose resolver only answers the names in `map`, so a test can
-- state exactly which siblings a module under test may reach.
function M.strict(map)
  local V = { require = function(name)
    return assert(map[name], "unexpected module " .. tostring(name))
  end }
  V.data = V.require
  return V
end

return M
