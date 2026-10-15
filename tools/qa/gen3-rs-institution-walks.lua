-- Disposable imported native maps: authored-room walks, actual 1ST, OFF,
-- and normal south-approach stair warps. No collision/script replacements.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or'SA_'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=prefix..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision');local Message=require('src.ui.game3.message')
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 local dir=assert(os.getenv('SHOT_DIR'))
 local rooms={{'LILYCOVE_CITY_LILYCOVE_MUSEUM_1F',10,10,16,2},{'LILYCOVE_CITY_LILYCOVE_MUSEUM_2F',11,12,13,2},
 {'SLATEPORT_CITY_OCEANIC_MUSEUM_1F',9,5,6,2},{'SLATEPORT_CITY_OCEANIC_MUSEUM_2F',10,7,6,2},
 {'RUSTBORO_CITY_DEVON_CORP_1F',9,7,14,2},{'RUSTBORO_CITY_DEVON_CORP_2F',9,5,2,2},{'RUSTBORO_CITY_DEVON_CORP_3F',9,8,2,2},
 {'MOSSDEEP_CITY_SPACE_CENTER_1F',8,5,13,2},{'MOSSDEEP_CITY_SPACE_CENTER_2F',8,9,13,2}}
 if os.getenv('QA_ROOM')then rooms={assert(rooms[tonumber(os.getenv('QA_ROOM'))])}end
 local function settle()
  for _=1,100 do
   local vm=require('src.core.game3.scripting.space').getVm()
   if not Message.isOpen() and not(vm and vm:isRunning())then return end
   U.hold(game,'b',24);U.wait(4)
  end
  local vm=require('src.core.game3.scripting.space').getVm()
  print('[NATIVE SCRIPT STATE]',vm and vm.ctx.status,vm and vm.ctx.waitKind,require('src.core.game3.field').locked)
 end
 for i,s in ipairs(rooms)do
  settle()
  local id=prefix..s[1];game.input:reset();assert(Map.load(nil,game,id,{x=s[2],y=s[3],facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();C.setLevel(3,game);U.wait(55)
  settle();assert(Collision.isWalkable(s[2],s[3])and not Collision.warpAt(s[2],s[3]),'invalid aisle')
  local walked=false
  for _,a in ipairs{{'left',-1,0},{'right',1,0},{'up',0,-1},{'down',0,1}}do
   if Collision.isWalkable(s[2]+a[2],s[3]+a[3])and not Collision.warpAt(s[2]+a[2],s[3]+a[3])then
    Player.reset(s[2],s[3],'up');game.input:reset();U.hold(game,a[1],16);U.wait(20)
    if Map.current==id and(Player.cellX~=s[2]or Player.cellY~=s[3])then walked=true;break end
   end
  end
  assert(walked,'native room aisle blocked: '..id);print('[INSTITUTION AISLE] PASS',ed,id,Player.cellX,Player.cellY)
  Player.reset(s[2],s[3],'up');game.input:reset();C.setLevel(0,game);U.wait(4);assert(U.shot(game,dir..'/'..i..'-OFF.png'))
  C.setLevel(6,game);C.yaw=0;C.pitch=.12;U.wait(45);assert(C.active and C.recovery.failures==0)
  assert(U.shot(game,dir..'/'..i..'-1ST.png'))
  C.setLevel(3,game);Player.reset(s[4],s[5],'up');game.input:reset();settle()
  assert(Collision.isWalkable(s[4],s[5])and not Collision.warpAt(s[4],s[5]),'invalid stair approach')
  assert(Collision.warpAt(s[4],s[5]-1),'missing native stair warp')
  U.hold(game,'up',18);U.wait(150)
  print('[INSTITUTION STAIR OBSERVED]',ed,id,Map.current,Player.cellX,Player.cellY)
  assert(Map.current~=id,'stair did not warp: '..id);assert(C.active and C.recovery.failures==0)
  assert(U.shot(game,dir..'/'..i..'-stair-destination.png'));print('[INSTITUTION STAIR] PASS',ed,id,Map.current)
 end
 love.event.quit()
end
