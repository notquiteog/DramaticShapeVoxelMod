return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 love.window.setMode(1280,720)
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local gen=V.require('Generation').number()
 local P=require('src.render.Pipelines');local dir=os.getenv('SHOT_DIR')
 local targets=gen==3 and {{'FR_VICTORY_ROAD_1F',10,10},{'FR_MT_MOON_1F',14,10}}or gen==2 and
  {{'DARK_CAVE_BLACKTHORN_ENTRANCE',19,8},{'ICE_PATH_1F',4,7}}or {{'MT_MOON_1F',10,10},{'DIGLETTS_CAVE',18,20}}
 if gen==3 then game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})end
 for _,q in ipairs(targets)do
  game.input:reset();if game.stack then game.stack:clear()end
  local map
  if gen==3 then
   assert(require('src.core.game3.map').load(nil,game,q[1],{x=q[2],y=q[3],facing='up'}))
   require('src.ui.game3.map_preview_screen').reset();V.require('Gen3Integration').setLevel(3,game)
   U.wait(150);map=V.require('Gen3Scene').sceneDef
  elseif gen==2 then
   local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
   assert(w:setMap(q[1],q[2],q[3],'up'));w.vm=nil;w.textbox=nil;P.setLevel('voxel',3);U.wait(180);map=w.map
  else game.stack:push(require('src.world.OverworldController'),q[1],q[2],q[3],'up');P.setLevel('voxel',3);U.wait(180);map=game.stack:top().map end
  local p=assert(V.require('InteriorDiorama').forMap(map,gen),'cave not enclosed')
  assert(p.cave and not V.require('InteriorDiorama').camera(p,.6,16/9))
  print('[cave enclosure]',gen,q[1],p.height,table.concat(p.bounds,','))
  U.shot(game,dir..'/'..q[1]..'-overview.png')
  for i,view in ipairs({{0,-.45},{math.pi/2,0},{math.pi,-.2}})do
   if gen==3 then local c=V.require('Gen3Integration');c.setLevel(6,game);c.yaw=view[1];c.pitch=view[2]
   else P.setLevel('voxel',6);local f=V.require('FirstPerson');f.yaw=view[1];f.pitch=view[2]end
   U.wait(45);U.shot(game,dir..'/'..q[1]..'-first-'..i..'.png')
  end
 end
 print('[cave enclosure] complete');love.event.quit()
end
