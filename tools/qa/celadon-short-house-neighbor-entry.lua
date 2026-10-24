-- Adjacent source house must preserve actual native Celadon Gym entry/return.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map=require('src.core.game3.map')
 game:_handleBootAction({action='new_game',start={map='FR_CELADON_CITY',x=11,y=31,facing='up'}})
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');C.setLevel(3,game);U.wait(200)
 local function hash()
  local d=Map.currentDef();local out={}
  for y=0,d.height-1 do for x=0,d.width-1 do local q=d.midLayout:cellAt(x,y);out[#out+1]=table.concat({q.mid,q.coll,q.elev},':')end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(out,';')))
 end
 local before=hash()
 for _=1,180 do U.hold(game,'up',1);if Map.currentDef().id~='FR_CELADON_CITY'then break end end
 assert(Map.currentDef().id=='FR_CELADON_CITY_GYM','native neighboring Gym entrance failed');U.wait(140)
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/gym-entered.png'))
 for _=1,260 do U.hold(game,'down',1);if Map.currentDef().id=='FR_CELADON_CITY'then break end end
 assert(Map.currentDef().id=='FR_CELADON_CITY','native neighboring Gym return failed');U.wait(180)
 assert(hash()==before,'native grid changed');assert(S.performanceSnapshot().scenery.celadonShortHouse>0,'neighboring source not rendered')
 assert(#game.mods.errors==0,table.concat(game.mods.errors,'\n'));assert(C.recovery.failures==0)
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/gym-returned.png'))
 print('[CELADON SOURCE NEIGHBOR ENTRY] PASS',require('src.core.GameVersion').get(),before)
end
