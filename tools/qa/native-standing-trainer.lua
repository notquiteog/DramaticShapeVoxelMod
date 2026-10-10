return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_1',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 V.require('Gen3Battle').setting:setIndex(1,game)
 V.require('BattleArt').backPlacementSetting:setIndex(2,game)
 local S=V.require('StandingTrainer');S.setting:setIndex(2,game)
 local calls=0;local tex=love.graphics.newCanvas(64,64)
 local image=require('src.core.game3.trainer_pic').back(0).image
 love.graphics.push('all');love.graphics.setCanvas(tex);love.graphics.clear(0,0,0,0);love.graphics.setColor(1,1,1,1);love.graphics.draw(image,0,0);love.graphics.pop()
 local handle=V.require('CharacterRenderers').register({id='qa-native-trainer',battleGenerations={3},drawBattleTrainer=function(ctx)
  assert(ctx.generation==3 and ctx.position and ctx.battle)
  local Mat=ctx.host.Mat4;local p=ctx.position
  local model=Mat.mul(Mat.mul(Mat.translate(p[1],p[2]+8,p[3]),Mat.rotateY(ctx.camera.yaw)),Mat.scale(16,16,1))
  ctx.host.Voxel3D.draw(V.require('BattleBillboard').mesh(),tex,model,0);calls=calls+1;return true
 end})
 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,6,35))
 local B=require('src.core.game3.battle')
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session})
 for i=1,500 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 U.wait(15);assert(B._phase=='command');assert(calls>0,'native trainer provider never drawn')
 U.shot(game,dir..'/legendary.png')
 S.setting:setIndex(1,game);U.wait(20);local stopped=calls;U.wait(10);assert(calls==stopped)
 U.shot(game,dir..'/stock.png');handle:release()
 S.setting:setIndex(2,game);U.wait(20);assert(calls==stopped);assert(not V.require('CharacterRenderers').battleActive())
 U.shot(game,dir..'/missing-provider.png');tex:release()
 print('[PASS native trainer public provider, STOCK and missing fallback]',calls);love.event.quit()
end
