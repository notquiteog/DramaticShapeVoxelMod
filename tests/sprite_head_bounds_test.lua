local reads=0
local data={getDimensions=function()return 12,10 end,getPixel=function(_,x,y)
 reads=reads+1;return 1,1,1,(x>=2 and x<9 and y>=3 and y<8)and 1 or 0 end}
local source={}
local Art={imageData=function(i)return i==source and data end}
local M=assert(loadfile('lib/SpriteHeadBounds.lua'))({require=function(n)assert(n=='BattleArt');return Art end})
love={graphics=setmetatable({},{__index=function()error('owned sprite must not access GPU')end})}
local function eq(a,b)for i=1,4 do assert(a[i]==b[i],i..':'..a[i]..'~='..b[i])end end
eq(M.get(source),{2,3,9,8});local once=reads;M.get(source);assert(reads==once)
local target={}
assert(M.rememberFit(target,data,16,false,1));eq(M.get(target),{4,9,11,14})
assert(M.rememberFit(target,data,16,true,1));eq(M.get(target),{5,9,12,14})
assert(not M.rememberFit(target,data,16,false,.5),'ambiguous sampling must retain GPU fallback')
assert(not M.rememberFit({},nil,16,false,1))
print('PASS CPU sprite bounds and mirrored/scaled native fits without GPU access')
