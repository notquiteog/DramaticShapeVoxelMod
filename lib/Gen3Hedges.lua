-- Purpose-built trimmed foliage. The original native drawing determines the
-- footprint; this closed rounded mesh uses an original leaf material rather
-- than stretching the top-down tile's outlines across a box.
local V=...
local M={}
local material
function M.image()
 if not material then
  material=assert(V.mod.assets:image('assets/environment/hoenn-hedge-leaves.png'))
  material:setFilter('nearest','nearest');material:setWrap('repeat','repeat')
 end
 return material
end
function M.release()
 if material then material:release();material=nil end
end
local function pointDistance(x,z,e)
 local dx,dz=e[3]-e[1],e[4]-e[2]
 local t=math.max(0,math.min(1,((x-e[1])*dx+(z-e[2])*dz)/(dx*dx+dz*dz)))
 return math.sqrt((x-e[1]-t*dx)^2+(z-e[2]-t*dz)^2)
end
function M.append(c,emit)
 local b,h=c.shape.bounds,c.shape.height
 local x,z=c.cx*16,c.cy*16
 local a,n,r,f=x+b[1],z+b[2],x+b[3],z+b[4]
 local j=c.hedgeJoin or{}
 local edges=c.hedgeEdges or{{a,n,a,f},{r,n,r,f},{a,n,r,n},{a,f,r,f}}
 local function height(xx,zz)
  local d=math.huge;for _,e in ipairs(edges)do d=math.min(d,pointDistance(xx,zz,e))end
  local radius=math.min(3,(r-a)/2,(f-n)/2)
  local shoulder=d<radius and math.sqrt(math.max(0,radius*radius-(radius-d)^2))or radius
  -- Small continuous leaf-cluster undulations, shared across tile seams.
  local ripple=.18*(1+math.sin(xx*1.13)*math.cos(zz*.91))
  return h-radius+shoulder-ripple
 end
 local function tex(xx,zz)
  return{(c.cx%4*16+xx-x)/64,(c.cy%4*16+zz-z)/64}
 end
 local nx,nz=math.ceil((r-a)/2),math.ceil((f-n)/2)
 for iz=0,nz-1 do for ix=0,nx-1 do
  local l,u=a+(r-a)*ix/nx,a+(r-a)*(ix+1)/nx
  local t,v=n+(f-n)*iz/nz,n+(f-n)*(iz+1)/nz
  emit({{l,height(l,t),t},{u,height(u,t),t},{u,height(u,v),v},{l,height(l,v),v}},
   {tex(l,t),tex(u,t),tex(u,v),tex(l,v)},1)
  emit({{l,.02,v},{u,.02,v},{u,.02,t},{l,.02,t}},
   {tex(l,v),tex(u,v),tex(u,t),tex(l,t)},.8)
 end end
 local sides={{{a,n},{a,f},1,nz},{{r,f},{r,n},2,nz},
  {{r,n},{a,n},3,nx},{{a,f},{r,f},4,nx}}
 for _,e in ipairs(sides)do if not j[e[3]]then
  for i=0,e[4]-1 do
   local function p(t)local k=t/e[4];return e[1][1]+(e[2][1]-e[1][1])*k,e[1][2]+(e[2][2]-e[1][2])*k end
   local ax,az=p(i);local bx,bz=p(i+1)
   local ah,bh=height(ax,az),height(bx,bz)
   local u0,u1=(i/e[4])*(math.abs(r-a)+math.abs(f-n))/128,((i+1)/e[4])*(math.abs(r-a)+math.abs(f-n))/128
   emit({{ax,.02,az},{bx,.02,bz},{bx,bh,bz},{ax,ah,az}},
    {{u0,h/64},{u1,h/64},{u1,(h-bh)/64},{u0,(h-ah)/64}},.76)
  end
 end end
end
return M
