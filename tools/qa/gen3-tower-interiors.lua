-- Native input/fallback/first-person tower reception review; copied QA imports.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or ed=='sapphire'and'SA_'or'FR_'
 local fr=prefix=='FR_';local id=prefix..(fr and'TRAINER_TOWER_LOBBY'or prefix=='EM_'and'BATTLE_FRONTIER_BATTLE_TOWER_LOBBY'or'BATTLE_TOWER_LOBBY')
 local x=fr and 9 or prefix=='EM_'and 12 or 6;local y=fr and 12 or prefix=='EM_'and 8 or 7
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=id,x=x,y=y,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration');local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local dir=assert(os.getenv('SHOT_DIR'));V.require('RenderDistance').setting:sync(32)
 local function place(cx,cy)
  game.input:reset();assert(Map.load(nil,game,id,{x=cx,y=cy,facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  assert(Collision.isWalkable(cx,cy)and not Collision.warpAt(cx,cy),'invalid approach')
 end
 place(x,y);C.setLevel(0,game);U.wait(5);assert(U.shot(game,dir..'/native-flat.png'))
 C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(70);assert(C.active and C.recovery.failures==0)
 assert(U.shot(game,dir..'/first-person.png'))
 C.setLevel(3,game)
 local walked=false
 for _,direction in ipairs{'left','right'}do
  Player.reset(x,y,'up');game.input:reset();U.wait(5);U.hold(game,direction,18);U.wait(20)
  if Map.current==id and Player.cellY==y and Player.cellX~=x then walked=true;break end
 end
 assert(walked,'both native front aisle directions failed')
 print('[TOWER INTERIOR WALK] PASS',ed,Player.cellX,Player.cellY)
 local px,py=fr and 17 or 6,fr and 9 or 2
 place(px,py);C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(45);assert(U.shot(game,dir..'/portal-first-person.png'))
 C.setLevel(3,game);Player.reset(px,py,'up');game.input:reset();U.wait(5);U.hold(game,'up',18);U.wait(150)
 print('[PORTAL OBSERVED]',ed,Map.current,Player.cellX,Player.cellY);assert(Map.current~=id,'native tower interior portal did not warp')
 assert(C.active and C.recovery.failures==0,'camera lost after interior warp')
 assert(U.shot(game,dir..'/portal-destination.png'))
 print('[TOWER INTERIOR PORTAL] PASS',ed,id,Map.current,Player.cellX,Player.cellY)
 if fr then
  for i,s in ipairs{{'TRAINER_TOWER_LOBBY',9,2},{'TRAINER_TOWER_1F',15,6},{'TRAINER_TOWER_1F',4,6}}do
   local from=prefix..s[1];game.input:reset();assert(Map.load(nil,game,from,{x=s[2],y=s[3],facing='up'}))
   require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();C.setLevel(3,game);U.wait(40)
   local direction=assert(Collision.stairWarpDir(Collision.behavior(s[2],s[3])),'not a native directional stair')
   local ax=s[2]+(direction=='left'and 1 or -1);local ay=s[3]
   Player.reset(ax,ay,direction);game.input:reset();assert(Collision.isWalkable(ax,ay)and not Collision.warpAt(ax,ay))
   U.hold(game,direction,24);U.wait(130);assert(Map.current~=from,'native stair portal failed')
   assert(C.active and C.recovery.failures==0);assert(U.shot(game,dir..'/stair-destination-'..i..'.png'))
   print('[TRAINER STAIR PORTAL] PASS',ed,from,s[2],s[3],Map.current)
  end
 end
 love.event.quit()
end
