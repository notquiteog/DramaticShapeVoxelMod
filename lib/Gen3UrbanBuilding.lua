-- Rustboro's flat-roof stone residences. Rear roof artwork projects over a
-- native walking row: walls and roof stop at its blocked boundary.
local M={}
function M.append(g,p,emit)
 local W,D,H=g.width*16,g.depth*16,p.wall;local r=g.custom
 local x,z=g.cx*16,g.cy*16;local atlasW=W*2+4
 local function uv(a,b,c,d)return {{a/atlasW,b/D},{c/atlasW,b/D},{c/atlasW,d/D},{a/atlasW,d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local wall,trim=sw(W*2,0),sw(W*2+2,0)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 local back=math.max(18,g.bodyBack or 18);local front=D-1;local roofBack=back-2
 -- Closed rear/sides and subdivided facade keep door reveals empty.
 box(2,0,W-2,back+1,H,back,wall)
 box(2,0,3,front,H,back,wall);box(W-3,0,W-2,front,H,back,wall)
 local cursor=2
 local function panel(a,b,top,bottom,zz)
  if b<=a then return end
  face({{a,D-top,zz},{b,D-top,zz},{b,D-bottom,zz},{a,D-bottom,zz}},uv(a+.05,top+.05,b-.05,bottom-.05))
 end
 for _,o in ipairs(r.openings or {})do if o.door then
  panel(cursor,o[1],48,D,front+.02);panel(o[1],o[3],48,o[2],front+.02)
  panel(o[1],o[3],o[2],D,front-.95)
  for _,xx in ipairs({o[1],o[3]})do box(xx-.35,0,xx+.35,front,D-o[2],front-1,trim)end
  box(o[1],D-o[2],o[3],front,D-o[2]+.8,front-1,trim)
  cursor=o[3]
 end end
 panel(cursor,W-2,48,D,front+.02)
 -- Modest sill/plinth bands and an opaque closed roof overhang.
 box(1.5,0,W-1.5,front+.4,1.5,back,trim)
 box(0,H,W,front+1,H+2,roofBack,trim)
 for zz=roofBack+2,front-3,16 do
  local edge=math.min(zz+16,front-2)
  face({{2,H+2.03,zz},{W-2,H+2.03,zz},{W-2,H+2.03,edge},{2,H+2.03,edge}},uv(W+6.05,16.05,W*2-6.05,16+edge-zz-.05))
 end
 for _,q in ipairs({{1,roofBack+1,W-1,roofBack+2},{1,front-2,W-1,front-1},{1,roofBack+2,2,front-2},{W-2,roofBack+2,W-1,front-2}})do
  box(q[1],H+2,q[3],q[4],H+3,q[2],wall)
 end
 -- Repeat the actual native window panel on unseen elevations. Each
 -- window receives a shallow projecting stone sill, not a pasted side card.
 local a,b,c,d=unpack(r.window)
 local window=uv(a+.05,b+.05,c-.05,d-.05)
 for yy=10,H-12,24 do
  for zz=back+8,front-12,24 do
   face({{1.97,yy+14,zz},{1.97,yy+14,zz+12},{1.97,yy,zz+12},{1.97,yy,zz}},window,.87)
   face({{W-1.97,yy+14,zz+12},{W-1.97,yy+14,zz},{W-1.97,yy,zz},{W-1.97,yy,zz+12}},window,.92)
   box(1.4,yy-.6,2.1,zz+12,yy+.3,zz,wall)
   box(W-2.1,yy-.6,W-1.4,zz+12,yy+.3,zz,wall)
  end
  for xx=10,W-14,24 do
   face({{xx+12,yy+14,back-.03},{xx,yy+14,back-.03},{xx,yy,back-.03},{xx+12,yy,back-.03}},window,.8)
   box(xx,yy-.6,xx+12,back+.1,yy+.3,back-.6,wall)
  end
 end
 if r.chimney then
  -- Native roof ventilation cabinet, with a recessed gray grille and cap.
  local left=W-22;local rear=20;local top=H+13
  box(left,H+2,W-4,rear+14,top,rear,wall)
  face({{left+1,top-1,rear+14.03},{W-5,top-1,rear+14.03},{W-5,H+4,rear+14.03},{left+1,H+4,rear+14.03}},uv(W-20.05,3.05,W-5.05,14.95))
  box(left-.5,top,W-3.5,rear+14.5,top+1,rear-.5,trim)
 end
end
return M
