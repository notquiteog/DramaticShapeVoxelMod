-- API3 option pages register through public callbacks/screens; they never
-- replace the cart's native row builder or grouping functions.
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
local emitted=0;package.loaded['src.mods.Runtime']={emit=function()emitted=emitted+1 end}
local Rows={build=function()return'cart builder'end,group=function()return'cart grouping'end}
package.loaded['src.ui.game3.option_rows']=Rows
local build,group=Rows.build,Rows.group
local callbacks,factories={},{}
local game={options={modOptions={}},mods={modOptions={}}};local saved=0
function game:persistOptions()saved=saved+1 end
local pressed;game.input={wasPressed=function(_,key)return key==pressed end}
local mod={id='TEST',hooks={wrap=function(_,key,fn)callbacks[key]=fn end},content={screens={register=function(_,id,value)factories[id]=value end}}}
mod.options={get=function(_,key)local bucket=game.mods.modOptions.TEST;return bucket and bucket[key]end}
local opened
mod.ui={ListMenu={new=function(g,title,items,opts)
 assert(g==game);return{items=items,index=1,update=function()return'base update'end,
 close=function(self)self.closed=true end,onChoose=opts.onChoose}
end}}
mod.ui.push=function(g,id,...)opened=assert(factories[id]).new(g,...);return opened end
local schema={{key='enabled',label='FEATURE',type='toggle',default=false}}
dofile('lib/InGameOptions.lua').install(mod,schema,'TEST OPTIONS')
assert(Rows.build==build and Rows.group==group,'native cart functions overwritten')
local native={id='textSpeed',label='NATIVE TEXT SPEED'}
local out=callbacks['ui.options.rows'](function(_,r)return r end,game,{native,{id='cancel',label='CANCEL'}})
assert(#out==3 and out[1]==native and out[2].id=='TEST:settings'and out[3].id=='cancel')
out[2].activate(game);assert(opened.items[1].right=='OFF','false default lost')
opened.onChoose(opened.items[1],opened);assert(game.mods.modOptions.TEST.enabled==true and opened.items[1].right=='ON')
pressed='left';opened:update(0);assert(game.options.modOptions.TEST.enabled==false and saved==2 and emitted==2)
pressed=nil;assert(opened:update(0)=='base update')
local called=0;callbacks['core.quit_to_launcher'](function()called=called+1 end)
opened:update(0);assert(opened.closed and called==1)
local base={native};assert(callbacks['ui.options.rows'](function(_,r)return r end,game,base)==base and#base==1)
print('PASS API3 public row/screen registration, false choices, persistence, native ownership and unload')
