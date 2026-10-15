-- Three native tower families; source pixels always come from the active game.
-- The north-edge drawing omits the roof, so its quiet closed cap continues
-- native metal/glass materials without inventing rooftop equipment.
local V=...
local M={}
function M.profile(g)
 local H=g.custom.tower=='emerald'and 224 or g.custom.tower=='rs'and 128 or 112
 return {w=g.width*16,h=g.depth*16,back=0,front=g.depth*16-1,wall=H,
  roofEnd=0,wallTop=0,wallBottom=g.depth*16,doorTop=g.depth*16-16,
  doorBottom=g.depth*16,doorHeight=24,projection=0,bevel=0}
end
function M.doorSurface(g,tx,ty)
 local o=g.custom.openings[1];local sx,sy=(tx-g.cx)*16,(ty-g.cy)*16
 if sx<o[3]and sx+16>o[1]and sy<o[4]and sy+16>o[2]then
  local x,z=g.cx*16,g.cy*16;local f=g.depth*16-1
  return {w=o[3]-o[1],h=o[4]-o[2],sourceX=x+o[1],sourceY=z+o[2],base=g.groundHeight or 0,
   vertices={{x+o[1],24,z+f-1.1},{x+o[3],24,z+f-1.1},{x+o[3],0,z+f-1.1},{x+o[1],0,z+f-1.1}}}
 end
end
local function hole(l,r,b,t,s,trim,door)return {l=l,r=r,b=b,t=t,source=s,trim=trim,door=door}end
-- A closed polygonal slab with continuous UVs, including the beveled sides
-- and underside. The supplied outline is convex and stays inside solid cells.
local function slab(C,ps,b,h,tex,edge)
 local cx,cz,l,n,r,f=0,0,math.huge,math.huge,-math.huge,-math.huge
 for _,p in ipairs(ps)do cx=cx+p[1];cz=cz+p[2];l=math.min(l,p[1]);r=math.max(r,p[1]);n=math.min(n,p[2]);f=math.max(f,p[2])end
 cx,cz=cx/#ps,cz/#ps
 local function uv(x,z)return {tex[1][1]+(x-l)/(r-l)*(tex[3][1]-tex[1][1]),tex[1][2]+(z-n)/(f-n)*(tex[3][2]-tex[1][2])}end
 for i,a in ipairs(ps)do local q=ps[i%#ps+1]
  C.face({{cx,h,cz},{a[1],h,a[2]},{q[1],h,q[2]},{cx,h,cz}},{uv(cx,cz),uv(a[1],a[2]),uv(q[1],q[2]),uv(cx,cz)})
  C.face({{cx,b,cz},{q[1],b,q[2]},{a[1],b,a[2]},{cx,b,cz}},edge,.65)
  C.face({{a[1],h,a[2]},{a[1],b,a[2]},{q[1],b,q[2]},{q[1],h,q[2]}},edge,.85)
 end
end
local function cap(C,l,n,r,f,b,h,tex,edge)
 slab(C,{{l+1,n},{r-1,n},{r,n+1},{r,f-1},{r-1,f},{l+1,f},{l,f-1},{l,n+1}},b,h,tex,edge)
end
local function tiling(C,sx,sy)
 return function(l,lo,r,hi)local u,v=l%16,(256-hi)%16
  return C.uv(sx+u+.02,sy+v+.02,sx+u+r-l-.02,sy+v+hi-lo-.02)
 end
end
local function windows(C,a,b,H,wall,trim,source,step,paneHeight,base,paneWidth)
 local L=math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2);local hs={}
 local width=paneWidth or math.min(L-2,22)
 for u=1,L-width-.1,math.max(width+4,24)do for y=base or 8,H-paneHeight,step do
  hs[#hs+1]=hole(u,u+width,y,y+paneHeight,source,trim)
 end end
 C.elevation(a,b,H,hs,wall)
end
local function portico(C,g,l,r,f,stone,glass,curved)
 local o=g.custom.openings[1];local path=curved and {{l,f-11},{l+16,f-11},{l+24,f},{r-24,f},{r-16,f-11},{r,f-11}}
  or{{l,f},{r,f}}
 for i=1,#path-1 do local a,b=path[i],path[i+1];local hs={}
  if a[1]<=o[1]and b[1]>=o[3]then hs={hole(o[1]-a[1],o[3]-a[1],0,24,{o[1]+.05,o[2]+.05,o[3]-.05,o[4]-.05},stone,true)}
  elseif curved then local L=math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)
   if L>6 then hs={hole(2,L-2,2,23,{80.05,112.05,94.95,127.95},stone)}end
  end
  C.elevation(a,b,24,hs,stone)
 end
 C.elevation({l,f-19},path[1],24,{},stone)
 C.elevation(path[#path],{r,f-19},24,{},stone)
 C.elevation({r,f-19},{l,f-19},24,{},stone)
 C.face({{l,0,f},{r,0,f},{r,0,f-19},{l,0,f-19}},stone,.65)
 for _,xx in ipairs{l,l+3,r-4,r-1}do C.box(xx,0,f-.3,xx+.6,24,f+.3,stone)end
 if curved then
  local ps={{l,f-20},{r,f-20},{r,f-9},{r-6,f-3},{r-24,f+.4},{l+24,f+.4},{l+6,f-3},{l,f-9}}
  slab(C,ps,24,28,C.uv(64.05,96.05,143.95,111.95),stone)
 else cap(C,l-.3,f-20,r+.3,f+.4,24,27,stone,stone)end
end
local function trainer(g,C)
 local H=112;local blue,trim,dark,glass=C.sw(40,40),C.sw(48,99),C.sw(48,103),C.sw(48,20)
 local ps={{18,.5},{126,.5},{126,94},{112,111},{32,111},{18,94}}
 local hs={}
 for _,sx in ipairs{43,67,91}do for _,sy in ipairs{0,20,44,68}do
  hs[#hs+1]=hole(sx-32,sx-22,H-sy-8,H-sy,{sx+.05,(sy==0 and 20 or sy)+.05,sx+9.95,(sy==0 and 28 or sy+8)-.05},dark)
 end end
 C.elevation({32,111},{112,111},H,hs,blue,function(l,lo,r,hi)return C.uv(32+l+.02,H-hi+.02,32+r-.02,H-lo-.02)end)
 windows(C,{18,.5},{18,94},H,blue,dark,{43.05,20.05,52.95,27.95},24,8,12,10)
 windows(C,{126,94},{126,.5},H,blue,dark,{43.05,20.05,52.95,27.95},24,8,12,10)
 windows(C,{126,.5},{18,.5},H,blue,dark,{43.05,20.05,52.95,27.95},24,8,12,10)
 -- Native reflective corner glazing becomes actual angled window bays.
 windows(C,{18,94},{32,111},H,blue,trim,{17.05,20.05,22.95,27.95},24,20,8,18)
 windows(C,{112,111},{126,94},H,blue,trim,{17.05,20.05,22.95,27.95},24,20,8,18)
 slab(C,ps,0,.5,blue,blue);slab(C,ps,H,H+2,trim,dark)
 -- Closed ribs continue the native blue metal/vent vocabulary around the
 -- elevations. No diagonal source reflection is pasted over a flat box.
 for zz=5,85,16 do
  C.box(17.7,2,zz,18.3,H,zz+1,blue);C.box(125.7,2,zz,126.3,H,zz+1,blue)
 end
 for xx=24,112,16 do C.box(xx,2,.2,xx+1,H,.8,blue)end
 portico(C,g,48,96,127,trim,glass,false)
 -- The native entrance has a real pitched pale canopy, not a folded card.
 local l,r,m,n,f=48,96,72,107,127.7
 C.face({{l,27,n},{m,37,n},{m,37,f},{l,27,f}},C.sw(68,101))
 C.face({{m,37,n},{r,27,n},{r,27,f},{m,37,f}},trim)
 C.face({{l,27,f},{r,27,f},{m,37,f},{l,27,f}},C.sw(68,101))
 C.face({{r,27,n},{l,27,n},{m,37,n},{r,27,n}},trim,.8)
 C.face({{l,27,n},{r,27,n},{r,27,f},{l,27,f}},trim,.65)
end
local function battle(g,C)
 local em=g.custom.tower=='emerald';local W,D=C.W,C.D;local H=em and 224 or 128;local front=D-17
 local redX=em and 16 or 32
 local red,stone,glass,gray=C.sw(redX+8,20),C.sw(em and 85 or 72,20),C.sw(em and 136 or 104,20),C.sw(em and 70 or 8,20)
 local ps=em and {{.5,front-16},{16,front},{48,front},{64,front-16},{80,front-16},{80,front},{96,front},{112,front-16},{160,front-16},{176,front},{192,front},{192,front-16},{208,front-16},{224,front},{256,front},{W-.5,front-16}}
  or{{.5,front-16},{16,front},{32,front},{64,front},{80,front},{80,front-12},{88,front-4},{120,front-4},{128,front-12},{128,front},{144,front},{176,front},{192,front},{W-.5,front-16}}
 for i=1,#ps-1 do local a,b=ps[i],ps[i+1]
  local brick=(a[1]>=redX and b[1]<=redX+32)or(a[1]>=W-redX-32 and b[1]<=W-redX)
  local pillar=em and ((a[1]==80 and b[1]==96)or(a[1]==176 and b[1]==192))
   or not em and ((a[1]==64 and b[1]==80)or(a[1]==128 and b[1]==144))
  if brick or pillar then C.elevation(a,b,H,{},brick and red or stone,brick and tiling(C,redX,0)or nil)
  else
   windows(C,a,b,H,gray,stone,em and {114.05,.05,157.95,23.95}or{98.05,.05,109.95,15.95},32,24,em and 8 or 40)
  end
 end
 local first,last=ps[1],ps[#ps]
 windows(C,{first[1],.5},first,H,gray,stone,em and {114.05,.05,157.95,23.95}or{98.05,.05,109.95,15.95},32,24,em and 8 or 40)
 windows(C,last,{last[1],.5},H,gray,stone,em and {114.05,.05,157.95,23.95}or{98.05,.05,109.95,15.95},32,24,em and 8 or 40)
 windows(C,{W-.5,.5},{.5,.5},H,gray,stone,em and {114.05,.05,157.95,23.95}or{98.05,.05,109.95,15.95},32,24,em and 8 or 40)
 C.face({{.5,0,front},{W-.5,0,front},{W-.5,0,.5},{.5,0,.5}},gray,.65)
 cap(C,.2,.2,W-.2,front+.4,H,H+2,gray,stone)
 -- Separate brick piers have closed return walls and roof caps. Their
 -- full source texture repeats on the side/back, not just the front face.
 for _,l in ipairs{redX,W-redX-32}do
  local f=em and D-1.4 or front-.2;local h=H+(em and 12 or 3)
  for _,edge in ipairs{{{l+.2,.6},{l+.2,f}},{{l+31.8,f},{l+31.8,.6}},{{l+31.8,.6},{l+.2,.6}},{{l+.2,f},{l+31.8,f}}}do C.elevation(edge[1],edge[2],h,{},red,tiling(C,redX,0))end
  cap(C,l+.1,.5,l+31.9,f+.1,h,h+1,gray,stone)
  C.face({{l+.2,0,f},{l+31.8,0,f},{l+31.8,0,.6},{l+.2,0,.6}},red,.65)
 end
 portico(C,g,em and 112 or 64,em and 160 or 144,D-1,stone,glass,not em)
end
function M.append(g,emit)
 local C=V.require('Gen3DepartmentStores').context(g,emit)
 if g.custom.tower=='trainer'then trainer(g,C)else battle(g,C)end
end
return M
