-- Native Route103 shore walk, no-surf boundary and OFF/actual first person.
-- QA profiles only; never change collision, VM, field permissions or surfing.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA identity required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[ed]);local id=pre..'ROUTE103'
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C=V.require('Gen3Integration')
 local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision')
 V.require('DayNight').setting:sync('day');V.require('RenderDistance').setting:sync(64)
 C.setLevel(0,game);assert(Map.load(nil,game,id,{x=20,y=9,facing='right'}))
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(5)
 local def=Map.currentDef();local l=def.midLayout
 local function digest()
  local out={};for y=0,def.height-1 do for x=0,def.width-1 do local c=l:cellAt(x,y);out[#out+1]=table.concat({c.mid,c.coll,c.elev},':')end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(out,';')))
 end
 local before=digest();assert(Col.isWalkable(20,9)and Col.isWalkable(21,9)and not Col.isWater(21,9))
 assert(Col.isWater(22,9),'native shore fixture lost water')
 C.setLevel(3,game);U.wait(30);Player.reset(20,9,'right');game.input:reset();U.hold(game,'right',16);U.wait(16)
 assert(Map.current==id and Player.cellX==21 and Player.cellY==9,'native dry shore walk failed');print('[SEA SHORE WALK] PASS',id)
 Player.reset(21,9,'right');game.input:reset();U.hold(game,'right',16);U.wait(16)
 assert(Map.current==id and Player.cellX==21 and Player.cellY==9,'native no-surf shore boundary changed');print('[SEA SHORE BOUNDARY] PASS',id)
 assert(digest()==before,'rock/water presentation changed native map cells')
 C.setLevel(0,game);U.wait(3);assert(U.shot(game,os.getenv('SHOT_DIR')..'/shore-OFF.png'))
 C.setLevel(6,game);C.yaw=math.pi*.5;C.pitch=.12;U.wait(25);assert(C.active and C.recovery.failures==0)
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/shore-1ST.png'))
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'));print('[SEA SHORE INPUT] PASS',ed,before)
 love.event.quit()
end
