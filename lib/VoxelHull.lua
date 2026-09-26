-- Closed, greedy-meshed voxel volumes. Organic trees/rocks use intersecting
-- solid masses and native palette samples; sculpture drawings use row hulls.
-- Only boundary faces exist; equal-colour coplanar faces are merged once per
-- template. No billboard anchors, cubes under the object, or per-frame work.
local V=...
local Trees=V and V.require('NativeTreeModels') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/NativeTreeModels.lua')
local M={}
function M.build(w,h,sample,step,bottom,depthLimit,organic,family)
 step=step or 1;bottom=bottom or 0
 local nx,ny=math.ceil(w/step),math.ceil(h/step)
 local depth=w
 local nz=math.ceil(depth/step)
 local vox,paints={},{}
 local foliage,wood,all={},{},{}
 local nativeRows={}
 local function key(x,y,z)return (y*nx+x)*nz+z end
 for y=0,ny-1 do
  local sy=math.min(h-1,h-1-y*step)
  local row,left,right={},nx,-1
  for x=0,nx-1 do
   local sx=math.min(w-1,x*step+math.floor(step/2))
   local r,g,b,a,u,v=sample(sx,sy)
   if a and a>.5 then
    local k=math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)
    paints[k]=paints[k]or{u,v};row[x]=k;left=math.min(left,x);right=math.max(right,x)
    if organic then
     all[#all+1]=k
     -- Ink outlines belong to the 2D drawing; distributing them across a
     -- solid crown makes black blocks. Lighting supplies the 3D shadows.
     if (family or sy<h*.76) and g>r*1.12 and g>b*1.08 then
      foliage[#foliage+1]=k
      local leafRow=nativeRows[y] or {};nativeRows[y]=leafRow;leafRow[x]=k
     end
     if sy>h*.65 and r>=g*.9 then wood[#wood+1]=k end
    end
   end
  end
  local center=(left+right+1)/2;local radius=(right-left+1)/2
  for x=left,right do if row[x] and not organic then
   local dx=x+.5-center
   local depth=math.sqrt(math.max(0,radius*radius-dx*dx))*.88
   if depthLimit then depth=math.min(depth,depthLimit/(2*step)) end
   local z0=math.max(0,math.floor(nx/2-depth));local z1=math.min(nx-1,math.ceil(nx/2+depth)-1)
   if depthLimit then
    local cells=math.max(1,math.floor(depthLimit/step))
    local first=math.floor((nx-cells)/2)
    z0=math.max(z0,first);z1=math.min(z1,first+cells-1)
   end
   for z=z0,z1 do vox[key(x,y,z)]=row[x] end
  end end
 end
 if organic and #all>0 then
  if #foliage==0 then foliage=all end;if #wood==0 then wood=all end
  local nativePaint={}
  if family then for y=0,ny-1 do
   local row=nativeRows[y]
   if not row then for d=1,ny do row=nativeRows[y+d] or nativeRows[y-d];if row then break end end end
   if row then
    local paint={};nativePaint[y]=paint
    for sx=0,nx-1 do
     local color=row[sx]
     if not color then for d=1,nx do color=row[sx-d] or row[sx+d];if color then break end end end
     paint[sx]=color
    end
   end
  end end
  local height=h-bottom
  local function oval(x,y,z,cx,cy,cz,rx,ry,rz)
   return ((x-cx)/rx)^2+((y-cy)/ry)^2+((z-cz)/rz)^2<=1
  end
  for y=0,ny-1 do for x=0,nx-1 do for z=0,nz-1 do
   local xx=(x+.5)*step/w-.5;local yy=((y+.5)*step-bottom)/height;local zz=(z+.5)*step/depth-.5
   local stemZ=((z+.5)*step-depth/2)/w
   local pool
   if yy>=0 then
    if organic=='tree' and family then
     local part=Trees.part(family,xx,yy,zz)
     if part then pool=part=='foliage' and foliage or wood end
    elseif organic=='tree' then
     -- Overlapping canopy lobes surround real trunk/branch volumes. The
     -- source image supplies colors only, never a front-facing solid slab.
     -- Each tree has a round footprint. Multi-row drawings are populated
     -- with separate trees by NativeTreeArt, never one elongated crown.
     -- Raise the canopy shoulders above head height on full-sized trees.
     local cy,ry=height>20 and .72 or .53,height>20 and .25 or .28
     if oval(xx,yy,zz,0,.82,0,.34,.18,.4)
      or oval(xx,yy,zz,-.12,cy,.02,.36,ry,.48)
      or oval(xx,yy,zz,.15,cy-.01,-.05,.34,ry-.01,.46)then pool=foliage
     elseif yy<.7 and xx*xx+stemZ*stemZ<(.065+.06*math.max(0,1-yy/.12))^2 then pool=wood
     elseif yy>.35 and yy<.68 and math.abs(math.abs(xx)-(yy-.35)*.65)<.055 and math.abs(stemZ)<.06 then pool=wood end
    elseif organic=='bush' then
     if oval(xx,yy,zz,-.17,.24,.06,.32,.26,.39)
      or oval(xx,yy,zz,.12,.35,-.08,.36,.36,.34)
      or oval(xx,yy,zz,.2,.2,.18,.26,.24,.25)then pool=foliage end
    elseif organic=='rock' then
     -- Three offset masses form a broad, asymmetric stone with a rounded
     -- top and real depth. Its foot is the rock itself, not a support box.
     if oval(xx,yy,zz,-.1,.34,.04,.38,.4,.39)
      or oval(xx,yy,zz,.12,.45,-.06,.34,.5,.32)
      or oval(xx,yy,zz,.22,.2,.18,.24,.27,.26)then pool=all end
    end
   end
   if pool then
    -- Native palette patches vary in all three axes; no repeated 2D bands
    -- through the middle. Coherent two-voxel patches retain greedy merging.
    local color
    if family and pool==foliage then
     -- Carry the drawing's leaf bands around the solid crown. Palette-only
     -- random noise erased the characteristic light/dark native leaf tiers.
     local row=nativePaint[y]
     if row then
      local azimuth=math.atan2(zz,xx)/(2*math.pi)+.5
      color=row[math.min(nx-1,math.floor(azimuth*nx))]
     end
    end
    if not color then
     local a,b,c=math.floor(x/2),math.floor(y/2),math.floor(z/2)
     local n=math.sin(a*12.9898+b*78.233+c*37.719)*43758.5453
     color=pool[math.floor((n-math.floor(n))*#pool)+1]
    end
    vox[key(x,y,z)]=color
   end
  end end end
 end
 local out={}
 -- Slice along each normal. Rectangle merging keeps the pixel silhouette
 -- while avoiding six independent cube faces for every solid pixel.
 for axis=1,3 do for _,sign in ipairs({-1,1})do
  local limits={nx,ny,nz};local uaxis=axis%3+1;local vaxis=(axis+1)%3+1
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
      p[1]=p[1]-w/2;p[2]=math.max(0,p[2]-bottom);p[3]=p[3]-nz*step/2
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
-- Native cutout pixels, kept on one upright plane for the optional 2.5D path.
function M.card(w,h,sample,bottom,height)
 local out={};local scale=(height or h)/h
 for y=0,h-1 do for x=0,w-1 do
  local _,_,_,a,u,v=sample(x,y)
  if a and a>.5 then
   local top=(h-y-(bottom or 0))*scale;local low=top-scale
   out[#out+1]={{x-w/2,top,0},{x+1-w/2,top,0},{x+1-w/2,low,0},{x-w/2,low,0},u=u,v=v,shade=1,card=true}
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
