local active=true
local mon={}
local nativePics=0
local S={drawPic=function()nativePics=nativePics+1 end,drawPanel=function()end,bgMode=function(self)return self.game.options.battleBg end}
package.loaded['src.battle.BattleState']=S
package.loaded['src.ui.gen2.BattleAnimView']={}
local V={require=function(k)return ({Generation={isGen2=function()return true end},OverworldBattle={setting={get=function()return active end},available=function()return true end,shot=function()return {canvas=true}end},Gen2Staged={drawn={enemy=mon}},Gen2BattlePipeline={install=function()end}})[k]end}
local M=assert(loadfile('lib/Gen2Battle.lua'))(V);M.install()
local s=setmetatable({game={options={battleBg='white',battleFit='fill',battleHud='extended'}},BG_WORLD_DIM=.31},{__index=S})
assert(s:bgMode()=='world' and s.BG_WORLD_DIM==0)
assert(s.game.options.battleBg=='white' and s.game.options.battleHud=='extended')
active=false;assert(s:bgMode()=='white' and s.BG_WORLD_DIM==.31)
s.game.options.battleBg='black';assert(s:bgMode()=='black')
active=true;assert(s:bgMode()=='world');M.sceneOverrideEnabled=false;assert(s:bgMode()=='black')
print('PASS Gen2 stage background ownership, native preferences, OFF and diagnostic fallback')

M.sceneOverrideEnabled=nil;active=true;s:drawPic(mon,false);assert(nativePics==0)
active=false;s:drawPic(mon,false);assert(nativePics==1,'cached stage must not suppress native pic after OFF')
active=true;M.sceneOverrideEnabled=false;s:drawPic(mon,false);assert(nativePics==2)
print('PASS cached stage picture ownership released on OFF/native diagnostic fallback')
