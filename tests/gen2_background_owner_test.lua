local active=true
local S={drawPanel=function()end,bgMode=function(self)return self.game.options.battleBg end}
package.loaded['src.battle.BattleState']=S
package.loaded['src.ui.gen2.BattleAnimView']={}
local V={require=function(k)return ({Generation={isGen2=function()return true end},OverworldBattle={setting={get=function()return active end}}})[k]end}
local M=assert(loadfile('lib/Gen2Battle.lua'))(V);M.install()
local s=setmetatable({game={options={battleBg='white',battleFit='fill',battleHud='extended'}},BG_WORLD_DIM=.31},{__index=S})
assert(s:bgMode()=='world' and s.BG_WORLD_DIM==0)
assert(s.game.options.battleBg=='white' and s.game.options.battleHud=='extended')
active=false;assert(s:bgMode()=='white' and s.BG_WORLD_DIM==.31)
s.game.options.battleBg='black';assert(s:bgMode()=='black')
active=true;assert(s:bgMode()=='world');M.sceneOverrideEnabled=false;assert(s:bgMode()=='black')
print('PASS Gen2 stage background ownership, native preferences, OFF and diagnostic fallback')
