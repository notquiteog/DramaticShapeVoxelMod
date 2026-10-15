-- Original Hoenn Pokeblock selection, cancellation, feeding and result flow.
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
 local P=require('src.core.game3.pokemon');local reader=P.monFrontPic
 local Use=require('src.ui.game3.rse.use_pokeblock');local Feed=require('src.ui.game3.rse.pokeblock_feed')
 local UI=rs and require('src.ui.game3.rs.use_pokeblock')or Use
 local oldPic,transitionDraws=nil,0;local instrumentedPicture=Native.picture
 Native.picture=function(mon,...)
  if Use.open and Use._st.sel==1 and oldPic and Use._st.monPic==oldPic then
   assert(mon.personality==100,'cursor relabeled outgoing native picture');transitionDraws=transitionDraws+1
  end
  return instrumentedPicture(mon,...)
 end
 local function waitFor(predicate,label)
  for i=1,1800 do if predicate()then U.wait(2);return end;U.wait(1)end
  error('native Pokeblock stalled '..label..' use='..tostring(Use._st.state)..' feed='..tostring(Feed._st.phase))
 end
 local function inputReady()return Use.open and Use._st.state=='input'and Use._st.fadeDir==0 end
 local function tap(btn)U.tap(game,btn);U.wait(3)end
 local Party=require('src.core.game3.party');game.session.party={}
 assert(Party.giveMon(game.session,25,15));assert(Party.giveMon(game.session,155,15))
 local party=game.session.party
 for i,mon in ipairs(party)do mon.personality=i*100;mon.isShiny=i==2;mon.contest={cool=0,beauty=0,cute=0,smart=0,tough=0,sheen=0}end
 local Block=require('src.core.game3.rse.pokeblock');Block.clearAll(game.session)
 assert(Block.add(game.session,{color=1,spicy=10,feel=20}))
 local exits=0;local function open()return UI.show({session=game.session,pokeblockId=0,onExit=function()exits=exits+1 end})end
 U.wait(75);assert(open());waitFor(inputReady,'initial input')
 oldPic=Use._st.monPic;shot('selection-fit',true)
 Interface.scalingSetting:sync('full');shot('selection-full',true)
 Interface.setting:sync('off');shot('selection-native',false);Interface.setting:sync('battle_art')
 tap('down');waitFor(inputReady,'second mon');shot('selection-shiny',true)
 assert(transitionDraws>0 and identities[100]==false and identities[200]==true,'native outgoing/incoming identity evidence')
 tap('b');waitFor(function()return not Use.open end,'cancel')
 assert(exits==1 and Block.get(game.session,0).color==1 and party[2].contest.sheen==0,'cancel consumed block/stats')
 assert(open());waitFor(inputReady,'reopen');oldPic=Use._st.monPic
 tap('down');waitFor(inputReady,'feed selection');tap('a')
 waitFor(function()return Use._st.state=='confirm'end,'confirm');tap('a')
 waitFor(function()return Feed.open and Feed._st.fade==0 end,'feeding')
 Interface.scalingSetting:sync('fit');shot('feed-fit',true)
 Interface.scalingSetting:sync('full');shot('feed-full',true)
 Interface.setting:sync('off');shot('feed-native',false);Interface.setting:sync('battle_art')
 for i=1,1800 do
  if Use.open and Use._st.state=='results_wait'then break end
  if i%8==0 then tap('a')else U.wait(1)end
 end
 assert(Use.open and Use._st.state=='results_wait','native feeding result not reached')
 shot('results-shiny',true);tap('a')
 for i=1,1800 do
  if not Use.open and not Feed.open then break end
  if i%8==0 then tap('a')else U.wait(1)end
 end
 assert(not Use.open and not Feed.open and exits==2,'native result/close callback')
 assert(game.session.party==party and #party==2 and party[1].contest.cool==0 and party[1].contest.sheen==0,'unselected party changed')
 assert(party[2].contest.cool==10 and party[2].contest.sheen==20 and Block.get(game.session,0).color==0,'native single-feed result/block consumption')
 assert(P.monFrontPic==reader,'native mon reader leaked')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native Pokeblock art]',version,'selection/feed FIT/FULL/OFF, outgoing identity draws',transitionDraws,'cancel/no-consume, one native feed cool10 sheen20 block consumed')
 love.event.quit()
end
