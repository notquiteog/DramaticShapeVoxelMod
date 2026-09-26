return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 V.require('CommunityVisuals').forest:sync('n64memory');V.require('CommunityVisuals').tower:sync('n64memory');local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end;game.stack:clear()
 local maps={'ILEX_FOREST','NEW_BARK_TOWN','CELADON_CITY'}
 if os.getenv('QA_MAPS')then maps={};for id in os.getenv('QA_MAPS'):gmatch('[^,]+')do maps[#maps+1]=id end end
 for _,map in ipairs(maps)do
  if true then
   assert(w:setMap(map,14,20,'up'));
   local Pm=require('src.world.gen2.Permissions');local best,px,py=math.huge
   for yy=3,w.map.heightCells-4 do for xx=3,w.map.widthCells-4 do
    local S=V.require('Gen2TileShape');local tx,ty=xx*2,(yy-2)*2
    local class=S.classAt(w.map,xx,yy-2,S.paletteOf(w.map.tileset,w.map:tileAt(tx,ty)),S.paletteOf(w.map.tileset,w.map:tileAt(tx,ty+1)))
    local clear=Pm.isWalkable(w.map:cellCollision(xx,yy)) and (class=='tree' or class=='roundtree' or class=='foresttree')
    local distance=(xx-14)^2+(yy-20)^2
    if clear and distance<best then best,px,py=distance,xx,yy end
   end end
   assert(px,'no open path fixture');assert(w:setMap(map,px,py,'up'));print('[walkable fixture]',map,px,py)
game.stack:clear();w.textbox=nil;w.stayedTextBox=nil;w.vm=nil
   for _,view in ipairs({{'overview',3,0,.25},{'first',6,math.pi,.05}})do
    P.setLevel('voxel',view[2]);U.wait(45);F.yaw=view[3];F.pitch=view[4];U.wait(35)
    U.shot(game,os.getenv('SHOT_DIR')..'/'..map..'-'..view[1]..'.png')
   end
  else print('[missing fixture]',map)end
 end
 print('[native trees] three Crystal families captured');love.event.quit()
end
