-- Circular nautical windows for Slateport's ferry terminal. Ring faces and
-- recessed glazing close at every angle; unseen sides do not repeat signage.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W=p.w;local back=math.max(g.bodyBack or 0,g.custom.bodyBack or 2)
 local function sw(a,b)local u,v=(a+.5)/(W*2+4),(b+.5)/p.h;return {{u,v},{u,v},{u,v},{u,v}}end
 local frame,dark=sw(28,66),sw(26,70)
 local function glassUV(a,r)return {(32.5+math.cos(a)*5.2*r)/(W*2+4),(71.5-math.sin(a)*5.2*r)/p.h}end
 local function window(cx,cy,cz,axis,outward,rx,ry)
  local function point(a,r,depth)
   local u,v=math.cos(a)*rx*r,math.sin(a)*ry*r
   if axis=='x'then return {x+cx+depth*outward,cy+v,z+cz+u}end
   return {x+cx+u,cy+v,z+cz+depth*outward}
  end
  for i=0,15 do
   local a,b=i*math.pi/8,(i+1)*math.pi/8
   emit({point(a,1,.1),point(b,1,.1),point(b,1,.65),point(a,1,.65)},dark,.86)
   emit({point(a,1,.65),point(b,1,.65),point(b,.8,.65),point(a,.8,.65)},frame,1)
   emit({point(a,.8,.65),point(b,.8,.65),point(b,.8,.2),point(a,.8,.2)},dark,.8)
   emit({point(0,0,.2),point(a,.8,.2),point(b,.8,.2),point(0,0,.2)},{glassUV(0,0),glassUV(a,1),glassUV(b,1),glassUV(0,0)},1)
  end
 end
 for _,cx in ipairs({32,80})do window(cx,(95-71)*40/31,95,'z',1,6.5,6.5*40/31)end
 for _,zz in ipairs({back+20,back+52})do
  window(2,25,zz,'x',-1,6.5,6.5);window(W-2,25,zz,'x',1,6.5,6.5)
 end
 for _,cx in ipairs({32,80})do window(cx,25,back,'z',-1,6.5,6.5)end
end
return M
