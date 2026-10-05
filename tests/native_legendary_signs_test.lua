local on=false;local loaded={};local V={}
function V.require(k)
 if k=='CommunityVisuals'then return {customSigns=function()return on end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end
 return loaded[k]
end
local M=V.require('NativeLegendarySigns');local uv={{.1,.2},{.2,.2},{.2,.3},{.1,.3}};local n=0
local function emit(q,t,shade)
 assert(type(shade)=="number")
 n=n+1;for i,p in ipairs(q)do
 assert(p[1]>=32 and p[1]<=48 and p[3]>=48 and p[3]<=64,'solid escaped source cell')
 assert(p[2]>=0 and p[2]<=13.4,'height changed')
 assert(t[i][1]>=.1 and t[i][1]<=.2 and t[i][2]>=.2 and t[i][2]<=.3,'foreign texture')
 end
end
assert(not M.draw({cx=2,cy=3},emit,uv)and n==0)
on=true;assert(M.draw({cx=2,cy=3},emit,uv)and n>30)
print('PASS optional native wayfinder, native UV, closed silhouette and cell bounds')

local custom=false
assert(M.draw({cx=2,cy=3,trim={{.15,.25},{.15,.25},{.15,.25},{.15,.25}},face=function(x,z,e)custom=true;assert(x==40 and z==60)end},emit,uv))
assert(custom,'noncontiguous native atlas face callback omitted')
