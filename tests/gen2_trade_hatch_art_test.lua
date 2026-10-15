local n=0;local function check(v,m)n=n+1;assert(v,m)end
local drawn;local failure=false
love={graphics={draw=function(image,x)drawn={image=image,x=x};if failure then error('draw failure')end end}}
local Trade={pic=function(_,record)return 'native-'..record.species end}
function Trade:drawPic(record,offset)
 local image=self:pic(record)
 if self.picAnim and record==self.get then image=self.picAnim:frame()end
 love.graphics.draw(image,56-offset);return 'trade-layout'
end
local Hatch={pic=function(self)return self.showMon and 'native-'..self.species or 'native-egg'end}
function Hatch:drawPic()
 local image=self:pic();if self.picAnim then image=self.picAnim:frame()end
 love.graphics.draw(image,56);return 'hatch-layout'
end
local tradeDraw,hatchDraw=Trade.drawPic,Hatch.drawPic
package.loaded['src.ui.gen2.TradeAnim']=Trade;package.loaded['src.ui.gen2.EggHatchAnim']=Hatch
local enabled=true;local requested
local V={require=function(name)
 if name=='Gen2PictureScope'then return dofile('lib/Gen2PictureScope.lua')end
 assert(name=='NativeInterfaceArt')
 return {picture=function(mon,size,side)requested={mon=mon,size=size,side=side};return enabled and 'selected-'..mon.species or nil end}
end}
local undo=assert(loadfile('lib/Gen2TradeHatchArt.lua'))(V).install()
local mon={species='CYNDAQUIL',shiny=true,dvs={attack=2},otName='SOURCE',otId=123}
local animation={frame=function()return 'native-frame'end}
local t=setmetatable({get=mon,picAnim=animation,frame=20},{__index=Trade})
check(t:drawPic(mon,17)=='trade-layout' and drawn.image=='selected-CYNDAQUIL' and drawn.x==39,'native trade offset/layout retained')
check(requested.mon==mon and requested.size==56 and requested.side=='front','trade retains actual sender/receiver identity')
check(t.picAnim==animation and rawget(t,'pic')==nil and t.frame==20,'trade draw restores native frame/timer')
local sender={species='CHIKORITA',dvs={attack=15},otId=456}
t:drawPic(sender,0);check(requested.mon==sender and drawn.image=='selected-CHIKORITA','sender does not borrow receiver identity')
local h=setmetatable({mon=mon,species='CYNDAQUIL',showMon=false,beatLeft=3},{__index=Hatch})
h:drawPic();check(drawn.image=='native-egg','unrevealed egg stays native')
h.showMon=true;h.picAnim=animation
check(h:drawPic()=='hatch-layout' and drawn.image=='selected-CYNDAQUIL','hatch revealed frame replaces native animation')
check(h.picAnim==animation and h.beatLeft==3 and requested.mon==mon,'hatch keeps animation/timer and real DVs')
h.species='QUILAVA';h:drawPic();check(requested.mon.species=='QUILAVA' and requested.mon.dvs==mon.dvs and mon.species=='CYNDAQUIL','explicit hatch species is presentation-only')
enabled=false;h:drawPic();check(drawn.image=='native-frame','OFF/missing frame immediately restores native sheet')
enabled=true;V.crystalSpritesActive=true;t:drawPic(mon,0);check(drawn.image=='native-frame','Crystal retains scene ownership')
V.crystalSpritesActive=false;t:drawPic({species='UNOWN'},0);check(drawn.image=='native-UNOWN','Unown form remains native')
h.mon={species='CYNDAQUIL',isEgg=true};h:drawPic();check(drawn.image=='native-frame','unhatched identity remains native')
h.mon=mon;local originalPic=function()return 'instance' end;h.pic=originalPic;failure=true
check(not pcall(h.drawPic,h),'render errors propagate')
check(h.pic==originalPic and h.picAnim==animation,'errors restore instance overrides and native animation')
undo();check(Trade.drawPic==tradeDraw and Hatch.drawPic==hatchDraw,'unload restores both scenes')
print('PASS '..n..' Gen2 trade/hatch selected-art contracts')
