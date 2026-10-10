return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(require('src.core.GameVersion').get()==os.getenv('POKEPORT_VERSION'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 love.window.setMode(1280,720)
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
 local targets={
 {'CELADON_DEPT_STORE_1F',15,1,'up',15,0,'CELADON_DEPT_STORE_2F'},
 {'CELADON_DEPT_STORE_2F',15,1,'up',15,0,'CELADON_DEPT_STORE_1F'},
 {'GOLDENROD_DEPT_STORE_1F',15,1,'up',15,0,'GOLDENROD_DEPT_STORE_2F'},
 {'GOLDENROD_DEPT_STORE_2F',15,1,'up',15,0,'GOLDENROD_DEPT_STORE_1F'},
 {'OLIVINE_PORT_PASSAGE',14,4,'right',15,4,'OLIVINE_PORT_PASSAGE',3,2},
 {'OLIVINE_PORT_PASSAGE',4,2,'left',3,2,'OLIVINE_PORT_PASSAGE',15,4},
 {'VERMILION_PORT_PASSAGE',14,4,'right',15,4,'VERMILION_PORT_PASSAGE',3,2},
 {'VERMILION_PORT_PASSAGE',4,2,'left',3,2,'VERMILION_PORT_PASSAGE',15,4},
 }
 for i,t in ipairs(targets)do
  assert(w:setMap(t[1],t[2],t[3],t[4]));w.vm=nil;w.textbox=nil
  assert(w.map:isWalkable(t[2],t[3]) and w.map:isWalkable(t[5],t[6]))
  local function grid()local a={};local m=w.map;for y=0,m.heightCells*2-1 do for x=0,m.widthCells*2-1 do a[#a+1]=m:tileAt(x,y)end end;for y=0,m.heightCells-1 do for x=0,m.widthCells-1 do a[#a+1]=m:cellCollision(x,y)end end;return table.concat(a,',')end
  local before=grid();P.setLevel('voxel',6);F.yaw=t[4]=='right' and math.pi/2 or t[4]=='left' and -math.pi/2 or math.pi;F.pitch=.18
  U.wait(120);assert(U.shot(game,dir..'/'..i..'-approach.png'));assert(grid()==before)
  local entry=w.map:warpAt(t[5],t[6]);assert(entry and entry.def.destMap==t[7])
  local result=w:movePlayer(t[4]);assert(result=='moved',result);U.wait(120)
  assert(w.map.id==t[7],'wrong stair destination '..w.map.id)
  if t[8]then assert(w.player.cellX==t[8] and w.player.cellY==t[9],'wrong intra-map landing')end
  print('[stairs]',t[1],i,'PASS native approach/render/step/warp',w.map.id,w.player.cellX,w.player.cellY)
 end
 love.event.quit()
end
