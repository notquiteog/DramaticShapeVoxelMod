-- Crystal's whole computer/console desk, drawn from its original tile grid.
-- Wall and floor pixels are claimed but never stretched over equipment.
local M={}
function M.build(t,data,perRow,aw,ah)
 local out={}
 local function tex(x,y)
  local tile=t.tiles[math.floor(y/8)+1][math.floor(x/8)+1]
  return {(tile%perRow*8+x%8+.5)/aw,(math.floor(tile/perRow)*8+y%8+.5)/ah}
 end
 local function face(p,uv,shade)p.uv=uv;p.shade=shade or 1;out[#out+1]=p end
 local function tone(x,y)local uv=tex(x,y);return {uv,uv,uv,uv}end
 local frame,case=tone(1,25),tone(3,5)
 local function box(l,b,n,r,h,s,uv)
  face({{l,h,n},{l,h,s},{r,h,s},{r,h,n}},uv)
  face({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.86)
  face({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.72)
  face({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.76)
  face({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)
 end
 local function source(x0,y0,w,h,a,b,c,d)
  for y=y0,y0+h-1 do for x=x0,x0+w-1 do
   local function p(u,v)local q={};for i=1,3 do q[i]=(a[i]*(1-u)+b[i]*u)*(1-v)+(d[i]*(1-u)+c[i]*u)*v end;return q end
   local u,v=(x-x0)/w,(y-y0)/h;local du,dv=1/w,1/h
   local uv=tex(x,y)
   face({p(u,v),p(u+du,v),p(u+du,v+dv),p(u,v+dv)},{uv,uv,uv,uv})
  end end
 end
 -- Open knee space, four legs and a thin tabletop, not a solid wardrobe.
 box(0,4,8,32,6,24,frame)
 for _,x in ipairs({2,28})do for _,z in ipairs({9,21})do box(x,0,z,x+2,4,z+2,frame)end end
 box(1,6,9,15,19,16,case)
 source(1,3,14,14,{1,19,16.02},{15,19,16.02},{15,6,16.02},{1,6,16.02})
 source(1,17,14,6,{1,6.04,16},{15,6.04,16},{15,6.04,23},{1,6.04,23})
 box(17,6,12,31,9,22,case)
 source(16,8,16,12,{16,9.04,12},{32,9.04,12},{32,9.04,22},{16,9.04,22})
 return out
end
return M
