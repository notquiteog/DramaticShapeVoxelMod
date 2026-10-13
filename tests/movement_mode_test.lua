local pressed={up=true,b=true};local input={}
function input:isDown(k)assert(self==input);return pressed[k]or false end
function input:wasPressed(k)assert(self==input);return k=='a'end
local game={input=input};package.loaded['src.core.Game']=game
local value='grid'
local M=assert(loadfile('lib/MovementMode.lua'))({require=function(n)
 if n=='ModSetting'then return {new=function(key,label,values,labels,default)
  assert(key=='movementMode' and values[default]=='grid')
  return {get=function()return value end}
 end}end
 assert(n=='FirstPerson');return {moveVector=function()return 0,-1 end,moveWorld=function()return 1,0 end}
end})
assert(not M.free());value='free';assert(M.free())
assert(M.direction(.1,.9)=='down' and M.direction(0,0)==nil)
local s={}
assert(M.grid(s,function(state)
 assert(state==s and game.input~=input)
 assert(game.input:isDown('right') and not game.input:isDown('up'))
 assert(game.input:isDown('b') and game.input:wasPressed('a'))
 return 'native-step'
end)=='native-step')
assert(game.input==input)
assert(not pcall(M.grid,s,function()error('native error')end) and game.input==input)
print('PASS grid default, free opt-in, camera direction and scoped native input restoration')
