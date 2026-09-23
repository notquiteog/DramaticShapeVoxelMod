local settings={}
local V={}
local nativePanel,nativeText,nativeMessage=0,0,0
local color
local Chrome={drawPanel=function()nativePanel=nativePanel+1 end}
local Font={COLOR={WHITE='white',NORMAL='normal'},draw=function(_,x,y,opts)
 nativeText=nativeText+1;color=opts and opts.colors;return 4,x+4,y
end}
local Message={_frame='battle',drawText=function()nativeMessage=nativeMessage+1 end}
package.loaded['src.ui.game3.battle_chrome']=Chrome
package.loaded['src.ui.game3.frlg_font']=Font
package.loaded['src.ui.game3.message']=Message
local draw={}
love={graphics={push=function()end,pop=function()end,setShader=function()end,
 setColor=function(...)draw.color={...}end,rectangle=function(mode,...)draw[mode]={...}end}}
local setting={new=function(key,_,values)
 local row={value=values[1],get=function(self)return self.value end};settings[key]=row;return row
end}
local theme={scale=function()return 3 end,paper={1,1,1,1},statusCard=function()draw.paper=theme and theme.paper end}
-- Assign separately so the callback captures the local table.
theme.statusCard=function()draw.paper=theme.paper end
V.require=function(name)
 if name=='ModSetting'then return setting end
 if name=='BattleTheme'then return theme end
 if name=='UiBackplates'then
  V.ui=V.ui or assert(loadfile('lib/UiBackplates.lua'))(V);return V.ui
 end
 error(name)
end
local O=assert(loadfile('lib/Gen3BattleOptions.lua'))(V)
local stage={active=true};local undo=O.install(stage)
Chrome.drawPanel('menu');assert(nativePanel==1,'outside battle draw was changed')
O.drawing=true;Chrome.drawPanel('menu');assert(nativePanel==1 and draw.fill[2]==112)
Font.draw('Move',10,122,{colors='old'});assert(color=='normal')
settings.textboxFill.value='BLACK';Font.draw('Move',10,122,{});assert(color=='white')
settings.battleUi.value='HUD';local n=nativeText;Font.draw('Move',10,122,{});assert(nativeText==n)
Message.drawText();assert(nativeMessage==0)
Font.draw('Name',10,20,{colors='original'});assert(color=='original')
package.loaded['src.ui.game3.bag_menu']={isOpen=function()return true end}
Chrome.drawPanel('menu');assert(nativePanel==2,'bag retained wrong chrome')
Font.draw('Bag',10,122,{colors='bag'});assert(color=='bag')
Message.drawText();assert(nativeMessage==1)
package.loaded['src.ui.game3.bag_menu']=nil
settings.hudColor.value='INVERTED';local paper=theme.paper;O.card();assert(draw.paper[1]<.1 and theme.paper==paper)
assert(O.ink()[1]>.9)
assert(O.hudScale(1920,1080)==3);settings.hudScale.value='og';assert(O.hudScale(1920,1080)==6.75)
undo();Chrome.drawPanel('menu');assert(nativePanel==3);assert(not O.drawing)
print('PASS native battle option scope, visibility, matching textbox ink, bag isolation, modern card palette/scale and restoration')
