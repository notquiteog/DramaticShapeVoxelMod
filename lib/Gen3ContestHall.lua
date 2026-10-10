-- Lilycove's native contest pavilion: red walls, gold pennants and a broad
-- chamfered metal roof. Source pixels provide every palette/material sample.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D=p.w,p.h
 local function uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local red,metal,white,dark,gold=sw(22,98),sw(14,24),sw(3,21),sw(6,85),sw(19,99)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 local back=math.max(18,g.bodyBack or 18);local H=32
 box(2,0,48,111,H,back,red);box(64,0,110,111,H,back,red)
 local doorway=H*20/24
 box(48,doorway,64,111,H,back,red);box(48,0,64,back+1,doorway,back,red)
 local function panel(a,b,t,d,zz)
  face({{a,(112-t)*H/24,zz},{b,(112-t)*H/24,zz},{b,(112-d)*H/24,zz},{a,(112-d)*H/24,zz}},uv(a+.05,t+.05,b-.05,d-.05))
 end
 panel(2,48,88,112,111.02);panel(64,110,88,112,111.02)
 panel(48,64,88,92,111.02);panel(48,64,92,112,110.05)
 for _,xx in ipairs({48,64})do box(xx-.4,0,xx+.4,111,doorway,110,metal)end
 -- Bounded corner/side pilasters and horizontal warm bands repeat the
 -- original pavilion language without putting source perspective on a wall.
 for zz=back,104,24 do
  box(1.7,0,2.2,zz+3,H,zz,dark);box(109.8,0,110.3,zz+3,H,zz,dark)
 end
 for xx=4,104,24 do box(xx,0,xx+3,back+.2,H,back-.3,dark)end
 for _,yy in ipairs({2,7,12})do
  box(1.6,yy,2.3,111,yy+1,back,gold);box(109.7,yy,110.4,111,yy+1,back,gold)
  box(2,yy,110,back+.3,yy+1,back-.4,gold)
 end
 -- Actual front pennants receive shallow closed relief.
 local function ribbon(ax,ay,bx,by)
  local dx,dy=bx-ax,by-ay;local len=math.sqrt(dx*dx+dy*dy);local ox,oy=-dy/len*.45,dx/len*.45
  local a={{ax+ox,ay+oy,111.08},{bx+ox,by+oy,111.08},{bx-ox,by-oy,111.08},{ax-ox,ay-oy,111.08}}
  local b={};for i,q in ipairs(a)do b[i]={q[1],q[2],111.5}end
  face(b,white);face({a[4],a[3],a[2],a[1]},gold,.8)
  for i=1,4 do local j=i%4+1;face({a[i],a[j],b[j],b[i]},gold,.9)end
 end
 for _,cx in ipairs({19,27,35,77,85,93})do
  ribbon(cx-2,31,cx,26);ribbon(cx,26,cx+2,31)
 end
 -- Eight-sided roof shell: bevel ring, closed underside, and opaque top.
 local outer={{6,8},{106,8},{112,14},{112,106},{106,112},{6,112},{0,106},{0,14}}
 local inner={{8,10},{104,10},{110,16},{110,104},{104,110},{8,110},{2,104},{2,16}}
 local center={56,38,60}
 for i,a in ipairs(outer)do
  local j=i%8+1;local b,c,d=outer[j],inner[j],inner[i]
  face({{a[1],32,a[2]},{b[1],32,b[2]},{b[1],35,b[2]},{a[1],35,a[2]}},dark,.9)
  face({{a[1],35,a[2]},{b[1],35,b[2]},{c[1],38,c[2]},{d[1],38,d[2]}},white)
  face({center,{d[1],38,d[2]},{c[1],38,c[2]},center},metal)
  face({{56,32,60},{b[1],32,b[2]},{a[1],32,a[2]},{56,32,60}},dark,.68)
 end
 -- The native round fasteners have closed faceted heads, not roof spikes.
 for zz=20,100,10 do for xx=12,100,8 do
  for i=0,7 do
   local a,b=i*math.pi/4,(i+1)*math.pi/4
   local p1={xx+math.cos(a),38,zz+math.sin(a)};local p2={xx+math.cos(b),38,zz+math.sin(b)}
   local q1={xx+math.cos(a)*.65,38.7,zz+math.sin(a)*.65};local q2={xx+math.cos(b)*.65,38.7,zz+math.sin(b)*.65}
   face({p1,p2,q2,q1},metal,.9)
   face({{xx,38.7,zz},q1,q2,{xx,38.7,zz}},white)
  end
 end end
end
return M
