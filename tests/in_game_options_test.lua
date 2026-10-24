local Adapter=dofile('lib/InGameOptions.lua')
local generation=3
package.loaded['src.core.GameVersion']={generation=function()return generation end}
local events={};package.loaded['src.mods.Runtime']={emit=function(_,e)events[#events+1]=e end}
local Rows={build=function()return {{id='textSpeed',label='TEXT SPEED'}}end,group=function(r)return r end}
package.loaded['src.ui.game3.option_rows']=Rows
local game={options={modOptions={}},mods={modOptions={}},writeOptions=function(g)g.writes=(g.writes or 0)+1 end}
local schemas={{key='toggle',label='TOGGLE',type='toggle',default=true},{key='choice',type='choice',choices={{'ORIGINAL','original'},{'ART','art'}},default='original'},
 {key='number',type='number',default=2,min=1,max=3,step=1}}
local mods={};local opened
for _,id in ipairs({'A','B'})do
 local m={id=id,hooks={},options={},callbacks={},content={screens={}}};local factories={}
 function m.options:get(key)
  local b=game.mods.modOptions[id];if b and b[key]~=nil then return b[key]end
  for _,r in ipairs(schemas)do if r.key==key then return r.default end end
 end
 function m.hooks:wrap(event,fn)m.callbacks[event]=fn end
 function m.content.screens:register(key,value)factories[key]=value end
 m.ui={ListMenu={new=function(g,title,items,opts)
  return{title=title,items=items,index=1,update=function()end,close=function()end}
 end}}
 m.ui.push=function(g,key,...)opened=factories[key].new(g,...);return opened end
 mods[id]=m;Adapter.install(m,schemas,id)
end
Adapter.install(mods.A,schemas,'A')
local function allRows()
 local out={{id='textSpeed',label='TEXT SPEED'}}
 for _,id in ipairs({'A','B'})do out=mods[id].callbacks['ui.options.rows'](function(_,r)return r end,game,out)end
 return out
end
local out=allRows();assert(#out==3 and out[1].id=='textSpeed')
for _,r in ipairs(out)do if r.id=='A:settings'then r.activate(game)end end
assert(opened.title=='A'and #opened.items==4)
local page={};for _,item in ipairs(opened.items)do if item.row then page[#page+1]=item.row end end
assert(page[1].value()=='ON');page[1].step(game,1);assert(page[1].value()=='OFF'and game.options.modOptions.A.toggle==false)
page[2].step(game,-1);assert(page[2].value()=='ART')
page[3].step(game,8);assert(page[3].value()=='3')
assert(events[1].mod=='A'and events[1].value==false and game.writes==3)
mods.A.callbacks['core.quit_to_launcher'](function()end)
assert(#allRows()==2,'unload lost another mod or kept stale settings')

generation=2
Adapter.install(mods.A,schemas)
local hook=mods.A.callbacks['ui.options.rows']
local out=hook(function(_,r)return r end,game,{{label='no id'},{id='cancel',label='BACK'}})
assert(#out==5 and out[5].id=='cancel','GB settings appeared below BACK')
local again=hook(function(_,r)return r end,game,out);assert(#again==5,'duplicate settings')
local get=mods.A.options.get;mods.A.options.get=function()return nil end
local fallback=hook(function(_,r)return r end,game,{{id='cancel'}})
assert(fallback[1].value()=='ON','unset toggle ignored true schema default')
mods.A.options.get=get
print('PASS independent native pages, false/choice/number persistence, events, unload composition and GB placement')

-- A pipeline row is editable through its existing owner, never a second
-- modOptions bucket, and must deduplicate the engine's own row.
local level=0
package.loaded['src.render.Pipelines']={level=function()return level end,
 levelLabel=function(_,n)return tostring(n)end,cycle=function(_,d)level=(level+d)%4 end,
 syncOptions=function(o)o.pipelines={tiltshift=level}end}
Adapter.install(mods.A,{{key='tiltshift',label='T-SHIFT',pipeline='tiltshift'}},'A')
local hook=mods.A.callbacks['ui.options.rows']
local rows=hook(function(_,r)return r end,game,{{id='cancel'}})
assert(rows[1].id=='pipeline:tiltshift' and rows[1].value()=='0')
rows[1].step(game,1)
assert(level==1 and game.options.pipelines.tiltshift==1 and rows[1].value()=='1')
assert(game.options.modOptions.A.tiltshift==nil,'pipeline got a duplicate setting')
local existing={id='pipeline:tiltshift'}
rows=hook(function(_,r)return r end,game,{existing,{id='cancel'}})
assert(#rows==2 and rows[1]==existing,'duplicate pipeline row')
print('PASS GB pipeline settings retain live owner, persistence and deduplication')
