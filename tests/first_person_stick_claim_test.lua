-- Focused regression: the right stick is camera-only while a camera claims
-- it. 0.3.73 taught Input twin-stick walking (rightstick_* -> up/down/left/
-- right), so an unclaimed throw steered the camera AND walked the player.
-- FirstPerson.stickClaimed is the gate both input wraps consult; with the
-- gate open the throw never reaches the engine's translation, with it shut
-- the engine keeps its new walk. See lib/FirstPerson.lua.
local checks = 0
local function check(value, message)
  checks = checks + 1
  if not value then error("FAIL: " .. message, 0) end
end

local settingNamespace = { mod = { id = "BATTLE_ART_VOXEL_FORK" } }
local ModSetting = assert(loadfile("lib/ModSetting.lua"))(settingNamespace)
local modules = {
  Mat4 = {},
  VoxelState = { level = 0 },
  Voxel3D = {},
  WorldCurve = {},
  ThirdPerson = { showsPlayer = function() return false end },
  ModSetting = ModSetting,
  CameraSettings = { invertY = ModSetting.new(
    "invertY", "Y-CONTROL INVERT", { false, true }, { "OFF", "ON" }) },
}
modules.VoxelState.isFreeCam = function(_, level)
  return (level or modules.VoxelState.level) >= 6 end
local namespace = { mod = settingNamespace.mod }
function namespace.require(name)
  return assert(modules[name], "unexpected FirstPerson dependency " .. tostring(name))
end

local FirstPerson = assert(loadfile("lib/FirstPerson.lua"))(namespace)

-- Off the free-camera rungs, with no staged battle lens: nothing claims
-- the stick, so the engine's own twin-stick walk stays in charge.
modules.VoxelState.level = 0
check(FirstPerson.stickClaimed() == false,
  "an unclaimed right stick stays with the engine")

-- A free-camera rung selected (1ST or 3RD) claims it, menus included --
-- the camera reads the stick even while a dialogue holds the player's
-- feet, and the player must not walk under the same throw.
modules.VoxelState.level = 6
check(FirstPerson.stickClaimed() == true,
  "the 1ST rung claims the right stick")
modules.VoxelState.level = 7
check(FirstPerson.stickClaimed() == true,
  "the 3RD boom claims the right stick")

-- A steerable staged-battle lens claims it too, even off the free-camera
-- rungs (the orbit rungs hand the battle its own camera).
modules.VoxelState.level = 0
modules.CamControl = { battleLive = function() return true end }
check(FirstPerson.stickClaimed() == true,
  "a steerable staged battle claims the right stick")
modules.CamControl.battleLive = function() return false end
check(FirstPerson.stickClaimed() == false,
  "an unsteerable staged battle releases the right stick")

print(("%d checks passed (first-person right-stick claim)"):format(checks))