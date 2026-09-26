-- Adjacent shared-art room and unrelated busy lab regression, isolated only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local gen=V.require('Generation').number()
 local maps=gen==3 and {'FR_RIVALS_HOUSE','FR_OAKS_LAB'} or gen==2 and {'CHERRYGROVE_POKECENTER_1F','ELMS_LAB'}or {'BLUES_HOUSE','OAKS_LAB'}
 if gen==3 then game:_handleBootAction({action='new_game',start={map='FR_PLAYERS_HOUSE_1F',x=4,y=7,facing='up'}})end
 for _,id in ipairs(maps)do
  game.input:reset();if game.stack then game.stack:clear()end
  if gen==3 then
   assert(require('src.core.game3.map').load(nil,game,id,{x=5,y=6,facing='up'}))
   V.require('Gen3Integration').setLevel(3,game);U.wait(100);assert(V.require('Gen3Integration').active)
  elseif gen==2 then
   local w=game.world;w.trySceneScript=function()return false end;assert(w:setMap(id,5,6,'up'));w.vm=nil;w.textbox=nil
   require('src.render.Pipelines').setLevel('voxel',3);U.wait(180)
  else
   game.stack:push(require('src.world.OverworldController'),id,5,6,'up')
   require('src.render.Pipelines').setLevel('voxel',3);U.wait(180)
  end
  U.shot(game,os.getenv('SHOT_DIR')..'/'..id..'.png')
 end
 print('[house neighbors] complete; inspect captures separately');love.event.quit()
end
