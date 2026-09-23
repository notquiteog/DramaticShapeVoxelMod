return function(game)
 io.stdout:setvbuf('no')
 assert(love.filesystem.getIdentity():match('^ports%-parity%-yellow%-'),'use an isolated link QA identity')
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'))
 local mode='double';local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local P=require('src.pokemon.Pokemon')
 U.teleport(game,'PALLET_TOWN',role=='host'and 8 or 9,15,'down')
 game.save.party={}
 require('src.render.Pipelines').setLevel('voxel',3)
 game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('OverworldBattle').setting:sync(true)
 for i=1,3 do game.save.party[i]=P.new(game.data,role=='host'and'BULBASAUR'or'RATTATA',role=='host'and 50 or 10,function()return 15 end)end
 game.save.player.name=role:upper();for _,m in ipairs(game.save.party)do m.moves={{id='TACKLE',pp=35,maxPp=35}}end
 local before=require('src.link.Protocol').packParty(game.save.party)
 U.wait(90)
 if role=='host'then assert(online.hostLan(18848))else assert(online.joinLan('127.0.0.1:18848'))end
 for i=1,1200 do if online.connected and online.peers.remote then break end;U.wait(1)end
 assert(online.connected and online.peers.remote,'pair failed');online.ui.close()
 local top=game.stack:top();if top then for k,v in pairs(top)do if type(v)~='table' and type(v)~='function'then print('[fixture overlay]',k,tostring(v))end end end
 U.teleport(game,'PALLET_TOWN',role=='host'and 8 or 9,15,'down');U.wait(30);online.say('ready-'..role)
 for _=1,1200 do local ready=false;for _,m in ipairs(online.chat)do if m.text=='ready-'..(role=='host'and'guest'or'host')then ready=true end end;if ready and not online.peers.remote.busy then break end;U.wait(1)end
 U.wait(15)
 if role=='host'then online.ui.close();print('[busy]',tostring(game.stack:top()),tostring(false),tostring(online.peers.remote.busy),tostring(online.ui.open),tostring(false));local ok,why=online.invite(mode);assert(ok,why)
 else
  for i=1,1000 do if online.activity then break end;U.wait(1)end
  assert(online.activity,'no invite');online.ui.close();assert(online.respond(true))
 end
 local entered,shot,lastScreen
 for i=1,14000 do
  local top=game.stack:top()
  if top and top.playerParty then
   entered=true;lastScreen=top;assert(top.doubleRoom,'native double adapter missing');assert(not top.doubleRoom.failed,'double state mismatch')
   if not shot and top.phase=='menu' and top.player2 and top.enemy2 then
    U.wait(100)
    assert(top.player.__crystalFullBodyImage==top.player.sprite,'lead full body missing')
    assert(top.player2.__crystalFullBodyImage==top.player2.sprite,'partner full body missing')
    assert(top.enemy.__crystalAnimation and top.enemy2.__crystalAnimation,'opponent animation missing')
    local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
    local hud=V.require('Gen1BattleHud');local stage=V.require('OverworldBattle')
    for _,key in ipairs({'player','enemy','player2','enemy2'})do assert(hud.cards[key],'missing HUD '..key)end
    local heads=stage.shot().heads
    assert(heads.player[1]~=heads.player2[1] or heads.player[2]~=heads.player2[2],'ally heads overlap')
    assert(heads.enemy[1]~=heads.enemy2[1] or heads.enemy[2]~=heads.enemy2[2],'enemy heads overlap')
    assert(U.shot(game,os.getenv('SHOT_DIR')..'/link-double.png'))
    V.require('ModernBattleUI').setting:sync(false);U.wait(4)
    assert(not hud.active(top) and not next(hud.cards),'native UI opt-out failed')
    V.require('ModernBattleUI').setting:sync(true);U.wait(4)
    shot=true
   end
  end
  if entered and not online.activity then break end
  if i%6==0 then U.tap(game,'a')else U.wait(1)end
  if i%600==0 then print('[GB link QA]',role,top and top.stage,top and top.phase)end
 end
 assert(shot,'four-battler sprite fixture never ran');assert(entered,'no native battle: '..tostring(online.notice));assert(not online.activity,'battle not complete');assert(online.connected,'world disconnected')
 local after=require('src.link.Protocol').packParty(game.save.party)
 local function same(a,b)
  if type(a)~=type(b)then return false end
  if type(a)~='table'then return a==b end
  for k,v in pairs(a)do if not same(v,b[k])then return false end end
  for k in pairs(b)do if a[k]==nil then return false end end;return true
 end
 assert(same(before,after),'party changed');assert(lastScreen and not lastScreen.doubleRoom.failed and lastScreen.doubleRoom.verified>=2,'double state verification failed');assert(online.lastActivity.result==(role=='host'and'win'or'lose'),'unexpected result: '..tostring(online.lastActivity.result));online.say('finished-'..role)
 print('[GB link QA] PASS',role,'battle completed, party restored, room connected')
 U.wait(150);online.disconnect();love.event.quit()
end
