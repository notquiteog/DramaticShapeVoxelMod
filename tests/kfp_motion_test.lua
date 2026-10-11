local settings={}
local V={require=function(name)
 assert(name=='ModSetting')
 return {new=function(key,_,values)
  local s={value=values[1]};function s:get()return self.value end;settings[key]=s;return s
 end}
end}
local M=assert(loadfile('lib/KfpMotion.lua'))(V)
local me={px=0,py=0,lift=0};local map={}
local x,y,z=M.sample(me,map,0,0);assert(x==0 and y==0 and z==0)
me.lift=4;x,y,z=M.sample(me,map,0,.05);assert(y==0,'off must preserve engine arc')
settings.kfpJump.value='subtle';x,y,z=M.sample(me,map,0,.2);assert(math.abs(y-2.4)<.001)
me.lift=0;x,y,z=M.sample(me,map,0,.21);assert(y<0,'landing settle')
x,y,z=M.sample(me,map,0,1);assert(y==0,'settle ends')
settings.kfpJump.value='off';settings.kfpHeadBob.value=true
me.px=4;x,y,z=M.sample(me,map,0,1.1);assert(y~=0,'distance driven bob')
settings.kfpHeadBob.value=false;settings.kfpDoorstep.value=true
x,y,z=M.sample(me,{},0,1.2);x,y,z=M.sample(me,{},0,1.3)
-- Hold stable map identity, otherwise each sample is another warp.
map={};M.sample(me,map,0,2);x,y,z=M.sample(me,map,0,2.15)
assert(y<0 and z>0 and x==0,'door movement uses camera heading')
settings.kfpDoorstep.value=false;x,y,z=M.sample(me,map,0,2.16);assert(x==0 and y==0 and z==0)
assert(me.px==4 and me.py==0 and me.lift==0,'presentation must not change actor')
M.reset();x,y,z=M.sample(me,map,0,3);assert(x==0 and y==0 and z==0)
x,y,z=M.sample({px=0/0,py=0},map,0,3);assert(x==0 and y==0 and z==0)
print('PASS KFP cosmetic camera motion')
