-- Native form identity only; no substitute pose or missing markings are invented.
local M={}
function M.form(dex,battler,presentation)
 local mon=battler and battler.mon
 if dex==327 then return 'unsupported-pid-spots'end
 if dex~=201 and dex~=351 and dex~=386 then return 'default'end
 local GV=require('src.core.GameVersion');local gen=GV.generation()
 if battler and(battler.__battleArtTransformed or battler.transformed)then
  return 'unresolved-transform-form'
 end
 if dex==201 then
  if gen==2 then
   local U=require('src.core.gen2.Unown')
   local letter=mon and U.letterFromDVs(mon.dvs)
   return letter and tostring(letter-1)or'unresolved-unown'
  elseif gen==3 then
   local P=require('src.core.game3.pokemon')
   return mon and mon.personality~=nil and tostring(P.unownLetter(mon.personality))or'unresolved-unown'
  end
  return 'unresolved-unown'
 elseif dex==386 then
  return ({ruby='0',sapphire='0',firered='1',leafgreen='2',emerald='3'})[GV.get()]or'unresolved-deoxys'
 end
 local p=presentation
 local form=p and(p.castformMon==nil or p.castformMon==mon)and tonumber(p.castformForm)or 0
 form=(form or 0)%128
 return form==0 and'default'or'castform-'..tostring(form)
end
return M
