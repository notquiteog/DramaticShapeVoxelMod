-- QA-only normal-input entries for the League, Museum, RS Devon/Space Center.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local ed=require('src.core.GameVersion').get()
 local prefix=ed=='ruby'and'RU_'or ed=='sapphire'and'SA_'or ed=='emerald'and'EM_'or'FR_'
 local spots=prefix=='FR_'and{{'INDIGO_PLATEAU_EXTERIOR',11,7,'INDIGO_PLATEAU_POKEMON_CENTER_1F'}}
  or{{'LILYCOVE_CITY',11,6,'LILYCOVE_CITY_LILYCOVE_MUSEUM_1F'},{'LILYCOVE_CITY',12,6,'LILYCOVE_CITY_LILYCOVE_MUSEUM_1F'}}
 if os.getenv('QA_MUSEUM_ONLY')~='1'and(ed=='ruby'or ed=='sapphire')then
  for _,x in ipairs{11,12}do spots[#spots+1]={'RUSTBORO_CITY',x,16,'RUSTBORO_CITY_DEVON_CORP_1F'}end
  spots[#spots+1]={'MOSSDEEP_CITY',64,14,'MOSSDEEP_CITY_SPACE_CENTER_1F'}
 end
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=prefix..spots[1][1],x=spots[1][2],y=spots[1][3],facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C=V.require('Gen3Integration');local Map=require('src.core.game3.map')
 local Player=require('src.core.game3.player');local Collision=require('src.core.game3.collision')
 local dir=assert(os.getenv('SHOT_DIR'));V.require('RenderDistance').setting:sync(32)
 local function place(id,x,y)
  game.input:reset();assert(Map.load(nil,game,id,{x=x,y=y,facing='up'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
 end
 if prefix~='FR_'then
  place(prefix..'LILYCOVE_CITY',10,1);C.setLevel(3,game);U.wait(70)
  assert(Collision.isWalkable(10,1)and Collision.isWalkable(11,1))
  U.hold(game,'right',18);U.wait(20)
  assert(Map.current==prefix..'LILYCOVE_CITY'and Player.cellY==1 and Player.cellX>10,'museum projected rear row blocked')
  print('[LANDMARK REAR LANE] PASS',ed,Player.cellX,Player.cellY)
 end
 for i,s in ipairs(spots)do
  local source=prefix..s[1];place(source,s[2],s[3])
  assert(Collision.isWalkable(s[2],s[3])and not Collision.warpAt(s[2],s[3]),'not a native approach')
  C.setLevel(0,game);U.wait(10);assert(U.shot(game,dir..'/native-flat-'..i..'.png'))
  C.setLevel(3,game);U.wait(70);assert(C.active and C.recovery.failures==0)
  U.hold(game,'up',18);U.wait(180)
  assert(Map.current==prefix..s[4],'wrong native destination: '..tostring(Map.current))
  assert(C.active and C.level==3 and C.recovery.failures==0,'camera lost on native warp')
  assert(U.shot(game,dir..'/entry-'..i..'.png'))
  print('[LANDMARK ENTRY] PASS',ed,source,s[2],s[3],Map.current,Player.cellX,Player.cellY)
 end
 love.event.quit(0)
end
