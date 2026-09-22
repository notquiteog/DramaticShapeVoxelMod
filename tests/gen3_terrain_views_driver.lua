-- Actual native first/third-person coverage; no inspection-camera override.
return function(game)
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1920,1080,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_LAVENDER_TOWN',x=18,y=9,facing='up'}})
 local E=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK);local C,V=E.firered.camera,E.lib
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local shots=0
 for _,target in ipairs({{'FR_LAVENDER_TOWN',18,9},{'FR_ROUTE_10',7,43},{'FR_VIRIDIAN_CITY',20,14}})do
  assert(Map.load(nil,game,target[1],{x=target[2],y=target[3],facing='up'}))
  local d=Map.currentDef();local original={};local best,pos
  for y=0,d.height-1 do for x=0,d.width-1 do
   original[y*d.width+x]=d.midLayout:midAt(x,y)
   if Collision.isWalkable(x,y) and not Collision.isWater(x,y) and not Collision.warpAt(x,y)then
    local n=(x-target[2])^2+(y-target[3])^2;if not best or n<best then best,pos=n,{x,y}end
   end
  end end
  assert(pos);Player.reset(pos[1],pos[2],'up')
  C.setLevel(3,game);C.yaw=0;U.wait(100)
  assert(C.active and V.require('Gen3Scene').cliffCount>0,'raised terrain not built')
  for _,view in ipairs({{3,0},{6,0},{7,0},{7,.65}})do
   C.setLevel(view[1],game);C.yaw=view[2];C.pitch=.16;U.wait(12)
   assert(C.active,'normal camera fell back to native')
   assert(U.shot(game,dir..'/'..target[1]..'_'..view[1]..'_'..view[2]..'.png'));shots=shots+1
  end
  for y=0,d.height-1 do for x=0,d.width-1 do assert(original[y*d.width+x]==d.midLayout:midAt(x,y),'native terrain mutated')end end
 end
 print('[terrain views] PASS',shots,'normal first/third-person views, raised cliffs, unchanged native maps')
 love.event.quit()
end
