local count=0
local function eq(a,b,m)assert(a==b,m);count=count+1 end
local setting={get=function()return 'rain'end}
local W=assert(loadfile('lib/Weather.lua'))({require=function(n)assert(n=='ModSetting');return{new=function()return setting end}end})
local maps={
 {id='ROUTE_1',def={tileset='OVERWORLD'}},
 {id='ROUTE_29',def={environment='ROUTE'}},
 {id='NEW_BARK_TOWN',def={environment='TOWN'}},
 {id='FR_ROUTE_1',def={mapType=3}},
 {id='FR_VIRIDIAN_FOREST',def={outdoor=true}},
}
for _,map in ipairs(maps)do
 for _,mode in ipairs({'rain','snow','fog','storm','clear'})do eq(W.modeAt(map,mode,10),mode,'shared weather mode')end
 eq(W.modeAt(map,'auto',100),W.modeAt(map,'auto',100),'stable schedule')
end
for _,map in ipairs({{id='OAKS_LAB',def={tileset='LAB'}},{id='ELMS_LAB',def={environment='INDOOR'}},{id='ICE_PATH',def={environment='CAVE'}},{id='FR_PALLET_TOWN_LAB',def={mapType=8}},{id='FR_ROCK_TUNNEL_1F',def={mapType=4}}})do
 eq(W.modeAt(map,'storm',0),'clear','indoors protected')
end
local saved='parent';local canvas={};local stack,paints=0,0
love={graphics={push=function()stack=stack+1 end,pop=function()stack=stack-1 end,origin=function()end,setCanvas=function(c)saved=c end,setShader=function()end,setDepthMode=function()end,setBlendMode=function()end,setColor=function()end,rectangle=function()paints=paints+1 end}}
for _,mode in ipairs({'rain','snow','fog','storm'})do
 W.apply(canvas,640,360,maps[1],1,mode);eq(stack,0,'graphics state balanced')
end
assert(paints>0,'weather drew nothing')
local old=paints;W.apply(canvas,640,360,maps[1],1,'clear');eq(paints,old,'clear has no effect cost')
local clock=W.clock;W.update(.25);eq(W.clock,clock+.25,'single update clock')
print('PASS shared weather parity ('..count..' checks)')
