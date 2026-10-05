local V=...
local M={}
M.setting=V.require('ModSetting').new('modernBattleUI','MODERN BATTLE UI',
  {true,false},{'ON','OFF'})
function M.providerEnabled()
 local provider=V.mod and V.mod.find and V.mod.find('MODERN_POKEMON_UI')
 local api=provider and provider.exports
 if not api or api.apiVersion~=1 or type(api.enabled)~='function'then return false end
 local ok,value=pcall(api.enabled)
 return ok and value==true
end
function M.enabled()return M.setting:get()==true and M.providerEnabled()end
return M
