-- Source-specific department-store architecture. Only identifier recipes and
-- dimensions ship here; textures come from each edition's live native atlas.
local M={}
function M.profile(g)
 local h=g.depth*16;local celadon=g.custom.store=='celadon'
 return {w=g.width*16,h=h,back=0,front=h-1,wall=celadon and 96 or 112,
  roofEnd=celadon and 64 or 0,wallTop=celadon and 64 or 0,wallBottom=h,
  doorTop=h-16,doorBottom=h,doorHeight=16,projection=0,bevel=0}
end
function M.doorSurface(g,tx,ty)
 for _,o in ipairs(g.custom.openings)do if o.door then
  local sx,sy=(tx-g.cx)*16,(ty-g.cy)*16
  if sx<o[3] and sx+16>o[1] and sy<o[4] and sy+16>o[2]then
   local x,z=g.cx*16,g.cy*16;local D=g.depth*16
   return {w=o[3]-o[1],h=o[4]-o[2],sourceX=x+o[1],sourceY=z+o[2],base=g.groundHeight or 0,
    vertices={{x+o[1],D-o[2],z+D-1.95},{x+o[3],D-o[2],z+D-1.95},
     {x+o[3],D-o[4],z+D-1.95},{x+o[1],D-o[4],z+D-1.95}}}
  end
 end end
end
local function context(g,emit)
 local W,D=g.width*16,g.depth*16;local x,z=g.cx*16,g.cy*16
 local C={W=W,D=D,back=g.custom.store=='celadon' and 18 or .5,front=D-1}
 function C.uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 function C.sw(a,b)return C.uv(a+.5,b+.5,a+.5,b+.5)end
 function C.face(v,t,s)
  local out={};for i,p in ipairs(v)do out[i]={x+p[1],p[2],z+p[3]}end;emit(out,t,s or 1)
 end
 function C.box(l,b,n,r,h,f,t)
  C.face({{l,h,n},{r,h,n},{r,h,f},{l,h,f}},t)
  C.face({{l,b,f},{r,b,f},{r,b,n},{l,b,n}},t,.65)
  C.face({{l,h,f},{r,h,f},{r,b,f},{l,b,f}},t)
  C.face({{r,h,n},{l,h,n},{l,b,n},{r,b,n}},t,.8)
  C.face({{l,h,n},{l,h,f},{l,b,f},{l,b,n}},t,.84)
  C.face({{r,h,f},{r,h,n},{r,b,n},{r,b,f}},t,.9)
 end
 -- Convex closed octagonal slabs have both undersides and all bevel faces.
 function C.slab(l,n,r,f,b,h,tex,edge,cut)
  local k=cut or 2;local ps={{l+k,n},{r-k,n},{r,n+k},{r,f-k},{r-k,f},{l+k,f},{l,f-k},{l,n+k}}
  for i,a in ipairs(ps)do local v=ps[i%8+1];local cx,cz=(l+r)/2,(n+f)/2
   C.face({{cx,h,cz},{a[1],h,a[2]},{v[1],h,v[2]},{cx,h,cz}},tex)
   C.face({{cx,b,cz},{v[1],b,v[2]},{a[1],b,a[2]},{cx,b,cz}},edge,.65)
   C.face({{a[1],h,a[2]},{a[1],b,a[2]},{v[1],b,v[2]},{v[1],h,v[2]}},edge,.85)
  end
 end
 -- Each elevation is cut around actual recessed apertures, rather than
 -- covering a solid box with glass cards. All reveals meet the inset pane.
 function C.elevation(a,b,H,holes,wall,native)
  local dx,dz=b[1]-a[1],b[2]-a[2];local length=math.sqrt(dx*dx+dz*dz)
  local ax,az=dx/length,dz/length;local nx,nz=-az,ax
  local function draw(v,t,s)
   local q={};for i,p in ipairs(v)do q[i]={a[1]+ax*p[1]+nx*p[3],p[2],a[2]+az*p[1]+nz*p[3]}end;C.face(q,t,s)
  end
  local xs,ys={0,length},{0,H}
  for u=16,length-1,16 do xs[#xs+1]=u end
  for y=16,H-1,16 do ys[#ys+1]=y end
  for _,o in ipairs(holes)do xs[#xs+1]=o.l;xs[#xs+1]=o.r;ys[#ys+1]=o.b;ys[#ys+1]=o.t end
  table.sort(xs);table.sort(ys)
  for j=1,#ys-1 do for i=1,#xs-1 do
   local l,r,lo,hi=xs[i],xs[i+1],ys[j],ys[j+1]
   if r>l and hi>lo then local hidden=false
    for _,o in ipairs(holes)do if l>=o.l and r<=o.r and lo>=o.b and hi<=o.t then hidden=true;break end end
    if not hidden then
     local tex=type(native)=='function'and native(l,lo,r,hi)or native and C.uv(a[1]+l+.02,D-hi+.02,a[1]+r-.02,D-lo-.02)or wall
     draw({{l,hi,0},{r,hi,0},{r,lo,0},{l,lo,0}},tex)
    end
   end
  end end
  for _,o in ipairs(holes)do
   local l,r,lo,hi=o.l,o.r,o.b,o.t;local dep=1.1
   local top={{l,hi},{r,hi}}
   -- Emerald's native window arch has two stepped shoulders. Fill its
   -- square bounding-box corners with wall, then close the stepped reveal.
   if o.arch then
    top={{l,hi-2},{l+2,hi-2},{l+2,hi-1},{l+3,hi-1},{l+3,hi},
     {r-3,hi},{r-3,hi-1},{r-2,hi-1},{r-2,hi-2},{r,hi-2}}
    for _,s in ipairs{{l,l+2,hi-2},{l+2,l+3,hi-1},{r-3,r-2,hi-1},{r-2,r,hi-2}}do
     draw({{s[1],hi,0},{s[2],hi,0},{s[2],s[3],0},{s[1],s[3],0}},wall)
    end
   end
   local source=o.source
   local function uv(lx,y)
    return {(source[1]+(lx-l)/(r-l)*(source[3]-source[1]))/(W*2+4),
     (source[2]+(hi-y)/(hi-lo)*(source[4]-source[2]))/D}
   end
   -- Split glazing into strips so even stepped arch corners have no hidden
   -- rectangle bridging the original wall. Door animation uses the same inset.
   for i=1,#top-1 do local u,v=top[i],top[i+1]
    if v[1]>u[1]then local h=math.min(u[2],v[2])
     draw({{u[1],h,-dep},{v[1],h,-dep},{v[1],lo,-dep},{u[1],lo,-dep}},
      {uv(u[1],h),uv(v[1],h),uv(v[1],lo),uv(u[1],lo)},o.door and 1 or 64.92)
    end
   end
   local outline={{l,lo},{l,top[1][2]}}
   for i=2,#top do outline[#outline+1]=top[i]end;outline[#outline+1]={r,lo}
   for i,u in ipairs(outline)do local v=outline[i%#outline+1]
    draw({{u[1],u[2],0},{v[1],v[2],0},{v[1],v[2],-dep},{u[1],u[2],-dep}},o.trim or wall,.82)
   end
  end
 end
 return C
end
local function lilycove(g,C)
 local W,D,back,front=C.W,C.D,C.back,C.front;local H=112
 local wall,trim,white=C.sw(19,20),C.sw(27,35),C.sw(66,71)
 local sill=C.sw(28,46);local roof=C.sw(19,18);white=C.sw(W+12,91)
 local holes={};local nativeWindows={}
 for _,sy in ipairs{0,32,64}do for _,sx in ipairs{26,66,106}do
  if not(sy==64 and sx==66)then
   local o={l=sx,r=sx+12,b=D-sy-14,t=D-sy,source={sx+.05,sy+.05,sx+11.95,sy+13.95},arch=not g.custom.squareWindows,trim=trim}
   holes[#holes+1]=o;nativeWindows[#nativeWindows+1]=o
  end
 end end
 for _,xx in ipairs{10,26,106,122}do holes[#holes+1]={l=xx,r=xx+12,b=8,t=15,source={xx+.05,97.05,xx+11.95,103.95},trim=C.sw(10,98)}end
 for _,o in ipairs(g.custom.openings)do if o.door then holes[#holes+1]={l=o[1],r=o[3],b=D-o[4],t=D-o[2],source=o,door=true}end end
 C.elevation({.5,front},{W-.5,front},H,(function()
  local out={};for _,o in ipairs(holes)do local q={};for k,v in pairs(o)do q[k]=v end;q.l=q.l-.5;q.r=q.r-.5;out[#out+1]=q end;return out
 end)(),wall,true)
 -- Native blank cladding is tiled on the unseen elevations. Matching window
 -- vocabulary/levels continue around the shell; placement is interpreted.
 local side={}
 for _,sy in ipairs{0,32,64}do for u=12,front-back-22,26 do side[#side+1]={l=u,r=u+12,b=D-sy-14,t=D-sy,source={26.05,32.05,37.95,45.95},arch=not g.custom.squareWindows,trim=trim}end end
 local function cladding(l,lo,r,hi)
  local u,v=l%16,(H-hi)%16
  return C.uv(16+u+.02,16+v+.02,16+u+r-l-.02,16+v+hi-lo-.02)
 end
 C.elevation({.5,back},{.5,front},H,side,wall,cladding)
 C.elevation({W-.5,front},{W-.5,back},H,side,wall,cladding)
 local rear={};for _,o in ipairs(nativeWindows)do rear[#rear+1]={l=W-.5-o.r,r=W-.5-o.l,b=o.b,t=o.t,source=o.source,arch=o.arch,trim=trim}end
 C.elevation({W-.5,back},{.5,back},H,rear,wall,cladding)
 -- Thin structural ribs and low sills use native colors, not stretched
 -- diagonal window pixels. No roof/volume extends beyond the source cells.
 for _,xx in ipairs{1,15,47,95,127,141}do C.box(xx-.35,0,front-.3,xx+.35,H,front+.3,wall)end
 for _,o in ipairs(nativeWindows)do C.box(o.l-.3,o.b-.8,front-.1,o.r+.3,o.b,front+.45,sill)end
 -- Separate raised Poké Ball plaque, with uninterrupted original artwork.
 C.box(52,38,front-.15,92,64,front+.3,wall)
 C.face({{52,64,front+.32},{92,64,front+.32},{92,38,front+.32},{52,38,front+.32}},C.uv(W+52.05,64.05,W+91.95,79.95))
 -- Four source orange/white shop awnings, each a closed sloping canopy.
 for _,xx in ipairs{10,26,106,122}do
  local n,f=front-3.5,front+.4;local l,r=xx,xx+12;local y=20
  local tex=C.uv(W+xx+.05,90.05,W+xx+11.95,93.95)
  C.face({{l,y+2,n},{r,y+2,n},{r,y,f},{l,y,f}},tex)
  C.face({{l,y-4,f},{r,y-4,f},{r,y-4,n},{l,y-4,n}},trim,.65)
  C.face({{l,y,f},{r,y,f},{r,y-4,f},{l,y-4,f}},tex)
  C.face({{r,y+2,n},{l,y+2,n},{l,y-4,n},{r,y-4,n}},trim,.8)
  C.face({{l,y+2,n},{l,y,f},{l,y-4,f},{l,y-4,n}},trim,.84)
  C.face({{r,y,f},{r,y+2,n},{r,y-4,n},{r,y-4,f}},trim,.9)
 end
 -- Recessed entrance, source sign fascia and canopy; no solid slab crosses it.
 for _,xx in ipairs{56,80}do C.box(xx,0,front-1.3,xx+8,20,front+.1,trim)end
 C.box(56,18,front-3,88,22,front+.45,trim)
 C.face({{56,22,front+.47},{88,22,front+.47},{88,18,front+.47},{56,18,front+.47}},C.uv(56.05,92.05,87.95,95.95))
 -- The source roof lies beyond the north map edge. This quiet closed cap
 -- continues its own blue cladding; it adds no invented rooftop equipment.
 C.slab(.2,.2,W-.2,D-.2,H,H+1.2,roof,trim,1.5)
 C.box(1.5,H+1.2,1.5,W-1.5,H+2.2,3,wall)
 C.box(1.5,H+1.2,D-3,W-1.5,H+2.2,D-1.5,wall)
 C.box(1.5,H+1.2,3,3,H+2.2,D-3,wall);C.box(W-3,H+1.2,3,W-1.5,H+2.2,D-3,wall)
 C.face({{.5,0,front},{W-.5,0,front},{W-.5,0,back},{.5,0,back}},wall,.65)
end
local function celadon(g,C)
 local W,D,back,front=C.W,C.D,C.back,C.front;local H=96
 local stone,purple,gold,glass=C.sw(36,76),C.sw(2,68),C.sw(63,95),C.sw(68,85)
 local gray,roofDark,green,yellow,white=C.sw(10,20),C.sw(5,20),C.sw(34,15),C.sw(52,20),C.sw(35,8)
 local path={{2,front-9},{8,front},{32,front},{48,front},{48,front-9},{54,front},{90,front},{96,front-9},{96,front},{112,front},{136,front},{142,front-9}}
 for i=1,#path-1 do local a,b=path[i],path[i+1]
  local length=math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)
  local pillar=i==3 or i==9;local gap=i==4 or i==8;local holes={}
  if pillar then
   local o=g.custom.openings[i==3 and 1 or 2]
   holes={{l=o[1]-a[1],r=o[3]-a[1],b=0,t=16,source=o,door=true,trim=purple}}
  elseif not gap then
   for level=0,4 do holes[#holes+1]={l=1,r=length-1,b=level*16+2,t=level*16+14,source={64.05,82.05,79.95,93.95},trim=gold}end
  end
  C.elevation(a,b,H,holes,pillar and stone or gold,pillar and true or function(_,lo)return lo>=80 and purple or gold end)
  if not pillar and not gap then
   local dx,dz=(b[1]-a[1])/length,(b[2]-a[2])/length
   local function point(u,y,d)return {a[1]+dx*u-dz*d,y,a[2]+dz*u+dx*d}end
   local near,far=-1.2,.3;local low,high=84,91
   local pale=C.sw(64,75)
   C.face({point(0,high,near),point(length,high,near),point(length,high,far),point(0,high,far)},pale)
   C.face({point(0,low,far),point(length,low,far),point(length,low,near),point(0,low,near)},gold,.65)
   C.face({point(0,high,far),point(length,high,far),point(length,low,far),point(0,low,far)},pale)
   C.face({point(length,high,near),point(0,high,near),point(0,low,near),point(length,low,near)},gold,.8)
   C.face({point(0,high,near),point(0,high,far),point(0,low,far),point(0,low,near)},gold,.84)
   C.face({point(length,high,far),point(length,high,near),point(length,low,near),point(length,low,far)},gold,.9)
  end
 end
 -- Side and rear elevations continue the same five glass storeys, separated
 -- by real stone piers and gold spandrels; every window has a closed reveal.
 local function side(a,b)
  local L=math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2);local hs={}
  for u=5,L-22,26 do for level=0,4 do hs[#hs+1]={l=u,r=u+18,b=level*16+2,t=level*16+14,source={64.05,82.05,79.95,93.95},trim=gold}end end
  C.elevation(a,b,H,hs,purple)
 end
 side({2,back},{2,front-9});side({142,front-9},{142,back});side({142,back},{2,back})
 -- Native two red-tiled white piers stand independently of their recessed
 -- glass doors. Keep all tile relief within the blocked facade row.
 local red=C.sw(36,74)
 for _,l in ipairs{32,96}do
  for y=49,85,4 do for _,xx in ipairs{l+3,l+11}do C.box(xx,y,front,xx+2,y+2,front+.18,red)end end
  C.box(l,94,front-.2,l+16,95,front+.25,gold)
  for _,xx in ipairs{l,l+14.5}do C.box(xx,0,front-.1,xx+1.5,32,front+.2,purple)end
  -- Closed entry canopy carries the native striped valance as one panel.
  C.box(l+1,18,front-3.5,l+15,20,front+.4,white)
  C.face({{l+1,20,front+.42},{l+15,20,front+.42},{l+15,16,front+.42},{l+1,16,front+.42}},C.uv(l+1.05,138.05,l+14.95,143.95))
 end
 -- Purple chamfered cornice and complete grey roof deck with real slotted
 -- recesses. Neither the cornice nor terrace enters the native rear lane.
 C.slab(.2,back-1,W-.2,D-.2,H,H+2,purple,purple,3)
 C.slab(1.2,back,W-1.2,D-1.2,H+2,H+2.6,gray,white,3)
 for _,l in ipairs{5,W-29}do
  C.box(l,H+2.6,back+8,l+24,H+2.8,front-9,roofDark)
  for xx=l,l+23,3 do C.box(xx,H+2.8,back+8,xx+1.5,H+3.8,front-9,gray)end
  C.box(l,H+2.8,back+7,l+24,H+3.8,back+8,gray)
  C.box(l,H+2.8,front-9,l+24,H+3.8,front-8,gray)
 end
 local l,r,n,f=34,110,back+8,front-20
 C.box(l,H+2.6,n,r,H+8,f,green)
 C.box(l+1,H+8,n+1,r-1,H+8.5,f-1,yellow)
 for xx=l+4,r-6,9 do
  C.box(xx,H+3.4,f,xx+5,H+5.3,f+.12,glass)
 end
 -- White/green terrace rails and posts are the actual native roof detail.
 for _,zz in ipairs{n,f}do
  for _,y in ipairs{H+10,H+13}do C.box(l,y,zz-.5,r,y+.7,zz+.5,white)end
  for xx=l,r,8 do C.box(xx-.5,H+8.5,zz-.6,xx+.5,H+13.7,zz+.6,green)end
 end
 for _,xx in ipairs{l,r}do
  for _,y in ipairs{H+10,H+13}do C.box(xx-.5,y,n,xx+.5,y+.7,f,white)end
  for zz=n+8,f-1,8 do C.box(xx-.6,H+8.5,zz-.5,xx+.6,H+13.7,zz+.5,green)end
 end
 C.face({{2,0,front-9},{142,0,front-9},{142,0,back},{2,0,back}},purple,.65)
 -- Close the underside below the chamfered facade bays and piers.
 for i=1,#path-1 do local a,b=path[i],path[i+1]
  C.face({{a[1],0,a[2]},{b[1],0,b[2]},{b[1],0,front-9},{a[1],0,front-9}},purple,.65)
 end
end
function M.append(g,emit)
 local C=context(g,emit)
 if g.custom.store=='celadon'then celadon(g,C)else lilycove(g,C)end
end
return M
