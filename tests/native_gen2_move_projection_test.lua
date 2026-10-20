local p,e={},{}
local actors={player='player2',enemy='enemy2',playerMon=p,enemyMon=e}
local bg={};local view={};local runner={bg=bg}
local screen={battle={doubles=true},anim=runner,animView=view,nativeAnimationActors=function()return actors end}
local models,enabled,fail=false,true,false
local stage={drawn={player2=p,enemy2=e}}
local shot={scale=2,pw=400,ph=300,lx=40,ly=6,canvas={},
 heads={['player2:effect']={.25,.6},['enemy2:effect']={.75,.2}}}
local calls,draws,depth,target=0,0,0,'native'
local panels=0
screen.nativeSceneLayout=function()return'gen2-native-pair'end
screen.drawPanel=function()assert(depth==0 and target=='native');panels=panels+1 end
local saved={}
local View={drawObjects=function(_,r,b,extra)
 calls=calls+1;assert(r==runner and b==screen.battle)
 if fail and target~='native'then error('native particle asset missing')end
 return nil,extra
end}
setmetatable(view,{__index=View})
package.loaded['src.ui.gen2.BattleAnimView']=View
love={graphics={
 push=function()depth=depth+1;saved[depth]=target end,pop=function()target=saved[depth];depth=depth-1 end,
 newCanvas=function()return{setFilter=function()end}end,
 setCanvas=function(c)target=c end,origin=function()end,clear=function()end,
 setScissor=function()end,setShader=function()end,setColor=function()end,setBlendMode=function()end,
 translate=function()end,rotate=function()end,scale=function()end,
 draw=function()assert(target=='native');draws=draws+1 end,
}}
local M=assert(loadfile('lib/NativeGen2MoveProjection.lua'))({require=function(k)
 return({StadiumModels={active=function()return models end},Gen2Staged=stage,
  Gen2Battle={stagedMon=function()return enabled end},OverworldBattle={shot=function()return shot end},
  BattleSpriteFooting={bounds=function()return{0,0,48,43}end}})[k]
end})
assert(M.actors(screen)==actors and M.background(screen,'player')==nil and M.background(screen,'player2')==bg)
local x,y,angle,scale=M.transform(shot,actors)
assert(x==30 and y==87)
local dx,dy=84,-44
local ex=x+(dx*math.cos(angle)-dy*math.sin(angle))*scale
local ey=y+(dx*math.sin(angle)+dy*math.cos(angle))*scale
assert(math.abs(ex-130)<1e-8 and math.abs(ey-27)<1e-8,'projection missed exact second actor')
screen.pic=function()return{getDimensions=function()return 48,48 end},false,'path'end
screen.picScale=function()return 1 end
local anchor=M.anchor(screen,'player2',p,80,143,48)
assert(anchor[1]==80 and anchor[2]==124,'native center lost visible footing')
M.begin(screen);view:drawObjects(runner,screen.battle);assert(calls==1 and draws==1 and depth==0 and target=='native')
assert(panels==1,'projected move covered original native HUD')
local function fallback()
 local n,d=calls,draws;local a,b=view:drawObjects(runner,screen.battle,'native')
 assert(a==nil and b=='native'and calls==n+1 and draws==d and depth==0)
end
enabled=false;fallback();enabled=true
stage.drawn.enemy2=nil;fallback();stage.drawn.enemy2=e
models=true;fallback();models=false
local old=shot.heads;shot.heads={};fallback();shot.heads=old
actors.enemy='player';assert(M.actors(screen)==actors and not M.back(screen,'player',true),'friendly target reused physical back box')
fallback() -- Missing friendly target projection retains native drawing.
actors.enemy='player2';assert(not M.actors(screen),'same actor was treated as two independent slots')
actors.enemy='enemy2'
fail=true;local n,d=calls,draws;view:drawObjects(runner,screen.battle)
assert(calls==n+2 and draws==d and depth==0 and target=='native','failed offscreen paint suppressed original')
fail=false;M.begin(nil);fallback()
print('PASS native move plane: both exact projections, logical friendly boxes, footing, native painter, OFF/models/missing-card fallback and failed-canvas cleanup')
