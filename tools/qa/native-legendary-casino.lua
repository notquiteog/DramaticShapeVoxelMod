return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_CELADON_CITY',x=20,y=20,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset()
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local target;for _,w in ipairs(Map.currentDef().warps or{})do
  if(w.map or w.mapId or w.destMap)=='FR_CELADON_CITY_GAME_CORNER'then target=w;break end
 end;assert(target,'no native casino warp')
 local py=target.y+3;while not Collision.isWalkable(target.x,py)do py=py+1;assert(py<target.y+8)end
 Player.reset(target.x,py,'up')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('CommunityVisuals');local scene=V.require('Gen3Scene');local I=V.require('Gen3Integration')
 C.casino:setIndex(2,game);I.setLevel(3,game);V.require('TreePresentation').changed('communityCasino')
 for i=1,1800 do U.wait(1);if(scene.legendaryBuildingCount or 0)>0 then break end end
 assert((scene.legendaryBuildingCount or 0)>0,'no shared native casino model');print('CASINO',scene.legendaryBuildingCount,target.x,target.y)
 U.wait(60);assert(U.shot(game,os.getenv('SHOT_DIR')..'/legendary.png'))
 I.setLevel(6,game);I.yaw=0;I.pitch=0;U.wait(60);assert(U.shot(game,os.getenv('SHOT_DIR')..'/first-person.png'))
 local doors=require('src.core.game3.doors');local opened=false;doors.open('FR_CELADON_CITY',target.x,target.y,{playSound=false},function()opened=true end)
 for i=1,90 do U.wait(1);if opened then break end end;assert(opened);assert(U.shot(game,os.getenv('SHOT_DIR')..'/door-open.png'))
 local closed=false;doors.close('FR_CELADON_CITY',target.x,target.y,{playSound=false},function()closed=true end)
 for i=1,90 do U.wait(1);if closed then break end end;assert(closed)
 C.casino:setIndex(1,game);V.require('TreePresentation').changed('communityCasino');I.setLevel(3,game);U.wait(120)
 assert((scene.legendaryBuildingCount or 0)==0);assert(U.shot(game,os.getenv('SHOT_DIR')..'/native.png'))
 print('[PASS native Legendary casino]');love.event.quit()
end
