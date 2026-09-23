-- Native GPU review fixture. Never runs against the user's normal save.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing non-QA profile')
 local U=dofile('tests/drivers/util.lua')
 local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1920,1080,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local export=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
 local V,C=export.lib,export.firered.camera
 local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision')
 local Scene=V.require('Gen3Scene')
 local maps={'FR_PEWTER_CITY_GYM','FR_CERULEAN_CITY_GYM','FR_VERMILION_CITY_GYM',
  'FR_CELADON_CITY_GYM','FR_FUCHSIA_CITY_GYM','FR_SAFFRON_CITY_GYM',
  'FR_CINNABAR_ISLAND_GYM','FR_VIRIDIAN_CITY_GYM','FR_SAFFRON_CITY_DOJO',
  'FR_MT_MOON_1F','FR_ROCK_TUNNEL_1F','FR_DIGLETTS_CAVE_NORTH_ENTRANCE',
  'FR_SEAFOAM_ISLANDS_1F','FR_NAVEL_ROCK_1F',
  'FR_PEWTER_CITY_MUSEUM_1F','FR_SILPH_CO_2F','FR_POWER_PLANT','FR_POKEMON_MANSION_B1F'}
 if os.getenv('QA_AREAS')then maps={};for id in os.getenv('QA_AREAS'):gmatch('[^,]+')do maps[#maps+1]=id end end
 for _,id in ipairs(maps)do
  assert(Map.load(nil,game,id,{x=5,y=5,facing='up'}))
  local def=Map.currentDef();local before={}
  for y=0,def.height-1 do for x=0,def.width-1 do before[#before+1]=def.midLayout:midAt(x,y)..':'..def.midLayout:collAt(x,y)end end
  local best,bx,by
  for y=1,def.height-2 do for x=1,def.width-2 do
   if Collision.isWalkable(x,y) and not Collision.isWater(x,y) and not Collision.warpAt(x,y)then
    local distance=(x-def.width*.5)^2+(y-def.height*.65)^2
    if not best or distance<best then best,bx,by=distance,x,y end
   end
  end end
  assert(bx,'no safe camera cell: '..id);Player.reset(bx,by,'up')
  -- This fixture checks lit cave geometry; native Flash masking stays native.
  game.session.flashLevel=0
  for _,view in ipairs({{3,0,'static'},{7,.65,'rotating'},{6,.65,'first'}})do
   C.setLevel(view[1],game);C.yaw=view[2];C.pitch=.12;U.wait(80)
   assert(C.active,'native fallback: '..id)
   assert(U.shot(game,dir..'/'..id..'_'..view[3]..'.png'))
  end
  local at=0
  for y=0,def.height-1 do for x=0,def.width-1 do at=at+1
   assert(before[at]==def.midLayout:midAt(x,y)..':'..def.midLayout:collAt(x,y),'presentation mutated native layout')
  end end
  print('[depth area]',id,'props',Scene.propCount,'camera',bx,by)
 end
 print('[depth areas] PASS rendering and native-layout integrity; captures require visual review')
 love.event.quit()
end
