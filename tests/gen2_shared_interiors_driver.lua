return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing non-QA profile')
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end;game.stack:clear()
 for _,case in ipairs({{'BILLS_FAMILYS_HOUSE',4,5,'common-house'},{'VIOLET_NICKNAME_SPEECH_HOUSE',4,5,'violet-house'},{'PLAYERS_HOUSE_1F',4,4,'players-house'},{'ELMS_LAB',4,6,'lab'},{'CHERRYGROVE_POKECENTER_1F',5,5,'center'}})do
  local map=case[1];if true then
   assert(w:setMap(map,case[2],case[3],'up'));game.stack:clear();w.textbox=nil;w.stayedTextBox=nil;w.vm=nil;U.wait(180)
   for _,view in ipairs({{'overview',3,0,.25},{'first',6,math.pi,.05},{'reverse',7,math.pi,.2}})do
    P.setLevel('voxel',view[2]);U.wait(45);F.yaw=view[3];F.pitch=view[4];U.wait(35)
    U.shot(game,os.getenv('SHOT_DIR')..'/'..case[4]..'-'..view[1]..'.png')
   end
  else print('[missing fixture]',map)end
 end
 print('[common houses] captures complete; inspect appearance separately');love.event.quit()
end
