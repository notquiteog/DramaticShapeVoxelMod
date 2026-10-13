-- Decorative service lanterns, not claimed native streetlamp tiles. Reviewed
-- Hoenn placements occupy blank wall strips beside the door and service sign.
local M={}
function M.placements(g,p)
 local r=g.custom
 if g.kind~='center' and g.kind~='mart' then return {} end
 if r and (r.centerRoof or r.martRoof) and p.w==64 then
  return {{12,9,60},{36,9,60}}
 end
 -- Further source-reviewed families may opt in with local {x,y,facadeZ} spots.
 return r and r.serviceLanterns or {}
end
function M.append(g,p,emit)
 local places=M.placements(g,p)
 local width,height=p.w*2+4,p.h
 local function sw(xx)
  local u,v=(xx+.5)/width,1.5/height
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local metal,glass=sw(p.w*2+2),sw(p.w*2+3)
 local x,z=g.cx*16,g.cy*16;local count=0
 local function face(v,t,s)
  local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end
  emit(out,t,s)
 end
 local function box(l,b,n,r,h,f,t,lit)
  local vs={{{l,h,f},{r,h,f},{r,b,f},{l,b,f}},{{r,h,n},{l,h,n},{l,b,n},{r,b,n}},
   {{l,h,n},{l,h,f},{l,b,f},{l,b,n}},{{r,h,f},{r,h,n},{r,b,n},{r,b,f}},
   {{l,h,n},{r,h,n},{r,h,f},{l,h,f}},{{l,b,f},{r,b,f},{r,b,n},{l,b,n}}}
  for i,v in ipairs(vs)do
   local shade=({1,.78,.84,.9,1,.65})[i]
   face(v,t,shade+(lit and 64 or 0))
  end
 end
 for _,q in ipairs(places)do
  local cx,base,back=q[1],q[2],q[3]
  local depth=math.min(2.1,g.depth*16-.2-back)
  -- Reject undersized or out-of-bounds fixtures instead of squeezing a post
  -- into an unreviewed native floor/door/corner region.
  if depth>=1.6 and cx>=2.3 and cx<=p.w-2.3 and base>=3 and base+7.7<=p.wall and back>=0 then
   count=count+1
   local front=back+depth
   box(cx-1.1,base-.4,back-.12,cx+1.1,base+6.8,back+.22,metal)
   box(cx-.35,base-.2,back+.15,cx+.35,base+.4,front-.5,metal)
   box(cx-2,base+.3,back+.25,cx+2,base+.9,front,metal)
   box(cx-1.65,base+.9,back+.45,cx+1.65,base+5.9,front-.25,glass,true)
   for _,xx in ipairs({cx-1.9,cx+1.6})do
    for _,zz in ipairs({back+.35,front-.3})do box(xx,base+.85,zz,xx+.3,base+6,zz+.3,metal)end
   end
   -- A thin crossbar, layered weather cap and small finial make the housing
   -- legible from close eye views; only the enclosed panes carry emission.
   box(cx-1.8,base+3.2,front-.18,cx+1.8,base+3.45,front+.01,metal)
   box(cx-2.2,base+5.9,back+.05,cx+2.2,base+6.4,front,metal)
   box(cx-1.8,base+6.4,back+.25,cx+1.8,base+7,front-.2,metal)
   box(cx-.3,base+7,back+.8,cx+.3,base+7.7,front-.6,metal)
  end
 end
 return count
end
return M
