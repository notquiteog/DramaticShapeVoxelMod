-- Original architectural reconstruction of Lilycove's museum. The native
-- drawing identifies the placement; it is deliberately not folded onto walls.
-- The three masses, glazed bays and roof lanterns use an authored material
-- atlas. No reference image or imported game pixels are distributed.
local V=...
local M={}
function M.prepare(cells,g)return V.require('Gen3MuseumApproach').prepare(cells,g)end
function M.material(g)
 local data=love.image.newImageData(g.width*32+4,g.depth*16)
 -- Quiet ceramic, slate, blue glazing, white frames and pale brass. Material
 -- coordinates stay compatible with the shared civic mesh/light collector.
 local colors={{.88,.93,.96},{.27,.32,.40},{.42,.68,.85},{.98,.99,1},{.86,.83,.53}}
 for y=0,g.depth*16-1 do for x=0,g.width*32+3 do
  local i=math.min(5,math.floor(x/32)+1);local c=colors[i];local k=1
  if i==1 then
   k=(x%16==0 or y%16==0)and .96 or 1
  elseif i==2 then
   k=y%12==0 and .87 or 1
  elseif i==3 then
   k=.83+.17*(1-y%32/31)
   if x%32>=5 and x%32<=7 then k=k+.11 end
  end
  data:setPixel(x,y,math.min(1,c[1]*k),math.min(1,c[2]*k),math.min(1,c[3]*k),1)
 end end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
 return image,nil,nil
end
function M.append(g,emit)
 local C=V.require('Gen3DepartmentStores').context(g,emit)
 local wall,slate,glass,white,gold=C.sw(12,12),C.sw(44,8),C.uv(64.5,.5,95.5,31.5),C.sw(108,12),C.sw(140,12)
 local pane={64.5,.5,95.5,31.5}
 local function aperture(l,r,b,t,door)return{l=l,r=r,b=b,t=t,source=pane,trim=white,door=door}end
 local function elevation(a,b,H,holes,floor)
  C.elevation(a,b,H,holes,wall,function(l,lo,r,hi)
   return C.uv(1+l%16,1+(H-hi)%16,1+l%16+r-l,1+(H-hi)%16+hi-lo)
  end,floor)
 end
 local function windows(L,H,central)
  local out={};local levels=central and {42,57,72}or{18,38}
  local width=central and 9 or 13
  local count=central and 3 or math.max(1,math.floor((L-8)/17))
  local spacing=(L-10)/count
  for i=0,count-1 do local x=5+i*spacing+(spacing-width)/2
   for _,y in ipairs(levels)do out[#out+1]=aperture(x,x+width,y,math.min(y+(central and 9 or 12),H-5))end
  end
  return out
 end
 local function frames(a,b,holes)
  local dx,dz=b[1]-a[1],b[2]-a[2];local L=math.sqrt(dx*dx+dz*dz);dx,dz=dx/L,dz/L
  -- Closed narrow frame bars; each follows its own wall plane, including
  -- side and rear elevations. Glass is genuinely behind the reveals.
  local function bar(u,v,lo,hi)
   local function p(x,y,d)return{a[1]+dx*x-dz*d,y,a[2]+dz*x+dx*d}end
   local q={p(u,hi,.22),p(v,hi,.22),p(v,lo,.22),p(u,lo,.22)}
   C.face(q,white)
   C.face({p(u,hi,-.25),p(v,hi,-.25),p(v,hi,.22),p(u,hi,.22)},white)
   C.face({p(u,lo,.22),p(v,lo,.22),p(v,lo,-.25),p(u,lo,-.25)},white,.7)
   C.face({p(u,hi,-.25),p(u,hi,.22),p(u,lo,.22),p(u,lo,-.25)},white,.85)
   C.face({p(v,hi,.22),p(v,hi,-.25),p(v,lo,-.25),p(v,lo,.22)},white,.85)
   C.face({p(v,hi,-.25),p(u,hi,-.25),p(u,lo,-.25),p(v,lo,-.25)},white,.8)
  end
  for _,o in ipairs(holes)do
   bar(o.l-.55,o.l,math.max(0,o.b-.55),o.t+.55);bar(o.r,o.r+.55,math.max(0,o.b-.55),o.t+.55)
   bar(o.l,o.r,o.t,o.t+.55);if not o.door then bar(o.l,o.r,o.b-.55,o.b)end
   if not o.door and o.r-o.l>11 then bar((o.l+o.r)/2-.35,(o.l+o.r)/2+.35,o.b,o.t)end
  end
 end
 local function face(a,b,H,holes,floor)elevation(a,b,H,holes,floor);frames(a,b,holes)end
 local function roof(l,n,r,f,H)
  C.slab(l,n,r,f,H,H+2,white,wall,1)
  -- Narrow parapet surrounds a quiet blue-grey roof deck.
  C.box(l+2,H+2,n+2,r-2,H+2.2,f-2,slate)
  for _,z in ipairs{n+1,f-2}do C.box(l+1,H+2,z,r-1,H+3,z+1,white)end
  for _,x in ipairs{l+1,r-2}do C.box(x,H+2,n+2,x+1,H+3,f-2,white)end
  -- Raised pitched skylights: glass slopes, two closed end triangles,
  -- underside and structural edge strips. No flat roof-pattern projection.
  local count=3;local gap=3;local width=(r-l-12-gap*(count-1))/count
  for i=0,count-1 do
   local x=l+6+i*(width+gap);local q=x+width;local m=(x+q)/2
   local near,far=n+7,f-7;local b,t=H+2.3,H+5.4
   C.face({{x,b,near},{m,t,near},{m,t,far},{x,b,far}},glass)
   C.face({{m,t,near},{q,b,near},{q,b,far},{m,t,far}},glass)
   C.face({{x,b,far},{q,b,far},{q,b,near},{x,b,near}},slate,.65)
   C.face({{x,b,near},{q,b,near},{m,t,near},{x,b,near}},glass,.82)
   C.face({{q,b,far},{x,b,far},{m,t,far},{q,b,far}},glass)
   for _,xx in ipairs{x,q-.6}do C.box(xx,b,near,xx+.6,b+.7,far,white)end
   C.box(m-.3,t,near,m+.3,t+.45,far,white)
   -- The crossbars follow both actual slopes rather than floating at ridge.
   for z=near,far,12 do
    for _,seg in ipairs{{x,b,m,t},{m,t,q,b}}do
     local a,b,ya,yb=seg[1],seg[3],seg[2]+.08,seg[4]+.08
     C.face({{a,ya+.3,z},{b,yb+.3,z},{b,yb+.3,z+.65},{a,ya+.3,z+.65}},white)
     C.face({{a,ya,z+.65},{b,yb,z+.65},{b,yb,z},{a,ya,z}},white,.65)
     C.face({{a,ya+.3,z+.65},{b,yb+.3,z+.65},{b,yb,z+.65},{a,ya,z+.65}},white)
     C.face({{b,yb+.3,z},{a,ya+.3,z},{a,ya,z},{b,yb,z}},white,.8)
     C.face({{a,ya+.3,z},{a,ya+.3,z+.65},{a,ya,z+.65},{a,ya,z}},white,.84)
     C.face({{b,yb+.3,z+.65},{b,yb+.3,z},{b,yb,z},{b,yb,z+.65}},white,.9)
    end
   end
  end
 end
 local function shell(l,n,r,f,H,central)
  local front=windows(r-l,H,central)
  if central then front[#front+1]=aperture(64-l,96-l,0,24,true)end
  face({l,f},{r,f},H,front)
  face({l,n},{l,f},H,windows(f-n,H,central))
  face({r,f},{r,n},H,windows(f-n,H,central))
  face({r,n},{l,n},H,windows(r-l,H,central))
  C.face({{l,0,f},{r,0,f},{r,0,n},{l,0,n}},slate,.65)
  roof(l-.2,n-.2,r+.2,f+.2,H)
  -- Low slate base plinth is divided at the real entrance, never boxed
  -- across it. Narrow corner piers are structural volumes with gold caps.
  C.box(l-.15,0,n-.15,l+.65,10,f+.15,slate);C.box(r-.65,0,n-.15,r+.15,10,f+.15,slate)
  C.box(l,0,n-.15,r,10,n+.65,slate)
  if central then
   C.box(l,0,f-.5,64,10,f+.15,slate);C.box(96,0,f-.5,r,10,f+.15,slate)
  else C.box(l,0,f-.5,r,10,f+.15,slate)end
  for _,xx in ipairs{l+.4,r-3.4}do
   C.box(xx,10,f-.5,xx+3,H+1,f+.7,white)
   C.box(xx-.3,H-3,f-.7,xx+3.3,H+1.5,f+.8,gold)
  end
 end
 -- Closed foundations meet the lower path even though the entry sits on
 -- its raised terrace. Never extend these volumes into native walking cells.
 local depth=g.foundationDepth or 0
 if depth>0 then
  C.box(1,-depth,33,48,0,111,slate);C.box(112,-depth,33,159,0,111,slate)
  C.box(48.5,-depth,33,111.5,0,95,slate)
 end
 -- Both projected roof rows are walkable in the original map. All geometry,
 -- even skylights, begins inside the native blocked row at z32.
 shell(1,33,48,111,54,false);shell(112,33,159,111,54,false)
 shell(48.5,33,111.5,95,84,true)
 -- Tall white articulated entrance piers stand beside the native passage.
 -- Their feet may extend into row6 only inside its blocked flank cells.
 for _,xx in ipairs{49,106}do
  C.box(xx,0,94,xx+5,82,110.8,wall)
  C.box(xx-.4,77,93.8,xx+5.4,82,111,gold)
  C.box(xx+.7,10,110.8,xx+4.3,74,111.2,white)
 end
 -- Low decorative fascia from the reference: inset brass panels, no text
 -- or invented oversized sign. Every panel has a closed backing and frame.
 C.box(59,28,94.8,101,34.5,95.55,white)
 for _,x in ipairs{62,71,80,89}do
  C.box(x,29.3,95.55,x+6.5,33.1,95.8,gold)
  C.box(x+.65,29.9,95.8,x+5.85,32.5,95.86,wall)
 end
 C.box(59,24.5,91,101,27,95.75,white)
end
return M
