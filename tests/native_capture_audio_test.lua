local voices={};local exists=true
local function sound()
 local s={volume=0,playing=false}
 function s:setLooping()end
 function s:setVolume(v)self.volume=v end
 function s:play()self.playing=true end
 function s:isPlaying()return self.playing end
 function s:stop()self.playing=false end
 function s:release()end
 function s:clone()local v=sound();voices[#voices+1]=v;return v end
 return s
end
love={filesystem={newFileData=function()return {release=function()end}end},audio={newSource=function()return sound()end}}
local mode='EMBER';local V={mod={read=function()if exists then return 'sample'end end}}
function V.require(k)
 assert(k=='PokeballSettings');return {active=function()return true end,audio={get=function()return mode end},audioVolume={get=function()return .75 end}}
end
local A=assert(loadfile('lib/EmberLegacyAudio.lua'))(V)
local battle={game={save={options={sfxVol=7}}}}
A.beginCapture(battle);assert(A.capture('throw'));assert(voices[#voices].volume==.75,'Gen1 master semantics changed')
local level=.25;A.nativeMaster(battle,function()return level end)
assert(A.capture('open'));assert(voices[#voices].volume==.1875)
level=0;A.sync(battle);assert(voices[#voices].volume==0,'live native master ignored')
mode='ORIGINAL';assert(not A.sync(battle));assert(not voices[#voices].playing)
mode='EMBER';exists=false;A.clear();A.beginCapture(battle);assert(not A.capture('throw'),'missing asset claimed playback')
print('PASS shared capture audio: Gen1 master unchanged, native master and OFF live, missing assets silent')
