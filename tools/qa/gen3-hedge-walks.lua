-- Native walking beside both Petalburg hedge families; isolated QA saves.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local ed=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[ed])
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local P=require('src.core.game3.player');local Col=require('src.core.game3.collision')
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 for _,a in ipairs{{'gym',12,8,'left',11,8,'down',12,9},{'garden',26,25,'up',26,24,'left',25,25}}do
  C.setLevel(0,game);assert(Map.load(nil,game,pre..'PETALBURG_CITY',{x=a[2],y=a[3],facing=a[4]}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(5)
  local l=Map.currentDef().midLayout
  assert(Col.isWalkable(a[2],a[3])and l:collAt(a[5],a[6])==7 and Col.isWalkable(a[8],a[9]))
  assert(V.require('Gen3TileShape').of('general','petalburg',l:midAt(a[5],a[6]),nil,7).kind=='hedge')
  P.reset(a[2],a[3],a[4]);C.setLevel(3,game);U.wait(20);U.hold(game,a[4],16);U.wait(16)
  assert(P.cellX==a[2]and P.cellY==a[3],'native hedge boundary changed')
  C.setLevel(0,game);U.wait(3);assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..a[1]..'-OFF.png'))
  C.setLevel(6,game);C.yaw=a[4]=='left'and -math.pi/2 or 0;C.pitch=.35;U.wait(25)
  assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..a[1]..'-1ST.png'))
  C.setLevel(3,game);P.reset(a[2],a[3],a[7]);U.hold(game,a[7],16);U.wait(16)
  assert(P.cellX~=a[2]or P.cellY~=a[3],'native hedge-side aisle obstructed')
  assert(#game.mods:status().errors==0);print('[HEDGE NATIVE] PASS',ed,a[1],'boundary and aisle')
 end
 love.event.quit()
end
