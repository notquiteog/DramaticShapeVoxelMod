-- Official native public-PC animation frames. Only the two reviewed complete
-- Center drawings share these aliases; home/lab PCs retain separate recipes.
local M={}
function M.matches(r,actual,expected)
 if actual==expected then return true end
 if r.name=='center_terminal'and r.pair=='network'and r.family==nil then
  return expected==0x62 and actual==0x63
 end
 if r.name=='hoenn_center_pc'and r.pair=='building__pokemon_center'and r.family=='rse'then
  return expected==4 and actual==5
 end
 return false
end
return M
