-- Original visual scene sequences on disposable imported profiles. The trade
-- callback is observed, not connected to a live peer or real party swap.
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
 local P=require('src.core.game3.pokemon');local readers={P.frontPic,P.monFrontPic,require('src.core.game3.mon_anim').framePic}
 game.session.party={};local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,25,15));assert(Party.giveMon(game.session,155,15))
 local offer,received=game.session.party[1],game.session.party[2]
 offer.personality=100;offer.isShiny=false;received.personality=200;received.isShiny=true
 U.wait(75)
 local Trade=require('src.core.game3.trade_scene');local swaps,done=0,0
 assert(Trade.play(offer,received,function(mon)assert(mon==received);done=done+1 end,{uiDriven=true,onSwap=function()swaps=swaps+1 end}))
 local shown=false
 for i=1,3000 do
  U.wait(1);local s=Trade.state()
  if not shown and s and s.playerVisible and(s.monX2 or 0)==0 then
   shown=true;shot('trade-fit',true);Interface.scalingSetting:sync('full');shot('trade-full',true)
   Interface.setting:sync('off');shot('trade-native',false);Interface.setting:sync('battle_art')
  end
  if i%8==0 then U.tap(game,'a')end
  if not Trade.isOpen()then break end
 end
 assert(not Trade.isOpen()and shown and done==1 and swaps==1,'native trade sequence/callbacks incomplete')
 assert(identities[100]==false and identities[200]==true,'trade partner/PID/shiny context lost')
 assert(game.session.party[1]==offer and game.session.party[2]==received,'art changed party ownership')
 local hatchChecked=false
 if not rs then
  local Breeding=require('src.core.game3.breeding');local egg=assert(Breeding.createEgg(game.session,155,false))
  local tid=tonumber(game.session.trainerId or game.session.id or game.session.playerId)or 0
  local sid=tonumber(game.session.secretId)or math.floor(tid/65536)
  local hatchPid=17*65536+require('bit').bxor(tid%65536,sid%65536,17)
  egg.personality=hatchPid;egg.isShiny=nil;game.session.party={egg};assert(P.isEgg(egg))
  local Hatch=require('src.ui.game3.egg_hatch');local finished=0
  assert(Hatch.start(egg,{session=game.session,slot=1,onDone=function()finished=finished+1 end}))
  shot('hatch-shell',false)
  for i=1,1800 do
   U.wait(1)
   if not hatchChecked and not Hatch._eggShown and Hatch._fade==0 and(Hatch._flashAlpha or 0)==0 then
    hatchChecked=true;Interface.scalingSetting:sync('fit');shot('hatch-fit',true)
    Interface.scalingSetting:sync('full');shot('hatch-full',true)
    Interface.setting:sync('off');shot('hatch-native',false);Interface.setting:sync('battle_art')
   end
   if Hatch._state=='nickname_ask'then U.tap(game,'b')end
   if not Hatch.isOpen()then break end
  end
  assert(not Hatch.isOpen()and finished==1 and hatchChecked,'native hatch/close incomplete: '..tostring(Hatch._state))
  assert(identities[hatchPid]==true and not P.isEgg(egg)and #game.session.party==1 and game.session.party[1]==egg,'native hatch identity/ownership')
 end
 assert(P.frontPic==readers[1]and P.monFrontPic==readers[2]and require('src.core.game3.mon_anim').framePic==readers[3],'picture reader leaked')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native trade/hatch art]',version,'trade FIT/FULL/OFF/native sequence',hatchChecked and'hatch shell/FIT/FULL/OFF/native result'or'RS hatch remains native indexed PPU')
 love.event.quit()
end
