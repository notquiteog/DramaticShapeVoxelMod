-- Closed, greedy-meshed pixel volumes from a source silhouette. Like the
-- original Gen1 round hulls, each artwork row defines a carved cross-section.
-- Only boundary faces exist; equal-colour coplanar faces are merged once per
-- template. No billboard anchors, cubes under the object, or per-frame work.
local M={}
function M.build(w,h,sample,step,bottom)
 step=step or 1;bottom=bottom or 0
 local nx,ny=math.ceil(w/step),math.ceil(h/step)
 local vox,paints={},{}
 local function key(x,y,z)return (y*nx+x)*nx+z end
 for y=0,ny-1 do
  local sy=math.min(h-1,h-1-y*step)
  local row,left,right={},nx,-1
  for x=0,nx-1 do
   local sx=math.min(w-1,x*step+math.floor(step/2))
   local r,g,b,a,u,v=sample(sx,sy)
   if a and a>.5 then
    local k=math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)
    paints[k]=paints[k]or{u,v};row[x]=k;left=math.min(left,x);right=math.max(right,x)
   end
  end
  local center=(left+right+1)/2;local radius=(right-left+1)/2
  for x=left,right do if row[x] then
   local dx=x+.5-center
   local depth=math.sqrt(math.max(0,radius*radius-dx*dx))*.88
   local z0=math.max(0,math.floor(nx/2-depth));local z1=math.min(nx-1,math.ceil(nx/2+depth)-1)
   for z=z0,z1 do vox[key(x,y,z)]=row[x] end
  end end
 end
 local out={}
 -- Slice along each normal. Rectangle merging keeps the pixel silhouette
 -- while avoiding six independent cube faces for every solid pixel.
 for axis=1,3 do for _,sign in ipairs({-1,1})do
  local limits={nx,ny,nx};local uaxis=axis%3+1;local vaxis=(axis+1)%3+1
  for plane=0,limits[axis]-1 do
   local grid={};local nw,nh=limits[uaxis],limits[vaxis]
   for v=0,nh-1 do for u=0,nw-1 do
    local p={};p[axis]=plane;p[uaxis]=u;p[vaxis]=v
    local colour=vox[key(p[1],p[2],p[3])]
    if colour then
     p[axis]=plane+sign
     local neighbour=p[axis]>=0 and p[axis]<limits[axis] and vox[key(p[1],p[2],p[3])]
     if not neighbour then grid[v*nw+u]=colour end
    end
   end end
   for v=0,nh-1 do for u=0,nw-1 do
    local colour=grid[v*nw+u]
    if colour then
     local ww,hh=1,1
     while u+ww<nw and grid[v*nw+u+ww]==colour do ww=ww+1 end
     while v+hh<nh do
      local whole=true
      for du=0,ww-1 do if grid[(v+hh)*nw+u+du]~=colour then whole=false;break end end
      if not whole then break end;hh=hh+1
     end
     for dv=0,hh-1 do for du=0,ww-1 do grid[(v+dv)*nw+u+du]=nil end end
     local q={u=paints[colour][1],v=paints[colour][2],shade=axis==2 and (sign>0 and 1 or .68) or axis==1 and .85 or .94}
     for _,uv in ipairs({{u,v},{u+ww,v},{u+ww,v+hh},{u,v+hh}})do
      local p={};p[axis]=(plane+(sign>0 and 1 or 0))*step;p[uaxis]=uv[1]*step;p[vaxis]=uv[2]*step
      p[1]=p[1]-w/2;p[2]=math.max(0,p[2]-bottom);p[3]=p[3]-nx*step/2
      q[#q+1]=p
     end
     if sign<0 then q[2],q[4]=q[4],q[2] end
     out[#out+1]=q
    end
   end end
  end
 end end
 return out
end
function M.append(quads,v,i,count,x,y,z)
 for _,q in ipairs(quads)do
  local base=#v
  for _,p in ipairs(q)do v[#v+1]={x+p[1],y+p[2],z+p[3],q.u,q.v,q.shade,0,0,0} end
  for _,k in ipairs({1,2,3,1,3,4})do i[#i+1]=base+k end
 end
 return (count or 0)+#quads
end
return M
