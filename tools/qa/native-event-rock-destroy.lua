return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local version=require('src.core.GameVersion').get();local hoenn=version=='emerald'or version=='ruby'or version=='sapphire'
 game:_handleBootAction({action='new_game',start={map='EM_BIRTH_ISLAND_EXTERIOR',x=15,y=15,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene');local I=V.require('Gen3Integration')
 require('src.core.game3.player').reset(15,15,'up')
 I.setLevel(3,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if I.active then break end end
 assert(I.active,'native voxel field not ready')
 local Objects=require('src.core.game3.objects');local Fx=require('src.core.game3.field_effects')
 local Effects=V.require('Gen3GroundEffects');local draw=Effects.draw;local cards=0
 Effects.draw=function(fx,groundAt,emit,...)
  return draw(fx,groundAt,function(id,...)if tostring(id):match('rock%-shard')then cards=cards+1 end;return emit(id,...)end,...)
 end
 local rock=assert(Objects.find(1),'native event rock not loaded')
 local sheet=Fx.loadSheet('deoxys_rock_fragments',8,8,4)
 local event=assert(Fx.startDestroyDeoxysRock(1),'native destruction not started')
 for i=1,180 do U.wait(1);assert(I.active and not scene.nativeRequired(game),'native destruction stole camera');if event.state=='shatter'then break end end
 assert(event.state=='shatter','native shake did not finish');U.wait(1)
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/shatter.png'))
 if sheet then assert(cards>0,'native fragments not drawn')else print('[BLOCKED native fragment art] public loader has no RGBA sheet')end
 for i=1,180 do U.wait(1);if event.amp==0 then break end end
 assert(event.amp==0 and rock.hidden and rock.def.hidden,'native rock removal did not finish');assert(I.active,'camera lost after removal')
 Effects.draw=draw
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/removed.png'))
 print('[PASS native event rock destruction]',version,cards);love.event.quit()
end
