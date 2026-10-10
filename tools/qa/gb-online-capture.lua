return function(game)
 assert(love.filesystem.getIdentity():match('^suite%-online%-.+%-qa$'),'isolated online QA profile required')
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion');local gen,v=GV.generation(),GV.get()
 if gen==3 then
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[v]
  game:_handleBootAction({action='new_game',start={map=prefix and prefix..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=role=='host'and 7 or 6,y=8,facing='down'}})
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
  local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
  game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('Gen3Integration').setLevel(3,game)
 elseif gen==1 then
  game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',role=='host'and 10 or 11,6,'down')
  require('src.render.Pipelines').setLevel('voxel',4)
 else
  local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
  game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',role=='host'and 10 or 11,6,'down'))
  require('src.render.Pipelines').setLevel('voxel',4)
 end
 U.wait(200)
 local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local function until_(fn,label)
  for i=1,2400 do if fn()then return end;if i%600==0 then print('[wait]',label,online.notice,online.activity and online.activity.status,game.stack:top()and game.stack:top().screenId)end;U.wait(1)end
  error(label..': '..tostring(online.notice))
 end
 if role=='host'then assert(online.hostLan(tonumber(os.getenv('QA_PORT'))or 18864))else assert(online.joinLan('127.0.0.1:'..(os.getenv('QA_PORT')or'18864')))end
 until_(function()return online.connected and online.peers.remote end,'pair')
 U.wait(180)

 assert(gen<3,'GB capture driver')
 local C=assert(game.mods.exports.overworld_wild_spawns.catching)
 local ow=game.world or game.overworld
 game.save.inventory=game.save.inventory or{};game.save.inventory.MASTER_BALL=3
 local opts=game.mods.modOptions.overworld_wild_spawns;opts.overworld_catching=true;opts.catch_throw_key='c';C.selectedBallIndex=4
 local chosen,id
 if role=='host'then
  until_(function()
   for key,e in pairs(C.logic.entities)do
    local r=C.logic.spawns[key]
    if r and r.networkId and e.sharedWild and not e.hiddenEncounter and not e.wildsAmbientPokemon
     and e.visibleSprite~=false and ow.map:isWalkableCell(e.cellX,e.cellY+1)
     and game.mods.exports.overworld_wild_spawns.sharedSpawns.canCatch({x=e.cellX,y=e.cellY+1,facing='up'}, {x=e.cellX,y=e.cellY,visibleSprite=true}, {action='catch',ballId=1,charge=0},ow.map.id)then chosen=e;id=r.networkId;return true end
   end
  end,'host shared target')
  chosen.update=function()end;chosen.moving=false
  U.wait(90);assert(online.say('catch:'..id))
 else
  until_(function()
   for _,msg in ipairs(online.chat)do
    local wanted=msg.text:match('^catch:(.+)$')
    if wanted then for key,r in pairs(C.logic.spawns)do if r.networkId==wanted and C.logic.entities[key]then chosen=C.logic.entities[key];id=wanted;return true end end end
   end
  end,'guest shared target')
 end
 local before=#game.save.party
 if role=='guest'then
  local p=ow.player;p.cellX=chosen.cellX;p.cellY=chosen.cellY+1;p.px=p.cellX*16;p.py=p.cellY*16;p.facing='up';p.moving=false
  U.wait(90)
  assert(game.mods.exports.overworld_wild_spawns.sharedSpawns.canCatch({x=p.cellX,y=p.cellY,facing=p.facing}, {x=chosen.cellX,y=chosen.cellY,visibleSprite=true}, {action='catch',ballId=1,charge=0},ow.map.id),'native target line blocked')
  local block=C:_catchBlocker(game,ow);assert(not block,block)
  assert(require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false}))
  U.wait(3);print('[throw state]',C.phase,C.hud.feedbackText,C.sharedPending and C.sharedPending.id,game.save.inventory.MASTER_BALL)
  until_(function()return #game.save.party==before+1 end,'guest native capture')
  assert(game.save.inventory.MASTER_BALL==2,'guest debit not exactly once')
  assert(online.say('caught:'..id))
 else
  until_(function()for _,msg in ipairs(online.chat)do if msg.text=='caught:'..id then return true end end end,'guest capture acknowledgment')
  assert(#game.save.party==before and game.save.inventory.MASTER_BALL==3,'remote capture changed host party/bag')
 end
 U.wait(90)
 for _,r in pairs(C.logic.spawns)do assert(r.networkId~=id,'caught shared actor resurrected')end
 assert(U.shot(game,dir..'/shared-captured.png'))
 print('[PASS live host reserved capture]',v,role,id)
 if role=='guest'then assert(online.say('capture-done'));U.wait(90)
 else until_(function()for _,msg in ipairs(online.chat)do if msg.text=='capture-done'then return true end end end,'done')end
 online.disconnect();U.wait(10);love.event.quit()
end
