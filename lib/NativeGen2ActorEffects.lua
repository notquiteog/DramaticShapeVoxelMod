-- Original paired send-out OBJ pixels, attached to their public native owner.
-- The runner, palettes, reveal clock and input remain entirely native.
local V=...
local M={}
local claim
function M.begin()claim=nil end
function M.owner(screen,slot,mon)
 if not(screen and screen.battle and screen.battle.doubles and mon
  and screen.anim and screen.anim.animId=='ANIM_SEND_OUT_MON'
  and screen.animView and type(screen.animView.drawObjects)=='function'
  and type(screen.nativeAnimationSlot)=='function')then return false end
 local cue=screen.afterSendOut
 if not(cue and cue.side==slot and cue.mon==mon)then return false end
 local ok,owns=pcall(function()
  return screen:nativeAnimationSlot()==slot and screen:activeMon(slot)==mon
 end)
 return ok and owns
end
function M.install()
 if M.installed then return end
 local View=require('src.ui.gen2.BattleAnimView')
 local original=View.drawObjects
 function View:drawObjects(runner,battle,...)
  local c=claim
  -- World textures publish before BattleState advances its native clock.
  -- Match the published actor/event, not the now-advanced runner frame.
  if c and self==c.view and runner==c.runner and c.screen.afterSendOut==c.cue
   and battle==c.screen.battle and M.owner(c.screen,c.slot,c.mon)
   and V.require('Gen2Staged').drawn[c.slot]==c.mon
   and V.require('Gen2Battle').stagedMon(c.mon)then return end
  return original(self,runner,battle,...)
 end
 M.original=original;M.installed=true
end
function M.paint(screen,slot,mon,ax,ay)
 if not M.owner(screen,slot,mon)then return false end
 local g=love.graphics
 if not(g.push and g.pop and g.translate)then return false end
 local back=slot=='player' or slot=='player2'
 local ok,image,_,path=pcall(screen.pic,screen,mon,back)
 if not(ok and image)then return false end
 local w,h=image:getDimensions()
 local scale=screen.picScale and screen:picScale(path,mon,back)or 1
 local bounds=V.require('BattleSpriteFooting').bounds(image)
 local x=(back and 16 or 96)+(back and math.floor((48-w)/2)or math.max(0,math.floor((56-w)/2)))
 local y=back and 96-h or math.max(0,56-h)
 if scale~=1 then x=x+math.floor(w*(1-scale)/2);y=y+math.floor(h*(1-scale))end
 local center,foot=x+w*scale/2,y+bounds[4]*scale
 M.install()
 -- Only the native palette reader sees this detached identity view. The
 -- actual battle and both teammates remain untouched, including on errors.
 local paletteBattle=setmetatable({[back and 'player' or 'enemy']=mon},{__index=screen.battle})
 g.push('all')
 local painted,err=pcall(function()
  g.translate(ax-center,ay-foot)
  M.original(screen.animView,screen.anim,paletteBattle)
 end)
 g.pop()
 if not painted then error(err,0)end
 claim={screen=screen,view=screen.animView,runner=screen.anim,cue=screen.afterSendOut,
  slot=slot,mon=mon}
 return true
end
return M
