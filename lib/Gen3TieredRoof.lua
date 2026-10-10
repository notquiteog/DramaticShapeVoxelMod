-- Raised gold dormer above Lilycove's specialist residence. Every roof prism
-- has an underside and end caps; source perspective is not used as footprint.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D=p.w,p.h
 local function uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local gold,trim,light=sw(22,20),sw(20,36),sw(30,12)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function prism(a,b,back,front,base,rear,near,tex)
  face({{a,rear,back},{b,rear,back},{b,near,front},{a,near,front}},tex)
  face({{a,base,front},{b,base,front},{b,base,back},{a,base,back}},trim,.65)
  face({{a,near,front},{b,near,front},{b,base,front},{a,base,front}},trim,.88)
  face({{b,rear,back},{a,rear,back},{a,base,back},{b,base,back}},gold,.8)
  face({{a,rear,back},{a,near,front},{a,base,front},{a,base,back}},gold,.82)
  face({{b,near,front},{b,rear,back},{b,base,back},{b,base,front}},gold,.9)
 end
 -- Narrow strips preserve the native repeated seams and diagonal highlights
 -- rather than stretching one whole top-down drawing over a slope.
 local function roof(a,b,back,front,base,rear,near)
  for xx=a,b-1,8 do
   local right=math.min(xx+8,b)
   prism(xx,right,back,front,base,rear,near,uv(26.05,16.05,33.95,33.95))
  end
 end
 roof(0,96,16,79,26,35,28)
 -- The upper tier is carried by a closed riser, not a floating slab.
 prism(16,80,18,63,28,35,35,gold)
 -- Raised central dormer leaves both lower roof wings visible.
 roof(16,80,16,63,35,48,39)
 -- Native pale ridge caps are closed shallow bars, not billboard edges.
 prism(0,96,16,20,34,36,36,light)
 prism(16,80,16,20,47,49,49,light)
 -- Recessed silver front fascia below the upper roof.
 face({{18,39,63.05},{78,39,63.05},{78,35,63.05},{18,35,63.05}},uv(18.05,36.05,77.95,42.95))
 -- Gold corner posts continue the native facade palette onto unseen walls.
 for _,xx in ipairs({1.7,91.3})do
  for _,zz in ipairs({18,75})do prism(xx,xx+3,zz,zz+3,0,28,28,gold)end
 end
end
return M
