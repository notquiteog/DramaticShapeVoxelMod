-- Focused real-runtime checks for shared outdoor props and native flowers.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=8,y=13,facing='up'}})
 love.window.setMode(1600,900,{resizable=true})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision')
 local Types=V.require('Gen3Tilesets');local Shapes=V.require('Gen3TileShape')
 local Versions=require('src.import.gba.versions')
 for _,case in ipairs({{'FR_PALLET_TOWN','fence',0x284},{'FR_PALLET_TOWN','fence',0x287},{'FR_FUCHSIA_CITY','fence',0xD6},{'FR_FUCHSIA_CITY','fence',0xD7},{'FR_FUCHSIA_CITY','fence',0xEE},{'FR_FUCHSIA_CITY','fence',0xF6},{'FR_FUCHSIA_CITY','fence',0x1F0},{'FR_FUCHSIA_CITY','fence',0x336},{'FR_FUCHSIA_CITY','fence',0x337},{'FR_FUCHSIA_CITY','fence',0x33F}})do
  assert(Map.load(nil,game,case[1],{x=8,y=12,facing='up'}))
  local def=Map.currentDef();local spec=Types.resolve(def.midLayout.pair,Versions.TILESET_PAIRS)
  local original={}
  for y=0,def.height-1 do for x=0,def.width-1 do original[y*def.width+x]=def.midLayout:collAt(x,y)end end
  local target,best
  for y=0,def.height-1 do for x=0,def.width-1 do
   local mid=def.midLayout:midAt(x,y)
   if Shapes.of(spec.primary,spec.secondary,mid).kind==case[2] and (not case[3] or mid==case[3]) then
    for dy=-4,4 do for dx=-4,4 do
     if x+dx>=0 and x+dx<def.width and y+dy>=0 and y+dy<def.height and math.abs(dx)+math.abs(dy)>=2 and Collision.isWalkable(x+dx,y+dy) and not Collision.warpAt(x+dx,y+dy) and not Collision.isWater(x+dx,y+dy) then
      local d=(x-def.width*.5)^2+(y-def.height*.5)^2+dx*dx+dy*dy+(dy<2 and 100 or 0)
      if not best or d<best then target,best={x=x,y=y,px=x+dx,py=y+dy,mid=mid},d end
     end
    end end
   end
  end end
  assert(target,'no safe fixture for '..case[2]);if case[1]=='FR_PALLET_TOWN' and case[2]=='fence'then target.px,target.py,target.x,target.y=12,18,14,16 end;Player.reset(target.px,target.py,'up')
  C.setLevel(3,game);U.wait(100);assert(C.active)
  local sample=def.midLayout:midAt(target.x,target.y)
  for _,level in ipairs({3,6,7})do
   C.setLevel(level,game);C.yaw=level>=6 and math.atan2(target.x-target.px,target.py-target.y) or 0;C.pitch=.24;U.wait(20)
   assert(C.active);assert(U.shot(game,dir..'/'..case[1]..'_'..case[2]..(case[3] and string.format('_%03X',case[3]) or '')..'_'..level..'.png'))
  end
  assert(def.midLayout:midAt(target.x,target.y)==sample,'visual prop changed map')
  for y=0,def.height-1 do for x=0,def.width-1 do assert(def.midLayout:collAt(x,y)==original[y*def.width+x],'visual fence changed collision')end end
  print('[outdoor fixture]',case[1],case[2],string.format('%03X',target.mid),target.x,target.y)
  if case[2]=='flowers' then
   local ts=require('src.core.game3.tileset_native').get(def.midLayout.pair)
   local Anim=require('src.core.game3.tileset_anim');local Outdoor=V.require('Gen3Outdoor')
   local frame=math.floor(Anim.counter/16)
   local before=Outdoor.image(ts,frame)
   assert(Outdoor.image(ts,frame)==before,'same-frame material not reused')
   U.wait(20)
   assert(math.floor(Anim.counter/16)~=frame,'native flower animation clock stalled')
   assert(Outdoor.image(ts,math.floor(Anim.counter/16))~=before,'plant atlas froze its first frame')
  end
 end
 dofile(assert(os.getenv('DS_MOD_PATH'),'DS_MOD_PATH required')..'/tests/canopy_billboard_gpu.lua')(V)
 print('[outdoor QA] PASS 30 native fence views and unchanged target cells')
 love.event.quit()
end
