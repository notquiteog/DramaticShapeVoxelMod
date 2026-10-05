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
