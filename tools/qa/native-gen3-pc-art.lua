-- Native storage portrait, cursor mosaic, party/box identity and close ownership.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();local rs=version=='ruby'or version=='sapphire'
 love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN',leafgreen='LG_PALLET_TOWN',firered='FR_PALLET_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(0,game)
 V.require('NativeCrystalArt').pack:sync('crystal')
 local Interface=V.require('InterfaceSprites');Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
 local Native=V.require('NativeInterfaceArt');local picture=Native.picture
 local P=require('src.core.game3.pokemon');local reader,front=P.monFrontPic,P.frontPic
 local images=setmetatable({},{__mode='k'});local hits,identities=0,{}
 Native.picture=function(mon,...)
  local image=picture(mon,...)
  if image then images[image]=true;identities[mon.personality]=V.require('BattleArt').isShiny(mon)end
  return image
 end
 local g=love.graphics;local draw=g.draw
 g.draw=function(image,...)if images[image]then hits=hits+1 end;return draw(image,...)end
 local function shot(name,want)
  hits=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  assert((hits>0)==want,name..': selected portrait ownership')
 end
 local Pc=require('src.ui.game3.pc_chrome');local panel=Pc.drawLeftDataPanel
 local maxMosaic,clean=0,0
 Pc.drawLeftDataPanel=function(mon,clock,mosaic)
  local shader=g.getShader();panel(mon,clock,mosaic)
  assert(g.getShader()==shader and P.monFrontPic==reader and P.frontPic==front,'PC draw leaked shader/reader')
  maxMosaic=math.max(maxMosaic,mosaic or 0);clean=clean+1
 end
 local Party=require('src.core.game3.party');game.session.party={}
 for _,id in ipairs({1,25,155})do assert(Party.giveMon(game.session,id,15))end
 local party=game.session.party;local normal,shiny=party[2],party[3]
 party[2],party[3]=nil,nil;normal.personality=100;normal.isShiny=false;shiny.personality=200;shiny.isShiny=true
 local Storage=require('src.core.game3.storage');local storage=Storage.ensure(game.session)
 local box=storage.boxes[1];box.mons[1],box.mons[2]=normal,shiny;storage.currentBox=1
 local UI=require('src.ui.game3.box_storage_ui');local exits=0
 local function open(mode)UI.show({session=game.session,subMode=mode,onClose=function()exits=exits+1 end});U.wait(80)end
 U.wait(75);Interface.setting:sync('off');open('move');assert(UI.isOpen()and UI.cursorSlot==1)
 shot('box-native-start',false);Interface.setting:sync('battle_art')
 shot('box-fit',true);Interface.scalingSetting:sync('full');shot('box-full',true)
 Interface.setting:sync('off');shot('box-native',false);Interface.setting:sync('battle_art');Interface.scalingSetting:sync('fit')
 U.tap(game,'right');U.wait(35);assert(UI.cursorSlot==2,'native cursor did not move')
 shot('box-shiny',true)
 assert(maxMosaic>0 and identities[100]==false and identities[200]==true,'native mosaic and distinct hovered identities')
 UI.close();assert(not UI.isOpen()and exits==1)
 open('deposit');assert(UI.drawerOpen);shot('party-fit',true)
 UI.close();assert(not UI.isOpen()and exits==2)
 assert(game.session.party==party and #party==1 and storage.boxes[1]==box and box.mons[1]==normal and box.mons[2]==shiny,'storage/party mutated')
 assert(not UI.hasPendingMon(),'unexpected held mon')
 Pc.drawLeftDataPanel=panel;Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native PC art]',version,'FIT/FULL/OFF, shiny cursor, native mosaic',maxMosaic,'clean draws',clean,'box/party ownership and close callbacks')
 love.event.quit()
end
