local Shell=dofile('lib/Gen3CaveShell.lua');local checks=0
local function check(v,m)assert(v,m);checks=checks+1 end
local p={bounds={0,0,64,64},height=96,wallpaperHeight=28,passages={{{16,32,0},{32,48,0}},{},{},{}}}
local function triangleArea(a,b,c)
 local x,y,z=b[1]-a[1],b[2]-a[2],b[3]-a[3];local u,v,w=c[1]-a[1],c[2]-a[2],c[3]-a[3]
 return math.sqrt((y*w-z*v)^2+(z*u-x*w)^2+(x*v-y*u)^2)/2
end
local verts,indices={},{}
for side=1,4 do
 local v,i=Shell.geometry(p,side,false)
 for _,q in ipairs(v)do
  check(q[2]>=-4 and q[2]<=96,'rock beyond enclosure height')
  check(q[1]<=0 or q[1]>=64 or q[3]<=0 or q[3]>=64,'rock entered native walking footprint')
 end
 for j=1,#i,3 do
  local a,b,c=v[i[j]],v[i[j+1]],v[i[j+2]]
  check(triangleArea(a,b,c)>1e-9,'degenerate rock triangle')
  if side==1 then
   local x,y,z=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3,(a[3]+b[3]+c[3])/3
   check(not(x>16 and x<48 and y>0 and y<32 and z<0 and z>-6),'rock face sealed actual native passage')
  end
 end
 local start=#verts;for _,q in ipairs(v)do verts[#verts+1]=q end;for _,n in ipairs(i)do indices[#indices+1]=start+n end
 for _,q in ipairs(Shell.geometry(p,side,true))do check(q[2]<=0,'cutaway grew solid wall')end
end
-- Exact edge incidence detects missing rock joins. A shared grid line can
-- contain several collinear vertices, so split each edge at all used points.
local function key(q)return string.format('%.7f,%.7f,%.7f',q[1],q[2],q[3])end
local points={};for _,v in ipairs(verts)do points[key(v)]=v end
local edges={};local triangles={}
for j=1,#indices,3 do local t={verts[indices[j]],verts[indices[j+1]],verts[indices[j+2]]};local tk={key(t[1]),key(t[2]),key(t[3])};table.sort(tk);tk=table.concat(tk,'|');check(not triangles[tk],'duplicate internal rock triangle');triangles[tk]=true
 for k=1,3 do local a,b=t[k],t[k%3+1];local dx,dy,dz=b[1]-a[1],b[2]-a[2],b[3]-a[3];local len=dx*dx+dy*dy+dz*dz;local cuts={{t=0,q=a},{t=1,q=b}}
  for _,q in pairs(points)do local u=((q[1]-a[1])*dx+(q[2]-a[2])*dy+(q[3]-a[3])*dz)/len
   if u>1e-7 and u<1-1e-7 then local x,y,z=a[1]+u*dx-q[1],a[2]+u*dy-q[2],a[3]+u*dz-q[3];if x*x+y*y+z*z<1e-14 then cuts[#cuts+1]={t=u,q=q}end end
  end
  table.sort(cuts,function(c,d)return c.t<d.t end)
  for n=1,#cuts-1 do local x,y=key(cuts[n].q),key(cuts[n+1].q);if x~=y then if x>y then x,y=y,x end;local ek=x..'|'..y;edges[ek]=(edges[ek]or 0)+1 end end
 end
end
for k,n in pairs(edges)do check(n==2,'open/internal rock edge '..k..' incidence'..n)end
print('PASS '..checks..' closed cave shell, exact portal, footprint, cutaway and surface ownership contracts')
