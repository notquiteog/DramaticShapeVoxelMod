-- Native scripted/contest picture lifecycle fixture on disposable profiles.
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
 local P=require('src.core.game3.pokemon')
 local Pic=require('src.ui.game3.mon_pic');local Entry=require('src.ui.game3.rse.contest_entry_pic')
 local original={Pic.draw,Pic.show,Pic.hide,Entry.show,Entry.hide,Entry.reset}
 U.wait(75)
 Pic.show(25,10,3,{noCry=true});local nativeImage=Pic._img
 shot('script-fit',true);Interface.scalingSetting:sync('full');shot('script-full',true)
 assert(Pic._img==nativeImage and not Pic._animTransform,'script cache/transform changed')
 Interface.setting:sync('off');shot('script-native',false);Interface.setting:sync('battle_art');Pic.hide()
 Pic.show(P.SPECIES_SPINDA,10,3,{noCry=true});shot('script-spinda-native',false);Pic.hide()
 if rs or version=='emerald'then
 Entry.show({species=155,personality=14,otId=9*65536+7},true)
 Interface.scalingSetting:sync('fit');shot('contest-fit',true)
 Interface.scalingSetting:sync('full');shot('contest-full',true)
 Interface.setting:sync('off');shot('contest-native',false);Interface.setting:sync('battle_art')
 assert(identities[14]==true,'contest packed OT/PID/shiny context lost')
 U.wait(90);Entry.hide();assert(not Pic.active and not Entry.active,'native hide lifecycle')
 end
 Pic.show(155,10,3,{noCry=true});shot('script-after-contest',true)
 assert(identities[0x8000]==false,'contest identity leaked to ordinary script')
 Pic.hide()
 assert(Pic.draw==original[1]and Pic.show==original[2]and Pic.hide==original[3]and Entry.show==original[4]and Entry.hide==original[5]and Entry.reset==original[6],'picture lifecycle leaked native owners')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native scripted art]',version,'script FIT/FULL/OFF, Spinda fallback, hide/cache restoration',(rs or version=='emerald')and'contest packed shiny identity verified'or'no native contest in this edition')
 love.event.quit()
end
