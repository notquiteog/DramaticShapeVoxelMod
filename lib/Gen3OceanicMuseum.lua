-- The public native roof drawing differs: Emerald has rounded lights and a
-- perforated panel; Ruby/Sapphire use square lights on a plain panel.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/196,b/80},{c/196,b/80},{c/196,d/80},{a/196,d/80}}end
 local function sw(a,b)return uv(a+.1,b+.1,a+.2,b+.2)end
 local frame,wall,roof,light=sw(10,52),sw(22,64),sw(48,17),sw(11,18)
 local function face(v,t,s)local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;emit(out,t,s or 1)end
 local function box(a,b,n,c,h,f,t)
  face({{a,h,f},{c,h,f},{c,b,f},{a,b,f}},t)
  face({{c,h,n},{a,h,n},{a,b,n},{c,b,n}},t,.8)
  face({{a,h,n},{a,h,f},{a,b,f},{a,b,n}},t,.82)
  face({{c,h,f},{c,h,n},{c,b,n},{c,b,f}},t,.9)
  face({{a,h,n},{c,h,n},{c,h,f},{a,h,f}},t)
  face({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 box(3,0,10,32,40,79,wall);box(64,0,10,93,40,79,wall)
 box(32,30,10,64,40,79,wall);box(32,0,10,64,30,11,wall)
 local function front(a,b,top,bottom,depth)
  face({{a,(80-top)*1.25,depth},{b,(80-top)*1.25,depth},{b,(80-bottom)*1.25,depth},{a,(80-bottom)*1.25,depth}},uv(a+.03,top+.03,b-.03,bottom-.03))
 end
 front(3,32,48,80,79.03);front(64,93,48,80,79.03);front(32,64,48,56,79.03)
 front(32,64,56,80,78.05)
 -- Four front supports echo the original frame; complete sections, not cards.
 for _,xx in ipairs({10,27,67,84})do box(xx-2,0,76,xx+2,43,79.3,frame)end
 for _,zz in ipairs({14,38,62})do
  for _,sx in ipairs({2.8,93.2})do
   face({{sx,30,zz},{sx,30,zz+10},{sx,8,zz+10},{sx,8,zz}},uv(16,57,22,70),sx<48 and .82 or .9)
  end
 end
 for _,xx in ipairs({12,36,60,80})do
  face({{xx+6,30,9.8},{xx,30,9.8},{xx,8,9.8},{xx+6,8,9.8}},uv(16,57,22,70),.8)
 end
 for _,xx in ipairs({10,27,67,84})do box(xx-2,0,9,xx+2,43,12,frame)end
 box(1,40,8,95,43,80,frame);box(3,43,10,93,44,78,roof)
 if not g.custom.squareRoofLights then
  local slot=sw(22,18)
  for zz=14,74,4 do for xx=7,89,4 do
   face({{xx,44.02,zz},{xx+1.4,44.02,zz},{xx+1.4,44.02,zz+1},{xx,44.02,zz+1}},slot,.88)
  end end
 end
 local lights={}
 for _,xx in ipairs({12,28,68,84})do for _,zz in ipairs({18,68})do lights[#lights+1]={xx,zz}end end
 for _,xx in ipairs({44,52})do for _,zz in ipairs({34,44})do lights[#lights+1]={xx,zz}end end
 for _,c in ipairs(lights)do
  if g.custom.squareRoofLights then box(c[1]-3,44,c[2]-3,c[1]+3,47,c[2]+3,light)
  else
   for ring=0,2 do for i=0,11 do
    local function q(k,j)local a=k*math.pi/6;local t=j*math.pi/6;return {c[1]+4*math.cos(t)*math.cos(a),44+3*math.sin(t),c[2]+4*math.cos(t)*math.sin(a)}end
    face({q(i,ring),q(i+1,ring),q(i+1,ring+1),q(i,ring+1)},light,.9+.1*ring/2)
   end end
  end
 end
end
return M
