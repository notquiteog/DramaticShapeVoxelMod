local n=0;local function check(v,s)n=n+1;assert(v,s)end
local calls={};local on=true
local picture=function(mon,size)calls[#calls+1]={mon=mon,size=size};return on and ('image-'..mon.species)or nil end
local Summary={picFor=function(_,mon)return 'native-'..mon.species,false end,picAnimFrame=function(self)return self.picAnim end}
local Dex={picFor=function(_,species)return 'dex-'..species,false end}
local oldSummary,oldAnim,oldDex=Summary.picFor,Summary.picAnimFrame,Dex.picFor
package.loaded['src.ui.gen2.SummaryMenu']=Summary;package.loaded['src.ui.gen2.PokedexMenu']=Dex
local V={require=function(name)assert(name=='NativeInterfaceArt');return {picture=picture}end}
local M=assert(loadfile('lib/Gen2InterfaceArt.lua'))(V);local undo=M.install()
local mon={species='PIKACHU',shiny=true,dvs={attack=10}}
local self=setmetatable({mon=mon,picAnim='native-animation'},{__index=Summary})
local image,trueColor=self:picFor(mon)
check(image=='image-PIKACHU' and trueColor and calls[1].mon==mon and calls[1].size==56,'native mon/DVs and56px block preserved')
check(self:picAnimFrame()==nil and self.picAnim=='native-animation','native animation suppressed without mutation')
check(Dex:picFor('BULBASAUR')=='image-BULBASAUR','Dex uses selected picture reader')
on=false;check(self:picFor(mon)=='native-PIKACHU' and self:picAnimFrame()=='native-animation','off restores native image/animation immediately')
on=true;check(self:picFor({species='PIKACHU',isEgg=true})=='native-PIKACHU','egg representation unchanged')
check(self:picFor({species='UNOWN'})=='native-UNOWN' and Dex:picFor('UNOWN')=='dex-UNOWN','Unown form reader retains ownership')
V.crystalSpritesActive=true;check(self:picFor(mon)=='native-PIKACHU','Crystal native sprite owner retained')
undo();check(Summary.picFor==oldSummary and Summary.picAnimFrame==oldAnim and Dex.picFor==oldDex,'menu methods restored at unload')
print('PASS '..n..' Gen2 interface owner/frame checks')
