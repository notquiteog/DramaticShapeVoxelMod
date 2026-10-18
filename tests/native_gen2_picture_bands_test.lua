local M=assert(loadfile('lib/NativeGen2PictureBands.lua'))()
local function eq(a,b)assert(a==b,tostring(a)..' ~= '..tostring(b))end
-- 48px player box: the top row is stationary; enemy keeps its bottom row.
local p=M.range(true,48,1,48,1,48,143,{0,1});eq(p[1],95);eq(p[2],103)
local e=M.range(false,56,1,56,1,56,143,{6,1});eq(e[1],135);eq(e[2],143)
-- Short native fronts remain bottom-padded, selected world frames retain
-- their larger source size, and original picture scales compose with resize.
local short=M.range(false,40,1,40,1,40,143,{6,1});eq(short[1],135);eq(short[2],143)
local full=M.range(true,48,1,96,1,96,143,{0,2});eq(full[1],47);eq(full[2],79)
local resize=M.range(true,48,1,48,.5,48,143,{0,1});eq(resize[1],95);eq(resize[2],103)
assert(not M.range(true,0,1,48,1,48,143,{0,1}))
local clip={2,3,4,5};local calls={};local G={getScissor=function()return unpack(clip)end,setScissor=function(...)clip={...}end}
M.draw(G,160,144,{95,103},8,function(x)calls[#calls+1]={x,unpack(clip)}end)
eq(#calls,3);eq(calls[1][1],8);eq(calls[1][5],95);eq(calls[2][3],103);eq(calls[3][1],0);eq(calls[3][5],8)
eq(clip[1],2);eq(clip[4],5)
assert(not pcall(M.draw,G,160,144,{95,103},8,function()error('draw failure')end));eq(clip[1],2);eq(clip[4],5)
calls={};M.draw(G,160,144,{-10,-2},8,function(x)calls[#calls+1]=x end);eq(#calls,1);eq(calls[1],8)
print('PASS native lifted-row mapping, fitted/short/resize bounds, split X, clip limits and error restoration')
local view={scanlines=function()local out={};for i=0,143 do out[#out+1]={src=i,dest=i,dx=i<72 and 3 or 5}end;return out end,
 bgpBands=function()return{{byte=0xe4,rows={0,1,4}},{byte=0x1b,rows={2,3}}}end}
local bg={scx=255,scy=0}
local runs=M.runs(view,bg,false,nil);eq(#runs,2);eq(runs[1].dx,4);eq(runs[1].n,72)
local excluded=M.runs(view,bg,false,{6,1});eq(#excluded,3);eq(excluded[1].n,48);eq(excluded[2].src,56)
local palettes=M.runs(view,{lcdc='BGP',scy=255},false,nil);eq(#palettes,3);eq(palettes[1].dest,1);eq(palettes[2].byte,0x1b)
local viewport=M.viewport(false,56,1,56,1,80,40);eq(viewport[1],-44);eq(viewport[2],116)
local rasterDraws={};M.drawRaster(G,160,144,runs,false,56,1,56,1,56,143,function(dx,dy,byte)rasterDraws[#rasterDraws+1]={dx,dy,clip[1],clip[3]}end,viewport)
assert(#rasterDraws>0);eq(rasterDraws[1][1],4);eq(rasterDraws[1][3],0);eq(rasterDraws[1][4],116)
eq(clip[1],2)
assert(not pcall(M.drawRaster,G,160,144,runs,false,56,1,56,1,56,143,function()error('raster fail')end));eq(clip[1],2)
print('PASS native public scanline grouping, lifted source exclusion, BGP rows, signed scroll and viewport clipping')
local dollClip=M.viewport(false,16,1,16,1,80,8,112)
assert(dollClip[1]==-40 and dollClip[2]==120,'native enemy doll112px origin retains viewport clipping')
