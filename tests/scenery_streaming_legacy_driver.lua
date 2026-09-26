-- Native Gen 1/2 streaming and first-person smoke; isolated profiles only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local gen=V.require('Generation').number();assert(gen==1 or gen==2)
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 V.require('TreePresentation').art:sync('modeled')
 local function enter(id,x,y)
  game.input:reset();game.stack:clear()
  if gen==2 then
   local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
   assert(w:setMap(id,x,y,'up'));w.vm=nil;w.textbox=nil;w.stayedTextBox=nil
  else game.stack:push(require('src.world.OverworldController'),id,x,y,'up')end
 end
 local forest=gen==1 and 'VIRIDIAN_FOREST' or 'ILEX_FOREST'
 enter(forest,14,20);P.setLevel('voxel',7);F.yaw=.8;F.pitch=.25
 U.wait(240)
 local flora=V.require('CommunityFlora')
 for i=1,240 do if flora.treeStats().pending==0 then break end;U.wait(1)end
 local stats=flora.treeStats();assert(stats.pending==0,'tree work never finished')
 print('[legacy stream]',gen,forest,'maps',stats.maps,'sections',stats.sections,'vertices',stats.vertices)
 U.shot(game,os.getenv('SHOT_DIR')..'/forest.png')
 enter(gen==1 and 'OAKS_LAB' or 'ELMS_LAB',5,10);P.setLevel('voxel',3);U.wait(180)
 U.shot(game,os.getenv('SHOT_DIR')..'/lab.png')
 P.setLevel('voxel',6);F.pitch=0;F.yaw=math.pi;U.wait(45)
 local camera=V.require('Voxel3D').camera;assert(camera and camera.eye[2]>=11.9,'first person stayed too low')
 U.shot(game,os.getenv('SHOT_DIR')..'/lab-first.png')
 print('[legacy stream] forest/lab/first-person complete',gen,camera.eye[2])
 love.event.quit()
end
