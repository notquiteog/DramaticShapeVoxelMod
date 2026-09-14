local draws={}
local function pic(w,h)return {getDimensions=function()return w,h end} end
local first,second={hp=10},{hp=10}
local screen={battle={doubles={},enemy2=second}}
function screen:activeMon()return first end
function screen:pic(mon)return mon==first and pic(56,56) or pic(64,48) end
local target
love={graphics={
 newCanvas=function(w,h)return {getWidth=function()return w end,getHeight=function()return h end,setFilter=function()end} end,
 getCanvas=function()return target end,setCanvas=function(v)target=v end,
 getColor=function()return 1,1,1,1 end,setColor=function()end,clear=function()end,
 draw=function(img,x,y)local w,h=img:getDimensions();draws[#draws+1]={x=x,y=y,w=w,h=h} end,
}}
local M=assert(loadfile('lib/Gen2Staged.lua'))({require=function(name)
 if name=='Generation' then return {isGen2=function()return true end} end
 if name=='BattleScene' then return {GB_W=160,GB_H=144} end
 error(name)
end})
local game={stack={states={screen}}}
local texture=assert(M.sideTexture(game,'enemy'))
assert(#draws==2,'both complete partner images must draw')
assert(draws[1].x+draws[1].w<=draws[2].x,'partner sprites overlap')
assert(draws[1].y+draws[1].h==draws[2].y+draws[2].h,'feet not aligned')
assert(M.drawn.enemy==first and M.drawn.enemy2==second,'flat replay must skip both rendered bodies')
assert(target==nil,'previous render target not restored')
local back=assert(M.sideTexture(game,'player'))
assert(back.noMirror==true,'native back sprites must not receive the Gen 1 front-pic mirror')
assert(back.modernFraming,'Crystal enables wider scene framing')
print('staged pair dimensions, separation, ground line and ownership passed')
