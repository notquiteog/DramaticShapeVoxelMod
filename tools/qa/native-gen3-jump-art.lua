-- Original Pokemon Jump renderer/Gfx component; no link session or save.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();local rs=version=='ruby'or version=='sapphire'
 love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({firered='FR_PALLET_TOWN',leafgreen='LG_PALLET_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version];assert(map)
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
 local Jump=require('src.core.game3.minigames.pokemon_jump')
 local art,err=Jump.loadArt();assert(art,err)
 local sim=Jump.new({art=art,players={{seat=0,species=25,name='ALPHA'},{seat=1,species=155,name='BETA'}},
  seat=0,leader=true,seed=123,partyMon={species=25,personality=100,isShiny=false},hooks={}})
 sim.game.monInfo[1].personality=200;sim.game.monInfo[1].shiny=true
 local gfx=sim.game.gfx;local state=sim.game;local info=state.monInfo;local players=state.players
 local P=require('src.core.game3.pokemon');local readers={P.frontPic,P.monFrontPic}
 local Stack=require('src.ui.game3.stack');local yValues={}
 local layer={draw=function()sim:draw()end,update=function()
  gfx:update();yValues[gfx.monSprites[0].y2]=true
 end}
 U.wait(75);Stack.push('jump_art_fixture',layer,{hideBelow=true,fullscreen=true})
 -- First populate the genuine native cache, then prove selected draws restore it.
 Interface.setting:sync('off');U.wait(3);local cache=assert(sim._pics);local native0,native1=cache[0],cache[1]
 Interface.setting:sync('battle_art');shot('jump-fit',true)
 Interface.scalingSetting:sync('full');shot('jump-full',true)
 Interface.setting:sync('off');shot('jump-native',false);Interface.setting:sync('battle_art')
 assert(identities[100]==false and identities[200]==true,'independent player PID/shiny identity lost')
 gfx:startMonIntroBounce(0);U.wait(5);shot('jump-bounce',true)
 for i=1,180 do if not gfx:isMonIntroBounceActive()then break end;U.wait(1)end
 assert(not gfx:isMonIntroBounceActive(),'native bounce did not finish')
 local count=0;for _ in pairs(yValues)do count=count+1 end;assert(count>1,'native sprite movement missing')
 assert(sim._pics==cache and cache[0]==native0 and cache[1]==native1,'selected art leaked into native cache')
 state.monInfo[1].personality=300;state.monInfo[1].shiny=false
 shot('jump-changed-player',true);assert(identities[300]==false,'changed remote identity stale')
 assert(state.monInfo==info and state.players==players and state.best.score==0 and gfx.points==0,'presentation changed simulation/score')
 assert(P.frontPic==readers[1]and P.monFrontPic==readers[2],'native picture reader changed')
 Stack.pop('jump_art_fixture');U.wait(2)
 Native.picture=picture;g.draw=draw;game.update=update
 print('[PASS native Pokemon Jump art]',version,'FIT/FULL/OFF, two player identities, original bounce, cache/score ownership; y positions',count)
 love.event.quit()
end
