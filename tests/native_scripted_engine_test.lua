local engine=assert(os.getenv('ASTRA_ENGINE'),'ASTRA_ENGINE required')
local draw
love={graphics={setColor=function()end,draw=function(...)draw={...}end}}
package.loaded['src.ui.game3.window']={stdFrame=function()end,template=function()return{}end}
package.loaded['src.core.game3.display']={TILE=8}
local native={getDimensions=function()return 64,64 end}
local P={SPECIES_EGG=412,SPECIES_SPINDA=308,SPECIES_DEOXYS=410,
 picSpecies=function(s)return s end,national=function(s)return s end,isShiny=function()return false end,
 frontPic=function()return{image=native,w=64,h=64}end}
package.loaded['src.core.game3.pokemon']=P
local Pic=assert(loadfile(engine..'/src/ui/game3/mon_pic.lua'))()
package.loaded['src.ui.game3.mon_pic']=Pic
package.loaded['src.ui.game3.rse.contest_entry_pic']={show=function()end,hide=function()end,reset=function()end}
local selected={getDimensions=function()return 80,96 end}
local Art={settings={false,{get=function()return 'full'end}},picture=function()return selected end}
local M=assert(loadfile('lib/NativeScriptedArt.lua'))()
local undo=M.install(Art,P)
Pic.show(25,10,3,{noCry=true});Pic.draw()
assert(draw[1]==selected and draw[2]==120 and draw[3]==64 and draw[4]==0 and draw[5]==1 and draw[6]==1 and draw[7]==40 and draw[8]==48,'FULL actual native viewport transform')
local t={x2=4,y2=-3,rotation=.7,sx=-.5,sy=1.2};Pic._animTransform=t;Pic.draw()
assert(draw[2]==124 and draw[3]==61 and draw[4]==.7 and draw[5]==-.5 and math.abs(draw[6]-1.2)<1e-10,'native animation rotation/translation/flip/squash preserved')
assert(Pic._animTransform==t and Pic._img==native and Pic._w==64 and Pic._h==64,'native cached state restored')
undo();Pic._animTransform=nil;Pic.draw();assert(draw[1]==native,'unloaded real native draw')
print('PASS actual native MonPic renderer oversized FULL transform, animation and fallback')
