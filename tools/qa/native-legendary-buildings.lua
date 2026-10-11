return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_VERMILION_CITY',x=12,y=20,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end
 local vm=Space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene')
 C.buildings:setIndex(2,game);V.require('Gen3Integration').setLevel(3,game);V.require('TreePresentation').changed('vermilionBuildings')
 for i=1,1800 do U.wait(1);if(scene.legendaryBuildingCount or 0)>0 then break end end
 print('BUILDINGS',scene.legendaryBuildingCount)
 assert((scene.legendaryBuildingCount or 0)>0,'no reviewed native buildings replaced')
 U.wait(30);assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/legendary.png'))
 local I=V.require('Gen3Integration');I.setLevel(6,game);I.yaw=0;I.pitch=0;U.wait(60)
 local doors=require('src.core.game3.doors');local opened=false;doors.open('FR_VERMILION_CITY',12,17,{playSound=false},function()opened=true end);for i=1,90 do U.wait(1);if opened then break end end;assert(opened,'native door did not finish opening')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/door-open.png'));local closed=false;doors.close('FR_VERMILION_CITY',12,17,{playSound=false},function()closed=true end);for i=1,90 do U.wait(1);if closed then break end end;assert(closed,'native door did not finish closing')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/door-closed.png'));I.setLevel(3,game)
 C.buildings:setIndex(1,game);V.require('TreePresentation').changed('vermilionBuildings');U.wait(120)
 assert((scene.legendaryBuildingCount or 0)==0,'INSTALLED retained replacement')
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/native.png'))
 print('[PASS native shared buildings]');love.event.quit()
end
