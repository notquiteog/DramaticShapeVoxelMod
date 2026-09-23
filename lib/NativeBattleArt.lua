-- Generation adapters for the existing BattleArt ownership/settings and
-- AnimatedBattleArt frame decoder. Never replace field or interface pictures.
local V=...
local Art=V.require('BattleArt')
local Animated=V.require('AnimatedBattleArt')
local M={}
local fitted=setmetatable({},{__mode='k'})
function M.image(mon,back)
 local side=back and Art.playerSide()or'front'
 return Animated.picture(mon,side)
end
function M.fit(image,size)
 local cache=fitted[image];if not cache then cache={};fitted[image]=cache end
 if cache[size]then return cache[size]end
 local g=love.graphics;local c=g.newCanvas(size,size)
 g.push('all');g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode();g.setBlendMode('alpha');g.clear(0,0,0,0);g.setColor(1,1,1,1)
 local w,h=image:getDimensions();local scale=math.min(size/w,size/h)
 g.draw(image,(size-w*scale)/2,size-h*scale,0,scale,scale);g.pop();c:setFilter('nearest','nearest');cache[size]=c
 return c
end
function M.settings()
 return {Art.setting,Art.frontAnimationSetting,Art.backAnimationSetting,Art.viewSetting,Art.duplicateSetting}
end
function M.install()
 local gen=require('src.core.GameVersion').generation()
 local undo={}
 if gen==3 then
  local P=require('src.core.game3.pokemon');local UI=require('src.core.game3.battle.ui')
  local active=false;local draw=UI.draw
  UI.draw=function(...)
   local prior=active;active=true;local r={pcall(draw,...)};active=prior
   if not r[1]then error(r[2],0)end;return unpack(r,2)
  end
  undo[#undo+1]=function()UI.draw=draw end
  for _,side in ipairs({'front','back'})do
   local key=side..'Pic';local original=P[key]
   P[key]=function(species,form,...)
    if active and (not form or form==0)then
     local image=M.image({species=P.national(species)},side=='back')
     if image then return {image=M.fit(image,64),w=64,h=64}end
    end
    return original(species,form,...)
   end
   undo[#undo+1]=function()P[key]=original end
  end
 elseif gen==2 then
  local State=require('src.ui.gen2.BattleState');local pic=State.pic
  State.pic=function(self,mon,back,...)
   local image=M.image(mon,back)
   if image then return M.fit(image,back and 48 or 56),true,nil end
   return pic(self,mon,back,...)
  end
  undo[#undo+1]=function()State.pic=pic end
 else
  local State=require('src.battle.BattleState');local draw=State.draw
  State.draw=function(self,...)
   local swapped={}
   for _,key in ipairs({'player','player2','enemy','enemy2'})do
    local b=self[key]
    if b and b.mon then
     local image=M.image({species=Art.speciesFor(b),dvs=b.mon.dvs},key:sub(1,6)=='player')
     if image then image=M.fit(image,key:sub(1,6)=='player'and 48 or 56);swapped[#swapped+1]={b,b.sprite,image};b.sprite=image end
    end
   end
   local r={pcall(draw,self,...)}
   for _,row in ipairs(swapped)do if row[1].sprite==row[3]then row[1].sprite=row[2]end end
   if not r[1]then error(r[2],0)end;return unpack(r,2)
  end
  undo[#undo+1]=function()State.draw=draw end
 end
 V.mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  for i=#undo,1,-1 do undo[i]()end
  for _,sizes in pairs(fitted)do for _,c in pairs(sizes)do c:release()end end;fitted=setmetatable({},{__mode='k'})
  return next(...)
 end)
end
return M
