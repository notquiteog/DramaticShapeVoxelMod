-- Original Hoenn credit slideshow, selected art, native fades and lifecycle.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();local rs=version=='ruby'or version=='sapphire'
 love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(0,game)
 V.require('NativeCrystalArt').pack:sync('crystal')
 local Interface=V.require('InterfaceSprites');Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
 local Native=V.require('NativeInterfaceArt');local picture=Native.picture
 local images=setmetatable({},{__mode='k'});local hits,identities=0,{}
 Native.picture=function(mon,...)
  local image=picture(mon,...)
  if image then local w,h=image:getDimensions();assert(w==64 and h==64,'Crystal interface fitting bypassed');images[image]=true;identities[mon.personality or 0]=V.require('BattleArt').isShiny(mon) end
  return image
 end
 local g=love.graphics;local draw=g.draw
 g.draw=function(image,...)if images[image]then hits=hits+1 end;return draw(image,...)end
 local function shot(name,want)
  hits=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  assert((hits>0)==want,name..': selected image ownership')
 end
 assert(rs or version=='emerald')
 local P=require('src.core.game3.pokemon');local reader=P.frontPic
 local Dex=require('src.core.game3.dex');Dex.setCaught(game.session.dex,25)
 local Credits=require(rs and 'src.ui.game3.rs.credits'or'src.ui.game3.rse.credits')
 local Shared=require('src.ui.game3.rse.credits');local calls=0
 local party=game.session.party;local dex=game.session.dex
 U.wait(75)
 local st=Credits.start({session=game.session,onDone=function()calls=calls+1 end})
 local function visible()
  for _,mon in ipairs(st.mons)do if mon.state==2 and mon.hold>20 and mon.nat==25 then return mon end end
 end
 local elapsed=0
 for i=1,12000 do if st.showMons and visible()then elapsed=i;break end;U.wait(1)end
 assert(elapsed>0,'native credit slide never became visible: '..tostring(st.mainFunc))
 local mon=visible();local t=mon.t
 shot('credits-fit',true)
 Interface.scalingSetting:sync('full');shot('credits-full',true)
 Interface.setting:sync('off');shot('credits-native',false);Interface.setting:sync('battle_art')
 assert(mon.t>t and mon.scale==256,'native slide timer/scale did not advance')
 local fading
 for i=1,300 do
  for _,m in ipairs(st.mons)do if m.state==3 and m.hold>4 then fading=m;break end end
  if fading then break end;U.wait(1)
 end
 assert(fading,'native slide never faded');shot('credits-fade',true)
 assert(identities[0]==false,'Dex explicit nonshiny identity changed')
 assert(P.frontPic==reader and game.session.party==party and game.session.dex==dex,'native reader/session ownership changed')
 Credits.finish();U.wait(2);assert(not Credits.isOpen()and calls==1,'native finish callback')
 Credits.start({session=game.session,onDone=function()calls=calls+1 end});U.wait(2)
 Credits.reset();U.wait(2);assert(not Credits.isOpen()and calls==1 and Shared.state==nil,'native reset lifecycle')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native Hoenn credits art]',version,'FIT/FULL/OFF, natural slide/fade, explicit Dex identity, finish/reset callbacks; frames',elapsed)
 love.event.quit()
end
