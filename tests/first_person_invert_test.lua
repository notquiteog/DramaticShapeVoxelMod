-- Focused regression for issue #26: vertical free-camera inversion.
local checks = 0
local function check(value, message)
  checks = checks + 1
  if not value then error("FAIL: " .. message, 0) end
end
local function near(a, b)
  return math.abs(a - b) < 1e-9
end

local settingNamespace = { mod = { id = "BATTLE_ART_VOXEL_FORK" } }
local ModSetting = assert(loadfile("lib/ModSetting.lua"))(settingNamespace)
local modules = {
  Mat4 = {}, VoxelState = {}, Voxel3D = {}, WorldCurve = {},
  ThirdPerson = { showsPlayer = function() return false end },
  ModSetting = ModSetting,
}
local namespace = { mod = settingNamespace.mod }
function namespace.require(name)
  return assert(modules[name], "unexpected FirstPerson dependency " .. tostring(name))
end

local FirstPerson = assert(loadfile("lib/FirstPerson.lua"))(namespace)
check(FirstPerson.invertYSetting:get() == false,
  "Y-control inversion defaults to OFF")
check(FirstPerson.invertYSetting.labels[1] == "OFF"
      and FirstPerson.invertYSetting.labels[2] == "ON",
  "the setting exposes OFF and ON choices")

FirstPerson.yaw, FirstPerson.pitch = 0, 0
FirstPerson.invertYSetting:setIndex(1)
FirstPerson.lookInput(0.25, 0.4)
check(near(FirstPerson.yaw, 0.25) and near(FirstPerson.pitch, 0.4),
  "OFF preserves the vertical look direction")

FirstPerson.yaw, FirstPerson.pitch = 0, 0
FirstPerson.invertYSetting:setIndex(2)
FirstPerson.lookInput(0.25, 0.4)
check(near(FirstPerson.yaw, 0.25) and near(FirstPerson.pitch, -0.4),
  "ON reverses pitch without changing yaw")

FirstPerson.invertYSetting:setIndex(1)
print(("%d checks passed (first-person inversion)"):format(checks))

local world={map={},busy=function()return true end}
local stack={states={},top=function(self)return self.states[#self.states] end}
package.loaded['src.core.Game']={world=world,overworld=world,stack=stack}
modules.VoxelState.isFreeCam=function()return true end
modules.Voxel3D.available=function()return true end
check(FirstPerson.looking() and not FirstPerson.driving(),'cutscene allows look without movement')
stack.states={{isTextBox=true}}
check(FirstPerson.looking() and not FirstPerson.driving(),'dialogue allows look without movement')
stack.states={{},{isTextBox=true}}
check(not FirstPerson.looking(),'dialogue over a menu cannot grant world control')
stack.states={};world.battleActive=true
check(not FirstPerson.looking(),'battle keeps its own camera')
world.battleActive=false;world.busy=function()return false end
check(FirstPerson.looking() and FirstPerson.driving(),'free roam retains look and walking')
print('Dialogue/cutscene look, movement lock, menu and battle ownership PASS')
