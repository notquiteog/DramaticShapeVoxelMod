local M=assert(loadfile('lib/BattleSpriteFooting.lua'))({require=function()error('no GPU read required for union fixture')end})
local quads={{getViewport=function()return 0,0,4,12 end},{getViewport=function()return 4,0,4,12 end}}
local data={getPixel=function(_,x,y)return 1,1,1,((x==1 and y==9)or(x==5 and y==6))and 1 or 0 end}
assert(M.union(data,quads)==10,'animation ground must exclude padding and retain raised frames')
local jumpGap=M.union(data,quads)-7
assert(jumpGap==3,'frame pose relative to union was lost')
print('PASS atlas union foot row removes common padding without flattening hops')
