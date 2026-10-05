local enabled=true;local setting={get=function()return enabled end}
local releases={};package.loaded['src.render.Assets']={register=function(x)releases[#releases+1]=x.release end}
local frame=1;local atlas={};local drawn=0;local push=0
local V={mod={},require=function(n)
 if n=='CrystalSprites'then return {fullBody=setting}end
 if n=='BattleArt'then return {isShiny=function(b)return b.mon.shiny end}end
 if n=='Crystal/full_body'then return function(_,dex,shiny)return function(mon)
  if dex(mon.species)>251 then return nil end
  return {image=atlas,quad={},frame=frame,width=32,height=40,variant=shiny(mon)}
 end end end
end}
love={graphics={newCanvas=function(w,h)return {w=w,h=h,setFilter=function()end,release=function(s)s.released=true end}end,
 push=function()push=push+1 end,pop=function()push=push-1 end,draw=function()drawn=drawn+1 end}}
for _,k in ipairs{'setCanvas','origin','setShader','setScissor','setDepthMode','setBlendMode','clear','setColor'}do love.graphics[k]=function()end end
local F=assert(loadfile('lib/NativeFullBody.lua'))(V);F.install()
local image=F.image({species=1});assert(image.w==32 and image.h==40 and push==0)
assert(F.image({species=1})==image and drawn==1,'frame decoded repeatedly')
frame=2;assert(F.image({species=1})~=image and drawn==2)
enabled=false;assert(not F.image({species=1}));enabled=true
assert(not F.image({species=252}),'missing species must retain native fallback')
releases[1]();assert(image.released)
local side,mode,owns='back','animated',true
local selected={};local modules={BattleArt={playerSide=function()return side end,ownsSpeciesArt=function()return owns end,
 setting={get=function()return mode end},backAnimationSetting={get=function()return'gen2'end},frontAnimationSetting={get=function()return'gen3'end}},
 AnimatedBattleArt={picture=function()return selected,{selected} end}}
local Art=assert(loadfile('lib/NativeBattleArt.lua'))({require=function(n)return modules[n]end})
Art.fullBody={image=function()return image end}
local ordinary,full=Art.image({},true);assert(ordinary==selected and full==false,'unstaged UI or animated frames mistaken for full-body flag')
Art.world=true;assert(Art.image({},true)==image and Art.stagePixelScale(true,true)==64/96)
assert(Art.image({},false)==selected,'enemy/front replaced')
mode='rom';assert(Art.image({},true)==selected);mode='animated'
owns=false;assert(Art.image({},true)==selected,'MODDED provider ownership stolen');owns=true
side='front';assert(Art.image({},true)==selected)
print('PASS native full-body frame cache, OFF/fallback, staged-only scope, pixel pitch and ROM/MODDED ownership')
