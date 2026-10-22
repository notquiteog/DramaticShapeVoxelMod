-- Exercise installed update hooks, not just the standalone mixer arithmetic.
local checks=0
for generation=1,3 do
 for _,name in ipairs({'KfpAtmosphere','NativeCaveAudio'})do
  if generation>1 or name=='KfpAtmosphere'then
   local hook,received
   local map={id='CAVE',kind='cave'}
   local V={mod={hooks={wrap=function(_,key,fn)if key=='core.update'then hook=fn end end}}}
   function V.require(key)
    if key=='ModSetting'then return{new=function()return{}end}end
    if key=='Generation'then return{number=function()return generation end}end
    if key=='KantoFirstPerson'then return{}end
    if key=='NativeAtmosphere'then return{gen3=function()return map end}end
    error(key)
   end
   package.loaded['src.core.game3.map']={current='CAVE',currentDef=function()return{}end}
   package.loaded['src.core.game3.player']={px=0,py=0}
   package.loaded['src.core.game3.battle']={isActive=function()return false end}
   local M=assert(loadfile('lib/'..name..'.lua'))(V)
   M.new=function()return{update=function(_,...)received={...}end}end
   M.facts=function()return{}end
   if name=='KfpAtmosphere'then M.install(function()return true end)
   else M.install(generation,function()return true end)end
   local game={phase=generation==3 and 'field'or'play',save={options={sfxVol=7}},world={map=map,player={px=0,py=0}}}
   game.overworld=game.world
   if generation==3 then game.options={sfxVol=0}end
   local called=0
   local function next()called=called+1;return 'native'end
   local index=name=='KfpAtmosphere'and 3 or 6
   assert(hook(next,game,.1)=='native'and called==1)
   assert(received[index]==(generation==3 and 0 or 1),'wrong generation options owner')
   local opts=game.options or game.save.options
   opts.sfxVol=2;hook(next,game,.1);assert(received[index]==2/7,'live volume not forwarded')
   opts.sfxVol=0;hook(next,game,.1);assert(received[index]==0,'mute not forwarded')
   checks=checks+3
  end
 end
end
print('PASS '..checks..' installed ambient hook volume checks across generations')
