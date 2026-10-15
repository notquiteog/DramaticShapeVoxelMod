-- Native Gen3 cards/intros keep their own transforms, fades, input and data.
-- Only the selected local player's front portrait changes during their draw.
local V=...
local M={}
local Crystal=V.require('NativeCrystalArt')
local Runtime=require('src.core.game3.runtime')
function M.picture()
 local image=Crystal.player('front')
 -- *_flip is a battle-back convention; interfaces use the authored front.
 if image then return V.require('NativeBattleArt').fit(image,64,false)end
end
local function localCard(card)
 local session=Runtime.getSession and Runtime.getSession()
 return card.open and card.side=='front'and not card._link and session
  and card._session==session
end
function M.install()
 local undo={}
 local function card(name,position)
  local ok,Screen=pcall(require,name)
  if not ok or type(Screen.draw)~='function'then return end
  local original=Screen.draw
  Screen.draw=function(...)
   if not localCard(Screen)then return original(...)end
   local image=M.picture()
   local x,y=position(Screen)
   if not image or not x or not y then return original(...)end
   -- FRLG/Emerald cache their ROM portrait privately. Intercept only its
   -- public draw call at the native 64px portrait slot; no private upvalues.
   -- Existing outer flip/scanline/fade transforms remain in force.
   local graphics=love.graphics;local draw=graphics.draw;local replaced=false
   graphics.draw=function(texture,px,py,...)
    if not replaced and px==x and py==y and texture and texture.getDimensions then
     local w,h=texture:getDimensions()
     if w==64 and h==64 then texture=image;replaced=true end
    end
    return draw(texture,px,py,...)
   end
   local result={pcall(original,...)}
   graphics.draw=draw
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  undo[#undo+1]=function()Screen.draw=original end
 end
 card('src.ui.game3.trainer_card',function(screen)
  if not screen._rse then return 165,44 end
  local m=require('src.ui.game3.rse.scene_kit').manifest('rse/trainer_card')
  if m and m.picOffset then return(19+m.picOffset[1])*8,(5+m.picOffset[2])*8 end
 end)
 card('src.ui.game3.rs.trainer_card',function(screen)
  local m=screen._man
  if m and m.pic then return m.pic.x,m.pic.y end
 end)
 local hofOK,Hall=pcall(require,'src.ui.game3.hall_of_fame')
 if hofOK and type(Hall.draw)=='function'then
  local original=Hall.draw
  Hall.draw=function(...)
   local player=Hall.open and Hall._player
   local session=Runtime.getSession and Runtime.getSession()
   local image=player and session and Hall._session==session and M.picture()
   if not image then return original(...)end
   local Trainer=require('src.core.game3.trainer_pic');local front=Trainer.front
   Trainer.front=function(id,...)
    if id==player.pic then return{image=image,w=64,h=64}end
    return front(id,...)
   end
   local result={pcall(original,...)};Trainer.front=front
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  undo[#undo+1]=function()Hall.draw=original end
 end
 local ok,Intro=pcall(require,'src.ui.game3.new_game_scene')
 if ok and type(Intro.drawPic)=='function'then
  local original=Intro.drawPic
  Intro.drawPic=function(self,...)
   local pic,assets=self.pic,self.assets
   if not(pic and assets and pic.image and(pic.image==assets.boySprite or pic.image==assets.girlSprite))then return original(self,...)end
   local image=M.picture();if not image then return original(self,...)end
   local prior=pic.image;pic.image=image
   local result={pcall(original,self,...)};pic.image=prior
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end
  undo[#undo+1]=function()Intro.drawPic=original end
 end
 for _,name in ipairs({'src.ui.game3.rse.birch_speech','src.ui.game3.rs.birch_speech'})do
  local found,Birch=pcall(require,name)
  if found and type(Birch.drawSprite)=='function'then
   local original=Birch.drawSprite
   Birch.drawSprite=function(self,sprite,...)
    local sprites=self.sprites
    if not(sprites and sprite and(sprite==sprites.brendan or sprite==sprites.may))then return original(self,sprite,...)end
    local image=M.picture();if not image then return original(self,sprite,...)end
    local prior,frame=sprite.img,sprite.frame;sprite.img,sprite.frame=image,0
    local result={pcall(original,self,sprite,...)};sprite.img,sprite.frame=prior,frame
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end
   undo[#undo+1]=function()Birch.drawSprite=original end
  end
 end
 return function()for i=#undo,1,-1 do undo[i]()end end
end
return M
