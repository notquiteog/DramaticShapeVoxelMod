return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 local version=require('src.core.GameVersion').get();local hoenn=version=='emerald'or version=='ruby'or version=='sapphire'
 game:_handleBootAction({action='new_game',start={map=hoenn and (version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_')..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=8,y=12,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene');local I=V.require('Gen3Integration')
 I.setLevel(7,game);scene.invalidate()
 for i=1,1800 do U.wait(1);if I.active then break end end
 assert(I.active,'native voxel field not ready')
 local Fx=require('src.core.game3.field_effects');Fx.animateFlashLevel(1,0)
 U.wait(2);assert(not I.active and scene.nativeRequired(game),'native flash not presented')
 local down,pos=love.mouse.isDown,love.mouse.getPosition;local x,y=10,10
 love.mouse.isDown=function(b)return b==2 end;love.mouse.getPosition=function()return x,y end
 local yaw=I.yaw;U.wait(1);x=30;U.wait(1)
 love.mouse.isDown, love.mouse.getPosition=down,pos
 assert(I.yaw~=yaw,'native effect discarded polled mouse direction')
 local aimed=I.yaw;assert(U.shot(game,os.getenv('SHOT_DIR')..'/native-effect.png'))
 for i=1,1800 do U.wait(1);if I.active then break end end
 assert(I.active and I.yaw==aimed,'return lost camera direction')
 U.wait(5);assert(U.shot(game,os.getenv('SHOT_DIR')..'/returned.png'))
 print('[PASS native effect look continuity]',version);love.event.quit()
end
