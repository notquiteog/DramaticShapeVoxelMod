return function(game)
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
 local wilds=assert(game.mods.exports.overworld_wild_spawns).sharedSpawns
 local skies=assert(game.mods.exports.wild_skies or game.mods.exports.WILD_SKIES)
 local function signature(rows)
  local parts={};for _,r in ipairs(rows or{})do parts[#parts+1]=tostring(r.id)..':'..tostring(r.species)..':'..tostring(r.level)end
  table.sort(parts);return require('src.link.Fingerprint').digest(table.concat(parts,'|')),#parts
 end
 local done={};local ack={}
 for frame=1,1800 do
  local map,ground=wilds.snapshot();local sky=skies.sharedSkyFieldSnapshot(map)
  local gh,gn=signature(ground);local sh,sn=signature(sky and sky.spawns)
  if role=='host'and frame%30==1 then
   assert(online.say('ground:'..gn..':'..gh));assert(online.say('sky:'..sn..':'..sh))
  end
  for _,msg in ipairs(online.chat)do
   if role=='guest'then
    for kind,val in pairs{ground=gn..':'..gh,sky=sn..':'..sh}do
     if msg.text==kind..':'..val and tonumber(val:match('^(%d+)'))>0 then done[kind]=true end
    end
   else if msg.text=='roster-ok'then ack.done=true end end
  end
  if role=='guest'and done.ground and done.sky then assert(online.say('roster-ok'));U.wait(90);break end
  if role=='host'and ack.done then break end
  U.wait(1)
 end
 assert(role=='host'and ack.done or role=='guest'and done.ground and done.sky,'live host ground/sky rosters did not converge')
 assert(U.shot(game,dir..'/shared-field.png'))
 print('[PASS live shared roster]',require('src.core.GameVersion').get(),role)
 online.disconnect();U.wait(10);love.event.quit()
end
