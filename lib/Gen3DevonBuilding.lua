-- Devon Corporation: tall central bay and lower side wings. The front strip
-- beside the two entrances remains native walkable floor, not a solid shell.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/324,b/144},{c/324,b/144},{c/324,d/144},{a/324,d/144}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local stone,trim,wall=sw(3,48),sw(6,63),sw(9,41)
 local function face(v,t,s)local q={};for i,a in ipairs(v)do q[i]={x+a[1],a[2],z+a[3]}end;emit(q,t,s or 1)end
 local function box(a,b,c,d,e,f,t)
  face({{a,e,d},{c,e,d},{c,b,d},{a,b,d}},t)
  face({{c,e,f},{a,e,f},{a,b,f},{c,b,f}},t,.8)
  face({{a,e,f},{a,e,d},{a,b,d},{a,b,f}},t,.82)
  face({{c,e,d},{c,e,f},{c,b,f},{c,b,d}},t,.9)
  face({{a,e,f},{c,e,f},{c,e,d},{a,e,d}},t)
  face({{a,b,d},{c,b,d},{c,b,f},{a,b,f}},t,.7)
 end
 for _,r in ipairs({{2,48},{112,158}})do
  box(r[1],0,r[2],127,96,2,wall)
  face({{r[1],96,127.02},{r[2],96,127.02},{r[2],0,127.02},{r[1],0,127.02}},uv(r[1]+.05,32.05,r[2]-.05,127.95))
  -- Raised cornices and solid parapet rims have closed undersides.
  for _,yy in ipairs({1,32,64,95})do box(r[1]-.5,yy,r[2]+.5,127.6,yy+2,1.5,stone)end
  face({{r[1]+1,98.03,3},{r[2]-1,98.03,3},{r[2]-1,98.03,124},{r[1]+1,98.03,124}},uv(r[1]+1.05,3.05,r[2]-1.05,26.95))
 end
 -- Central tower ends only on native blocked cells. Twin recessed portals
 -- share the same source/height mapping as Civic.doorSurface.
 box(48,0,64,143,112,2,stone);box(96,0,112,143,112,2,stone)
 box(64,28,96,143,112,2,wall)
 box(64,0,96,3,28,2,wall)
 local function center(a,b,top,bottom,depth)
  local y1,y0=(144-top)*112/96,(144-bottom)*112/96
  face({{a,y1,depth},{b,y1,depth},{b,y0,depth},{a,y0,depth}},uv(a+.05,top+.05,b-.05,bottom-.05))
 end
 center(48,64,48,144,143.02);center(96,112,48,144,143.02)
 center(64,96,48,120,143.02)
 center(64,80,120,144,142.05);center(80,96,120,144,142.05)
 -- Inset entrance reveals are fully enclosed.
 for _,xx in ipairs({64,80,96})do box(xx-.4,0,xx+.4,143,28,141.9,trim)end
 box(64,28,96,143,29,142,trim)
 for _,yy in ipairs({36,73,110})do box(47.7,yy,112.3,143.6,yy+2,1.7,stone)end
 box(48,112,112,143,116,2,trim)
 face({{50,116.03,4},{110,116.03,4},{110,116.03,140},{50,116.03,140}},uv(50.05,2.05,109.95,30.95))
 -- Extend the authored slender window language onto side and back elevations.
 local function window(a,b,c,d)
  -- Rectangle in x/z coordinates; original pointed windows remain upright.
  for _,yy in ipairs({38,70})do
   face({{a,yy+17,b},{c,yy+17,d},{c,yy,d},{a,yy,b}},uv(17.05,40.05,23.95,54.95),.9)
  end
  face({{a,26,b},{c,26,d},{c,8,d},{a,8,b}},uv(10.05,98.05,16.95,119.95),.88)
 end
 for zz=10,110,20 do window(1.97,zz,1.97,zz+7);window(158.03,zz+7,158.03,zz)end
 for xx=10,142,20 do window(xx+7,1.97,xx,1.97)end
 -- Continuous vertical stone piers and tiered central pilasters.
 for zz=3,123,20 do
  box(1.6,2,2.1,zz+2,95,zz,stone);box(157.9,2,158.4,zz+2,95,zz,stone)
 end
 for xx=3,143,20 do box(xx,2,xx+2,2.1,95,1.6,stone)end
 for _,xx in ipairs({50,62,82,102,108})do
  box(xx,30,xx+1.5,143.4,109,142.9,stone)
 end
 -- Native roof crest reinterpreted as a solid winged medallion. The rear
 -- disk and edge ring close the shallow relief, so orbit views see its depth.
 local cx,cy,cz=80,115,143.7;local n=12;local ring={}
 for i=0,n-1 do local a=i*2*math.pi/n;ring[i+1]={cx+math.cos(a)*3.4,cy+math.sin(a)*4,cz}end
 for i=1,n do local a,b=ring[i],ring[i%n+1]
  face({{cx,cy,cz+.9},{b[1],b[2],cz+.9},{a[1],a[2],cz+.9},{cx,cy,cz+.9}},stone)
  face({a,b,{b[1],b[2],cz+.9},{a[1],a[2],cz+.9}},trim,.85)
  face({{cx,cy,cz},a,b,{cx,cy,cz}},trim,.75)
 end
 for _,sign in ipairs({-1,1})do
  for j=0,2 do
   local a=80+sign*(3+j*1.8);local b=80+sign*(5+j*1.8)
   box(math.min(a,b),116+j,math.max(a,b),144.6,117.3+j,143.5,stone)
  end
 end
end
return M
