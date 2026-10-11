-- QA: all seven mods enabled; Wilds enabled=false/random_encounters=false,
-- Wild Skies bumps=false. Private matching profiles, QA_ROLE and QA_PORT.
return function(game)
 local U=dofile('tests/drivers/util.lua');local role=assert(os.getenv('QA_ROLE'));local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local version=require('src.core.GameVersion').get();local prefix=version=='ruby'and'RU_'or version=='sapphire'and'SA_'or'EM_'
 local map=(version=='firered'or version=='leafgreen')and'FR_ROUTE_19'or prefix..'ROUTE104'
 local gbaKanto=version=='firered'or version=='leafgreen'
 local hx,gx,ypos=gbaKanto and 9 or 7,gbaKanto and 8 or 6,gbaKanto and 12 or 8
 game:_handleBootAction({action='new_game',start={map=map,x=role=='host'and hx or gx,y=ypos,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,gbaKanto and 131 or require('src.core.game3.pokemon').speciesFromName('PELIPPER'),50))
 game.session.party[1].nickname=role=='host'and'HOSTMON'or'GUESTMON'
 game.session.party[1].moves={19,57,33};game.session.party[1].pp={15,15,35}
 local flags=require('src.core.game3.scripting.flags');local moves=require('src.core.game3.field_moves')
 flags.setFlag(space.store,nil,moves.badgeFlag('FLY'),true)

 assert(require('src.core.GameVersion').generation()==3)
 if game.mods.exports.BATTLE_ART_VOXEL_FORK then game.mods.exports.BATTLE_ART_VOXEL_FORK.lib.require('Gen3Integration').setLevel(0,game)end
 local ex=assert(game.mods.exports.DRAMATIC_SKY_RIDE);local S=assert(ex.gen3)
 local P=require('src.core.game3.player');U.wait(180)

 local online=assert(game.mods.exports['gen1online-plus']).multiplayer
 local function until_(fn,label)
  for i=1,1800 do if fn()then return end;U.wait(1)end
  error(label..': '..tostring(online.notice))
 end
 if role=='host'then assert(online.hostLan(tonumber(os.getenv('QA_PORT'))or 18951))else assert(online.joinLan('127.0.0.1:'..(os.getenv('QA_PORT')or'18951')))end
 until_(function()return online.connected and online.peers.remote end,'paired')
 flags.setFlag(space.store,nil,moves.badgeFlag('SURF'),true)
 local Col=require('src.core.game3.collision');local O=require('src.core.game3.objects')
 local sx,sy;local candidates=0
 for y=0,Col._heightCells-2 do for x=0,Col._widthCells-1 do
  if Col.isWalkable(x,y)and not Col.isWater(x,y)and Col.isWater(x,y+1)and not Col.warpAt(x,y)and not O.blocks(x,y)and not O.blocks(x,y+1)then candidates=candidates+1;if role=='host' or candidates==4 then sx,sy=x,y;break end end
 end;if sx then break end end
 assert(sx,'native shoreline absent')
 P.reset(sx,sy,'down');U.wait(2)
 local ok,why=S.mount(1,'surf');assert(ok,why);U.wait(90)
 assert(P.surfing and Col.isWater(P.cellX,P.cellY),'native Surf did not reach water')
 assert(ex.isWaterRiding(),'Surf mount lost')
 for i=1,4 do U.tap(game,'a');U.wait(8)end
 until_(function()local p=online.peers.remote;return p and p.ride and p.ride.mode=='surf'and p.ride.species==(gbaKanto and 'LAPRAS'or'PELIPPER')end,'remote native Surf pose')
 assert(online.say('surf-mounted'))
 until_(function()for _,m in ipairs(online.chat)do if not m.localSender and m.text=='surf-mounted'then return true end end end,'partner mounted')
 assert(U.shot(game,dir..'/surf.png'))
 U.hold(game,'up',9);U.wait(60)
 assert(not P.surfing and not ex.isWaterRiding(),'native return to shore retained water mount')
 assert(S.dismount())
 until_(function()local p=online.peers.remote;return p and not p.ride end,'remote shore return')
 assert(online.say('surf-done'))
 until_(function()for _,m in ipairs(online.chat)do if not m.localSender and m.text=='surf-done'then return true end end end,'partner done')
 U.wait(180) -- let the transport deliver the final pose/chat before either client closes
 print('[PASS paired native Surf shore return]',version,role)
 online.disconnect()
 love.event.quit()
end
