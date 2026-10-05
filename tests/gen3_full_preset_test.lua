local writes={};local modules={}
local function setting(key,values,index)
 local s={values=values,index=index}
 function s:setIndex(i,game)self.index=i;writes[#writes+1]=key;game.options[key]=self.values[i]end
 function s:get()return self.values[self.index]end
 return s
end
modules.Gen3SceneOptions={tilt=setting('tilt',{0,1,2,3},1)}
modules.WorldCurve={setting=setting('curve',{0,1},2)}
modules.Water={setting=setting('water',{'full','off'},2)}
modules.Gen3Battle={setting=setting('battles',{true,false},2)}
modules.BattleArt={viewSetting=setting('view',{'front','back'},1)}
local day=setting('day',{'sync','night'},2)
modules.DayNight={forceSync=function(g)if day:get()~='sync'then day:setIndex(1,g)end end}
local V={require=function(n)return assert(modules[n],n)end}
local P=assert(loadfile('lib/Gen3FullPreset.lua'))(V)
local game={options={nativeTextSpeed=2}}
local state=P.new(3)
assert(not state:update(3,game) and #writes==0)
assert(state:update(1,game))
assert(game.options.tilt==3 and game.options.curve==0 and game.options.water=='full' and game.options.battles and game.options.view=='back' and game.options.day=='sync')
modules.Gen3Battle.setting:setIndex(2,game);modules.Gen3SceneOptions.tilt:setIndex(1,game)
local count=#writes;assert(not state:update(1,game) and #writes==count,'FULL resets edited settings each frame')
day:setIndex(2,game);state:update(1,game);assert(day:get()=='sync','FULL clock differs from Gen1')
state:update(3,game);day:setIndex(2,game);state:update(3,game);assert(day:get()=='night','FULL owns clock after exit')
local loaded=P.new(1);count=#writes;loaded:update(1,game)
assert(#writes==count+1 and modules.Gen3Battle.setting:get()==false,'loading FULL reapplied preset')
assert(game.options.nativeTextSpeed==2,'native UI preference changed')
print('PASS native FULL entry, edit retention, clock pin, exit, loaded-save preservation and native UI isolation')
