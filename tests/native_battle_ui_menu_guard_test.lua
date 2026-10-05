local V={require=function(name)
 if name=='UiBackplates'then return{}end
 if name=='ModSetting'then return {new=function()return{}end}end
 error(name)
end}
local M=assert(loadfile('lib/Gen3BattleOptions.lua'))(V)
assert(not M.covered())
for _,prefix in ipairs({'src.ui.game3.','src.ui.game3.rse.'})do
 for _,name in ipairs({'bag_menu','party_menu','summary_menu','help_system','pokedex'})do
  local key=prefix..name
  package.loaded[key]={isOpen=function()return true end};assert(M.covered(),key)
  package.loaded[key].isOpen=function()return false end;assert(not M.covered(),key)
  package.loaded[key]=nil
 end
end
print('PASS FRLG/Emerald menus exclude modern battle styling')
