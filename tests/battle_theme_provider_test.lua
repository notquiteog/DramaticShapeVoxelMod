local provider
local V={mod={find=function()return provider end}}
local T=assert(loadfile('lib/BattleTheme.lua'))(V)
local fallback=T.panel
assert(type(fallback)=='function')
provider={exports={apiVersion=1,enabled=function()return true end,battleTheme={apiVersion=1,panel=function()return 'modern' end}}}
assert(T.panel()=='modern' and type(T.text)=='function','theme not delegated or partial fallback lost')
provider.exports.enabled=function()return false end;assert(T.panel==fallback)
provider.exports.enabled=function()error('provider failure')end;assert(T.panel==fallback)
provider.exports.enabled=function()return true end;provider.exports.apiVersion=2;assert(T.panel==fallback)
V.mod.find=function()error('loader failure')end;assert(T.panel==fallback)
print('PASS optional late-bound theme, OFF, partial API and errors')

local colors={}
love={graphics={setColor=function(...)colors[#colors+1]={...}end,polygon=function()end,rectangle=function()end,line=function()end}}
local paper=T.paper;T.statusCard(0,0,40,20,20,false,{paper={.07,.1,.13,.96}})
assert(colors[2][1]==.07 and colors[5][1]==.07 and T.paper==paper,'fallback card style did not reach pointer and panel without mutation')
local supplied
V.mod.find=function()return {exports={apiVersion=1,enabled=function()return true end,battleTheme={apiVersion=1,statusCard=function(x,y,w,h,tip,selected,style)supplied=style end}}}end
T.statusCard(0,0,40,20,20,false,{paper={.07,.1,.13,.96}})
assert(supplied.paper[1]==.07,'provider did not receive per-card style')

-- Mobile insets are read through the public engine API, never OS guesses.
local rect={24,12,592,436}
package.loaded['src.core.SafeArea']={rect=function()return unpack(rect)end}
local x,y,w,h=T.viewport(640,480);assert(x==24 and y==12 and w==592 and h==436)
rect={0,32,360,580};x,y,w,h=T.viewport(360,640);assert(y==32 and h==580,'rotation reused old inset')
rect={900,0,10,10};x,y,w,h=T.viewport(640,480);assert(x==0 and w==640,'invalid inset escaped window')
package.loaded['src.core.SafeArea'].rect=function()error('backend unavailable')end
x,y,w,h=T.viewport(640,480);assert(x==0 and y==0 and w==640 and h==480)
print('PASS public safe area, rotation, invalid/backend fallback without native UI changes')

local color=true
V.require=function(name)assert(name=='UiBackplates');return {hudUsesColor=function()return color end}end
local card
provider={exports={apiVersion=1,enabled=function()return true end,battleTheme={apiVersion=1,combatCard=function(...)card=select(7,...);return true end}}}
V.mod.find=function()return provider end
local original={name='TEST'}
for _,value in ipairs({true,false})do color=value;assert(T.combatCard(0,0,90,18,0,false,original));assert(card.hudColor==(value and 'COLOR'or'INVERTED'));assert(original.hudColor==nil)end
provider.exports.enabled=function()return false end;assert(not T.combatCard(0,0,90,18,0,false,original))
print('PASS shared semantic HUD color and independent OFF fallback')
