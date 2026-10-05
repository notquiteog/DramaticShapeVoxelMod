local provider
local setting={get=function()return true end}
local V={mod={find=function(id)assert(id=='MODERN_POKEMON_UI');return provider end}}
V.require=function(name)assert(name=='ModSetting');return {new=function()return setting end}end
local Mode=assert(loadfile('lib/ModernBattleUI.lua'))(V)
assert(not Mode.enabled(),'standalone voxel changed native UI')
provider={exports={apiVersion=1,enabled=function()return true end}}
assert(Mode.enabled(),'compatible optional provider ignored')
provider.exports.enabled=function()return false end;assert(not Mode.enabled())
provider.exports.enabled=function()error('provider failure')end;assert(not Mode.enabled())
provider.exports.apiVersion=2;assert(not Mode.enabled())
print('PASS native UI default and optional modern provider ownership')
