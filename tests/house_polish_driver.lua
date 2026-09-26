-- Native source/overview/first-person house fixtures, never user progress.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local gen=V.require('Generation').number();local R=V.require('Voxel3D');local dir=os.getenv('SHOT_DIR')
 if gen==3 then
  local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
  game:_handleBootAction({action='new_game',start={map='FR_PLAYERS_HOUSE_1F',x=6,y=4,facing='up'}})
  for _,id in ipairs({'FR_PLAYERS_HOUSE_1F','FR_PLAYERS_HOUSE_2F'})do
   game.input:reset();assert(Map.load(nil,game,id,{x=6,y=4,facing='up'}));require('src.ui.game3.map_preview_screen').reset()
   C.setLevel(3,game);U.wait(75);assert(C.active);U.shot(game,dir..'/'..id..'-overview.png')
   assert(Map.load(nil,game,id,{x=9,y=4,facing='up'}));C.setLevel(6,game);C.yaw=.55;C.pitch=-.12;U.wait(65)
   U.shot(game,dir..'/'..id..'-stairs-first.png')
  end
  assert(Map.load(nil,game,'FR_PLAYERS_HOUSE_2F',{x=3,y=4,facing='up'}));C.yaw=0;C.pitch=0;U.wait(65)
  U.shot(game,dir..'/dresser-first.png')
  assert(Map.load(nil,game,'FR_PLAYERS_HOUSE_1F',{x=10,y=4,facing='left'}));C.yaw=-math.pi/2;C.pitch=-.1;U.wait(65)
  U.shot(game,dir..'/mom-seated-first.png')
  C.setLevel(7,game);C.yaw=-.6;C.pitch=.48;U.wait(65);U.shot(game,dir..'/mom-seated-orbit.png')
 else
  local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
  local maps=gen==2 and {'PLAYERS_HOUSE_1F','PLAYERS_HOUSE_2F'}or {'REDS_HOUSE_1F','REDS_HOUSE_2F'}
  for _,id in ipairs(maps)do
   game.input:reset();game.stack:clear()
   if gen==2 then local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
    assert(w:setMap(id,6,6,'up'));w.textbox=nil;w.stayedTextBox=nil;w.vm=nil
   else game.stack:push(require('src.world.OverworldController'),id,6,6,'up')end
   P.setLevel('voxel',3);U.wait(180);U.shot(game,dir..'/'..id..'-overview.png')
   P.setLevel('voxel',6);U.wait(60);F.pitch=0;F.yaw=math.pi;U.wait(60)
   local camera=R.camera;local player=(gen==2 and game.world or game.overworld).player
   local eye=V.require('SpriteBillboards').eyeHeight(player.sprite.def)-(player.spriteYOffset or 0)
   assert(camera and math.abs(camera.eye[2]-eye)<.01,'GB camera not at player eye height: '..tostring(camera and camera.eye[2])..' expected '..eye)
   U.shot(game,dir..'/'..id..'-first.png')
   print('[house eyes]',gen,id,camera.eye[2])
   if gen==2 then
    local w=game.world;local x=id=='PLAYERS_HOUSE_1F' and 9 or 7
    assert(w:setMap(id,x,id=='PLAYERS_HOUSE_1F' and 2 or 1,'up'));w.textbox=nil;w.vm=nil
    F.yaw=math.pi;F.pitch=id=='PLAYERS_HOUSE_1F' and -.12 or .75;U.wait(65)
    U.shot(game,dir..'/'..id..'-stairs-first.png')
   end
   if gen==2 then
    local room=V.require('InteriorDiorama').forMap(game.world.map,gen)
    if id=='PLAYERS_HOUSE_2F'then assert(room.openings and #room.openings>0,'upstairs opening sealed')end
    local count=0
    for _,q in ipairs(V.require('Structures').forMap(game.world.map).objectQuads or {})do
     if q.interiorStairRole=='house-tread'then count=count+1 end
    end
    assert(count==4,'native house stairs were claimed by another builder: '..count)
   end
  end
 end
 print('[house polish] fixtures complete; inspect captures separately');love.event.quit()
end
