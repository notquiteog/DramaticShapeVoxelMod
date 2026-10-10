return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'));local mode=os.getenv('QA_MODE')or'single';local port=tonumber(os.getenv('QA_PORT'))or 18864
 game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',role=='host'and 10 or 11,6,'down')
 local Mon=require('src.pokemon.Pokemon');game.save.party={Mon.new(game.data,'PIKACHU',20),Mon.new(game.data,'PIDGEY',20)}
 for _,m in ipairs(game.save.party)do m.hp=7;m.moves={{id='TACKLE',pp=2}}end
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
 until_(function()local s=game.stack:top();return s and s.kind=='link'end,'native battle screen')
 local screen=game.stack:top();assert(U.shot(game,dir..'/battle.png'))
 for i=1,12000 do
  if not online.activity then break end
  local top=game.stack:top();if top~=screen and top and top.party and top.index then for n,m in ipairs(top.party)do if (m.hp or 0)>0 then top.index=n;break end end end
  U.tap(game,'a');U.wait(1)
  if i%600==0 then print('[battle progress]',screen.phase,screen.battle and screen.result,screen.doubleRoom and screen.doubleRoom.turn)end
 end
 assert(not online.activity,'native battle did not complete')
 assert(screen.result=='win'or screen.result=='lose'or screen.result=='draw','battle ended before native outcome')
 if mode=='double'then assert(screen.doubleRoom and not screen.doubleRoom.failed and screen.doubleRoom.turn>1,'doubles failed before verified turn')end
 print('[native result]',screen.result,screen.result,screen.doubleRoom and screen.doubleRoom.verified)
 assert(game.save.party[1].hp==7 and game.save.party[1].moves[1].pp==2,'battle modified saved party')
 U.wait(90);assert(game.stack:top()==game.overworld,'battle did not return control to world');assert(U.shot(game,dir..'/battle-return.png'))
 print('[PASS live Gen1 native battle]',require('src.core.GameVersion').get(),role,mode)
 online.disconnect();U.wait(10);love.event.quit()
end
