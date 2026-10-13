local L=dofile('lib/BuildingLights.lua')
local function pane(x,y,z,shade)
 return {{x,y+8,z,0,0,shade},{x+8,y+8,z,1,0,shade},{x+8,y,z,1,1,shade},{x,y,z,0,1,shade}}
end
local front=pane(10,4,20,64.9)
local lamps=L.collect(front,nil,16,16)
assert(#lamps==1 and lamps[1][1]==14 and lamps[1][2]==8 and lamps[1][3]==21)
assert(lamps[1][5]==0 and lamps[1][6]==1,'light faces into wall')
assert(#L.collect(pane(10,4,20,1),nil,16,16)==0,'unmarked wall glows')
local floor={{0,0,0,0,0,64.9},{8,0,0,1,0,64.9},{8,0,8,1,1,64.9},{0,0,8,0,1,64.9}}
assert(#L.collect(floor,nil,16,16)==0,'roof art became window light')
local swatch=pane(0,0,0,1);for _,p in ipairs(swatch)do p[4],p[5]=.5,.5 end
assert(#L.collect(swatch,function()return true end,16,16)==0,'flat paint swatch became emitter')
 swatch[2][4]=.505;swatch[3][4]=.505;swatch[3][5]=.505;swatch[4][5]=.505
 assert(#L.collect(swatch,function()return true end,16,16)==0,'subpixel paint swatch became emitter')
local marked=L.collect(pane(0,0,0,1),function(x,y)return x>=8 end,16,16)
assert(#marked==1 and marked[1][1]==6,'masked emitter not anchored to glass')
local parts={{lights={}}}
for i=1,100 do parts[1].lights[i]={i*10,8,20,30,0,1}end
local field=L.bake(parts)
assert(field.count==100,'some sources were dropped by a global light limit')
local function sample(f,x,y,z)
 local ix=math.floor((x-f.origin[1])/f.step[1]+.5)
 local iy=math.floor((y-f.origin[2])/f.step[2]+.5)
 local iz=math.floor((z-f.origin[3])/f.step[3]+.5)
 return f.values[(iy*f.size[3]+iz)*f.size[1]+ix+1]or 0
end
for _,p in ipairs(parts[1].lights)do assert(sample(field,p[1],p[2],p[3])>.8,'omitted emitter')end
assert(sample(field,500,8,0)==0,'door light leaked behind its facade')
local street=L.bake({{lights={{0,24,0,42,0,0}}}})
assert(sample(street,0,0,0)>0 and sample(street,8,8,8)>0,'street lamp has no ground light')
assert(not L.bake({}),'empty scene allocated a lightfield')
-- Mask keeps blue roof/sky paint, frames and a second material bank dark.
local function data(w,h)
 local px={}
 return {getDimensions=function()return w,h end,getPixel=function(_,x,y)return unpack(px[y*w+x]or{.1,.6,.8,1})end,
 setPixel=function(_,x,y,...)px[y*w+x]={...}end,release=function()end,setFilter=function()end}
end
love={image={newImageData=data},graphics={newImage=function(d)return d end}}
local Glow=dofile('lib/Gen3BuildingGlow.lua')
local source=data(68,64);source:setPixel(10,46,.9,.8,.5,1)
local mask,read=Glow.build({kind='house',custom={openings={{8,44,20,54}}}},{w=32,h=64},source)
assert(mask and read(9,46) and not read(10,46) and not read(9,20) and not read(41,46))
assert(not read(-1,46) and not read(99,46))
print('PASS actual-pane emitters, outward normals, floor/paint exclusion, unlimited spatial lighting and native-glass masks')
