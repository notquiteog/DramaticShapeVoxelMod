-- Native 0.2.73 FireRed smoke/visual QA in a DISPOSABLE identity only.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local dir=assert(os.getenv('SHOT_DIR'))
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa','refusing a non-QA save identity')
 assert(require('src.core.Version').engine=='0.2.73')
 assert(require('src.core.GameVersion').generation()==3)
 love.window.setMode(1280,720,{resizable=true})
 game:_handleBootAction({action='new_game',name='RED',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local export=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
 local C=assert(export.firered).camera
 local V=export.lib;local R=V.require('Voxel3D')
 C.setLevel(3,game);U.wait(90)
 assert(C.active and C.rendered>0,'adapter loaded without drawing')
 local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision')
 local Battle=require('src.core.game3.battle')
 local battleDraw=Battle.draw
 local n=0
 for _,case in ipairs({{'FR_PALLET_TOWN',10,9},{'FR_ROUTE_1',9,10},{'FR_VIRIDIAN_CITY',16,17},{'FR_PLAYERS_HOUSE_2F',6,6}})do
  assert(Map.load(nil,game,case[1],{x=case[2],y=case[3],facing='down'}))
  local def=Map.currentDef()
  local best,bx,by
  for y=1,def.height-2 do for x=1,def.width-2 do
   if Collision.isWalkable(x,y) and not Collision.warpAt(x,y) and not Collision.isWater(x,y) then
    local d=(x-case[2])^2+(y-case[3])^2
    if not best or d<best then best,bx,by=d,x,y end
   end
  end end
  assert(bx,'no safe camera position')
  Player.reset(bx,by,'down')
  C.setLevel(3,game);U.wait(140)
  print('[FireRed view]',case[1],def.midLayout.pair,'HD2D',C.active)
  if case[1]=='FR_PLAYERS_HOUSE_2F' then
   assert(not C.active,'unmapped interior must preserve native presentation')
   assert(U.shot(game,dir..'/interior_native.png'));n=n+1
  else
   for _,level in ipairs({3,7,6,0})do
    C.setLevel(level,game);C.yaw=0;U.wait(12)
    assert((level==0)==not C.active,'incorrect render mode')
    if level>0 then assert(R.canopyFacing==(level>=6),'wrong foliage rotation mode')end
    assert(U.shot(game,dir..'/'..case[1]..'_'..level..'.png'));n=n+1
   end
  end
 end
 assert(Battle.draw==battleDraw,'FireRed native battle renderer was replaced')
 assert(Map.load(nil,game,'FR_PALLET_TOWN',{x=10,y=9,facing='right'}))
 C.setLevel(7,game);C.yaw=math.pi/2;U.wait(45)
 local x=Player.cellX
 U.hold(game,'up',40);U.wait(10)
 assert(Player.cellX>x,'camera-relative native step did not move east')
 print('[FireRed movement]',x,Player.cellX,Player.cellY)
 -- Input cycling goes through the real Game3 dispatcher, not the facade.
 game:keypressed('3');game:keyreleased('3');U.wait(8);assert(C.level==0 and not C.active)
 game:keypressed('3');game:keyreleased('3');U.wait(8);assert(C.level==1 and C.active)
 print('[FireRed QA] PASS',n,'screenshots; native movement, camera cycle, foliage modes and interior fallback')
 love.event.quit()
end
