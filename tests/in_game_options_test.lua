local Adapter=dofile('lib/InGameOptions.lua')
local generation=3
package.loaded['src.core.GameVersion']={generation=function()return generation end}
local events={};package.loaded['src.mods.Runtime']={emit=function(_,e)events[#events+1]=e end}
local Rows={build=function()return {{id='textSpeed',label='TEXT SPEED'}}end,group=function(r)return r end}
package.loaded['src.ui.game3.option_rows']=Rows
local game={options={modOptions={}},mods={modOptions={}},writeOptions=function(g)g.writes=(g.writes or 0)+1 end}
local schemas={{key='toggle',label='TOGGLE',type='toggle',default=true},{key='choice',type='choice',choices={{'ORIGINAL','original'},{'ART','art'}},default='original'},
 {key='number',type='number',default=2,min=1,max=3,step=1}}
local mods={}
for _,id in ipairs({'A','B'})do
 local m={id=id,hooks={},options={},callbacks={}}
 function m.options:get(key)
  local s=game.mods.modOptions[id];if s and s[key]~=nil then return s[key]end
  for _,r in ipairs(schemas)do if r.key==key then return r.default end end
 end
 function m.hooks:wrap(event,fn)m.callbacks[event]=fn end
 mods[id]=m;Adapter.install(m,schemas,id)
end
Adapter.install(mods.A,schemas,'A') -- hot reload leaves exactly one page
local ctx={game=game};local rows=Rows.build(ctx);assert(#rows==7 and rows[1].id=='textSpeed')
local title,page
local groups=Rows.group(rows,function(t,p)title,page=t,p end);assert(#groups==3)
for _,r in ipairs(groups)do if r.id=='A:settings'then r.activate(ctx)end end;assert(title=='A' and #page==3)
assert(page[1].value()=='ON');page[1].step(ctx,1);assert(page[1].value()=='OFF' and game.options.modOptions.A.toggle==false)
page[2].step(ctx,-1);assert(page[2].value()=='ART')
page[3].step(ctx,8);assert(page[3].value()=='3','numeric max not clamped')
assert(events[1].mod=='A' and events[1].value==false and game.writes==3)
mods.A.callbacks['core.quit_to_launcher'](function()end)
assert(#Rows.build(ctx)==4,'unload lost another mod or kept stale rows')
generation=2
Adapter.install(mods.A,schemas)
local hook=mods.A.callbacks['ui.options.rows']
local out=hook(function(_,r)return r end,game,{{label='no id'},{id='cancel',label='BACK'}})
assert(#out==5 and out[5].id=='cancel','GB settings appeared below BACK')
local again=hook(function(_,r)return r end,game,out);assert(#again==5,'duplicate settings')
print('PASS independent native pages, false/choice/number persistence, events, unload composition and GB placement')
