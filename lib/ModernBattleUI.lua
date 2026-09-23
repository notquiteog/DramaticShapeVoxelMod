local V=...
local M={}
M.setting=V.require('ModSetting').new('modernBattleUI','MODERN BATTLE UI',
  {true,false},{'ON','OFF'})
function M.enabled()return M.setting:get()==true end
return M
