-- Reviewed landmark architecture. Native-art families read each live edition;
-- the museum delegates to its authored architectural materials and geometry.
local V=...
local M={}
function M.profile(g)
 local D=g.depth*16;local k=g.custom.landmark
 return {w=g.width*16,h=D,back=0,front=D-1,wall=k=='rs_devon'and 112 or k=='museum'and 84 or 64,
  roofEnd=k=='indigo'and 64 or 32,wallTop=32,wallBottom=D,
  doorTop=D-16,doorBottom=D,doorHeight=16,projection=0,bevel=0}
end
function M.doorSurface(g,tx,ty)
 local k=g.custom.landmark;local D=g.depth*16
 for _,o in ipairs(g.custom.openings)do
  local sx,sy=(tx-g.cx)*16,(ty-g.cy)*16
  if sx<o[3]and sx+16>o[1]and sy<o[4]and sy+16>o[2]then
   local top=k=='rs_devon'and 28 or k=='museum'and 24 or 16
   local front=k=='museum'and 95 or D-1
   local x,z=g.cx*16,g.cy*16
   return {w=o[3]-o[1],h=o[4]-o[2],sourceX=x+o[1],sourceY=z+o[2],base=g.groundHeight or 0,
    vertices={{x+o[1],top,z+front-1.1},{x+o[3],top,z+front-1.1},
     {x+o[3],0,z+front-1.1},{x+o[1],0,z+front-1.1}}}
  end
 end
end
local function hole(l,r,b,t,s,arch,door,trim)
 return {l=l,r=r,b=b,t=t,source=s,arch=arch,door=door,trim=trim}
end
local function front(C,l,r,f,H,sy,ey,holes,wall,native)
 local hs={};for _,o in ipairs(holes or {})do local q={};for k,v in pairs(o)do q[k]=v end;q.l=q.l-l;q.r=q.r-l;hs[#hs+1]=q end
 C.elevation({l,f},{r,f},H,hs,wall,native~=false and function(a,lo,b,hi)
  return C.uv(l+a+.02,sy+(H-hi)/H*(ey-sy)+.02,l+b-.02,sy+(H-lo)/H*(ey-sy)-.02)
 end)
end
local function side(C,a,b,H,wall,window,levels,floor)
  local length=math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2);local hs={}
  for u=8,length-15,24 do for _,y in ipairs(levels or {})do
   if not floor or y>=floor then hs[#hs+1]=hole(u,u+(window[6]or 7),y,y+(window[5]or 15),window,false,false,wall)end
  end end
  C.elevation(a,b,H,hs,wall,nil,floor)
 end
-- Complete shell including the underside and roof. No opaque box is placed
-- behind glazing/portals: the elevation mesh itself has inset closed reveals.
local function shell(C,l,n,r,f,H,sy,ey,holes,wall,window,levels,native,rearFloor)
 front(C,l,r,f,H,sy,ey,holes,wall,native)

 side(C,{l,n},{l,f},H,wall,window,levels);side(C,{r,f},{r,n},H,wall,window,levels);side(C,{r,n},{l,n},H,wall,window,levels,rearFloor)
 C.face({{l,0,f},{r,0,f},{r,0,n},{l,0,n}},wall,.65)
 C.face({{l,H,n},{r,H,n},{r,H,f},{l,H,f}},wall)
end
local function roof(C,l,n,r,f,b,h,tex,edge)
 local ps={{l+1,n},{r-1,n},{r,n+1},{r,f-1},{r-1,f},{l+1,f},{l,f-1},{l,n+1}}
 local cx,cz=(l+r)/2,(n+f)/2
 local function uv(x,z)return {tex[1][1]+(x-l)/(r-l)*(tex[3][1]-tex[1][1]),tex[1][2]+(z-n)/(f-n)*(tex[3][2]-tex[1][2])}end
 for i,a in ipairs(ps)do local q=ps[i%8+1]
  C.face({{cx,h,cz},{a[1],h,a[2]},{q[1],h,q[2]},{cx,h,cz}},{uv(cx,cz),uv(a[1],a[2]),uv(q[1],q[2]),uv(cx,cz)})
  C.face({{cx,b,cz},{q[1],b,q[2]},{a[1],b,a[2]},{cx,b,cz}},edge,.65)
  C.face({{a[1],h,a[2]},{a[1],b,a[2]},{q[1],b,q[2]},{q[1],h,q[2]}},edge,.85)
 end
end
local function devon(g,C)
 local wall,stone,trim=C.sw(9,41),C.sw(3,48),C.sw(6,63)
 local win={17.05,40.05,23.95,54.95}
 for _,r in ipairs{{2,48},{112,158}}do
  local holes={}
  for _,sy in ipairs{40,72}do for _,sx in ipairs(r[1]<48 and {17,41}or{121,145})do
   holes[#holes+1]=hole(sx,sx+6,128-sy-15,128-sy,{sx+.05,sy+.05,sx+5.95,sy+14.95},false,false,stone)
  end end
  for _,sx in ipairs(r[1]<48 and {10,26,42}or{114,130,146})do
   holes[#holes+1]=hole(sx,sx+5,24,31,{sx+.05,97.05,sx+4.95,103.95},false,false,stone)
  end
  shell(C,r[1],2,r[2],127,96,32,128,holes,wall,win,{24,56,80})
  roof(C,r[1]-.5,1.5,r[2]+.5,127.5,96,99,C.uv(r[1]+1.05,3.05,r[2]-1.05,26.95),stone)
  for _,y in ipairs{1,32,64,95}do C.box(r[1]-.4,y,1.6,r[2]+.4,y+2,127.6,stone)end
 end
 local holes={hole(64,80,0,28,{64.05,120.05,79.95,143.95},true,true,trim),hole(80,96,0,28,{80.05,120.05,95.95,143.95},true,true,trim)}
 shell(C,48,2,112,143,112,48,144,holes,wall,win,{38,70})
 for _,xx in ipairs{50,62,82,102,108}do C.box(xx,30,142.9,xx+1.5,110,143.4,stone)end
 for _,y in ipairs{36,73,110}do C.box(48.2,y,1.7,111.8,y+2,143.6,stone)end
 roof(C,48.2,1.5,111.8,143.5,112,116,C.uv(56.05,3.05,103.95,22.95),trim)
 -- Native winged crest remains intact on a shallow closed medallion.
 C.box(71,107,143.3,89,123,143.8,stone)
 C.face({{71,123,143.82},{89,123,143.82},{89,107,143.82},{71,107,143.82}},C.uv(71.05,30.05,88.95,45.95))
end
local function space(g,C)
 local wall,gray,glass=C.sw(4,44),C.sw(4,33),C.sw(68,40)
 local H=96;local holes={hole(64,80,0,16,{64.05,112.05,79.95,127.95},false,true,gray),hole(64,80,16,96,{64.05,32.05,79.95,111.95},false,false,gray)}
 for _,sy in ipairs{34,50,66,82,98}do for _,sx in ipairs{10,26,42,90,106,122}do
  holes[#holes+1]=hole(sx,sx+10,128-sy-4,128-sy,{sx+.05,sy+.05,sx+9.95,sy+3.95},false,false,gray)
 end end
 -- Two source roof cells are actually walkable. The whole closed shell
 -- and its roof stay south of row1, rather than trapping a player there.
 shell(C,1,33,143,127,H,32,128,holes,wall,{10.05,34.05,19.95,37.95,4,10},{26,42,58,74,90})
 for _,xx in ipairs{2,18,34,50,82,98,114,130}do C.box(xx,1,126.7,xx+2,95,127.4,wall)end
 -- The central strip is a continuous recessed glass spine with solid
 -- mullions. Its original highlight pattern is sampled per floor.
 for sy=32,96,16 do
  local b,t=128-sy-16,128-sy
  C.box(64,b,126.9,80,b+.8,127.3,gray)
 end
 -- The same gray horizontal divisions and green piers wrap all sides.
 for y=14,94,16 do
  C.box(.7,y,33,1.3,y+1,127,gray);C.box(142.7,y,33,143.3,y+1,127,gray)
  C.box(1,y,32.7,143,y+1,33.3,gray)
 end
 for zz=38,110,24 do C.box(.7,1,zz,1.3,95,zz+2,wall);C.box(142.7,1,zz,143.3,95,zz+2,wall)end
 for xx=6,126,24 do C.box(xx,1,32.7,xx+2,95,33.3,wall)end
 roof(C,.5,32.5,143.5,127.5,H,H+3,C.sw(10,12),gray)
 -- Roof details are the native twin low ventilation drums, not Emerald's
 -- rocket, gantries or satellite dish. Each cylinder is capped underneath.
 for _,cx in ipairs{24,120}do
  local ring={};for i=0,15 do local a=i*math.pi/8;ring[#ring+1]={cx+math.cos(a)*6,103,56+math.sin(a)*6}end
  for i,a in ipairs(ring)do local b=ring[i%16+1]
   C.face({a,b,{b[1],99,b[3]},{a[1],99,a[3]}},gray,.86)
   C.face({{cx,99,56},{a[1],99,a[3]},{b[1],99,b[3]},{cx,99,56}},gray,.65)
   C.face({{cx,103,56},b,a,{cx,103,56}},C.sw(24,12))
  end
  for zz=52,60,2 do C.box(cx-4,103,zz,cx+4,103.6,zz+.7,gray)end
 end
end
local function indigo(g,C)
 local wall,green,trim,glass=C.sw(4,70),C.sw(20,20),C.sw(68,99),C.sw(84,101)
 local holes={}
 for _,sx in ipairs{29,45,61,109,125,141}do holes[#holes+1]=hole(sx,sx+6,10,42,{sx+.05,68.05,sx+5.95,77.95},false,false,trim)end
 -- The wings stop before the native tree trunks and statue cells.
 shell(C,1,.5,175,95,48,64,96,holes,wall,{26.05,65.05,30.95,78.95},{10,30},false)
 roof(C,.5,.2,175.5,95.5,48,51,C.uv(1.05,.05,174.95,63.95),trim)
 for _,xx in ipairs{1,18,38,54,120,136,156,173}do C.box(xx,0,94.8,xx+1.2,48,95.4,trim)end
 local door={hole(80,96,0,16,{80.05,96.05,95.95,111.95},false,true,trim)}
 shell(C,64,.5,112,111,56,80,112,door,trim,{26.05,65.05,30.95,78.95},{26},false,48)
 -- Central source pediment is a genuine gable with two sloping planes,
 -- closed triangular ends, underside and a finite raised ridge.
 local l,r,m,n,f=64,112,88,.5,111.5
 local function slope(a,b)
  C.face({{a[1],a[2],n},{b[1],b[2],n},{b[1],b[2],f},{a[1],a[2],f}},C.uv(1.05,.05,174.95,63.95))
 end
 slope({l,56},{m,80});slope({m,80},{r,56})
 C.face({{l,56,f},{r,56,f},{m,80,f},{l,56,f}},green)
 C.face({{r,56,n},{l,56,n},{m,80,n},{r,56,n}},green,.8)
 C.face({{l,56,n},{r,56,n},{r,56,f},{l,56,f}},trim,.65)
 -- Real stepped fascia follows the pediment instead of a diagonal card.
 for j=0,11 do
  local xx=l+j*2;local y=56+j*2
  C.box(xx,y,f-.4,xx+2,y+2,f+.2,C.sw(82,70))
  C.box(r-j*2-2,y,f-.4,r-j*2,y+2,f+.2,C.sw(82,70))
 end
 -- The source has a white chevron with a muted green inset.
 C.face({{68,57,111.52},{108,57,111.52},{88,77,111.52},{68,57,111.52}},C.sw(78,74))
 C.box(87.2,80,n,88.8,81,f,green)
 -- Orange timber siding is modeled between the slender recessed windows.
 for _,span in ipairs{{2,29},{35,45},{51,61},{112,125},{131,141},{147,174}}do
  for yy=3,44,4 do C.box(span[1],yy,94.9,span[2],yy+.6,95.25,C.sw(38,84))end
 end
 -- Four complete source tree composites become small closed ornamental
 -- trees, bounded by their blocked trunk tiles. Statue drawings stay native.
 for _,cx in ipairs{24,56,120,152}do
  C.box(cx-1.5,0,102.5,cx+1.5,9,105.5,C.sw(24,105))
  for _,tier in ipairs{{6,5.5},{10,7.5},{15,7.2},{20,6.1},{25,4.5},{29,2.5}}do
   local y,r=tier[1],tier[2]
   C.slab(cx-r,104-r,cx+r,104+r,y,y+4,C.sw(20+(y%3)*2,85),C.sw(24,89),math.min(2,r/2))
  end
 end
 -- Native recessed entrance grille is above the blue sliding doors.
 for _,xx in ipairs{64,107}do C.box(xx,0,110.8,xx+5,56,111.4,C.sw(78,99))end
 C.box(64,1,110.8,80,3,111.4,trim);C.box(96,1,110.8,112,3,111.4,trim)
 C.box(64,34,110.8,112,36,111.4,trim)
 C.box(80,17,110.8,96,30,111.4,C.sw(84,87))
 for xx=82,94,3 do C.box(xx,18,111.3,xx+.7,29,111.6,trim)end
end
function M.append(g,emit)
 local C=V.require('Gen3DepartmentStores').context(g,emit)
 local k=g.custom.landmark
 if k=='museum'then V.require('Gen3Museum').append(g,emit)elseif k=='rs_devon'then devon(g,C)
 elseif k=='rs_space'then space(g,C)elseif k=='indigo'then indigo(g,C)else error('unknown landmark '..tostring(k))end
end
return M
