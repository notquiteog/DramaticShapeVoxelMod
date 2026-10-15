-- Original PokeNav condition/ribbon navigation on disposable imported profiles.
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
 game.session.party={};local Party=require('src.core.game3.party');local Ribbon=require('src.core.game3.rse.ribbons')
 assert(Party.giveMon(game.session,25,15));assert(Party.giveMon(game.session,155,15))
 local party=game.session.party;party[1].personality=100;party[1].isShiny=false;party[2].personality=200;party[2].isShiny=true
 for _,mon in ipairs(party)do mon.contest={cool=120,beauty=60,cute=30,smart=90,tough=160,sheen=50};Ribbon.set(mon,'cool',1)end
 local ribbons={Ribbon.word(party[1]),Ribbon.word(party[2])}
 U.wait(75)
 local Nav=require('src.ui.game3.'..(rs and'rs'or'rse')..'.pokenav.init')
 local shell=Nav.show({session=game.session,game=game});U.wait(90)
 if rs then shell:openCondition()else assert(shell:setActiveMenu(Nav.MENU.CONDITION_GRAPH_PARTY))end
 U.wait(90);shot('condition-fit',true);Interface.scalingSetting:sync('full');shot('condition-full',true)
 Interface.setting:sync('off');shot('condition-native',false);Interface.setting:sync('battle_art')
 U.tap(game,'down');U.wait(60);shot('condition-shiny',true)
 assert(identities[100]==false and identities[200]==true,'condition navigation/PID/shiny identity')
 U.tap(game,'b');U.wait(60)
 if rs then shell:openSearch(nil,nil,true)else assert(shell:setActiveMenu(Nav.MENU.RIBBONS_MON_LIST))end
 U.wait(90);U.tap(game,'a');U.wait(90)
 Interface.scalingSetting:sync('fit');shot('ribbons-fit',true)
 Interface.scalingSetting:sync('full');shot('ribbons-full',true)
 Interface.setting:sync('off');shot('ribbons-native',false);Interface.setting:sync('battle_art')
 U.tap(game,'a');U.wait(30);shot('ribbon-description',true);U.tap(game,'b');U.wait(30)
 for i=1,8 do if not Nav.isOpen()then break end;U.tap(game,'b');U.wait(60)end
 assert(not Nav.isOpen(),'native PokeNav exit failed')
 assert(game.session.party==party and #party==2 and Ribbon.word(party[1])==ribbons[1]and Ribbon.word(party[2])==ribbons[2],'art changed party/ribbons')
 for _,mon in ipairs(party)do assert(mon.contest.cool==120 and mon.contest.sheen==50,'art changed contest stats')end
 assert(P.frontPic==readers[1]and P.monFrontPic==readers[2]and require('src.core.game3.mon_anim').framePic==readers[3],'picture reader leaked')
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native PokeNav art]',version,'condition/ribbons FIT/FULL/OFF, shiny switch, ribbon description, exit, party/stat invariants')
 love.event.quit()
end
