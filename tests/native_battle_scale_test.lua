-- Shared pixel pitch preserves native artwork proportions instead of filling
-- every species' slot; far-side depth and UI heads use the same cached image.
local calls={};local frame=0
local g={newCanvas=function(w,h,opts)assert(opts.dpiscale==1);return{setFilter=function()end}end,
 draw=function(image,x,y,angle,sx,sy)calls[#calls+1]={sx=math.abs(sx),sy=sy,x=x,y=y}end}
for _,k in ipairs({'push','pop','setCanvas','origin','setShader','setScissor','setDepthMode','setBlendMode','clear','setColor'})do g[k]=function()end end
love={graphics=g}
local front,back='gen5','gen5'
local art={playerSide=function()return 'back'end,frontAnimationSetting={get=function()return front end},backAnimationSetting={get=function()return back end}}
local M=assert(loadfile('lib/NativeBattleArt.lua'))({require=function(n)return n=='BattleArt'and art or {}end})
local function pic(w,h)return {getDimensions=function()return w,h end}end
assert(M.stagePixelScale(true)==nil,'ordinary native battle retains original slot layout')
M.staged=true
local near,far=M.stagePixelScale(true),M.stagePixelScale(false)
assert(far<near and math.abs(far/near-.68)<1e-9)
local small,big=pic(24,28),pic(70,66)
M.fit(small,64,false,near);M.fit(big,64,false,near)
assert(calls[1].sx==calls[2].sx,'small art is not enlarged independently')
assert(calls[1].y==64-28*near,'feet remain at slot bottom')
M.fit(big,64,false,far);assert(calls[3].sx<calls[2].sx,'equal art is smaller across the field')
local n=#calls;M.fit(big,64,false,far);assert(#calls==n,'fitted frame is cached')
M.fit(big,64,true,far);assert(#calls==n+1,'mirrored frame has independent cache key')
front='gen3';assert(M.stagePixelScale(false)==.68,'native 64px source is not treated as BW')
M.staged=false;M.fit(small,64,false);assert(calls[#calls].sx>near,'2D fallback retains normal fit')
M.world=true
assert(M.stagePixelScale(true)==64/96 and M.stagePixelScale(false)==1,'world cards preserve source pitch; perspective alone changes apparent size')
front='gen5';assert(M.stagePixelScale(true)==M.stagePixelScale(false),'identical source generations share identical world scale')
print('PASS battle source-pixel scale, far-row perspective, foot anchoring, cache and 2D fallback')
