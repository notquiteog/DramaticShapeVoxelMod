-- Native mailbox variants and local fence/sign recipes, preserving map cells.
return function(game)
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1600,900,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=5,y=9,facing='up'}})
 local E=game.mods.exports.BATTLE_ART_VOXEL_FORK;local V,C=E.lib,E.firered.camera
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local Types,Shapes,Furniture=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('Gen3Furniture')
 local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native')
 local n=0
 for _,case in ipairs({{'FR_PALLET_TOWN',0x2A5,'mailbox'},{'FR_SAFFRON_CITY',0x327,'mailbox'},
  {'FR_PALLET_TOWN',0x284,'fence'},{'FR_FUCHSIA_CITY',0x296,'sign'},
  {'FR_SAFARI_ZONE_CENTER',0x308,'fence'},{'FR_SAFFRON_CITY',0x33C,'sign'}})do
  assert(Map.load(nil,game,case[1],{x=8,y=12,facing='up'}))
  local d=Map.currentDef();local ts=Tiles.get(d.midLayout.pair);local spec=Types.resolve(d.midLayout.pair,Versions.TILESET_PAIRS)
  local cells,targets={},{}
  for y=0,d.height-1 do for x=0,d.width-1 do
   local mid=d.midLayout:midAt(x,y)
   cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=d.midLayout.pair,primary=spec.primary,secondary=spec.secondary,ts=ts,shape=Shapes.of(spec.primary,spec.secondary,mid)}
   if mid==case[2]then targets[#targets+1]={x,y}end
  end end
  assert(#targets>0,'no source fixture '..case[1]..' '..case[2])
  local props=Furniture.extract(cells)
  if case[3]=='mailbox' then
   local count=0;for _,p in ipairs(props)do if p.recipe.kind=='mailbox' then count=count+1 end end
   assert(count==#targets,'mailbox halves were not claimed together')
  end
  local target=targets[1];local best,pos
  for y=0,d.height-1 do for x=0,d.width-1 do
   if Collision.isWalkable(x,y) and not Collision.warpAt(x,y) and not Collision.isWater(x,y)then
    local dd=(x-target[1])^2+(y-target[2]-4)^2
    if not best or dd<best then best,pos=dd,{x,y}end
   end
  end end
  assert(pos);Player.reset(pos[1],pos[2],'up');C.setLevel(3,game);C.yaw=0;U.wait(130)
  for _,level in ipairs({3,6,7})do
   C.setLevel(level,game);C.yaw=level>=6 and math.atan2(target[1]-pos[1],pos[2]-target[2]-1) or 0;C.pitch=.2;U.wait(16)
   assert(C.active);assert(U.shot(game,dir..'/'..case[1]..'_'..case[3]..'_'..string.format('%03X',case[2])..'_'..level..'.png'));n=n+1
  end
  for _,c in pairs(cells)do assert(d.midLayout:midAt(c.cx,c.cy)==c.mid,'prop mutated source map')end
  print('[street props]',case[1],case[3],#targets)
 end
 print('[street props] PASS',n,'native views, complete mailbox matches and unchanged source maps')
 love.event.quit()
end
