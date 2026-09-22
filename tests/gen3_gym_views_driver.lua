return function(game)
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1920,1080,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local C=game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local Buildings=V.require('Gen3Buildings');local Types=V.require('Gen3Tilesets');local Shapes=V.require('Gen3TileShape')
 local Versions=require('src.import.gba.versions')
 for _,city in ipairs({'PEWTER_CITY','CERULEAN_CITY','VERMILION_CITY','CELADON_CITY','FUCHSIA_CITY','SAFFRON_CITY','CINNABAR_ISLAND','VIRIDIAN_CITY'})do
  local id='FR_'..city
  assert(Map.load(nil,game,id,{x=10,y=10,facing='up'}))
  local def=Map.currentDef();local spec=Types.resolve(def.midLayout.pair,Versions.TILESET_PAIRS)
  local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do
   local mid=def.midLayout:midAt(x,y)
   cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=def.midLayout.pair,primary=spec.primary,secondary=spec.secondary,shape=Shapes.of(spec.primary,spec.secondary,mid)}
  end end
  local gyms=Buildings.prepare(cells);assert(#gyms==(city=='SAFFRON_CITY' and 2 or 1),'missing/duplicate gym: '..id)
  local g;for _,b in ipairs(gyms)do if b.variant~='dojo' then assert(not g);g=b end end
  local count=0;for _,c in pairs(cells)do if c.gym==g then count=count+1 end end
  assert(count==g.width*5,'incomplete gym shell')
  local function locate(tx,ty)
   local pos,best
   for y=1,def.height-2 do for x=1,def.width-2 do
    if Collision.isWalkable(x,y) and not Collision.warpAt(x,y) and not Collision.isWater(x,y)then
     local d=(x-tx)^2+(y-ty)^2;if not best or d<best then pos,best={x,y},d end
    end
   end end
   assert(pos);Player.reset(pos[1],pos[2],'up')
  end
  locate(g.cx+g.width*.5,g.cy+6);C.setLevel(3,game);C.yaw=0;U.wait(220)
  assert(C.active and V.require('Gen3Scene').gymCount==#gyms,'native gym model absent')
  assert(U.shot(game,dir..'/'..id..'_gym_static.png'))
  for _,level in ipairs({6,7})do
   C.setLevel(level,game);C.yaw=0;C.pitch=.15;U.wait(20)
   assert(U.shot(game,dir..'/'..id..'_gym_'..level..'.png'))
  end
  locate(g.cx+g.width+3,g.cy+1);C.setLevel(7,game);C.yaw=-math.pi/2;C.pitch=.2;U.wait(25)
  assert(U.shot(game,dir..'/'..id..'_gym_side.png'))
  for _,c in pairs(cells)do assert(def.midLayout:midAt(c.cx,c.cy)==c.mid,'geometry changed native map')end
  print('[gym exterior QA]',id,g.variant,g.width,count)
 end
 print('[gym exteriors] PASS eight complete gyms plus Fighting Dojo, 32 native camera views, unchanged map cells')
 love.event.quit()
end
