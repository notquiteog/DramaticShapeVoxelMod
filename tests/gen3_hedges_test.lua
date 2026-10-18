local calls,filtered,wrapped,released=0,false,false,false
local model=assert(loadfile('lib/Gen3Hedges.lua'))({mod={assets={image=function(_,path)
 assert(path=='assets/environment/hoenn-hedge-leaves.png');calls=calls+1
 return{setFilter=function(_,a,b)filtered=a=='nearest'and b=='nearest'end,
 setWrap=function(_,a,b)wrapped=a=='repeat'and b=='repeat'end,release=function()released=true end}
end}}})
assert(model.image()==model.image()and calls==1 and filtered and wrapped)
model.release();assert(released)
local P=assert(loadfile('lib/Gen3BoundaryProps.lua'))({require=function()return model end})
local cells={}
for x=0,2 do for y=0,1 do if x<2 or y==1 then
 cells[x..':'..y]={cx=x,cy=y,collision=7,shape={kind='hedge',height=7,bounds={0,0,16,16}}}
end end end
P.prepare(cells)
local edges,faces,high={},0,0
local function key(p)return string.format('%.6f,%.6f,%.6f',p[1],p[2],p[3])end
for _,c in pairs(cells)do
 model.append(c,function(v,uv)
  faces=faces+1
  for i,p in ipairs(v)do
   assert(p[1]>=c.cx*16 and p[1]<=(c.cx+1)*16 and p[3]>=c.cy*16 and p[3]<=(c.cy+1)*16)
   assert(p[2]>=.02 and p[2]<=7);high=math.max(high,p[2])
   assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
   local a,b=key(p),key(v[i%4+1]);local k=a<b and a..'|'..b or b..'|'..a
   edges[k]=(edges[k]or 0)+1
  end
 end)
 assert(c.collision==7,'mesh changed native permissions')
end
assert(faces>600 and high>6.5)
for k,count in pairs(edges)do assert(count==2,'open or doubled hedge mesh edge '..k..': '..count)end
print('PASS closed joined L-shaped hedge, bounded rounded foliage, continuous seams and cached public material loading')
