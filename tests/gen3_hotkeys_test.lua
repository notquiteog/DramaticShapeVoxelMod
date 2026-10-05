local root=os.getenv('DS_MOD_PATH')or'.'
local writes=0
local function setting()
 return {value=0,cycle=function(self,game)self.value=self.value+1;writes=writes+1;game.saved=self.value end}
end
local mods={VoxelGrid={setting=setting()},WorldCurve={setting=setting()},Water={setting=setting()}}
local H=assert(loadfile(root..'/lib/Gen3Hotkeys.lua'))({require=function(name)return assert(mods[name])end})
local game={input={keyBindings={}},zoomGateOK=function(self)return not self.locked end}
local cameraLevel
local camera={level=3,setLevel=function(level,g)cameraLevel=level;assert(g==game)end}
local scene={tilt=setting()};local stage={setting=setting()}
local function key(k,phase,look,field)return H.handle(game,{key=k,phase=phase or'pressed'},camera,scene,stage,look,field)end
for _,k in ipairs({'5','7','8','9'})do
 local before=writes
 assert(key(k,'pressed',true,true)and writes==before+1)
 assert(key(k,'released',true,true)and writes==before+1,'release toggled twice')
 assert(not key(k,'pressed',false,false)and writes==before+1,'battle/menu changed field mode')
 game.locked=true;assert(not key(k,'pressed',true,true));game.locked=false
 game.input.captureArmed=true;assert(not key(k,'pressed',true,true));game.input.captureArmed=false
 game.input.keyBindings[k]='a';assert(not key(k,'pressed',true,true));game.input.keyBindings[k]=nil
end
assert(mods.VoxelGrid.setting.value==1 and mods.WorldCurve.setting.value==1 and mods.Water.setting.value==1 and stage.setting.value==1)
assert(key('3','pressed',true,false)and cameraLevel==4,'recap camera cycle')
assert(key('3','released',true,false))
stage.active=true;assert(key('6','pressed',false,false)and scene.tilt.value==1,'battle tilt')
assert(not key('5','pressed',false,false),'battle scenery gate')
assert(not key('q','pressed',true,true)and not H.handle(game,nil,camera,scene,stage,true,true))
print('PASS native hotkeys, persistence calls, field gates and binding ownership')
