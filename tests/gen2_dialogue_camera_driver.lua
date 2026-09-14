return function(game)
 local U=dofile('/home/admin/Apps/Gen1Recomp/source/tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local F=V.require('FirstPerson');local P=require('src.render.Pipelines')
 local TextBox=require('src.render.TextBox');local w=game.world
 w.trySceneScript=function()return false end;w.noWildEncounters=true
 assert(w:setMap('NEW_BARK_TOWN',7,5,'down'));U.wait(160);game.stack:clear()
 -- Xvfb has no desktop focus manager; explicitly model an active game window.
 local focus=love.window.hasFocus;love.window.hasFocus=function()return true end
 for _,mode in ipairs({6,7}) do
  P.setLevel('voxel',mode);U.wait(60)
  local box=TextBox.new(game,'The camera can turn while this conversation waits.')
  game.stack:push(box);U.wait(10)
  assert(F.looking() and not F.driving(),'dialogue look/movement gates wrong')
  local x,y=w.player.cellX,w.player.cellY
  local yaw=F.yaw
  game:mousemoved(100,100,60,0,false);U.wait(3)
  assert(math.abs(F.yaw-yaw)>.01,'mouse look blocked by text')
  yaw=F.yaw;game:gamepadaxis(nil,'rightx',1);U.wait(10);game:gamepadaxis(nil,'rightx',0)
  assert(math.abs(F.yaw-yaw)>.01,'right stick look blocked by text')
  yaw=F.yaw
  game:pointerEvent('pressed','touch','qa-look',600,300,0,0)
  game:pointerEvent('moved','touch','qa-look',700,300,100,0)
  game:pointerEvent('released','touch','qa-look',700,300,0,0)
  U.wait(3);assert(math.abs(F.yaw-yaw)>.01,'touch look blocked by text')
  game:keypressed('up');U.wait(12);game:keyreleased('up')
  assert(w.player.cellX==x and w.player.cellY==y,'looking unlocked walking during dialogue')
  assert(game.stack:top()==box,'look input dismissed dialogue')
  if os.getenv('SHOT_DIR') then assert(U.shot(game,os.getenv('SHOT_DIR')..'/dialogue_'..mode..'.png')) end
  game.stack:clear()
  -- Native script VM running gate, without adding any persistent story state.
  local running=w.vm.running;w.vm.running=function()return true end
  assert(F.looking() and not F.driving(),'script must allow look without movement')
  yaw=F.yaw;game:mousemoved(100,100,60,0,false);U.wait(3)
  assert(math.abs(F.yaw-yaw)>.01,'cutscene look blocked')
  w.vm.running=running
  game:openStartMenu();U.wait(3);yaw=F.yaw
  assert(not F.looking(),'start menu must keep cursor ownership')
  game:mousemoved(100,100,60,0,false);U.wait(3);assert(F.yaw==yaw,'camera moved under menu')
  game.stack:clear()
 end
 love.window.hasFocus=focus
 print('[dialogue camera] PASS: mouse, stick, touch; both modes; movement/dialogue preserved; script and menu gates')
 love.event.quit()
end
