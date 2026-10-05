return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 require('src.render.Pipelines').setLevel('voxel',4)
 V.require('UiBackplates').arenaFill:setIndex(1,game)
 local mode=os.getenv('QA_CAPTURE_MODE')or'caught'
 local settings=V.require('PokeballSettings');settings.enabled:setIndex(mode=='off'and 1 or 2,game);V.require('OverworldBattle').setting:setIndex(1,game)
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',10)}
 U.wait(100)
 game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil -- QA warp setup completed before encounter
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 for i=1,450 do screen=V.require('Gen2Staged').screenFor(game);if screen and screen.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(screen,'no battle screen');U.wait(30)
 print('QA capture stage',screen.phase,V.require('Gen2Battle').stagedMon(screen:activeMon('enemy')),screen:bgMode(),game.options.battleBg,V.require('UiBackplates').arenaFill:get(),V.require('Gen2Battle').sceneOverrideEnabled)
 print('QA layout',screen:wideLayout(),game.options.battleLayout)
 local shot=V.require('OverworldBattle').shot();local d=shot.canvas:newImageData();local png=d:encode('png');local f=assert(io.open(os.getenv('SHOT_DIR')..'/stage.png','wb'));f:write(png:getString());f:close();d:release()
 U.shot(game,os.getenv('SHOT_DIR')..'/before.png')
 local ball=V.require('Pokeball');local draw=ball.draw;local draws=0;ball.draw=function(self,...)draws=draws+1;return draw(self,...)end
 local scene=V.require('BattleScene');local count=0;local start=scene.startNormalBall
 scene.startNormalBall=function(...)count=count+1;return start(...)end
 if mode=='escape'then screen.battle.random=function(n)return n-1 end end
 screen:useItem(mode=='escape'and'POKE_BALL'or'MASTER_BALL')
 local sound=screen.anim.hooks.sound;screen.anim.hooks.sound=function(name,...)print('QA capture sound',name);return sound(name,...)end
 while game.stack:top()~=screen do game.stack:pop()end -- QA: dismiss optional MMO XP notification
 for i=1,550 do U.wait(1);if i==45 or i==100 or i==250 or i==400 then U.shot(game,os.getenv('SHOT_DIR')..'/capture-'..i..'.png')end end
 local deadline=love.timer.getTime()+2;while love.timer.getTime()<deadline do U.wait(1)end
 U.shot(game,os.getenv('SHOT_DIR')..'/final.png')
 if mode~='off'then assert(draws>0,'3D ball never drawn')end
 if mode=='escape'then local before=draws;deadline=love.timer.getTime()+.3;while love.timer.getTime()<deadline do U.wait(1)end;assert(draws==before,'escaped ball did not clean up')end
 ball.draw=draw
 assert(count==(mode=='off'and 0 or 1),'native 3D capture ownership '..count)
 if mode=='escape'then assert(screen.ballThrow.caught==false,'escape fixture unexpectedly caught')end
 print('[PASS Gen2 capture runtime]',count,screen.ballThrow and screen.ballThrow.wobble)
 scene.startNormalBall=start;settings.enabled:setIndex(1,game);V.require('Gen2Capture').finish()
 love.event.quit()
end
