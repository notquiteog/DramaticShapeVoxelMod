local n=0;local function check(v,m)n=n+1;assert(v,m)end
local active,missing,fail=true,false,false
local draws,color={}, {0.2,0.4,0.6,0.8}
local sound={plays=0,stops=0,release=function()end,getDuration=function()return .975 end}
function sound:play()self.plays=self.plays+1 end
function sound:stop()self.stops=self.stops+1 end
function sound:setVolume(v)self.volume=v end
love={audio={newSource=function()return sound end},graphics={
 newQuad=function(x)return{x=x,release=function()end}end,
 getColor=function()return unpack(color)end,setColor=function(...)color={...}end,
 draw=function(...)draws[#draws+1]={...}end}}
local image={getDimensions=function()return 64,16 end,setFilter=function()end}
local release
package.loaded['src.render.Assets']={image=function()if not missing then return image end end,register=function(t)release=t.release end}
local Callbacks={};package.loaded['src.core.game3.battle.anim_callbacks']=Callbacks
package.loaded['src.core.game3.battle.anim_sprites']={release=function(s)s.active=false end}
local Audio={_sfxVolume=.3};package.loaded['src.core.game3.audio']=Audio
local Vm={};local vm=setmetatable({},{__index=Vm})
function Vm:launch(script,opts)
 self.script,self.opts,self.ctx,self.active=script,opts,opts.ctx or{},true
 if self.headless or opts.headless then self.active=false;if opts.onEnd then opts.onEnd()end end
 return 'native-result'
end
local vmLaunch=Vm.launch
package.loaded['src.core.game3.battle.anim_vm']=Vm
local Anim={vm=function()return vm end,reset=function(v)vm.active=false;return v end,update=function(v)return v end}
function Anim.launchShiny(key,opts)
 if fail then error('native launch error')end
 local o={};for k,v in pairs(opts or{})do o[k]=v end
 o.attackerId=key;o.targetId=(opts and opts.keys and opts.keys[2])or key
 return vm:launch({{op='native'}},o)
end
local launch,reset,update=Anim.launchShiny,Anim.reset,Anim.update
package.loaded['src.core.game3.battle.anim']=Anim
local V={mod={path='.'},require=function(name)assert(name=='NativeCrystalArt');return{active=function()return active end}end}
local M=assert(loadfile('lib/NativeCrystalShiny.lua'))(V);local undo=M.install()
local done=0;local ctx={other='preserved'};local opts={ctx=ctx,onEnd=function()done=done+1 end}
check(Anim.launchShiny(1,opts)=='native-result','native return preserved')
check(Vm.launch==vmLaunch and vm.script[1].callback=='BattleArtCrystalShiny','scoped VM substitution restored')
check(vm.ctx~=ctx and vm.ctx.other=='preserved'and not ctx.BattleArtCrystalShiny,'caller context untouched')
check(vm.opts.attackerId==1 and vm.opts.targetId==1 and #vm.script==3,'native single ID resolution retained')
local cb=Callbacks.BattleArtCrystalShiny
local s={active=true,_vm=vm,x=176,y=40}
for i=0,6 do cb(s)end
s:customDraw();check(#draws==1 and draws[1][2].x==0 and draws[1][3]==168 and draws[1][4]==22,'authored first sparkle and native anchor')
check(color[1]==.2 and color[4]==.8,'draw restores color')
check(sound.plays==1 and sound.volume==.3,'single sound uses native SFX volume')
for i=7,14 do cb(s)end
draws={};s:customDraw();check(#draws==2 and draws[1][2].x==16,'overlapping sequence and frame durations')
for i=15,58 do cb(s)end
check(s.active and done==0,'wait belongs to VM until sound duration')
cb(s);check(not s.active and done==0,'controller releases without calling continuation')
vm.opts.onEnd();check(done==1,'native completion continuation once')
Anim.launchShiny(3,{keys={3,1}})
check(#vm.script==4 and vm.opts.attackerId==3 and vm.opts.targetId==1 and vm.script[2].animBattler=='target','native doubles IDs retained')
local a,b={active=true,_vm=vm,x=10,y=20},{active=true,_vm=vm,x=30,y=40}
cb(a);cb(b);check(sound.plays==2,'double controllers share one sound')
Audio._sfxVolume=0;check(Anim.update(9)==9 and sound.volume==0,'live mute and native update return')
active=false;Anim.update();cb(a);cb(b);check(not a.active and not b.active,'toggle off releases owned sprites')
Anim.launchShiny(0,opts);check(vm.script[1].op=='native','unselected pack native fallback')
active=true;Anim.launchShiny(0,{headless=true,onEnd=function()done=done+1 end})
check(vm.script[1].op=='native'and done==2,'headless native completion')
Anim.launchShiny(0);cb({active=true,_vm=vm});vm.ctx={};local stops=sound.stops
Anim.update();check(sound.stops>stops,'interrupted VM stops custom audio')
Anim.launchShiny(0);check(Anim.reset('result')=='result','native reset return preserved')
fail=true;check(not pcall(Anim.launchShiny,0)and Vm.launch==vmLaunch,'error restores VM seam');fail=false
release();missing=true;Anim.launchShiny(0);check(vm.script[1].op=='native','missing bundled art native fallback')
missing=false;love.audio.newSource=function()error('missing sound')end
Anim.launchShiny(0);check(vm.script[1].op=='native','missing bundled audio native fallback')
undo();check(Anim.launchShiny==launch and Anim.reset==reset and Anim.update==update and not Callbacks.BattleArtCrystalShiny,'uninstall restores all native seams')
print('PASS '..n..' native Crystal shiny contracts')
