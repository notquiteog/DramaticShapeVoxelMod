-- Which cart is running, asked once and answered the same way everywhere.
--
-- Battle Art installs a number of patches onto engine tables. On a Gen 1 boot
-- those tables ARE the running game; on a Gen 2 boot a require for a Gen 1
-- name is answered by src/mods/Gen2Compat.lua, and only three of the members
-- it serves are seams Gold dispatches back through (`update`, `interact`,
-- `talkTo` -- Gen2Compat.worldTick / interactWrapper / talkToWrapper). A patch
-- on anything else is taken, reads back as our own function, and is never
-- called. That failure is silent, which is exactly why every install site
-- that patches rather than calls has to ask this module first.
--
-- The engine's own branch is GameVersion.generation() (1 or 2) with
-- GameVersion.engine() ("gen1" / "gs" / "crystal") for lineage inside a
-- generation -- src/core/Game2.lua:391 picks Crystal's screens that way. We
-- ask the same questions rather than inventing a version allow-list: a list of
-- cart names is what MK409 flags, and it is wrong the moment a cart is added.
--
-- GameVersion.set runs at engine boot (main.lua:253), long before
-- mods:load (src/core/Game2.lua:1125), so this is already true when our entry
-- chunk runs and stays true for the life of the process -- the active cart
-- cannot change without a restart. Hence the cache.

-- No V and no mod API: this module asks the engine one question and is
-- loadable by any harness that can require src.core.GameVersion -- or by one
-- that cannot, which is what the pcall below is for.

local Generation = {}

-- nil until the first ask; false if the engine module could not be reached
local cached

local function resolve()
  if cached ~= nil then return cached end
  -- pcall because a headless harness may stub a narrower engine tree, and a
  -- missing GameVersion must degrade to Gen 1 rather than break the load:
  -- Gen 1 is what every build before this one assumed unconditionally.
  local ok, GameVersion = pcall(require, "src.core.GameVersion")
  if not ok or type(GameVersion) ~= "table" then
    cached = false
    return cached
  end
  cached = GameVersion
  return cached
end

-- 1 or 2. Gen 1 is the fallback: it is what this mod did before Gen 2 was a
-- target, so an unreadable engine leaves behaviour exactly as it shipped.
--
-- GameVersion is the ONLY source on purpose. A tempting second signal is that
-- Loader:_game answers nil when the loader's generation is not 1, which is the
-- one thing that does follow the SDK harness's `generation = 2` option --
-- T.sdk.loadMod passes it straight into Loader.new and never sets GameVersion.
-- But `mod.game` is also nil for any test that hands a lib module a stub V,
-- and there are a great many of those, so that signal reads Gen 2 for a unit
-- test that meant nothing of the kind. A test that wants the Gen 2 arm sets
-- the cart the way a boot does -- GameVersion.set("crystal") -- which is one
-- line in the harness and keeps the production answer single-sourced.
--
-- Memoized: the active cart cannot change without a restart, and the callers
-- include the OPTIONS row predicates, re-evaluated whenever that screen
-- rebuilds. A test that changes the cart mid-process calls Generation.reset().
local number

function Generation.number()
  if number then return number end
  number = 1
  local GameVersion = resolve()
  if GameVersion and type(GameVersion.generation) == "function" then
    local ok, gen = pcall(GameVersion.generation)
    if ok and type(gen) == "number" then number = gen end
  end
  return number
end

-- Drop the memo. For a harness that boots more than one cart in one process;
-- nothing in a real session needs it.
function Generation.reset()
  number = nil
  cached = nil
end

function Generation.isGen1() return Generation.number() == 1 end
function Generation.isGen2() return Generation.number() == 2 end

-- The version id: "red" / "blue" / "yellow" / "gold" / "silver" / "crystal",
-- or nil when the engine did not answer. For CONTENT that genuinely differs
-- per cart -- a map table, a sprite set -- never as a feature gate.
function Generation.version()
  local GameVersion = resolve()
  if not GameVersion or type(GameVersion.get) ~= "function" then return nil end
  local ok, id = pcall(GameVersion.get)
  if not ok or type(id) ~= "string" then return nil end
  return id
end

-- Lineage within a generation: "gen1" for Red/Blue/Yellow, "gs" for
-- Gold/Silver, "crystal" for Crystal. Crystal is a real fork of the Gen 2
-- engine rather than a reskin -- it has animated battle front pics
-- (src/ui/gen2/BattleState.lua:animData), its own intro and splash screens,
-- and screens Gold never had -- so the pieces that care about that difference
-- ask for the lineage and not for the version name.
-- The fallback is keyed to the GENERATION rather than fixed, so the two
-- answers can never contradict each other: a build that knows it is on Gen 2
-- but cannot name the cart must not report the Gen 1 lineage. "gs" is the
-- right unknown there because it is the base Gen 2 arm -- Crystal is the fork
-- of it -- so an unknown cart declines Crystal-only behaviour rather than
-- claiming it. This is reachable in the SDK harness, which takes a generation
-- without setting GameVersion.
function Generation.lineage()
  local fallback = Generation.isGen2() and "gs" or "gen1"
  local GameVersion = resolve()
  if not GameVersion or type(GameVersion.engine) ~= "function" then
    return fallback
  end
  local ok, id = pcall(GameVersion.engine)
  if not ok or type(id) ~= "string" then return fallback end
  -- GameVersion's own default is "gen1" for any row without an `engine` key,
  -- which is the same unset answer the harness leaves behind.
  if id == "gen1" and Generation.isGen2() then return fallback end
  return id
end

-- A set rather than a comparison, for the same reason the porting guide
-- writes screen-id tests as `BOX_IDS[id]`: a bare `== "crystal"` reads to a
-- static scan as a cart allow-list, which is the pattern that quietly excludes
-- a mod from a game. This is a LINEAGE test -- which engine arm is running,
-- not which box the cart came in -- and the lookup says so.
local CRYSTAL_LINEAGE = { crystal = true }

function Generation.isCrystal()
  return CRYSTAL_LINEAGE[Generation.lineage()] == true
end

-- Gen 1's screen id under the generation that is running.
--
-- The screens registry serves both generations out of one table and gives
-- Gold's builtins a "Gen2" prefix, because half of them share a module name
-- with a Gen 1 screen (src/ui/Screens.lua:17-38). So a literal id pushed or
-- compared by name matches nothing on Gold, which is what MK409 warns about.
--
-- One pairing is NOT the prefix rule and has to be spelled out: Gen 1's
-- `BoxMenu` is Bill's PC *top menu*, whose Gold counterpart is `Gen2PcMenu`.
-- Gold's own `Gen2BoxMenu` is the withdraw/deposit list that Gen 1 builds
-- inline, so the mechanical prefix would open the wrong screen.
local SCREEN_PAIRS = { BoxMenu = "Gen2PcMenu" }

function Generation.screenId(name)
  if type(name) ~= "string" or name == "" then return name end
  if Generation.isGen1() then return name end
  return SCREEN_PAIRS[name] or ("Gen2" .. name)
end

-- A one-line label for the log and for the options screen's own diagnostics.
function Generation.label()
  local id = Generation.version()
  if id then return id end
  return "gen" .. tostring(Generation.number())
end

return Generation
