return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local Runtime=require('src.mods.Runtime')
 local update=game.update;game.update=function(self,dt)return Runtime.call('core.update',update,self,dt)end
 local emerald=require('src.core.GameVersion').get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=emerald and 'EM_LITTLEROOT_TOWN' or 'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration')
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 local P=require('src.core.game3.player');P.setVisible(true)
 V.require('VoxelGrid').set(false,game);C.setLevel(7,game);C.yaw=0;C.pitch=.16;U.wait(180)
 local Fx=require('src.core.game3.field_effects');local count=0
 Fx.startExclamation(P,function()count=count+1 end)
 U.wait(10)
 print('[emote camera]',C.active,'native',V.require('Gen3Scene').nativeRequired(game),'error',C.lastError)
 U.shot(game,os.getenv('SHOT_DIR')..'/exclamation.png')
 assert(C.active,'exclamation stole voxel camera')
 local yaw=C.yaw
 Runtime.call('input.gamepad',function()end,game,{phase='axis',axis='rightx',value=.8})
 U.wait(8)
 Runtime.call('input.gamepad',function()end,game,{phase='axis',axis='rightx',value=0})
 assert(C.yaw~=yaw,'right stick lost look control')
 U.wait(90);assert(count==1,'native emote completion changed');assert(C.active,'camera did not remain active')
 print('[emote completed]',count);love.event.quit()
end
