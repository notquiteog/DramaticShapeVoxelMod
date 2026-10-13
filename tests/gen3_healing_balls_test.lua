local M=dofile('lib/Gen3HealingBalls.lua')
for count=0,6 do
 local pixels={}
 for i=0,count-1 do
  local col,row=i%2,math.floor(i/2)
  for y=1,6 do for x=1,6 do pixels[(9+col*6+x)..':'..(4+row*4+y)]=true end end
 end
 local data={getPixel=function(_,x,y)return 1,1,1,pixels[x..':'..y]and 1 or 0 end}
 local quads=0
 local actual=M.append(data,80,7.18,16,function(v,uv)
  quads=quads+1
  for _,p in ipairs(v)do assert(p[1]>=88.9 and p[1]<=103.1 and p[2]>=7.18 and p[2]<=10.39 and p[3]>=28.7 and p[3]<=43.1,'ball outside native tray')end
  for _,t in ipairs(uv)do assert(t[1]>0 and t[1]<1 and t[2]>0 and t[2]<1)end
 end)
 assert(actual==count,'native ball count mismatch '..count..'/'..actual)
 assert(quads==count*48,'sphere lost closed rings')
end
assert(not M.canvas({newImageData=function()error('no readback')end},0,0,0,function()error('unexpected mesh')end),'readback must retain original draw fallback')
print('PASS native zero-to-six healing balls, tray bounds, closed rings and readback fallback')
