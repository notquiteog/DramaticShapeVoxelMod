-- Cached window emitters accumulated into a spatial light field at scene build.
-- Positions come from the rendered openings, never guessed tile coordinates.
local M={}
function M.collect(vertices,read,w,h)
 local out={}
 for i=1,#vertices,4 do
  local a,b,c,d=vertices[i],vertices[i+1],vertices[i+2],vertices[i+3]
  local ux,uy,uz=b[1]-a[1],b[2]-a[2],b[3]-a[3]
  local vx,vy,vz=d[1]-a[1],d[2]-a[2],d[3]-a[3]
  local nx,ny,nz=vy*uz-vz*uy,vz*ux-vx*uz,vx*uy-vy*ux
  local length=math.sqrt(nx*nx+ny*ny+nz*nz)
  local tagged=a[6]>=64 and a[6]<128
  local mapped=(math.abs(b[4]-a[4])+math.abs(d[4]-a[4]))*w>1
   and (math.abs(b[5]-a[5])+math.abs(d[5]-a[5]))*h>1
  if length>1 and math.abs(ny)<length*.1 and (tagged or read and mapped) then
   nx,nz=nx/length,nz/length
   local sx,sy,sz,n=0,0,0,0
   for t=0,7 do for s=0,7 do
    local u,v=(s+.5)/8,(t+.5)/8
    local tx=a[4]+u*(b[4]-a[4])+v*(d[4]-a[4])
    local ty=a[5]+u*(b[5]-a[5])+v*(d[5]-a[5])
    if tagged or read and read(math.floor(tx*w),math.floor(ty*h)) then
     sx=sx+a[1]+u*ux+v*vx;sy=sy+a[2]+u*uy+v*vy;sz=sz+a[3]+u*uz+v*vz;n=n+1
    end
   end end
   if n>=3 then
    local light={sx/n+nx,sy/n,sz/n+nz,30,nx,nz,tagged=tagged}
    local duplicate=false
    for _,p in ipairs(out)do
     local d2=(p[1]-light[1])^2+(p[2]-light[2])^2+(p[3]-light[3])^2
     -- A caged lantern's several panes share one emitter. Its first pane
     -- faces out from the mount; avoid counting each face as a separate fixture.
     if (tagged and p.tagged and d2<36) or (p[5]*nx+p[6]*nz>.9 and d2<144) then duplicate=true;break end
    end
    if not duplicate then out[#out+1]=light end
   end
  end
 end
 return out
end
-- Static sources are accumulated once when a scene is built. A packed light
-- volume makes fragment cost independent of the number of lamps in the town.
function M.bake(parts,check)
 local lights={};local lo={math.huge,0,math.huge};local hi={-math.huge,0,-math.huge}
 for _,part in ipairs(parts or{})do for _,p in ipairs(part.lights or{})do
  lights[#lights+1]=p
  lo[1]=math.min(lo[1],p[1]-p[4]);lo[3]=math.min(lo[3],p[3]-p[4])
  hi[1]=math.max(hi[1],p[1]+p[4]);hi[2]=math.max(hi[2],p[2]+p[4]);hi[3]=math.max(hi[3],p[3]+p[4])
 end end
 if #lights==0 then return nil end
 local step={4,4,4};local n={}
 for i=1,3 do lo[i]=math.floor(lo[i]/step[i])*step[i];n[i]=math.ceil((hi[i]-lo[i])/step[i])+1 end
 local values={};local nx,ny,nz=n[1],n[2],n[3]
 for _,p in ipairs(lights)do
  local r=p[4];local rsq=r*r
  local range={}
  for i=1,3 do range[i]={math.max(0,math.floor((p[i]-r-lo[i])/step[i])),math.min(n[i]-1,math.ceil((p[i]+r-lo[i])/step[i]))}end
  for iy=range[2][1],range[2][2]do
   local dy=lo[2]+iy*step[2]-p[2]
   for iz=range[3][1],range[3][2]do
    local dz=lo[3]+iz*step[3]-p[3]
    for ix=range[1][1],range[1][2]do
     local dx=lo[1]+ix*step[1]-p[1]
     local f=1-(dx*dx+dy*dy+dz*dz)/rsq
     local a=math.max(0,math.min(1,(dx*p[5]+dz*p[6]+2)/2))
     if f>0 and a>0 then
      a=a*a*(3-2*a);f=f*f
      local k=(iy*nz+iz)*nx+ix+1
      values[k]=math.min(1.2,(values[k]or 0)+f*f*a)
     end
    end
   end
   if check then check()end
  end
 end
 return {origin=lo,step=step,size=n,values=values,count=#lights}
end
function M.texture(parts,check)
 local field=M.bake(parts,check);if not field then return nil end
 local nx,ny,nz=unpack(field.size)
 local cols=math.max(1,math.ceil(math.sqrt(ny*(nz+2)/(nx+2))))
 local width,height=(nx+2)*cols,(nz+2)*math.ceil(ny/cols)
 local data=love.image.newImageData(width,height)
 for iy=0,ny-1 do
  local ox,oz=(iy%cols)*(nx+2)+1,math.floor(iy/cols)*(nz+2)+1
  for iz=0,nz-1 do for ix=0,nx-1 do
   local v=(field.values[(iy*nz+iz)*nx+ix+1]or 0)/1.2
   if v>0 then data:setPixel(ox+ix,oz+iz,v,v,v,1)end
  end end
  if check then check()end
 end
 field.image=love.graphics.newImage(data);field.image:setFilter('linear','linear');field.image:setWrap('clamp','clamp')
 data:release();field.values=nil;field.atlas={width,height,cols}
 return field
end
return M
