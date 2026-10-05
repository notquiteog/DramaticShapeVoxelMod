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
