return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',role=='host'and 10 or 11,6,'down'))
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,os.getenv('QA_EVOLVE')=='1'and'ONIX'or'PIKACHU',20),Mon.new(game.data,'PIDGEY',20)}
 if os.getenv('QA_EVOLVE')=='1'then game.save.party[1].item='METAL_COAT'end
 game.save.party[1].nickname=role=='host'and'HOSTMON'or'GUESTMON'
 require('src.render.Pipelines').setLevel('voxel',4)
 U.wait(160);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local function until_(fn,label)
  for i=1,2400 do if fn()then return end;if i%600==0 then print('[wait]',label,online.notice,online.activity and online.activity.status,game.stack:top()and game.stack:top().screenId)end;U.wait(1)end
  error(label..': '..tostring(online.notice))
 end
 if role=='host'then assert(online.hostLan(18864))else assert(online.joinLan('127.0.0.1:18864'))end
 until_(function()return online.connected and online.peers.remote end,'pair')
 U.wait(90)
 if role=='host'then local ok,why=online.invite('trade');assert(ok,why)
 else until_(function()return online.activity and online.activity.status=='incoming'end,'invite');assert(online.respond(true))end
 until_(function()local s=game.stack:top();return s and s.screenId=='OnlineCrystalTrade'end,'native trade screen')
 local screen=game.stack:top()
 until_(function()return screen.remote.session.stage=='picking'end,'party exchange')
 assert(U.shot(game,dir..'/trade.png'));assert(screen:pick(1))
 until_(function()return screen.remote.session.stage=='confirming'end,'confirm')
 assert(screen:confirm())
 for i=1,3600 do
  if not online.activity then break end
  if game.stack:top() then U.tap(game,'a')end;U.wait(1)
  if i%600==0 then print('[trade progress]',screen.phase,screen.remote.session.stage)end
 end
 assert(not online.activity,'native trade did not complete')
 assert(game.save.party[1].nickname==(role=='host'and'GUESTMON'or'HOSTMON'),'party was not swapped')
 if os.getenv('QA_EVOLVE')=='1'then assert(game.save.party[1].species=='STEELIX'and game.save.party[1].item==nil,'native held-item evolution failed')end
 U.wait(90);assert(game.stack:top()==nil and game.phase=='play','trade screen did not return control to world');assert(U.shot(game,dir..'/trade-return.png'))
 print('[PASS live Gen2 native trade]',require('src.core.GameVersion').get(),role,game.save.party[1].nickname)
 online.disconnect();U.wait(10);love.event.quit()
end
