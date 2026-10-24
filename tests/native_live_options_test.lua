local Options=dofile('lib/InGameOptions.lua')
local build={build=function()return{}end,group=function(rows)return rows end}
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
package.loaded['src.ui.game3.option_rows']=build
local changed
package.loaded['src.mods.Runtime']={emit=function(_,event)changed=event end}
local raw=1;local preset=true
local live={values={'off','full'},read=function()return raw end}
function live:row()return{value=function()return preset and 'PRESET' or self.values[raw]end,
 step=function(_,dir)preset=false;raw=raw==1 and 2 or 1;return true end}end
local hooks={};local mod={id='test',hooks={wrap=function(_,id,fn)hooks[id]=fn end},options={get=function()return 'off'end},content={screens={}}}
local factory;function mod.content.screens:register(_,value)factory=value.new end
local menu
mod.ui={ListMenu={new=function(game,title,items)return{items=items,update=function()end,close=function()end}end},push=function(game,_,...)menu=factory(game,...)end}
Options.install(mod,{{key='x',type='choice',choices={{'OFF','off'},{'FULL','full'}}}},'TEST',nil,{x=live})
local game={};local items=hooks['ui.options.rows'](function(_,r)return r end,game,{})
items[1].activate(game);local row=menu.items[1].row
assert(row.value()=='PRESET','native row ignores effective preset')
row.step({game={}},1)
assert(not preset and row.value()=='full' and changed.key=='x' and changed.value=='full','child edit did not use native live row')
hooks['core.quit_to_launcher'](function()end)
assert(#hooks['ui.options.rows'](function(_,r)return r end,game,{})==0)
print('PASS effective native row, CUSTOM switch, event and unload')
