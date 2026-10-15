-- Native input over the museum flight in both directions; no gameplay override.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or assert(ed=='sapphire')and'SA_'
 local id=prefix..'LILYCOVE_CITY';local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=id,x=11,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player');local S=V.require('Gen3Scene');local dir=assert(os.getenv('SHOT_DIR'))
 V.require('RenderDistance').setting:sync(32);V.require('DayNight').setting:sync('day')
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
 C.setLevel(6,game);C.yaw=0;C.pitch=.16;U.wait(80)
 local function ground()return S.groundAt(Player.px+8,Player.py+8,Player.currentElevation)end
 local function walk(direction,target)
  local last=ground();local max=0;local done=false
  for _=1,180 do
   if Player.cellY==target or Player.moving and Player.targetY==target then game.input:reset();U.wait(1)else U.hold(game,direction,1)end
   local h=ground();max=math.max(max,math.abs(h-last));last=h
   assert(Map.current==id,'walk escaped into a door')
   if Player.cellY==target and not Player.moving then done=true;break end
  end
  assert(done,'native stair walk stalled');assert(max<=1.51,'contact jumped between treads')
  return max
 end
 for _,x in ipairs{11,12}do
  assert(Map.load(nil,game,id,{x=x,y=9,facing='up'}));require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(30)
  local low=ground();assert(U.shot(game,dir..'/lower-'..x..'.png'))
  local up=walk('up',6);local high=ground();assert(high-low==12,'museum landing not above lower path')
  U.wait(3)
  local R=V.require('Voxel3D');local Sprites=require('src.core.game3.ow_sprites');local eye=V.require('Gen3SpriteAnchor').eyeHeight(Sprites.getDraw(Sprites.playerGraphicsId(game)))
  assert(math.abs(R.camera.eye[2]-high-eye)<.01,'camera and actor support disagree')
  assert(U.shot(game,dir..'/upper-'..x..'.png'))
  local down=walk('down',9);assert(ground()==low,'lower landing height drifted')
  assert(U.shot(game,dir..'/descended-'..x..'.png'))
  print('[MUSEUM STAIRS] PASS',ed,x,'low',low,'high',high,'up/down max',up,down)
 end
 C.setLevel(3,game);game.input:reset();assert(Map.load(nil,game,id,{x=11,y=6,facing='up'}));U.wait(30)
 U.hold(game,'up',18);U.wait(180)
 assert(Map.current==prefix..'LILYCOVE_CITY_LILYCOVE_MUSEUM_1F','native door warp changed')
 assert(C.active and C.recovery.failures==0);print('[MUSEUM STAIR DOOR] PASS',ed)
 love.event.quit()
end
