local sound='off';local reads,steps=0,0
local sources={}
love={filesystem={newFileData=function(bytes,name)return name end},audio={newSource=function(name)
 local s={playing=false,volume=0}
 function s:setLooping(v)self.loop=v end
 function s:setVolume(v)self.volume=v end
 function s:setPitch(v)self.pitch=v end
 function s:isPlaying()return self.playing end
 function s:play()self.playing=true;if not self.loop then steps=steps+1 end end
 function s:stop()self.playing=false end
 function s:release()self.released=true end
 sources[name]=s;return s
end}}
local V={mod={read=function(_,path)reads=reads+1;return 'bytes' end},require=function(n)
 if n=='CommunityVisuals'then return{caveSoundLevel=function()return sound end}end
 if n=='NativeAtmosphere'then return{kind=function(map)return map and map.kind end}end
end}
local A=assert(loadfile('lib/NativeCaveAudio.lua'))(V)
local a=A.new();local cave={kind='cave'}
a:update(.1,cave,0,0,true,1);assert(reads==0)
sound='low';a:update(.1,cave,0,0,true,1);assert(reads==1 and steps==0)
a:update(.1,cave,8,0,true,1);assert(steps==0)
a:update(.1,cave,16,0,true,.5);assert(steps==1 and sources['sfx-cavestep.mp3'].volume==.41)
a:update(.1,cave,64,0,true,1);assert(steps==1,'warp emitted footsteps')
a:update(.1,cave,80,0,false,1);assert(steps==1)
for i=1,40 do a:update(.1,nil,0,0,false,1)end
assert(not sources['amb-cave.mp3'].playing and a.volume==0)
sound='mid';for i=1,40 do a:update(.1,cave,0,0,true,.5)end
assert(math.abs(a.volume-.31)<.0001)
sound='off';for i=1,40 do a:update(.1,cave,16,0,true,1)end
assert(a.volume==0 and steps==1)
a:clear();assert(sources['amb-cave.mp3'].released)
V.mod.read=function()error('not packaged')end
local absent=A.new();sound='mid';absent:update(.1,cave,0,0,true,1);absent:update(.1,cave,16,0,true,1)
assert(absent.sources['amb-cave.mp3']==false and absent.errors['sfx-cavestep.mp3'])
print('PASS native cave audio volume, OFF, fade, map/step boundaries and missing-asset fallback')
