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
 local Options=require('src.ui.game3.rs.option_menu');Options.show({game=game,session=game.session})
 U.wait(2);assert(Options.isOpen(),'RS native options not open')
 local yaw=I.yaw;local forwarded=false
 R.call('input.gamepad',function()forwarded=true end,game,{phase='axis',axis='rightx',value=1})
 U.wait(3);assert(forwarded and I.yaw==yaw,'RS options lost stick ownership')
 R.call('input.gamepad',function()end,game,{phase='axis',axis='rightx',value=0})
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/native-options.png'))
 Options.close(game);U.wait(3);assert(not Options.isOpen()and I.active,'native options exit lost voxel view')
 print('[PASS native RS camera menu ownership]',version);love.event.quit()
end
