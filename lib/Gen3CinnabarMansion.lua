-- The mansion's three native dormers and checkerboard canopy become closed
-- roof volumes. The entrance recess stays inside the original blocked row.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D=p.w,p.h
 local function uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local brown,gold,trim,glass=sw(6,10),sw(5,36),sw(4,28),uv(20,16,28,24)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 box(2,0,40,63,72,1,gold);box(72,0,110,63,72,1,gold)
 box(40,0,48,52,72,1,gold);box(64,0,72,52,72,1,gold)
 box(48,22.5,64,52,72,1,gold);box(48,0,64,2,22.5,1,gold)
 local function panel(a,b,t,d,zz)
  face({{a,(64-t)*2.25,zz},{b,(64-t)*2.25,zz},{b,(64-d)*2.25,zz},{a,(64-d)*2.25,zz}},uv(a+.03,t+.03,b-.03,d-.03))
 end
 panel(2,40,32,64,63.03);panel(72,110,32,64,63.03)
 panel(40,48,32,64,52.03);panel(64,72,32,64,52.03)
 panel(48,64,32,54,52.03);panel(48,64,54,64,51.05)
 -- Native cornices and windows continue along the back and end walls.
 for _,yy in ipairs({3,36,69})do
  box(1.7,yy,2.2,63,yy+2,1,brown);box(109.8,yy,110.3,63,yy+2,1,brown)
  box(2,yy,110,1.2,yy+2,.7,brown)
 end
 for _,yy in ipairs({12,48})do
  for _,zz in ipairs({12,36})do
   face({{1.65,yy+16,zz},{1.65,yy+16,zz+10},{1.65,yy,zz+10},{1.65,yy,zz}},uv(12,34,20,42))
   face({{110.35,yy+16,zz+10},{110.35,yy+16,zz},{110.35,yy,zz},{110.35,yy,zz+10}},uv(12,34,20,42))
  end
  for _,xx in ipairs({12,28,80,96})do face({{xx+8,yy+16,.65},{xx,yy+16,.65},{xx,yy,.65},{xx+8,yy,.65}},uv(12,34,20,42))end
 end
 -- Closed gable over the full house, plus the three smaller native dormers.
 local function roof(a,b,back,front,base,ridge,peak,t)
  face({{a,base,back},{b,base,back},{b,peak,ridge},{a,peak,ridge}},t,.86)
  face({{a,peak,ridge},{b,peak,ridge},{b,base,front},{a,base,front}},t)
  for _,xx in ipairs({a,b})do
   face({{xx,base,back},{xx,peak,ridge},{xx,base,front},{xx,base,back}},brown,.85)
  end
  face({{a,base,front},{b,base,front},{b,base,back},{a,base,back}},trim,.7)
  box(a,base-1,b,front,base,front-1,trim);box(a,base-1,b,back+1,base,back,trim)
 end
 roof(0,112,0,64,72,14,98,brown)
 for _,cx in ipairs({24,56,88})do
  box(cx-7,80,cx+7,44,94,26,gold)
  face({{cx-4,92,44.04},{cx+4,92,44.04},{cx+4,84,44.04},{cx-4,84,44.04}},glass)
  -- Dormer roofs run back into the main slope, with solid side triangles.
  face({{cx-9,94,25},{cx,102,25},{cx,102,45},{cx-9,94,45}},brown,.9)
  face({{cx,102,25},{cx+9,94,25},{cx+9,94,45},{cx,102,45}},brown)
  face({{cx-9,94,45},{cx,102,45},{cx+9,94,45},{cx-9,94,45}},trim)
  face({{cx+9,94,25},{cx,102,25},{cx-9,94,25},{cx+9,94,25}},trim,.8)
  face({{cx-9,94,45},{cx+9,94,45},{cx+9,94,25},{cx-9,94,25}},trim,.7)
 end
 face({{40,.08,64},{72,.08,64},{72,.08,52},{40,.08,52}},sw(56,60),.85)
 -- Checkerboard source art is horizontal canopy paving, not a wall poster.
 box(40,34,72,63,38,51,trim)
 face({{40,38.03,51},{72,38.03,51},{72,38.03,63},{40,38.03,63}},uv(W+41,36,W+71,48))
 box(41,0,45,62,34,59,gold);box(67,0,71,62,34,59,gold)
end
return M
