local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local events={};local image={getDimensions=function()return 100,80 end}
local selected=image;local seen;local depth=0;local failDraw,failOriginal
love={graphics={getStackDepth=function()return depth end,push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 draw=function(img,x,y,r,sx,sy,ox,oy)seen={img,x,y,r,sx,sy,ox,oy};events[#events+1]='picture';if failDraw then error('draw failure')end end}}
local Kit={drawFade=function(pal,n)events[#events+1]='fade';return nil,'fade',false end}
local fade=Kit.drawFade
local Screen={draw=function(self,marker)
 events[#events+1]='ui';if self.mon then events[#events+1]='native'end
 if failOriginal then error('native failure')end
 local a,b,c=Kit.drawFade('palette',0);check(a==nil and b=='fade'and c==false,'native fade returns preserved')
 return nil,marker,false
end}
local original=Screen.draw
package.loaded['src.ui.game3.rse.starter_choose']=Screen
package.loaded['src.ui.game3.rse.scene_kit']=Kit
local mon={species=1252,x=120,y=64,affine={scale=128}}
local self={mon=mon};local seenSpecies
local undo=dofile('lib/NativeStarterArt.lua').install({picture=function(m)seenSpecies=m.species;return selected end},{national=function(n)return n-1000 end})
local a,b,c=Screen.draw(self,'starter')
check(a==nil and b=='starter'and c==false,'exact native draw returns')
check(table.concat(events,',')=='ui,picture,fade','selected picture occupies original final-fade ordering')
check(self.mon==mon and Kit.drawFade==fade and depth==0,'mon/fade/graphics state restored')
check(seenSpecies==252 and seen[5]==0.5 and seen[7]==50 and seen[8]==40,'FULL remains centered at native affine scale')
local halfSize
self.policy={drawAffine=function(x,y,scale,half,draw)halfSize=half;love.graphics.push('all');draw(scale/256);love.graphics.pop()end}
Screen.draw(self);check(halfSize==50,'RS policy retains affine with expanded FULL viewport')
selected=nil;events={};Screen.draw(self);check(table.concat(events,',')=='ui,native,fade','OFF/missing selected art retains native quad')
selected=image;failOriginal=true;local ok=pcall(Screen.draw,self)
check(not ok and self.mon==mon and Kit.drawFade==fade,'native errors restore mon and fade seam')
failOriginal=false;failDraw=true;ok=pcall(Screen.draw,self)
check(not ok and self.mon==mon and Kit.drawFade==fade and depth==0,'selected draw errors unwind temporary owners')
failDraw=false;self.mon=nil;events={};Screen.draw(self);check(table.concat(events,',')=='ui,fade','closed preview stays native')
undo();check(Screen.draw==original,'unload restores class draw')
print('PASS '..checks..' native starter art checks')
