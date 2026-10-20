local mode,volume,missing,failClone,failPlay='EMBER',.8,nil,nil,nil
local denyPlay
local sources={}
love={filesystem={newFileData=function(bytes,name)return{name=name,release=function()end}end},audio={}}
local function source(name,clone)
 local s={name=name,cloneVoice=clone,playing=false}
 function s:setLooping()end
 function s:clone()if failClone==self.name then error('clone failed')end;return source(self.name,true)end
 function s:setVolume(v)self.volume=v end
 function s:play()if failPlay==self.name then error('device failed')end;if denyPlay==self.name then return false end;self.playing=true end
 function s:isPlaying()return self.playing end
 function s:stop()self.playing=false;self.stopped=true end
 function s:release()self.released=true end
 sources[#sources+1]=s;return s
end
love.audio.newSource=function(data)return source(data.name,false)end
local settings={active=function()return true end,audio={get=function()return mode end},audioVolume={get=function()return volume end}}
local A=assert(loadfile('lib/EmberLegacyAudio.lua'))({require=function(name)assert(name=='PokeballSettings');return settings end,
 mod={read=function(_,path)if missing and path:find(missing,1,true)then return nil end;return 'sound'end}})
local battle={};A.nativeMaster(battle,function()return .5 end);assert(A.sync(battle))
local function playing()local n=0;for _,s in ipairs(sources)do if s.playing then n=n+1;assert(s.volume==.4)end end;return n end
assert(A.playSendoutGroup(1,{false,true}));assert(playing()==2)
assert(A.play('trail',1));local before=playing()
failPlay='poke_ball_send_out_shiny.ogg'
assert(not A.playSendoutGroup(2,{false,true}));assert(playing()==before,'partial failed group or unrelated voices removed')
failPlay=nil;failClone='poke_ball_send_out_shiny.ogg'
assert(not A.playSendoutGroup(2,{false,true}));assert(playing()==before);failClone=nil
denyPlay='poke_ball_send_out_shiny.ogg'
assert(not A.playSendoutGroup(2,{false,true}));assert(playing()==before);denyPlay=nil
denyPlay='poke_ball_send_out_shiny.ogg'
assert(not A.play('sendout',2,true));assert(playing()==before);denyPlay=nil
A.clear();missing='shiny';assert(A.sync(battle))
assert(not A.playSendoutGroup(1,{false,true}));assert(playing()==0,'missing second file left first playing')
A.clear();missing=nil;assert(A.sync(battle))
assert(not A.playSendoutGroup(1,{false,false}));assert(playing()==0)
for i=1,8 do assert(A.playSendoutGroup(i,{false,true}))end
assert(playing()==12,'voice bound exceeded')
mode='ORIGINAL';assert(not A.playSendoutGroup(1,{false,true}));assert(playing()==0)
for _,s in ipairs(sources)do assert(s.released,'source leaked after mode cleanup')end
print('PASS mixed sendout preflight, exact variants/volume, rollback without unrelated voice loss, bounded voices and OFF cleanup')
