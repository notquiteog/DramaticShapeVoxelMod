-- Original Emerald Battle Factory selection/swap sequences on an isolated profile.
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
 assert(version=='emerald','Factory is native Emerald content')
 local P=require('src.core.game3.pokemon');local readers={P.frontPic,P.monFrontPic,require('src.core.game3.mon_anim').framePic}
 game.session.party={};local Party=require('src.core.game3.party')
 for i,species in ipairs({25,155,1,4,7,133})do assert(Party.giveMon(game.session,species,30))end
 local party=game.session.party;local mons={}
 for i,mon in ipairs(party)do mon.personality=100+i;mon.isShiny=i==2 or i==4;mons[i]={monId=i,mon=mon}end
 local function tap(btn)U.tap(game,btn);U.wait(3)end
 local function phase(screen,want)
  for i=1,900 do if screen._st.phase==want and(not screen._st.picAnim or screen._st.picAnim.finished)then U.wait(2);return end;U.wait(1)end
  error('native '..screen.ID..' phase '..tostring(screen._st.phase)..' expected '..want)
 end
 U.wait(75)
 local Select=require('src.ui.game3.rse.factory_select');local selected,calls
 calls=0;assert(Select.show({session=game.session,mons=mons,onDone=function(ids)calls=calls+1;selected=ids end}))
 for i=1,3 do
  print('[Factory choice]',i,Select._st.phase,Select._st.cursor,Select._st.menuCursor)
  phase(Select,'choose');if i>1 then tap('right')end
  tap('a');phase(Select,'menu')
  if i==1 then
   shot('rental-fit',true);Interface.scalingSetting:sync('full');shot('rental-full',true)
   Interface.setting:sync('off');shot('rental-native',false);Interface.setting:sync('battle_art')
  end
  tap('down');tap('a')
 end
 phase(Select,'yesno');shot('rental-three',true);tap('a')
 for i=1,900 do if not Select.isOpen()then break end;U.wait(1)end
 assert(not Select.isOpen()and calls==1 and selected[1]==1 and selected[2]==2 and selected[3]==3,'native three-rental callback')
 assert(identities[101]==false and identities[102]==true,'rental identity/shiny context')
 local Swap=require('src.ui.game3.rse.factory_swap');local result;calls=0
 local player={party[1],party[2],party[3]};local enemy={party[4],party[5],party[6]}
 local opts={session=game.session,party=player,enemy=enemy,onDone=function(r)calls=calls+1;result=r end}
 assert(Swap.show(opts));phase(Swap,'choose');tap('a');phase(Swap,'menu')
 Interface.scalingSetting:sync('fit');shot('swap-fit',true)
 Interface.scalingSetting:sync('full');shot('swap-full',true)
 Interface.setting:sync('off');shot('swap-native',false);Interface.setting:sync('battle_art')
 tap('down');tap('a');phase(Swap,'choose');assert(Swap._st.inEnemyScreen,'native enemy party switch')
 tap('a');phase(Swap,'yesno');shot('swap-enemy-shiny',true)
 assert(identities[104]==true,'enemy picture identity lost');tap('a')
 for i=1,900 do if not Swap.isOpen()then break end;U.wait(1)end
 assert(not Swap.isOpen()and calls==1 and result.swapped and result.playerMonId==1 and result.enemyMonId==1,'native accepted swap callback')
 result=nil;assert(Swap.show(opts));phase(Swap,'choose');tap('b');phase(Swap,'yesno');tap('a')
 for i=1,900 do if not Swap.isOpen()then break end;U.wait(1)end
 assert(not Swap.isOpen()and calls==2 and not result.swapped,'native swap cancellation')
 assert(game.session.party==party and #party==6 and player[1]==party[1]and enemy[1]==party[4],'presentation changed party ownership')
 assert(P.frontPic==readers[1]and P.monFrontPic==readers[2]and require('src.core.game3.mon_anim').framePic==readers[3],'picture reader leaked')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native Factory art]',version,'rental/swap FIT/FULL/OFF, three-choice/shiny callbacks, accepted/cancelled swap, unchanged party ownership')
 love.event.quit()
end
