-- Littleroot's native stepped roof, with closed lower wings and raised fascia.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D=p.w,p.h
 local function uv(a,b,c,d)return {{a/(W*2+4),b/D},{c/(W*2+4),b/D},{c/(W*2+4),d/D},{a/(W*2+4),d/D}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local gold,trim=sw(15,7),sw(10,37)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function prism(a,b,back,front,base,rear,near,tex)
  face({{a,rear,back},{b,rear,back},{b,near,front},{a,near,front}},tex)
  face({{a,base,front},{b,base,front},{b,base,back},{a,base,back}},trim,.65)
  face({{a,near,front},{b,near,front},{b,base,front},{a,base,front}},trim,.85)
  face({{b,rear,back},{a,rear,back},{a,base,back},{b,base,back}},gold,.8)
  face({{a,rear,back},{a,near,front},{a,base,front},{a,base,back}},trim,.82)
  face({{b,near,front},{b,rear,back},{b,base,back},{b,base,front}},trim,.9)
 end
 local function roof(a,b,back,front,base,rear,near)
  for xx=a,b-1,8 do prism(xx,math.min(xx+8,b),back,front,base,rear,near,uv(14.05,14.05,21.95,33.95))end
 end
 roof(0,80,17,79,25,35,28)
 -- Structural riser supports the raised roof and its pale inset fascia.
 prism(8,72,18,59,28,38,38,trim)
 roof(8,72,16,59,38,49,41)
 prism(0,80,17,21,34,36,36,uv(14.05,2.05,21.95,8.95))
 prism(8,72,16,20,48,50,50,uv(14.05,2.05,21.95,8.95))
 face({{10,41,59.05},{70,41,59.05},{70,35,59.05},{10,35,59.05}},uv(10.05,35.05,69.95,42.95))
end
return M
