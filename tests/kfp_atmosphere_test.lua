local options,reads,sources={},{},{}
local V={mod={read=function(_,path)reads[#reads+1]=path;if path:match('^vendor/')then return 'audio'end end}}
V.require=function(name)
 assert(name=='ModSetting');return {new=function(key,_,values)
 local s={value=values[1]};function s:get()return self.value end;options[key]=s;return s end}
end
love={filesystem={newFileData=function()return {release=function()end}end},audio={newSource=function()
 local s={plays=0,playing=false};function s:setLooping(v)self.loop=v end
 function s:setVolume(v)self.volume=v end;function s:play()self.plays=self.plays+1;self.playing=true end
 function s:stop()self.playing=false end;function s:isPlaying()return self.playing end;function s:release()self.released=true end
 sources[#sources+1]=s;return s end}}
local M=assert(loadfile('lib/KfpAtmosphere.lua'))(V)
assert(M.read('../../secret')==nil and #reads==0)
assert(M.read('amb-cave.mp3')=='audio' and #reads==2,'zip-aware fallback')
local a=M.new();local f={map='a',kind='town',x=0,z=0}
a:update(f,.1,1,true);assert(#sources==0,'default off avoids loading')
options.kfpAmbience.value='mid';a:update(f,.1,1,true);assert(a.sources['amb-town.mp3'].playing)
a:update(f,.1,0,true);assert(a.sources['amb-town.mp3'].volume==0,'mute immediate')
options.kfpFootsteps.value=true;f.grass=true;a:update(f,.1,1,true);f.x=8;a:update(f,.1,1,true)
assert(a.sources['sfx-grass1.mp3'].plays==1)
f.x=80;a:update(f,.1,1,true);assert(not a.sources['sfx-grass2.mp3'],'teleport is not stride')
options.kfpDoorSounds.value=true;f={map='room',kind='room',shop=true,x=0,z=0};a:update(f,.1,1,true)
assert(a.sources['sfx-shopdoor.mp3'].plays==1)
f={map='cave',kind='cave',x=0,z=0};a:update(f,.1,1,true)
assert(not a.sources['amb-cave.mp3'],'existing cave owner not duplicated')
a:clear();for _,s in ipairs(sources)do assert(s.released)end
print('PASS KFP bounded optional audio and asset ownership')
