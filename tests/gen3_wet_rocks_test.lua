-- Water placement is visual only: source hull/UV/footprints remain identical.
local V,cache={},{};function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local style='native'
cache.TreePresentation={props={get=function()return style end}}
cache.Gen3Outdoor={mask=function()
 local out={};for y=1,14 do for x=1,14 do if(x-7.5)^2+(y-8)^2<36 then out[y*16+x]=true end end end;return out
end}
local Cave=V.require('Gen3Cave');local Sea=V.require('Gen3SeaRocks')
local ts={cols=1,midToSlot={[0xc5]=0},imageData={getPixel=function()return .55,.4,.32,1 end}}
local uv=function()return{{0,0},{1,0},{1,1},{0,1}}end
local function render(wet,line)
 local out={};local lo,hi=math.huge,-math.huge
 Cave.rock({cx=2,cy=3,mid=0xc5,ts=ts,shape={ground=0x2d,height=6,wetRock=wet,waterline=line}},function(v,t,shade,anchor)
  out[#out+1]={v=v,t=t,shade=shade,anchor=anchor}
  for _,p in ipairs(v)do assert(p[1]>=32 and p[1]<=48 and p[3]>=48 and p[3]<=64,'wet boulder escaped its source cell');lo=math.min(lo,p[2]);hi=math.max(hi,p[2])end
 end,uv)
 return out,lo,hi
end
for _,setting in ipairs{'native','cards'}do style=setting
 local land,l,h=render(false);assert(#land>0 and(setting=='cards'or l>=0),'land rock placement changed')
 for _,line in ipairs{.05,3.25,-1.5}do
  local wet,low,high=render(true,line)
  assert(#wet==#land and low<line and high>line and math.abs((low+high)/2-line)<1e-9,'small wet rock not half submerged')
  local offset=line-(l+h)/2
  for i,q in ipairs(wet)do
   assert(q.shade==land[i].shade)
   for k,p in ipairs(q.v)do local a=land[i].v[k]
    assert(p[1]==a[1]and p[3]==a[3]and math.abs(p[2]-a[2]-offset)<1e-9,'wet flag distorted source geometry')
    assert(q.t[k][1]==land[i].t[k][1]and q.t[k][2]==land[i].t[k][2],'wet flag changed original pixels')
   end
  end
 end
end
assert(Sea.waterline({shape={}})==.05 and Sea.waterline({shape={waterline=0}})==0)
assert(Sea.waterline({shape={waterline=0/0}})==.05)
print('PASS wet hull/card half immersion, arbitrary local waterlines, source footprints/UVs, and unchanged land boulders')
-- A collision-bearing source cell can have a different terrain base from the
-- adjacent water; the local offset must still meet the one world water plane.
do
 local W=V.require('Gen3Water');local c={cx=0,cy=0,pair='general__petalburg',base=7,shape={kind='rock',ground=0x2d,wetRock=true}}
 local cells={['0:0']=c,['1:0']={cx=1,cy=0,pair=c.pair,base=2,mid=0x170,collision=0x29,shape={kind='water'}}}
 assert(W.bind(cells)==1 and math.abs(c.shape.waterline+4.95)<1e-9)
 assert(c.shape.waterGround==0x170 and math.abs(c.base+Sea.waterline(c)-2.05)<1e-9)
end
print('PASS wet-rock local placement meets adjacent world water despite differing native elevations')
