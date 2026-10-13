return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local version=require('src.core.GameVersion').get();local hoenn=version=='emerald'or version=='ruby'or version=='sapphire'
 game:_handleBootAction({action='new_game',start={map=hoenn and (version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_')..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=8,y=14,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene');local I=V.require('Gen3Integration')
 require('src.core.game3.player').reset(10,17,'up')
 I.setLevel(3,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if I.active then break end end
 assert(I.active,'native voxel field not ready')
 local G=V.require('Gen3GroundEffects');local draw=G.draw;local cards=0
 G.draw=function(fx,ground,emit,cam)return draw(fx,ground,function(id,...)if id:match('^cut%-leaf')then cards=cards+1 end;return emit(id,...)end,cam)end
 local Fx=require('src.core.game3.field_effects');local done=0
 Fx.startCutGrass(10,17,function()done=done+1 end)
 U.wait(4);assert(I.active and not scene.nativeRequired(game),'Cut burst stole camera')
 assert(cards>0,'no native leaf cards drawn');assert(U.shot(game,os.getenv('SHOT_DIR')..'/cut.png'))
 U.wait(35);assert(I.active and done==1,'native Cut completion changed')
 G.draw=draw;print('[PASS native Cut world cards]',version,cards);love.event.quit()
end
