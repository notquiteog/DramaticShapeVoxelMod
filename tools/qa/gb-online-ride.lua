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
 local ride=assert(game.mods.exports.DRAMATIC_SKY_RIDE)
 local M=require(gen==2 and 'src.battle.gen2.Mon' or 'src.pokemon.Pokemon')
 game.save.party={M.new(game.data,'RAPIDASH',40)}
 local function saw(text)for _,m in ipairs(online.chat)do if m.text==text then return true end end end
 local function peer()
  for _,e in ipairs((game.world or game.overworld).entities or{})do if e.id=='gen1online_room_peer'then return e end end
 end
 if role=='host'then
  assert(ride.requestGroundMount(game.save.party[1]),'ground mount refused')
  local pose=assert(ride.networkPose());assert(pose.mode=='ground'and pose.species=='RAPIDASH')
  assert(online.say('mounted'))
  until_(function()return saw('mounted-seen')end,'mounted ack')
  assert(ride.requestGroundDismount());assert(online.say('dismounted'))
  until_(function()return saw('dismounted-seen')end,'dismounted ack')
 else
  until_(function()return saw('mounted')and peer()and peer().mountSprite end,'remote mount')
  assert(not ride.isMounted(),'remote ride changed local state')
  assert(U.shot(game,dir..'/peer-mounted.png'));assert(online.say('mounted-seen'))
  until_(function()return saw('dismounted')and peer()and not peer().mountSprite end,'remote dismount')
  assert(U.shot(game,dir..'/peer-dismounted.png'));assert(online.say('dismounted-seen'));U.wait(90)
 end
 print('[PASS live GB ride replication]',v,role)
 online.disconnect();U.wait(10);love.event.quit()
end
