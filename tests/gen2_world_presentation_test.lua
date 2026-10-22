local root=os.getenv('DS_MOD_PATH')or'.'
local M=assert(loadfile(root..'/lib/Gen2WorldPresentation.lua'))()
local source={getDimensions=function()return 840,788 end}
local current='native-target';local calls={};local allocations,releases=0,0
local function call(name)return function(...)calls[#calls+1]={name,...}end end
love={graphics={getCanvas=function()return current end,setCanvas=function(c)current=c end,
 push=call('push'),pop=call('pop'),origin=call('origin'),setScissor=call('scissor'),setShader=call('shader'),clear=call('clear'),
 setDepthMode=call('depth'),setStencilTest=call('stencil'),setColorMask=call('mask'),setColor=call('color'),setBlendMode=call('blend'),draw=call('draw'),newCanvas=function(w,h,opt)
 allocations=allocations+1;assert(w==320 and h==300 and opt.dpiscale>=2.625)
 return{getDimensions=function()return w,h end,setFilter=function()end,release=function()releases=releases+1 end}
 end}}
local World={drawPipeline=function()return source end};local native=World.drawPipeline
local uninstall=M.install(World)
assert(World:drawPipeline('other',320,300)==source and allocations==0)
local out=World:drawPipeline('voxel',320,300);assert(out~=source and current=='native-target')
assert(calls[1][1]=='push'and calls[#calls][1]=='pop')
local draw;for _,c in ipairs(calls)do if c[1]=='draw'then draw=c end end
local resets={};for _,c in ipairs(calls)do resets[c[1]]=c end
assert(resets.depth[2]=='always'and resets.depth[3]==false and #resets.stencil==1 and resets.mask[2]and resets.mask[5])
assert(draw[2]==source and draw[6]==320/840 and draw[7]==300/788)
assert(World:drawPipeline('voxel',320,300)==out and allocations==1)
love.graphics.draw=function()error('GPU fixture failure')end
assert(World:drawPipeline('voxel',320,300)==nil and current=='native-target'and calls[#calls][1]=='pop')
source={getDimensions=function()return 320,300 end};assert(World:drawPipeline('voxel',320,300)==source)
uninstall();assert(World.drawPipeline==native and releases==1)
print('gen2_world_presentation_test: pass')
