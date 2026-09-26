local checks=0
local function check(v,msg)checks=checks+1;assert(v,msg)end
local modules={};local hooks={}
local V={mod={hooks={wrap=function(_,key,fn)hooks[key]=fn end}}}
function V.require(name)if not modules[name]then modules[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return modules[name]end
local UI=V.require('UiBackplates');local Mode=V.require('ModernBattleUI')
Mode.setting:setIndex(2)
local stageOn=true;local shot={heads={player={.3,.6},enemy={.7,.4}}}
modules.OverworldBattle={enabled=function()return stageOn end,shot=function()return shot end,
 hudScaleSetting={get=function()return 'scaled'end}}
local cards,buttons,texts=0,0,{}
modules.BattleTheme={scale=function()return 1 end,layoutStatusCards=function(items)
 local out={};for _,p in ipairs(items)do out[p.id]=p end;return out end,
 statusCard=function()cards=cards+1 end,button=function()buttons=buttons+1 end,
 text=function(t)texts[#texts+1]=t end,commandHub=function()end,hpColor=function()return 0,1,0,1 end}
local stack,rects,color,inks=0,{},{},{}
love={graphics={push=function()stack=stack+1 end,pop=function()stack=stack-1 end,
 setShader=function()end,setScissor=function()end,setColor=function(...)color={...}end,
 rectangle=function(mode,...)rects[#rects+1]={mode=mode,color=color}end,
 origin=function()end,scale=function()end,getDimensions=function()return 640,480 end}}
local Chrome={DEFAULT_BOX_PALETTE={{255,255,255},{255,255,255},{255,255,255},{0,0,0}},
 box=function()end,printThrough=function()end,printRightThrough=function()end,cursorThrough=function()end,
 paletteGlyphs=function(p)return p,function()inks[#inks+1]=p[4]end,function()end end}
local originalPrint=Chrome.printThrough
package.loaded['src.ui.gen2.Chrome']=Chrome
package.loaded['src.render.Font']={encode=function()return {65}end,advanceOf=function()return 8 end,width=function()return 8 end}
package.loaded['src.render.Renderer']={frameRects=function()return {vux=0,vuy=0,vuw=640,vuh=480}end}
local calls={hud=0,bottom=0};local fail=false
local State={drawEnemyHud=function()calls.hud=calls.hud+1;Chrome.printThrough('enemy',1,0)end,
 drawPlayerHud=function()calls.hud=calls.hud+1 end,
 drawBottom=function()calls.bottom=calls.bottom+1;Chrome.box(0,12,20,6);Chrome.printThrough('message',1,14);if fail then error('draw error')end end}
local savedEnemy,savedBottom=State.drawEnemyHud,State.drawBottom
package.loaded['src.ui.gen2.BattleState']=State
local Adapter=V.require('Gen2BattleUI');local undo=Adapter.install()
local s=setmetatable({phase='menu',showPlayerHud=true,showEnemyHud=true,battle={},menuIndex=1}, {__index=State})
function s:activeMon(side)return {name=side,level=5,hp=8,maxHp=10}end
function s:statusHUDVisible()return true end
function s:hudCleared()return false end
function s:name(mon)return mon.name end
function s:statusTag()return nil end
function s:hudHp(mon)return mon.hp end
function s:bottomUIVisible()return true end
function s:menuLabels()return {'FIGHT','PACK','PKMN','RUN'}end
s:drawEnemyHud();s:drawBottom();check(calls.hud==1 and calls.bottom==1,'OFF modern retains native UI')
UI.textboxFill:setIndex(2);s:drawBottom()
check(rects[#rects-1].color[4]==.30 and inks[#inks][1]==255,'HALF paper and white glyphs')
check(Chrome.printThrough==originalPrint and stack==0,'scoped UI state restored')
UI.textboxFill:setIndex(4);local before=#rects;s:drawBottom();check(#rects==before,'OFF paper draws no rectangle')
UI.battleUi:setIndex(2);s:drawEnemyHud();check(calls.hud==1,'TEXTBOX hides HUD')
UI.battleUi:setIndex(3);local n=calls.bottom;s:drawBottom();check(calls.bottom==n,'HUD hides textbox without changing controls')
UI.battleUi:setIndex(1);UI.hudColor:setIndex(2);s:drawEnemyHud();check(inks[#inks][1]==255,'INVERTED HUD uses white ink')
check(Adapter.backplate(s,0,0,12,4),'INVERTED native HUD has dark backing')
fail=true;local ok=pcall(s.drawBottom,s);check(not ok and Chrome.printThrough==originalPrint and stack==0,'native draw error restores text functions and state');fail=false
Mode.setting:setIndex(1);local nativeHud=calls.hud;local nativeBottom=calls.bottom
s:drawEnemyHud();s:drawPlayerHud();s:drawBottom()
check(calls.hud==nativeHud and calls.bottom==nativeBottom,'modern owns native HUD and command draw only')
local game={stack={top=function()return s end}}
hooks['render.hud'](function()return 'native' end,game,{})
check(cards==2 and buttons==4,'modern displays both status cards and native command choices')
check(texts[#texts]=='RUN','modern choices preserve native labels/order')
local ownedCards=cards
s.usesModernDoublesHud=function()return true end
hooks['render.hud'](function()end,game,{})
check(cards==ownedCards,'companion-owned singles must not draw a second modern HUD')
s.usesModernDoublesHud=function()return false end
hooks['render.hud'](function()end,game,{})
check(cards==ownedCards+2,'disabling companion HUD returns ownership to Battle Art')
s.usesModernDoublesHud=nil
local oldcards=cards;game.stack.top=function()return {}end
hooks['render.hud'](function()end,game,{})
check(cards==oldcards,'covering menu retains frame ownership')
s.battle.doubles=true;s:drawEnemyHud();check(calls.hud==nativeHud+1,'native doubles companion retains ownership')
undo();check(State.drawEnemyHud==savedEnemy and State.drawBottom==savedBottom,'unload restores native UI methods')
print('PASS '..checks..' Gen2 native battle option checks')
