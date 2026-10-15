-- Disposable profiles only. Real battle/VM drawing; shiny records are staged.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();love.window.setMode(480,320,{vsync=0})
 local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C=V.require('Gen3Integration');C.setLevel(3,game)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 V.require('Gen3Battle').setting:sync(false)
 local crystal=V.require('NativeCrystalArt');local prior=crystal.pack:get();crystal.pack:sync('crystal')
 game.session.party={};assert(require('src.core.game3.party').giveMon(game.session,6,35))
 U.wait(90)
 local B=require('src.core.game3.battle')
 assert(require('src.core.game3.battle_bridge').startWild(nil,game,{species=19,level=3}))
 for i=1,400 do if B._phase=='command'then break end;if i%100==0 then print('waiting battle',i,B._phase)end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='command','battle command not reached')
 local battleUpdate=B.update;B.update=function()end
 local Mode=V.require('ModernBattleUI');assert(Mode.providerEnabled(),'real Modern UI provider unavailable')
 Mode.setting:sync(false)
 local O=V.require('Gen3BattleOptions');local UI=V.require('UiBackplates');UI.arenaFill:sync('OFF')
 local Layer=V.require('NativeHudLayer');local draw=Layer.draw;local layers={}
 Layer.draw=function(owner,w,h,k,x,y,pal,fn,...)layers[#layers+1]={k=k,pal=pal};return draw(owner,w,h,k,x,y,pal,fn,...)end
 local hp=B._st.player.mon.hp;local mon=B._st.player.mon
 V.require('Gen3Battle').setting:sync(true);U.wait(30)
 assert(V.require('Gen3Battle').active,'voxel battle stage inactive')
 assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.battlePresentation.nativeHudOwned(),'original HUD ownership not published')
 local function shot(name,scale,invert,want)
  layers={};U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  assert((#layers>0)==want,name..': native layer consumer ownership')
  if want then print('HUD options',name,layers[1].k,layers[1].pal~=nil,UI.hudColor:get(),UI.arenaFill:get());assert(layers[1].k==scale and (layers[1].pal~=nil)==invert,name..': option consumption mismatch')end
  assert(B._st.player.mon==mon and mon.hp==hp,'HUD draw changed native Pokemon')
 end
 O.scale:sync('og');UI.hudColor:sync('COLOR');shot('original-color',1,false,true)
 O.scale:sync('scaled');shot('compact-color',.5,false,true)
 UI.hudColor:sync('INVERTED');shot('compact-inverted',.5,true,true)
 O.scale:sync('og');shot('original-inverted',1,true,true)
 UI.arenaFill:sync('WHITE');shot('white-arena-native-ink',1,false,true);UI.arenaFill:sync('OFF')
 game.mods.modOptions.MODERN_POKEMON_UI=game.mods.modOptions.MODERN_POKEMON_UI or{}
 local provider=game.mods.modOptions.MODERN_POKEMON_UI
 local priorProvider=provider.modernBattleUI;provider.modernBattleUI=false
 shot('provider-off-native',1,false,false);provider.modernBattleUI=priorProvider
 -- Modern mode retains its existing HUD consumer, without a second native layer.
 Mode.setting:sync(true);shot('modern',1,false,false);Mode.setting:sync(false)
 Layer.draw=draw;crystal.pack:sync(prior);B.update=battleUpdate;game.update=update
 print('[PASS native original HUD]',version,'OG/compact/COLOR/INVERTED/white/provider-off/modern')
 love.event.quit()
end
