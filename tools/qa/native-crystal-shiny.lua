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
 local Anim=require('src.core.game3.battle.anim')
 local Seq=require('src.core.game3.battle.shiny_seq')
 local Sprites=require('src.core.game3.battle.anim_sprites')
 local Coords=require('src.core.game3.battle.anim_coords')
 local shiny={mon={personality=0,otId=0,otSecretId=0}}
 local normal={mon={personality=128,otId=0,otSecretId=0}}
 local done=0
 local function callback()done=done+1 end
 assert(not Seq.start(normal,1,callback)and done==0,'native nonshiny selection changed')
 local function step(n)for i=1,n do Anim.update(1/60)end end
 local function owned()
  local out={};Sprites.forEachActive(function(s)if s.customDraw and s._crystalAge then out[#out+1]=s end end)
  return out
 end
 local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 assert(Seq.start(shiny,1,callback));step(16)
 local s=owned();assert(#s==1 and s[1].hostId==1,'native enemy anchor missing')
 shot('single-native-stage');step(100);assert(done==1 and #owned()==0,'native completion once')
 C.setLevel(3,game);V.require('Gen3Battle').setting:sync(true)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 U.wait(30);assert(V.require('Gen3Battle').active,'voxel battle stage inactive')
 assert(Seq.start(shiny,0,callback));step(24);assert(#owned()==1 and owned()[1].hostId==0)
 shot('player-voxel-stage');step(100);assert(done==2,'player continuation missing')
 Coords.setDouble(true)
 assert(Seq.startMany({shiny,shiny},{1,3},callback));step(24)
 s=owned();assert(#s==2,'double controllers missing')
 local ids={};for _,sprite in ipairs(s)do ids[sprite.hostId]=true end
 assert(ids[1]and ids[3],'native double battler IDs lost');shot('double-voxel-stage')
 step(100);assert(done==3,'double completion was duplicated');Coords.setDouble(nil)
 crystal.pack:sync('selected');assert(Seq.start(shiny,1,callback));step(75)
 assert(#owned()==0,'native selected-art fallback intercepted');shot('selected-native-sparkles')
 step(150);assert(done==4,'native fallback completion missing')
 crystal.pack:sync('crystal');assert(Seq.start(shiny,1,callback));step(20)
 crystal.pack:sync('selected');step(100);assert(done==5 and #owned()==0,'live toggle stranded continuation')
 crystal.pack:sync('crystal');assert(Seq.start(shiny,1,callback));step(20)
 Anim.reset();step(100);assert(done==5 and #owned()==0,'reset fired continuation or retained sprite')
 crystal.pack:sync(prior);B.update=battleUpdate;game.update=update
 print('[PASS native Crystal shiny]',version,'single/player/double/native/toggle/reset; continuations',done)
 love.event.quit()
end
