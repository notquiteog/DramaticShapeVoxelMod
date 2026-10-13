local M=dofile('lib/Gen3ScreenEffects.lua')
assert(M.supports('flash')and not M.supports('bg_flash')and not M.supports('flash_level'))
assert(M.alpha({{kind='flash',alpha=.5},{kind='flash',alpha=.5}})==.75)
assert(M.alpha({{kind='flash',alpha=0/0},{kind='bg_flash',alpha=1}})==0)
local drawn,depth=0,0
love={graphics=setmetatable({push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 rectangle=function(mode,x,y,w,h)assert(mode=='fill'and w==1280 and h==720);drawn=drawn+1 end},
 {__index=function()return function()end end})}
local canvas={getDimensions=function()return 1280,720 end}
assert(M.draw(canvas,{{kind='flash',alpha=.5}})and depth==0 and drawn==1)
assert(not M.draw(canvas,{})and drawn==1)
love.graphics.rectangle=function()error('GPU failure')end
assert(not pcall(M.draw,canvas,{{kind='flash',alpha=1}})and depth==0,'failed veil leaked graphics state')
print('PASS native full-world flash alpha/layers, framebuffer dimensions and state restoration')
