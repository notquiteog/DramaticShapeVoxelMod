return function(game)
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1920,1080,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C=game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local Buildings,Civic=V.require('Gen3Buildings'),V.require('Gen3Civic')
 local Types,Shapes=V.require('Gen3Tilesets'),V.require('Gen3TileShape')
 local Versions=require('src.import.gba.versions')
 local total=0
 for _,id in ipairs({'FR_VIRIDIAN_CITY','FR_PEWTER_CITY','FR_SAFFRON_CITY','FR_CINNABAR_ISLAND'})do
  assert(Map.load(nil,game,id,{x=10,y=10,facing='up'}))
  local d=Map.currentDef();local spec=Types.resolve(d.midLayout.pair,Versions.TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do
   local mid=d.midLayout:midAt(x,y)
   cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=d.midLayout.pair,primary=spec.primary,secondary=spec.secondary,shape=Shapes.of(spec.primary,spec.secondary,mid)}
  end end
  local list=Civic.prepare(cells,Buildings.prepare(cells));local count=0
  for _,g in ipairs(list)do if g.kind~='gym' then
   count=count+1
   local function locate(tx,ty)
    local best,pos
    for y=0,d.height-1 do for x=0,d.width-1 do
     if Collision.isWalkable(x,y) and not Collision.warpAt(x,y) and not Collision.isWater(x,y)then
      local dist=(x-tx)^2+(y-ty)^2;if not best or dist<best then best,pos=dist,{x,y}end
     end
    end end
    assert(pos);Player.reset(pos[1],pos[2],'up')
   end
   locate(g.cx+g.width/2,g.cy+g.depth+3);C.setLevel(3,game);C.yaw=0;U.wait(220)
   assert(C.active and V.require('Gen3Scene').civicCount>=count)
   for _,level in ipairs({3,6,7})do
    C.setLevel(level,game);C.yaw=0;C.pitch=.18;U.wait(12)
    assert(U.shot(game,dir..'/'..id..'_'..g.kind..'_'..level..'.png'));total=total+1
   end
   locate(g.cx+g.width+3,g.cy+2);C.setLevel(7,game);C.yaw=-math.pi/2;U.wait(12)
   assert(U.shot(game,dir..'/'..id..'_'..g.kind..'_side.png'));total=total+1
  end end
  assert(count==2,'missing Center/Mart model: '..id)
  for _,c in pairs(cells)do assert(d.midLayout:midAt(c.cx,c.cy)==c.mid,'model changed map data')end
 end
 local style=V.require('TreePresentation')
 assert(style.flat(),'flat trunks not the default')
 assert(Map.load(nil,game,'FR_ROUTE_1',{x=11,y=15,facing='up'}));C.setLevel(7,game);C.yaw=math.pi/2;C.pitch=.1;U.wait(220)
 for _,value in ipairs({'flat','solid','flat'})do
  local before=V.require('Gen3Scene').builds
  style.setting:sync(value);style.changed(style.setting.key);U.wait(25)
  assert(V.require('Gen3Scene').builds>before,'trunk option did not rebuild')
  assert(U.shot(game,dir..'/trees_'..value..'.png'))
 end
 dofile('/home/admin/Projects/DramaticShapeVoxelMod/tests/canopy_billboard_gpu.lua')(V)
 print('[civic QA] PASS',total,'Center/Mart views, unchanged maps, live flat/solid trunks and shared GPU transforms')
 love.event.quit()
end
