return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local version=require('src.core.GameVersion').get();local prefix=version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_'
 game:_handleBootAction({action='new_game',start={map=prefix..'OLDALE_TOWN',x=role=='host'and 7 or 6,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('Gen3Integration').setLevel(3,game)
 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,6,50))
 game.session.party[1].moves={19,57,33};game.session.party[1].pp={15,15,35}
 local flags=require('src.core.game3.scripting.flags');local moves=require('src.core.game3.field_moves')
 flags.setFlag(space.store,nil,moves.badgeFlag('FLY'),true)
 local Link=require('src.core.game3.link');local LB=require('src.core.game3.link.battle')
 local send=LB.sendSetup;LB.sendSetup=function(...) print('[link setup sent]',role,LB.mode,type(LB.mode));return send(...)end
 local open=Link.open;Link.open=function(...)
  local lk,why=open(...);if lk then local take=lk.take;lk.take=function(self,kind,...)
   local msg=take(self,kind,...);if msg and kind==LB.MSG.SETUP then print('[link setup received]',role,msg.mode,type(msg.mode),LB.mode,type(LB.mode))end;return msg
  end end;return lk,why
 end
 local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local ride=assert(game.mods.exports.DRAMATIC_SKY_RIDE).gen3
 local P=require('src.core.game3.player');local Sprites=require('src.core.game3.ow_sprites')
 U.wait(250)
 if role=='host'then assert(online.hostLan(18864))else assert(online.joinLan('127.0.0.1:18864'))end
 local function until_(fn,label)
  for i=1,2400 do if fn()then return end;if i%600==0 then local LB=require('src.core.game3.link.battle');print('[wait]',label,game.phase,online.activity and online.activity.status,online.lastActivity and online.lastActivity.result,online.lastActivity and online.lastActivity.peerResult,LB.state)end;U.wait(1)end;error(label..': '..tostring(online.notice))
 end
 until_(function()return online.connected and online.peers.remote end,'pair')
 local function saw(text)for _,m in ipairs(online.chat)do if m.text==text then return true end end end
 local function peer()return game.mods.exports['gen1online-plus'].netNpcs()[1]end
 if role=='host'then
  local ok,why=ride.mount(1,'ground');assert(ok,why);assert(online.say('ground'))
  until_(function()return saw('ground-seen')end,'ground ack')
  assert(ride.dismount());P.reset(7,8,'down');U.wait(2)
  ok,why=ride.mount(1,'fly');assert(ok,why);U.hold(game,'down',10);U.wait(2);assert(online.say('flight'))
  until_(function()return saw('flight-seen')end,'flight ack')
  assert(ride.dismount(true));assert(online.say('landed'))
  until_(function()return saw('landed-seen')end,'landing ack')
  assert(online.say('done'));U.wait(120)
 else
  until_(function()return saw('ground')and peer()and peer().graphicsId>=830000 end,'mounted peer')
  local row=peer();assert(Sprites.getDraw(row.graphicsId),'remote mount sprite missing');assert(not ride.active,'peer mounted local player')
  assert(U.shot(game,dir..'/peer-ground.png'));assert(online.say('ground-seen'))
  until_(function()return saw('flight')and peer()and (peer().raiseY or 0)<-20 end,'airborne peer')
  row=peer();assert(row.graphicsId>=830000);assert(not ride.active);assert(online.peers.remote.busy,'airborne peer accepted activities')
  assert(U.shot(game,dir..'/peer-flight.png'));assert(online.say('flight-seen'))
  until_(function()return saw('landed')and peer()and peer().graphicsId<1024 and (peer().raiseY or 0)==0 end,'dismount peer')
  assert(online.say('landed-seen'));until_(function()return saw('done')end,'done')
 end
 -- Return peers next to each other before invitations, preserving room/chat.
 P.reset(role=='host' and 7 or 6,8,'down');U.wait(120)
 assert(online.say('ready-'..role))
 until_(function()return saw('ready-'..(role=='host'and'guest'or'host'))end,'ready')
 local B=require('src.core.game3.battle')
 for _,mode in ipairs({'single','double','trade'})do
  if mode=='double' then assert(Party.giveMon(game.session,9,30))end
  game.session.party[1].hp=7;game.session.party[1].pp[1]=2
  if role=='host' then U.wait(80);local ok,why=online.invite(mode);assert(ok,why)
  else until_(function()return online.activity and online.activity.status=='incoming'end,'invite '..mode);assert(online.respond(true))end
  if mode=='trade' then
   until_(function()return require('src.ui.game3.link_trade_menu').isOpen()end,'trade menu');U.wait(180)
   assert(U.shot(game,dir..'/trade.png'))
  else
   until_(function()return B.isActive()end,'native '..mode..' battle')
   for i=1,400 do if B._phase=='command' then break end;U.tap(game,'a');U.wait(3)end
   assert(B._phase=='command','native battle intro did not complete: '..tostring(B._phase))
   local st=B.getState();assert(not not st.double==(mode=='double'))
   assert(game.session.party[1].hp>7,'party not prepared')
   local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local f=V.require('Gen3Battle').frame
   if mode=='double'then for id=0,3 do local c=assert(f.byId[id]);local b=V.require('SpriteHeadBounds').get(c.tex)
    for _,x in ipairs({b[1],b[3]})do for _,y in ipairs({b[2],b[4]})do local p=assert(f:head(id,x,y));assert(p[1]>=0 and p[1]<=1,'cropped doubles actor '..id)end end
   end end
   assert(U.shot(game,dir..'/'..mode..'.png'))
  end
  assert(online.say('loaded-'..mode..'-'..role));until_(function()return saw('loaded-'..mode..'-'..(role=='host'and'guest'or'host'))end,'loaded peers');U.wait(90)
  -- A real disconnect must restore the pre-link party, including HP and PP.
  online.disconnect();U.wait(60)
  assert(game.session.party[1].hp==7 and game.session.party[1].pp[1]==2,'disconnect lost party state')
  if mode~='trade' then
   P.reset(role=='host'and 7 or 6,8,'down');U.wait(60)
   if role=='host' then assert(online.hostLan(18864))else U.wait(60);assert(online.joinLan('127.0.0.1:18864'))end
   until_(function()return online.connected and online.peers.remote end,'reconnect')
   U.wait(120)
  end
 end
 print('[network ride] PASS',role,'remote mount/flight pose/height/dismount, local mount untouched')
 online.disconnect();U.wait(10);assert(#game.mods.exports['gen1online-plus'].netNpcs()==0,'ghost after disconnect');love.event.quit()
end
