-- Mossdeep's Space Center: native facade, two wings, central glazed spine,
-- rooftop dish and a launch display. Projected gantry cells are scenery only;
-- their native collision/elevation/warps remain untouched.
local M={}
local upper={{0x371,0x372,0x373,0x374,0x375,0x376},
 {0x379,0x37a,0x37b,0x37c,0x37d,0x37e},
 {0x381,0x382,0x383,0x384,0x385,0x386},
 {0x389,0x38a,0x38b,0x38c,0x170,0x38e},
 {0x391,0x392,0x393,0x394,0x395,0x396},
 {0x399,0x39a,0x39b,0x39c,0x39d,0x39e}}
function M.prepare(cells,g)
 for iy,row in ipairs(upper)do for ix,mid in ipairs(row)do
  local c=cells[(g.cx+ix)..':'..(g.cy-7+iy)]
  if not c or c.pair~=g.pair or c.mid~=mid then return end
 end end
 g.launchDisplay=true
 for iy,row in ipairs(upper)do for ix,mid in ipairs(row)do
  if mid~=0x170 then
   local c=cells[(g.cx+ix)..':'..(g.cy-7+iy)]
   c.shape=iy<=4 and {kind='water',ground=0x170} or {kind='interiorFloor',ground=iy==5 and 2 or 1}
  end
 end end
end
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/(p.w*2+4),b/p.h},{c/(p.w*2+4),b/p.h},{c/(p.w*2+4),d/p.h},{a/(p.w*2+4),d/p.h}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local olive,roof,gray,white,glass=sw(12,87),sw(7,24),sw(4,66),sw(101,35),sw(68,57)
 local dark=sw(104,13)
 local function face(v,t,s)
  local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end
  emit(q,t,s or 1)
 end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 -- A recessed door remains inside the native warp cell. Source facade
 -- pixels are split into the two wings and central glass, never roof cards.
 local front=127
 box(2,0,64,front,80,2,olive);box(80,0,142,front,80,2,olive)
 box(64,24,80,front,80,2,gray)
 for _,r in ipairs({{2,64},{80,142}})do
  face({{r[1],80,front+.02},{r[2],80,front+.02},{r[2],0,front+.02},{r[1],0,front+.02}},uv(r[1]+.05,48.05,r[2]-.05,127.95))
 end
 face({{64,80,front+.03},{80,80,front+.03},{80,24,front+.03},{64,24,front+.03}},uv(64.05,48.05,79.95,111.95))
 face({{64,24,front-.95},{80,24,front-.95},{80,0,front-.95},{64,0,front-.95}},uv(64.05,112.05,79.95,127.95))
 -- Native dark inset bays and pale olive piers wrap around the unseen walls.
 for _,sx in ipairs({2,142})do
  for zz=12,100,22 do for yy=36,60,24 do
   local q=sx==2 and sx-.03 or sx+.03
   face({{q,yy+13,zz},{q,yy+13,zz+10},{q,yy,zz+10},{q,yy,zz}},uv(8.05,56.05,13.95,61.95),.86)
  end end
 end
 for xx=12,120,22 do for yy=36,60,24 do
  face({{xx+10,yy+13,1.97},{xx,yy+13,1.97},{xx,yy,1.97},{xx+10,yy,1.97}},uv(8.05,56.05,13.95,61.95),.82)
 end end
 -- Native vertical piers have shallow solid relief around the glass bays.
 for _,xx in ipairs({2,18,34,50,82,98,114,130})do
  box(xx,29,xx+3,127.35,79,126.9,olive)
 end
 for zz=2,112,22 do
  box(1.65,29,2.1,zz+3,79,zz,olive)
  box(141.9,29,142.35,zz+3,79,zz,olive)
 end
 for xx=2,134,22 do box(xx,29,xx+3,2.1,79,1.65,olive)end
 -- Squared world-space cornices replace the diagonally drawn fascia ends.
 for _,r in ipairs({{1,64},{80,143}})do
  box(r[1],20,r[2],127.4,23,1,gray)
  box(r[1],25,r[2],127.3,28,1,olive)
  box(r[1],79,r[2],127.5,82,1,roof)
 end
 box(64,80,80,126,83,2,gray)
 for zz=7,111,20 do
  box(65,83,79,zz+14,84,zz,glass)
  box(64,84,80,zz+1,85,zz,gray)
 end
 -- Faceted closed launch platform and dish use actual source swatches.
 local function ring(cx,cz,r,y,n)
  local out={};for i=0,n-1 do local a=i*2*math.pi/n;out[#out+1]={cx+math.cos(a)*r,y,cz+math.sin(a)*r}end;return out
 end
 local function connect(a,b,t,s)
  for i=1,#a do local j=i%#a+1;face({a[i],a[j],b[j],b[i]},t,s)end
 end
 local function cap(a,c,t)
  for i=1,#a do face({c,a[i],a[i%#a+1],c},t)end
 end
 local pad0,pad1=ring(33,27,20,82,16),ring(33,27,20,85,16)
 connect(pad0,pad1,gray,.88)
 local dome=ring(33,27,14,93,16)
 connect(pad1,dome,gray,.9);cap(dome,{33,97,27},dark)
 local lower,rim=ring(108,27,6,84,20),ring(108,27,18,97,20)
 connect(lower,rim,white,.92)
 local inner=ring(108,27,16,96,20)
 connect(rim,inner,white);connect(inner,ring(108,27,4,86,20),gray,.83)
 cap(ring(108,27,4,86,20),{108,86,27},dark)
 box(107,86,109,28,99,26,gray)
 -- Short rooftop antenna, distinct from the launch display.
 box(134,82,136,48,90,46,white)
 if g.launchDisplay then
  -- Circular rocket body, conical shoulder/nose, blue bands and four fins.
  box(55,82,73,23,85,5,gray)
  local tiers={{85,7},{98,7},{100,6},{112,6},{115,5},{150,5},{159,3},{169,.5}}
  local rocketWhite=white
  local rocketX,rocketZ=64,14
  for i=1,#tiers-1 do
   local a,b=tiers[i],tiers[i+1]
   connect(ring(rocketX,rocketZ,a[2],a[1],12),ring(rocketX,rocketZ,b[2],b[1],12),(i==2 or i==4) and glass or rocketWhite,.97)
  end
  cap(ring(rocketX,rocketZ,.5,169,12),{rocketX,171,rocketZ},gray)
  for i=0,3 do
   local a=i*math.pi/2;local dx,dz=math.cos(a),math.sin(a);local px,pz=-dz*.9,dx*.9
   local v={{rocketX+dx*5+px,103,rocketZ+dz*5+pz},{rocketX+dx*10+px,85,rocketZ+dz*10+pz},{rocketX+dx*5+px,85,rocketZ+dz*5+pz}}
   local w={};for j,q in ipairs(v)do w[j]={q[1]-px*2,q[2],q[3]-pz*2}end
   face({v[1],v[2],v[3],v[3]},white);face({w[3],w[2],w[1],w[1]},white,.8)
   for j=1,3 do local k=j%3+1;face({v[j],w[j],w[k],v[k]},gray,.85)end
  end
  -- Gantry towers are volumetric latticework, not vertical sprite cards.
  -- Red paint is sampled from the native launch display metatiles via the
  -- spare swatches installed by material().
  local red=sw(p.w*2,2)
  local function beam(ax,ay,bx,by,zz)
   local dx,dy=bx-ax,by-ay;local n=math.sqrt(dx*dx+dy*dy)
   local ox,oy=-dy/n*.5,dx/n*.5
   local a={{ax+ox,ay+oy,zz-.45},{bx+ox,by+oy,zz-.45},{bx-ox,by-oy,zz-.45},{ax-ox,ay-oy,zz-.45}}
   local b={};for i,q in ipairs(a)do b[i]={q[1],q[2],zz+.45}end
   face(a,red);face({b[4],b[3],b[2],b[1]},red,.86)
   for i=1,4 do local j=i%4+1;face({a[i],a[j],b[j],b[i]},red,.9)end
  end
  for _,cx in ipairs({20,100})do
   box(cx-3,82,cx+3,8,85,2,gray)
   for _,dx in ipairs({-2,2})do for _,dz in ipairs({-2,2})do box(cx+dx-.6,85,cx+dx+.6,5+dz+.6,172,5+dz-.6,red)end end
   for yy=87,157,10 do
    box(cx-3,yy,cx+3,8,yy+1,2,red)
    -- Two crossed diagonal beams on each open side have finite thickness.
    for _,zz in ipairs({2.5,7.5})do
     beam(cx-2,yy+1,cx+2,yy+9,zz)
     beam(cx+2,yy+1,cx-2,yy+9,zz)
    end
   end
   box(cx-3,170,cx+3,8,174,2,gray)
   local a,b=cx<64 and cx+3 or cx-16,cx<64 and cx+16 or cx-3
   for _,yy in ipairs({145,168})do box(a,yy,b,6,yy+2,4,red)end
  end
  -- Short foreground gantry/elevator frame on the left circular platform.
  for _,cx in ipairs({29,37})do box(cx-.7,85,cx+.7,34,119,32,gray)end
  box(28,117,38,34,120,32,gray)
  box(30,89,36,33,98,29,olive)
 end
end
return M
