-- Native capture must not initialize GB terrain just to construct a ball.
package.loaded['src.render.PaletteFX']={}
local native=true;local loaded={}
local forbidden={ChunkMesher=true,VoxelScene=true,Gen6Backdrop=true,TerrainAtlas=true,
 CaveSconces=true,TowerLobbyDetails=true,TowerGraveMist=true,CaveAtmosphere3D=true}
local ball={};local cleared=0
local V={require=function(name)
 loaded[name]=(loaded[name]or 0)+1
 if native and forbidden[name]then error('native capture requested GB dependency '..name)end
 return ({Generation={isGen3=function()return native end},
  PokeballSettings={active=function()return true end},Pokeball={new=function(id)ball.id=id;return ball end},
  EmberLegacyAudio={beginCapture=function()end,clear=function()cleared=cleared+1 end},
  SuccessStars={invalidate=function()end},['q57/Adapter']={clear=function()end},
  VoxelScene={groundAt=function()return 12 end}})[name]or{}
end}
local M=assert(loadfile('lib/BattleScene.lua'))(V)
assert(M.startNormalBall('SAFARI_BALL',true,3,{})and ball.id=='SAFARI_BALL')
M.finishNormalBattleBall();assert(cleared==1)
for name in pairs(forbidden)do assert(not loaded[name],name..' imported during native capture')end
native=false;loaded={};M=assert(loadfile('lib/BattleScene.lua'))(V)
for name in pairs(forbidden)do assert(loaded[name]==1,'GB eager initialization changed: '..name)end
assert(M.groundY({}, {enemy={0,0},playerCell={0,0}})==12)
print('PASS native capture avoids GB terrain dependencies; legacy scene initialization retained')
