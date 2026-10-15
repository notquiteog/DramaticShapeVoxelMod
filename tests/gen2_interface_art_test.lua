local n=0;local function check(v,s)n=n+1;assert(v,s)end
local calls={};local on=true
local picture=function(mon,size,side)calls[#calls+1]={mon=mon,size=size,side=side};return on and ('image-'..mon.species..(side=='back'and '-back'or''))or nil end
local Summary={picFor=function(_,mon)return 'native-'..mon.species,false end,picAnimFrame=function(self)return self.picAnim end}
local Dex={picFor=function(_,species)return 'dex-'..species,false end}
local oldSummary,oldAnim,oldDex=Summary.picFor,Summary.picAnimFrame,Dex.picFor
local Hall={monPic=function(_,mon,back)return 'hof-'..mon.species..(back and '-back'or''),false end,
 picAnimFrame=function(self)return self.picAnim end,currentMon=function(self)return self.mon end}
local Box={picFor=function(_,mon)return 'box-'..mon.species,false end}
local boxPic=Box.picFor;package.loaded['src.ui.gen2.BoxMenu']=Box
local oldHof,oldHofAnim=Hall.monPic,Hall.picAnimFrame
package.loaded['src.ui.gen2.HallOfFame']=Hall
package.loaded['src.ui.gen2.SummaryMenu']=Summary;package.loaded['src.ui.gen2.PokedexMenu']=Dex
local evolutionRestored,tradeHatchRestored=false,false
local V={require=function(name)
 if name=='Gen2OakArt'then return {install=function()return function()end end}end
 if name=='Gen2TradeHatchArt'then return {install=function()return function()tradeHatchRestored=true end end}end
 if name=='Gen2EvolutionArt'then return {install=function()return function()evolutionRestored=true end end}end
 assert(name=='NativeInterfaceArt');return {picture=picture}
end}
local M=assert(loadfile('lib/Gen2InterfaceArt.lua'))(V);local undo=M.install()
local mon={species='PIKACHU',shiny=true,dvs={attack=10}}
local self=setmetatable({mon=mon,picAnim='native-animation'},{__index=Summary})
local image,trueColor=self:picFor(mon)
check(image=='image-PIKACHU' and trueColor and calls[1].mon==mon and calls[1].size==56,'native mon/DVs and56px block preserved')
check(self:picAnimFrame()==nil and self.picAnim=='native-animation','native animation suppressed without mutation')
check(Box:picFor(mon)=='image-PIKACHU'and calls[#calls].mon==mon,'Box picture retains stored mon identity')
check(Dex:picFor('BULBASAUR')=='image-BULBASAUR','Dex uses selected picture reader')
local hof=setmetatable({mon=mon,picAnim='hof-animation',timer=120},{__index=Hall})
check(hof:monPic(mon,false)=='image-PIKACHU','Hall of Fame front uses selected art')
check(hof:monPic(mon,true)=='image-PIKACHU-back' and calls[#calls].mon==mon and calls[#calls].side=='back','Hall of Fame back retains original identity')
check(hof:picAnimFrame()==nil and hof.picAnim=='hof-animation' and hof.timer==120,'Hall of Fame native frame suppressed without changing animation or timing')
on=false;check(self:picFor(mon)=='native-PIKACHU' and self:picAnimFrame()=='native-animation','off restores native image/animation immediately')
check(hof:monPic(mon,true)=='hof-PIKACHU-back' and hof:picAnimFrame()=='hof-animation','Hall of Fame OFF restores both native paths')
on=true;check(self:picFor({species='PIKACHU',isEgg=true})=='native-PIKACHU','egg representation unchanged')
check(self:picFor({species='UNOWN'})=='native-UNOWN' and Dex:picFor('UNOWN')=='dex-UNOWN','Unown form reader retains ownership')
check(hof:monPic({species='UNOWN'},true)=='hof-UNOWN-back','Hall of Fame Unown form remains native')
V.crystalSpritesActive=true;check(self:picFor(mon)=='native-PIKACHU','Crystal native sprite owner retained')
check(hof:monPic(mon,false)=='hof-PIKACHU' and hof:picAnimFrame()=='hof-animation','Crystal owns Hall of Fame art')
undo();check(Summary.picFor==oldSummary and Summary.picAnimFrame==oldAnim and Dex.picFor==oldDex,'menu methods restored at unload')
check(Hall.monPic==oldHof and Hall.picAnimFrame==oldHofAnim,'Hall of Fame methods restored at unload')
check(Box.picFor==boxPic,'Box reader restored at unload')
check(evolutionRestored and tradeHatchRestored,'scene adapters restored at unload')
print('PASS '..n..' Gen2 interface owner/frame checks')
