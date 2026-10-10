return function(game)
 assert(love.filesystem.getIdentity():match('^suite%-online%-.+%-qa$'),'isolated online QA profile required')
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local GV=require('src.core.GameVersion');local gen,v=GV.generation(),GV.get()
 if gen==3 then
  local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[v]
  game:_handleBootAction({action='new_game',start={map=prefix and prefix..'ROUTE101'or'FR_ROUTE_1',x=role=='host'and 7 or 6,y=8,facing='down'}})
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

 assert(gen==3,'GBA capture driver')
 local ex=game.mods.exports.overworld_wild_spawns;local C,S=assert(ex.gen3Catching),assert(ex.gen3)
 local Bag=require('src.core.game3.bag');assert(Bag.add(game.session.bag,1,3))
 local Player=require('src.core.game3.player');local Col=require('src.core.game3.collision');local O=require('src.core.game3.objects')
 local opts=game.mods.modOptions.overworld_wild_spawns or{};game.mods.modOptions.overworld_wild_spawns=opts;opts.overworld_catching=true;opts.catch_throw_key='c';C.ball=1
 local chosen,id
 if role=='host'then
  until_(function()
   for _,r in pairs(S.spawns)do
    local x,y=r.cellX,r.cellY+1
    if r.networkId and not r.ambient and not r.scenery and r.behavior~='hidden'and Col.isWalkable(x,y)and not Col.warpAt(x,y)and not O.blocks(x,y)then chosen=r;id=r.networkId;return true end
   end
  end,'host shared target')
  chosen.catching=true
  U.wait(90);assert(online.say('catch:'..id))
 else
  until_(function()
   for _,msg in ipairs(online.chat)do
    local wanted=msg.text:match('^catch:(.+)$')
    if wanted then for _,r in pairs(S.spawns)do if r.networkId==wanted then chosen=r;id=wanted;return true end end end
   end
  end,'guest shared target')
 end
 local before=#game.session.party
 if role=='guest'then
  Player.reset(chosen.cellX,chosen.cellY+1,'up')
  U.wait(90)
  assert(require('src.mods.Runtime').call('input.key',function()return false end,game,{key='c',phase='pressed',isrepeat=false}))
  until_(function()return #game.session.party==before+1 end,'guest native capture')
  assert(Bag.get(game.session.bag,1)==2,'guest debit not exactly once')
  assert(online.say('caught:'..id))
 else
  until_(function()for _,msg in ipairs(online.chat)do if msg.text=='caught:'..id then return true end end end,'guest capture acknowledgment')
  assert(#game.session.party==before and Bag.get(game.session.bag,1)==3,'remote capture changed host party/bag')
 end
 U.wait(90)
 for _,r in pairs(S.spawns)do assert(r.networkId~=id,'caught shared actor resurrected')end
 assert(U.shot(game,dir..'/shared-captured.png'))
 print('[PASS live host reserved capture]',v,role,id)
 if role=='guest'then assert(online.say('capture-done'));U.wait(90)
 else until_(function()for _,msg in ipairs(online.chat)do if msg.text=='capture-done'then return true end end end,'done')end
 online.disconnect();U.wait(10);love.event.quit()
end
