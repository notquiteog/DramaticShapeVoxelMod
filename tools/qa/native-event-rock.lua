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
 local rock=assert(Objects.find(1),'native event rock not loaded');local x=rock.px
 assert(Fx.startMoveDeoxysRock(1,17,12,12),'native move not started')
 U.wait(4);assert(I.active and not scene.nativeRequired(game),'native rock slide stole camera')
 assert(rock.px~=x and rock.px~=272,'native slide skipped intermediate position')
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/sliding.png'))
 U.wait(15);assert(I.active and rock.px==272 and rock.py==192,'native slide target changed')
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/settled.png'))
 print('[PASS native event rock slide]',version);love.event.quit()
end
