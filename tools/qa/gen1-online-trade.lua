return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'));local mode='trade';local port=tonumber(os.getenv('QA_PORT'))or 18864
 game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',role=='host'and 10 or 11,6,'down')
 local Mon=require('src.pokemon.Pokemon');game.save.party={Mon.new(game.data,'PIKACHU',20),Mon.new(game.data,'PIDGEY',20)}
 game.save.party[1].nickname=role=='host'and'HOSTMON'or'GUESTMON'
 require('src.render.Pipelines').setLevel('voxel',4);U.wait(160)
 local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local function until_(fn,label)
  for i=1,2400 do if fn()then return end;if i%600==0 then print('[wait]',label,online.notice,online.activity and online.activity.status,game.stack:top()and game.stack:top().screenId)end;U.wait(1)end
  error(label..': '..tostring(online.notice))
 end
 if role=='host'then assert(online.hostLan(port))else assert(online.joinLan('127.0.0.1:'..port))end
 until_(function()return online.connected and online.peers.remote end,'pair')
 U.wait(90)
 if role=='host'then local ok,why=online.invite(mode);assert(ok,why)
 else until_(function()return online.activity and online.activity.status=='incoming'end,'invite');assert(online.respond(true))end
 until_(function()local s=game.stack:top();return s and s.stage=='trade' and s.trade and s.trade.stage=='picking'end,'native trade screen')
 local screen=game.stack:top();assert(U.shot(game,dir..'/trade.png'))
 for i=1,3600 do
  if not online.activity then break end
  if game.stack:top()==screen and screen.pickChoice==1 then U.tap(game,'right') else U.tap(game,'a') end
  U.wait(1)
 end
 assert(not online.activity,'native trade did not complete')
 assert(game.save.party[1].nickname==(role=='host'and'GUESTMON'or'HOSTMON'),'party was not swapped')
 U.wait(90);assert(game.stack:top()==game.overworld,'trade did not return control to world')
 assert(U.shot(game,dir..'/trade-return.png'))
 print('[PASS live Gen1 native trade]',require('src.core.GameVersion').get(),role,game.save.party[1].nickname)
 online.disconnect();U.wait(10);love.event.quit()
end
