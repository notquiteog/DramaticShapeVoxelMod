-- Per-category presentation preferences. Providers still own source matching,
-- availability and native-footprint checks; selecting MODERN 3D promises no asset.
-- No legacy art/preset keys are migrated into these independent preferences.
local V = ...
local ModSetting = V.require('ModSetting')
local M = { settings = {}, order = {}, registrations = {}, byCategory = {}, byKey = {} }
local values = { 'modern', 'voxel', 'hd2d' }
local labels = { 'MODERN 3D', 'NATIVE VOXEL', 'HD2D' }
local description = 'MODERN 3D prefers matching ORAS, HGSS or BDSP models where supported. '
  .. 'NATIVE VOXEL builds 3D forms from 100% original game sprite art. '
  .. 'HD2D keeps sprite art in the 3D scene. Source availability is checked by each renderer.'

local function copy(list)
  local out = {}
  for i, value in ipairs(list) do out[i] = value end
  return out
end

-- Providers may append their own category without registering a render pass or
-- depending on any model pack. Returns the ordinary ModSetting and its metadata.
-- Category IDs and setting keys are unique; a provider cannot replace defaults
-- for built-in actors/flowers by registering their category a second time.
function M.register(category, spec)
  assert(type(category) == 'string' and category:match('^[a-z][a-z0-9_]*$'),
    'visual style category must be a lowercase identifier')
  assert(not M.byCategory[category], 'visual style category already registered: ' .. category)
  if spec == nil then spec = {} end
  assert(type(spec) == 'table', 'visual style registration expects a metadata table')
  local key = spec.key or ('visualStyle_' .. category)
  local label = spec.label or (category:upper():gsub('_', ' ') .. ' STYLE')
  local default = spec.default or 'modern'
  assert(type(key) == 'string' and key ~= '' and not M.byKey[key],
    'visual style setting key must be nonempty and unique')
  assert(type(label) == 'string' and label ~= '', 'visual style label must be nonempty')
  assert(spec.help == nil or type(spec.help) == 'string', 'visual style help must be text')
  local defaultIndex
  for i, value in ipairs(values) do if value == default then defaultIndex = i end end
  assert(defaultIndex, 'visual style default must be modern, voxel or hd2d')
  local setting = ModSetting.new(key, label, copy(values), copy(labels), defaultIndex)
  local registration = {
    category = category, key = key, label = label, setting = setting,
    default = default, help = spec.help or description, order = #M.order + 1,
  }
  M.order[#M.order + 1] = category
  M.settings[#M.settings + 1] = setting
  M.registrations[#M.registrations + 1] = registration
  M.byCategory[category], M.byKey[key] = registration, registration
  return setting, registration
end

-- Unknown categories have no preference; callers must register them explicitly.
-- No fallback renderer or model availability is inferred from these predicates.
function M.setting(category)
  local registration = M.byCategory[category]
  return registration and registration.setting or nil
end
function M.get(category)
  local setting = M.setting(category)
  return setting and setting:get() or nil
end
function M.modern(category) return M.get(category) == 'modern' end
function M.voxel(category) return M.get(category) == 'voxel' end
function M.hd2d(category) return M.get(category) == 'hd2d' end

M.register('buildings',  { key = 'visualStyleBuildings',  label = 'BUILDING STYLE' })
M.register('trees',      { key = 'visualStyleTrees',      label = 'TREE STYLE' })
M.register('flowers',    { key = 'visualStyleFlowers',    label = 'FLOWER STYLE', default = 'hd2d' })
M.register('props',      { key = 'visualStyleProps',      label = 'PROP STYLE' })
M.register('interiors',  { key = 'visualStyleInteriors',  label = 'INTERIOR STYLE' })
M.register('terrain',    { key = 'visualStyleTerrain',    label = 'TERRAIN STYLE' })
M.register('pokemon',    { key = 'visualStylePokemon',    label = 'POKEMON STYLE', default = 'hd2d' })
M.register('characters', { key = 'visualStyleCharacters', label = 'CHARACTER STYLE', default = 'hd2d' })

return M
