return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 local U=dofile('tests/drivers/util.lua');local dir=os.getenv('SHOT_DIR');local version=require('src.core.GameVersion').get()
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=version=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('VoxelGrid').set(false,game);local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local C=V.require('Gen3Integration')
 local maps=version=='emerald'and{'EM_OLDALE_TOWN_MART','EM_RUSTBORO_CITY_HOUSE3','EM_FORTREE_CITY_HOUSE3','EM_LITTLEROOT_TOWN_PROFESSOR_BIRCHS_LAB'}or{'FR_VIRIDIAN_CITY_POKEMON_CENTER_1F','FR_CERULEAN_CITY_MART','FR_ROUTE_2_HOUSE'}
 for _,id in ipairs(maps)do
  local d=assert(game.data.maps[id]);Map.ensureMidLayout(game,id,d)
  local native={};for y=0,d.height-1 do for x=0,d.width-1 do native[#native+1]=d.midLayout:collAt(x,y)end end
  local px,py
  for y=d.height-2,2,-1 do for x=math.floor(d.width/2),d.width-2 do if not px and d.midLayout:collAt(x,y)==0 then px,py=x,y end end end
  assert(px,'no walkable viewing cell');assert(Map.load(nil,game,id,{x=px,y=py,facing='up'}));U.wait(20)
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
  Player.reset(px,py,'up');Player.setVisible(true)
  local FF=V.require('Gen3Furniture');local PP=V.require('Gen3Tilesets');local pair=PP.canonical(d.midLayout.pair);local spec=PP.resolve(pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),primary=spec.primary,secondary=spec.secondary,pair=pair,ts={}}end end
  for _,p in ipairs(FF.extract(cells))do if p.recipe.design then
   local rows={};for y=p.cy-1,p.cy+#p.recipe.rows do local row={};for x=p.cx,p.cx+#p.recipe.rows[1]-1 do row[#row+1]=tostring(d.midLayout:collAt(x,y))end;rows[#rows+1]=table.concat(row,',')end
   print('[prop]',id,p.recipe.design,p.cx,p.cy,table.concat(rows,' / '))
  end end
  C.setLevel(0,game);U.wait(3);U.shot(game,dir..'/'..id..'-native.png')
  C.setLevel(3,game);U.wait(100);U.shot(game,dir..'/'..id..'-overview.png')
  local views={EM_FORTREE_CITY_HOUSE3={1,4},EM_RUSTBORO_CITY_HOUSE3={8,3},EM_LITTLEROOT_TOWN_PROFESSOR_BIRCHS_LAB={3,3}};local pos=views[id];if pos and d.midLayout:collAt(pos[1],pos[2])==0 then Player.reset(pos[1],pos[2],'up')end
  C.setLevel(6,game);C.yaw=0;C.pitch=0;U.wait(15);U.shot(game,dir..'/'..id..'-first.png')
  local n=0;for y=0,d.height-1 do for x=0,d.width-1 do n=n+1;assert(native[n]==d.midLayout:collAt(x,y),'renderer changed native collision')end end
  assert(not C.lastError,tostring(C.lastError));print('[PASS]',id,px,py)
 end
 love.event.quit()
end
