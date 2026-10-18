-- GPU resource failure must leave native drawing usable on every platform.
local allocated,released,depth,attempts=0,0,0,0
local failure
local g={newCanvas=function()
 attempts=attempts+1;if failure=='allocation'then error('out of GPU memory')end
 allocated=allocated+1;return{setFilter=function()end,release=function()released=released+1 end}
end,push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 draw=function()if failure=='draw'then error('unsupported canvas draw')end end}
for _,k in ipairs({'setCanvas','origin','setShader','setScissor','setDepthMode','setBlendMode','clear','setColor'})do g[k]=function()end end
love={graphics=g}
local image={getDimensions=function()return 56,56 end}
local Art={playerSide=function()return 'back'end}
local V={require=function(n)return n=='BattleArt'and Art or{}end}
for _,mode in ipairs({'allocation','draw'})do
 failure=mode;local M=assert(loadfile('lib/NativeBattleArt.lua'))(V);local before=attempts
 assert(M.fit(image,64)==nil and depth==0,'failed picture fit restores state')
 assert(M.fit(image,64)==nil and attempts==before+1,'failed fit is not retried every frame')
end
assert(allocated==released,'failed fit releases allocated GPU resource')
failure=nil;assert(assert(loadfile('lib/NativeBattleArt.lua'))(V).fit(image,64),'successful fit remains available')

local nativeFront,nativeBack={image='native front'},{image='native back'}
local Trainer={front=function()return nativeFront end,back=function()return nativeBack end}
local originalFront,originalBack=Trainer.front,Trainer.back
package.loaded['src.core.game3.trainer_pic']=Trainer
package.loaded['src.core.game3.battle']={_st={trainerPicId=4,trainerClassName='BUG CATCHER'}}
package.loaded['src.core.game3.scripting.trainers']={info=function()return{}end}
local active=true
local TV={require=function(n)return assert(({BattleArt={trainerImage=function()return image end},
 AnimatedBattleArt={playerTrainerPicture=function()return image end},Gen3SpriteLight={tag=function(v)return v end}})[n])end}
for _,mode in ipairs({'allocation','draw'})do
 failure=mode;local M=assert(loadfile('lib/Gen3TrainerArt.lua'))(TV)
 local undo=M.install(function()return active end,function()return nil end)
 assert(Trainer.front(4)==nativeFront,'failed front fit retains native portrait')
 local before=attempts
 assert(Trainer.back(0)==nativeBack and depth==0,'failed sheet retains native portrait and state')
 assert(Trainer.back(0)==nativeBack and attempts==before+1,'failed sheet does not allocate every frame')
 assert(Trainer.back(2)==nativeBack,'scripted trainer keeps original owner')
 active=false;assert(Trainer.front(4)==nativeFront and Trainer.back(0)==nativeBack,'inactive adapter stays native');active=true
 undo();assert(Trainer.front==originalFront and Trainer.back==originalBack,'unload restores native readers')
end
failure=nil
print('PASS allocation/draw failure, cached fallback, native trainer ownership and graphics/resource cleanup')
