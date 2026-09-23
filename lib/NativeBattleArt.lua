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
function M.fit(image,size,mirror)
 local cache=fitted[image];if not cache then cache={};fitted[image]=cache end
 local key=mirror and ('flip:'..size) or size
 if cache[key]then return cache[key]end
 local g=love.graphics;local c=g.newCanvas(size,size)
 g.push('all');g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode();g.setBlendMode('alpha');g.clear(0,0,0,0);g.setColor(1,1,1,1)
 local w,h=image:getDimensions();local scale=math.min(size/w,size/h)
 g.draw(image,(size-w*scale)/2+(mirror and w*scale or 0),size-h*scale,0,mirror and -scale or scale,scale);g.pop();c:setFilter('nearest','nearest');cache[key]=c
 return c
end
function M.settings()
 return {Art.setting,Art.frontAnimationSetting,Art.backAnimationSetting,Art.viewSetting,Art.duplicateSetting,Art.frontFlipSetting,Art.trainerSetting,Art.playerArtSetting,Art.playerAnimationSetting}
end
function M.install()
 local gen=require('src.core.GameVersion').generation()
 local undo={}
 if gen==3 then
  local P=require('src.core.game3.pokemon');local UI=require('src.core.game3.battle.ui')
  local Anim=require('src.core.game3.battle.anim')
  local active=false;local artMon,explicitArtMon;local draw=UI.draw
  local Light=V.require('Gen3SpriteLight')
  undo[#undo+1]=V.require('Gen3TrainerArt').install(function()return active end,M.fit)
  UI.draw=function(...)
   local prior,priorMon,priorExplicit=active,artMon,explicitArtMon;active,artMon,explicitArtMon=true,nil,nil
   local r={pcall(Light.scope,draw,...)};active,artMon,explicitArtMon=prior,priorMon,priorExplicit
   if not r[1]then error(r[2],0)end;return unpack(r,2)
  end
  undo[#undo+1]=function()UI.draw=draw end
  -- Native draw_mon_sprite resolves the displayed battler through this
  -- public read seam immediately before requesting its image. Retain that
  -- exact mon, including same-species doubles and a queued switch/faint.
  -- Species lookup alone cannot distinguish differently shiny partners.
  local shown=Anim.shownBattler
  if type(shown)=='function'then
   Anim.shownBattler=function(side,battler,...)
    local resolved=shown(side,battler,...)
    if active and not explicitArtMon then artMon=resolved or battler end
    return resolved
   end
   undo[#undo+1]=function()Anim.shownBattler=shown end
  end
  -- HUD head bounds must read the same selected image as the native draw.
  local battlerPic=UI.battlerPic
  UI.battlerPic=function(side,battler,...)
   local prior,priorMon,priorExplicit=active,artMon,explicitArtMon
   active,artMon,explicitArtMon=true,battler,battler
   local r={pcall(battlerPic,side,battler,...)};active,artMon,explicitArtMon=prior,priorMon,priorExplicit
   if not r[1]then error(r[2],0)end;return unpack(r,2)
  end
  undo[#undo+1]=function()UI.battlerPic=battlerPic end
  for _,side in ipairs({'front','back'})do
   local key=side..'Pic';local original=P[key]
   P[key]=function(species,form,...)
    if active and (not form or form==0)then
     local source=artMon and (artMon.mon or artMon)
     local mon={species=P.national(species)}
     if source then
      mon.personality=source.personality;mon.otId=source.otId
      mon.otSecretId=source.otSecretId;mon.isShiny=source.isShiny
     end
     local image=M.image(mon,side=='back')
     if image then return Light.tag({image=M.fit(image,64,side=='back' and Art.playerSide()=='front' and Art.flipsPlayerFront()),w=64,h=64})end
    end
    local entry=original(species,form,...)
    return active and Light.tag(entry)or entry
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
  local scene=State.drawScene
  if type(scene)=='function'then
   State.drawScene=function(self,...)
    if V.crystalSpritesActive then return scene(self,...)end
    local previous={self.playerBackImage,self.playerBackTrueColor,self.playerBackPath,
     self.enemyTrainerImage,self.enemyTrainerTrueColor,self.enemyTrainerPath}
    if self.showPlayerTrainer and not self.tutorial then
     local image=Animated.playerTrainerPicture(math.floor((self.backpicSlide or 0)/2)*8)
     if image then self.playerBackImage,self.playerBackTrueColor,self.playerBackPath=image,true,nil end
    end
    if self.showEnemyTrainer and type(self.enemyTrainerClass)=='string'then
     local name=self.enemyTrainerClass:lower():gsub('^opp_',''):gsub('_','-')
     local image=Art.trainerImage(name)
     if image then self.enemyTrainerImage,self.enemyTrainerTrueColor,self.enemyTrainerPath=image,true,nil end
    end
    local result={pcall(scene,self,...)}
    self.playerBackImage,self.playerBackTrueColor,self.playerBackPath=previous[1],previous[2],previous[3]
    self.enemyTrainerImage,self.enemyTrainerTrueColor,self.enemyTrainerPath=previous[4],previous[5],previous[6]
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
   undo[#undo+1]=function()State.drawScene=scene end
  end
 end
 -- Gen 1 already owns battler images through BattleArt.apply and
 -- AnimatedBattleArt.update. A second draw-time replacement breaks ownership
 -- checks and makes the original UI back render over the staged sprite.

 V.mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  for i=#undo,1,-1 do undo[i]()end
  for _,sizes in pairs(fitted)do for _,c in pairs(sizes)do c:release()end end;fitted=setmetatable({},{__mode='k'})
  return next(...)
 end)
end
return M
