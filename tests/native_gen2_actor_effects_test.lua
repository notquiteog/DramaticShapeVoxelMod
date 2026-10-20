local mon,partner={},{}
local image={getDimensions=function()return 48,48 end}
local screen={battle={doubles=true,player=mon},anim={animId='ANIM_SEND_OUT_MON',frames=7}}
screen.afterSendOut={side='player2',mon=partner}
function screen:nativeAnimationSlot()return self.afterSendOut and self.afterSendOut.side end
function screen:activeMon(slot)return slot=='player2'and partner or mon end
function screen:pic()return image,false,'native.png'end
function screen:picScale()return 1 end
local staged={drawn={player2=partner}}
local enabled=true
local moved,depth,native,battles={},0,0,{}
local fail=false
local View={drawObjects=function(_,runner,battle,extra)
 native=native+1;battles[#battles+1]=battle
 if fail then error('native renderer failed')end
 return nil,extra
end}
screen.animView=setmetatable({},{__index=View})
package.loaded['src.ui.gen2.BattleAnimView']=View
love={graphics={push=function(kind)assert(kind=='all');depth=depth+1 end,
 pop=function()depth=depth-1 end,translate=function(x,y)moved={x,y}end}}
local M=assert(loadfile('lib/NativeGen2ActorEffects.lua'))({require=function(name)
 if name=='Gen2Staged'then return staged end
 if name=='Gen2Battle'then return{stagedMon=function(m)return enabled and m==partner end}end
 if name=='BattleSpriteFooting'then return{bounds=function()return{0,0,48,43}end}end
 error(name)
end})
assert(M.owner(screen,'player2',partner) and not M.owner(screen,'player',mon))
M.begin()
assert(M.paint(screen,'player2',partner,80,80))
assert(moved[1]==40 and moved[2]==-11 and depth==0,'native visible foot/center or state restoration changed')
assert(battles[1]~=screen.battle and battles[1].player==partner and screen.battle.player==mon,'palette identity mutated live battle')
local n=native;screen.animView:drawObjects(screen.anim,screen.battle);assert(native==n,'native particle replay duplicated')
local function fallback()
 local before=native
 local a,b=screen.animView:drawObjects(screen.anim,screen.battle,'return')
 assert(native==before+1 and a==nil and b=='return','native fallback or return tuple lost')
end
enabled=false;fallback();enabled=true
staged.drawn.player2=nil;fallback();staged.drawn.player2=partner
screen.anim.frames=8;local before=native;screen.animView:drawObjects(screen.anim,screen.battle)
assert(native==before,'post-publication native clock duplicated published actor pixels')
screen.anim.frames=7
local runner=screen.anim;screen.anim={animId='ANIM_SEND_OUT_MON',frames=7};fallback();screen.anim=runner
screen.afterSendOut=nil;fallback();screen.afterSendOut={side='player2',mon=partner}
M.begin();fallback()
fail=true;local ok=pcall(M.paint,screen,'player2',partner,80,80);assert(not ok and depth==0,'error leaked graphics stack')
fail=false;fallback()
screen.anim.param=1;assert(M.paint(screen,'player2',partner,80,80),'original shiny arm discarded')
M.begin();screen.battle.doubles=nil;assert(not M.paint(screen,'player2',partner,80,80))
screen.battle.doubles=true;screen.nativeAnimationSlot=function()error('provider missing')end
assert(not M.paint(screen,'player2',partner,80,80))
assert(depth==0 and mon~=partner)
print('PASS original paired particles: exact slot/palette, visible footing, native shiny/OFF, failed composition, stale publication/runner and graphics cleanup')
