local Pair=assert(loadfile('lib/NativeGen2PairPicture.lua'))()
local lead,partner={hp=20},{hp=10}
local screen={activeMon=function(_,slot)return slot=='enemy2'and partner or lead end}
local drawn={};local calls={};local prior={};local target=prior
local blend,alpha='add','alphamultiply';local clip={2,3,40,50};local color={.2,.3,.4,.5}
local fail=false
love={graphics={
 getCanvas=function()return target end,setCanvas=function(v)target=v end,
 getColor=function()return unpack(color)end,setColor=function(...)color={...}end,
 getBlendMode=function()return blend,alpha end,setBlendMode=function(b,a)blend,alpha=b,a end,
 getScissor=function()return unpack(clip)end,setScissor=function(...)clip={...}end,
 clear=function()end,draw=function(tex,x,y)
  assert(blend=='alpha'and alpha=='premultiplied'and #clip==0,'canvas blend/clip incorrect')
  if fail then error('GPU unavailable')end;calls[#calls+1]={tex,x,y}
 end,
}}
local missing=false
local padding=1
local function render(_,slot,actorOnly)
 assert(actorOnly);if missing and slot=='enemy2'then return nil end
 drawn[slot]=slot=='enemy2'and partner or lead
 local width=slot=='enemy2'and 64 or 48
 return{canvas=slot,ax=80,ay=144-padding,bottomPadding=padding,contentWidth=width,contentHeight=56,
  noMirror=true,hudAnchors={[slot]={80,100}}}
end
local function canvas()return{}end
local function restored()
 assert(target==prior and color[1]==.2 and color[4]==.5)
 assert(blend=='add'and alpha=='alphamultiply'and clip[1]==2 and clip[4]==50)
end
local out=assert(Pair.texture({},'enemy',screen,render,canvas,drawn))
assert(out.contentWidth==112 and out.hudAnchors.enemy[1]<out.hudAnchors.enemy2[1])
assert(drawn.enemy==lead and drawn.enemy2==partner and #calls==2);restored()
fail=true;assert(Pair.texture({},'enemy',screen,render,canvas,drawn)==nil)
assert(not drawn.enemy and not drawn.enemy2,'failed composition claimed native actors');restored();fail=false
missing=true;assert(Pair.texture({},'enemy',screen,render,canvas,drawn)==nil)
assert(not drawn.enemy and not drawn.enemy2,'missing partner claimed lead');missing=false
assert(Pair.texture({},'enemy',screen,render,function()return nil end,drawn)==nil)
assert(not drawn.enemy and not drawn.enemy2)
partner.hp=0;local solo=assert(Pair.texture({},'enemy',screen,render,canvas,drawn))
assert(solo.canvas=='enemy','completed faint retained dead partner')
screen.faintSlide={side='enemy2',frames=0}
assert(Pair.texture({},'enemy',screen,render,canvas,drawn).contentWidth==112,'native faint lost actor at zero HP')
padding=64;calls={}
local effects=assert(Pair.texture({},'enemy',screen,render,canvas,drawn))
assert(effects.ay==80 and calls[1][3]==0 and calls[2][3]==0,'native particles below feet clipped or actors shifted')
print('PASS independent GSC pair composition, faint ownership, premultiplied alpha and failure cleanup')
