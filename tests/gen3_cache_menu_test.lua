local hook;local actions={};local options,choose,done,text;local saved=true;local dropped=false
local Start={cursor=3,close=function(silent)assert(silent);actions[#actions+1]='close'end,
 show=function(o)assert(o.game=='game'and o.session=='session'and o.cursor==3);actions[#actions+1]='start'end}
package.loaded['src.ui.game3.start_menu']=Start
package.loaded['src.ui.game3.choice']={multi=function(o,index,cb)options=o;choose=cb;assert(index==0)end}
package.loaded['src.ui.game3.message']={show=function(t,o)text=t;done=o.done end}
local cache={saveRamToDisk=function()return saved,saved and 2 or 0,saved and 0 or 2 end,drop=function()dropped=true end}
local V={mod={hooks={wrap=function(_,name,cb)assert(name=='ui.start_menu.items');hook=cb end}},require=function(name)assert(name=='NativeGeometryCache');return cache end}
assert(loadfile('lib/Gen3CacheMenu.lua'))(V).install()
local function next(_,items)return items end
local items={{id='party'},{id='save',label='SAVE'}}
assert(hook(next,'game',false)==false)
hook(next,'game',items);assert(#items==3 and items[2].label=='CACHE');hook(next,'game',items);assert(#items==3)
items[2].onSelect('game','session');assert(options[1]=='SAVE'and options[2]=='DROP'and options[3]=='CANCEL')
choose(0);assert(text=='CACHE SAVED\n2 FILES');done();saved=false;choose(0);assert(text:find('FAILED'));done()
choose(1);assert(dropped and text=='MODEL RAM CACHE DROPPED');done();choose(127);assert(actions[2]=='start')
print('PASS native CACHE insertion, duplicate guard, SAVE/failure/DROP and cancel-to-parent')
