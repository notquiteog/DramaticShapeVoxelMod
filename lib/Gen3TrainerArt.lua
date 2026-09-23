-- Native trainer image readers are separate from Pokemon readers. Preserve
-- their exact 64px frame contract and let the native send-out pick its frame.
local V=...
local Art=V.require('BattleArt')
local Animated=V.require('AnimatedBattleArt')
local M={}
local aliases={['bug-catcher']='bug-catcher',['fisherman']='fisher',psychic='psychic-tr',
 ['black-belt']='blackbelt',['pokemon-maniac']='pokemaniac',['rocket-grunt']='rocket',
 ['team-rocket']='rocket',['young-couple']=false,['sis-and-bro']=false}
local named={BROCK='brock',MISTY='misty',['LT. SURGE']='lt-surge',ERIKA='erika',KOGA='koga',
 SABRINA='sabrina',BLAINE='blaine',GIOVANNI='giovanni',LORELEI='lorelei',BRUNO='bruno',AGATHA='agatha',LANCE='lance'}
function M.key(st,info)
 if not st or st.link or st.wild then return nil end
 info=info or st
 local class=tostring(info.className or st.trainerClassName or ''):upper()
 local name=tostring(info.name or st.trainerName or ''):upper()
 if class=='LEADER' or class=='ELITE FOUR' or class=='BOSS' or class=='ROCKET BOSS' then
  return named[name]
 end
 if class=='RIVAL' then return st.earlyRival and 'rival1' or 'rival2' end
 if class=='CHAMPION' then return 'rival3' end
 local key=class:lower():gsub('[^%w]+','-'):gsub('^%-',''):gsub('%-$','')
 if key=='cooltrainer' then return tonumber(info.gender)==1 and 'cooltrainer-f' or 'cooltrainer-m' end
 if key=='swimmer' and tonumber(info.gender)==1 then return 'swimmer-f' end
 if aliases[key]~=nil then return aliases[key] or nil end
 return key~='' and key or nil
end
function M.install(active,fit)
 local Trainer=require('src.core.game3.trainer_pic')
 local Battle=require('src.core.game3.battle')
 local Trainers=require('src.core.game3.scripting.trainers')
 local front,back=Trainer.front,Trainer.back
 local sheets={}
 Trainer.front=function(id,...)
  if active()then
   local st=Battle._st
   if st and not st.link and tonumber(id)==tonumber(st.trainerPicId)then
    local info=st.trainerId and Trainers.info(st.trainerId)
    local key=M.key(st,info);local image=key and Art.trainerImage(key)
    if image then return {image=fit(image,64),w=64,h=64}end
   end
  end
  return front(id,...)
 end
 Trainer.back=function(gender,...)
  -- Old Man, Poke Dude and other scripted roles retain their native sheets.
  if active() and (gender==0 or gender==1)then
   local st=Battle._st
   if st and not st.pokedude and not st.tutorial and not st.safari then
    local frames,key={},'';local width,height=0,0
    for i,progress in ipairs({0,1,25,49,72})do
     local image=Animated.playerTrainerPicture(progress)
     if not image then return back(gender,...)end
     frames[i]=image;key=key..tostring(image)..':'
     local w,h=image:getDimensions();width=math.max(width,w);height=math.max(height,h)
    end
    if not sheets[key]then
     local g=love.graphics;local c=g.newCanvas(64,320)
     g.push('all')
     local ok,err=pcall(function()
      g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode();g.setBlendMode('alpha')
      g.clear(0,0,0,0);g.setColor(1,1,1,1)
      local scale=math.min(64/width,64/height)
      for i,image in ipairs(frames)do local w,h=image:getDimensions()
       g.draw(image,(64-w*scale)/2,i*64-h*scale,0,scale,scale)
      end
     end)
     g.pop()
     if not ok then c:release();error(err,0)end
     c:setFilter('nearest','nearest');sheets[key]=c
    end
    return {image=sheets[key],w=64,h=320}
   end
  end
  return back(gender,...)
 end
 return function()
  Trainer.front,Trainer.back=front,back
  for _,image in pairs(sheets)do image:release()end
 end
end
return M
