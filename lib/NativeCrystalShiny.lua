-- The native shiny sequence selects the real battlers and owns its continuation.
-- Supply Crystal's bundled sequence as ordinary VM sprites, including doubles.
local V=...
local M={}
local Crystal=V.require('NativeCrystalArt')
local Assets=require('src.render.Assets')
local Anim=require('src.core.game3.battle.anim')
local Vm=require('src.core.game3.battle.anim_vm')
local Callbacks=require('src.core.game3.battle.anim_callbacks')
local Sprites=require('src.core.game3.battle.anim_sprites')
local Audio=require('src.core.game3.audio')
local name='BattleArtCrystalShiny'
-- Authored GB coordinates relative to the original enemy center (120,40).
local sequence={{6,-8,-18,1},{14,12,-12,1},{22,18,8,1},{30,2,19,1},
 {38,-19,12,1},{46,-22,-7,1},{54,-4,-1,2}}
local image,quads,source,duration,current
local function stop()
 if source then source:stop()end
 current=nil
end
local function resources()
 if image and source then return true end
 local base=V.mod.path..'/assets/crystal/shiny_visuals/'
 local ok,img=pcall(Assets.image,base..'gen2_sparkles.png')
 if not ok or not img then return false end
 local audioOK,sound=pcall(love.audio.newSource,base..'gen2_shiny_sparkle.mp3','static')
 if not audioOK or not sound then return false end
 local w,h=img:getDimensions()
 if w<64 or h<16 then sound:release();return false end
 image,source,quads=img,sound,{}
 image:setFilter('nearest','nearest')
 for i=1,4 do quads[i]=love.graphics.newQuad((i-1)*16,0,16,16,w,h)end
 -- Legacy Crystal finishes at the end of this sound. Use VM frames so mute,
 -- pause and audio-driver timing cannot strand the battle continuation.
 duration=math.max(1,math.ceil(source:getDuration('seconds')*60))
 return true
end
local function frame(age)
 if age<0 or age>=24 then return end
 if age<4 then return 1 elseif age<9 then return 2 elseif age<15 then return 3 elseif age<20 then return 4 end
 return 1
end
local function draw(sprite)
 if not current or not Crystal.active()then return end
 local g=love.graphics
 local r,gc,b,a=g.getColor();g.setColor(1,1,1,1)
 for _,s in ipairs(sequence)do
  local f=frame(sprite._crystalAge-s[1])
  if f then g.draw(image,quads[f],math.floor(sprite.x+s[2]),math.floor(sprite.y+s[3]),0,s[4],s[4],8,8)end
 end
 g.setColor(r,gc,b,a)
end
function M.install()
 local launch,reset,update,callback=Anim.launchShiny,Anim.reset,Anim.update,Callbacks[name]
 local installed=true
 Callbacks[name]=function(sprite)
  local state=sprite._vm.ctx[name]
  if not installed or not state or state~=current or not Crystal.active()then Sprites.release(sprite);return end
  if not state.started then
   state.started=true;source:setVolume(Audio._sfxVolume or 1);source:play()
  end
  sprite._crystalAge=(sprite._crystalAge or -1)+1
  if sprite._crystalAge>=duration then Sprites.release(sprite);return end
  sprite.customDraw=draw
 end
 Anim.launchShiny=function(key,opts)
  if not Crystal.active()or Anim._headless or(opts and opts.headless)or not resources()then return launch(key,opts)end
  -- Scope the VM substitution to the original launchShiny call. Its native
  -- ID/side resolution, caller options and return value remain authoritative.
  local original=Vm.launch
  Vm.launch=function(vm,script,o)
   Vm.launch=original
   if vm.headless then return original(vm,script,o)end
   stop()
   local state={};current=state
   local copy={};for k,v in pairs(o or{})do copy[k]=v end
   copy.ctx={};for k,v in pairs((o and o.ctx)or{})do copy.ctx[k]=v end
   copy.ctx[name]=state
   local onEnd=copy.onEnd
   copy.onEnd=function(...)
    if current==state then stop()end
    if onEnd then return onEnd(...)end
   end
   local ops={}
   for _,role in ipairs(copy.targetId~=copy.attackerId and{'attacker','target'}or{'attacker'})do
    ops[#ops+1]={op='createsprite',noGfx=true,callback=name,animBattler=role,subpriority=5,w=16,h=16}
   end
   ops[#ops+1]={op='waitforvisualfinish'};ops[#ops+1]={op='end'}
   return original(vm,ops,copy)
  end
  local result={pcall(launch,key,opts)};Vm.launch=original
  if not result[1]then stop();error(result[2],0)end
  return unpack(result,2)
 end
 Anim.reset=function(...)stop();return reset(...)end
 Anim.update=function(...)
  if current then
   local vm=Anim.vm()
   if not Crystal.active()or not vm or not vm.active or vm.ctx[name]~=current then stop()
   elseif source then source:setVolume(Audio._sfxVolume or 1)end
  end
  return update(...)
 end
 return function()
  installed=false;stop()
  Anim.launchShiny,Anim.reset,Anim.update,Callbacks[name]=launch,reset,update,callback
 end
end
Assets.register({release=function()
 stop();if source then source:release()end
 if quads then for _,q in ipairs(quads)do q:release()end end
 image,quads,source,duration=nil,nil,nil,nil
end})
return M
