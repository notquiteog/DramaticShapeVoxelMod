local calls=0
local input={isDown=function(_,key)return key=='up' or key=='a' end}
local World={pollInput=function(self,pad)
 calls=calls+1
 self.heldDir=nil
 for _,key in ipairs({'up','down','left','right'}) do if pad:isDown(key) then self.heldDir=key;break end end
 assert(pad:isDown('a'),'A was swallowed')
 return 'native'
end}
package.loaded['src.world.gen2.World']=World
local active=true
local FP={driving=function()return active end,moveVector=function()return 0,1 end,moveWorld=function()return 1,0 end}
local Walk=assert(loadfile('lib/Gen2CameraWalk.lua'))({require=function(id)assert(id=='FirstPerson');return FP end})
assert(Walk.available());Walk.install();local installed=World.pollInput;Walk.install();assert(World.pollInput==installed)
local world=setmetatable({busy=function()return false end},{__index=World})
assert(world:pollInput(input)=='native' and world.heldDir=='right')
assert(input:isDown('up') and not input:isDown('right'),'original input mutated')
active=false;world:pollInput(input);assert(world.heldDir=='up','menu input transformed')
active=true;world.busy=function()return true end;world:pollInput(input);assert(world.heldDir=='up','script input transformed')
assert(calls==3,'native input called twice or bypassed')
assert(Walk.direction(0,0)==nil and Walk.direction(-1,.2)=='left' and Walk.direction(.2,-1)=='up')
print('Gen 2 camera input rotation, native delegation, idle/menu/script guards passed')
