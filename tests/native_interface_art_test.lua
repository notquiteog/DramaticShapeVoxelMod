local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local function img(id,w,h)return {id=id,getDimensions=function()return w or 80,h or 80 end}end
local first,second=img('one'),img('two')
local frames={first,second};local current=second
local selected,scale='battle_art','fit'
local fitCalls,lastMon=0
local Interface={setting={get=function()return selected end},scalingSetting={get=function()return scale end}}
local fitImages={}
local Art={fitPreparedFrames=function(input,w,h,full)
 check(input==frames,'fit must retain animation-wide union')
 check(w==64 and h==64,'native interface target is 64 pixels')
 fitCalls=fitCalls+1
 local out={img('fit1',full and 80 or 64),img('fit2',full and 80 or 64)}
 fitImages[full and 'full' or 'fit']=out;return out
end}
local Animated={picture=function(mon,side)lastMon=mon;check(side=='front','interface uses front');return current,frames end}
local original=function()return {image=img('rom')}end
local P={frontPic=original,national=function(id)return id-1000 end,isEgg=function(mon)return mon.isEgg end}
local Summary={_party={{species=1025,personality=456,otId=123,otSecretId=321,isShiny=true}},_cursor=1}
local fail=false;local seen
Summary.draw=function()
 seen=P.frontPic(1025,0)
 if fail then error('native draw failure')end
 return 'summary'
end
local Dex={draw=function()seen=P.frontPic(1025,0);return 'dex'end}
package.loaded['src.core.game3.pokemon']=P
package.loaded['src.ui.game3.summary_menu']=Summary
package.loaded['src.ui.game3.pokedex']=Dex
local V={require=function(name)return assert(({InterfaceSprites=Interface,BattleArt=Art,AnimatedBattleArt=Animated})[name],name)end}
local Native=assert(loadfile('lib/NativeInterfaceArt.lua'))(V)
local initialSummary,initialDex=Summary.draw,Dex.draw
local undo=Native.install()
check(Summary.draw()=='summary' and seen.image==fitImages.fit[2],'correct animated fitted frame')
check(lastMon.species==25 and lastMon.personality==456 and lastMon.isShiny==true,'Summary mon-aware national/shiny context')
check(P.frontPic==original,'front provider restored after scoped draw')
current=first;Summary.draw();check(seen.image==fitImages.fit[1] and fitCalls==1,'frame selection preserves fitted animation union cache')
scale='full';Summary.draw();check(seen.image==fitImages.full[1] and fitCalls==2,'FULL switches live without resetting animation')
Dex.draw();check(lastMon.personality==nil and lastMon.isShiny==nil,'Dex remains regular species preview')
fail=true;local ok=pcall(Summary.draw)
check(not ok and P.frontPic==original,'native error restores sprite provider')
fail=false;selected='off';Summary.draw();check(seen.image.id=='rom','OFF retains native art')
selected='modded';Dex.draw();check(seen.image.id=='rom','MODDED retains provider art')
selected='battle_art';Summary._party[1].isEgg=true;Summary.draw();check(seen.image.id=='rom','eggs retain native species rules')
undo();check(Summary.draw==initialSummary and Dex.draw==initialDex,'unload restores native owners')
print('PASS '..checks..' native interface art checks')
