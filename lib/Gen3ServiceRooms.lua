-- Native Center/Mart envelopes. Source corner drawings select this finish;
-- collision, staff lanes, native doors and room fixtures remain engine-owned.
local M={}
local kinds={
 network={kind='center',corners={0x2a0,0x2a6,0x2a1,0x2a2},floor=0x281,wall={0x284,0x28c}},
 ['building__pokemon_center']={kind='center',corners={0x208,0x20f,0x228,0x237},floor=0x202,wall={0x20b,0x213}},
 ['building__rom_082d4bcc']={kind='mart',corners={0x290,0x291,0x2bd,0x2be},floor=0x281,wall={0x285,0x285,single=true}},
 ['building__shop']={kind='mart',corners={0x210,0x215,0x214,0x21c},floor=0x201,wall={0x212,0x21a}},
}
function M.profile(def,pair)
 local k=kinds[pair];local l=def and def.midLayout
 if not(k and l and l.midAt and def.width and def.height)then return end
 local w,h=def.width,def.height
 -- Native FRLG maps carry a final black padding row; it is not floor.
 while h>2 do local padding=true;for x=0,w-1 do local m=l:midAt(x,h-1);if m~=0 and m~=8 and m~=0x1a and m~=0x1b and m~=0x1c then padding=false;break end end;if not padding then break end;h=h-1 end
 local c=k.corners
 if l:midAt(0,0)~=c[1]or l:midAt(w-1,0)~=c[2]or l:midAt(0,h-1)~=c[3]or l:midAt(w-1,h-1)~=c[4]then return end
 local x,z=w*16,h*16;local top,bottom=16,16
 -- FRLG's lower triangle cells remain natively walkable. Offset the plane
 -- four pixels into the drawn black corner so their centers stay clear.
 if l.collAt and(l:collAt(0,h-1)==0 or l:collAt(w-1,h-1)==0)then bottom=12 end
 local outline={{top,3.8},{x-top,3.8},{x,3.8+top},{x,z-bottom},{x-bottom,z},{bottom,z},{0,z-bottom},{0,3.8+top}}
 local outer={}
 for i,a in ipairs(outline)do
  local prev,next=outline[(i-2)%#outline+1],outline[i%#outline+1]
  local dx,dz=a[1]-prev[1],a[2]-prev[2];local len=math.sqrt(dx*dx+dz*dz);local px,pz=dz/len,-dx/len
  dx,dz=next[1]-a[1],next[2]-a[2];len=math.sqrt(dx*dx+dz*dz);local nx,nz=dz/len,-dx/len;local scale=3/(1+px*nx+pz*nz)
  outer[i]={a[1]+(px+nx)*scale,a[2]+(pz+nz)*scale}
 end
 return {kind=k.kind,floor=k.floor,wall=k.wall,bounds={0,3.8,x,z},height=32,
  outline=outline,outer=outer,
  sides={1,1,2,3,3,3,4,1},width=w,rows=h}
end
function M.replacesFloor(c,plan)
 return c.cx>=0 and c.cx<plan.width and c.cy>=0 and c.cy<plan.rows
  and(c.cy<=1 or c.cx==0 or c.cx==plan.width-1)
  and not(c.prop and c.prop.recipe.noGround)
end
function M.clip(poly,outline)
 for i,a in ipairs(outline)do
  local b=outline[i%#outline+1];local input=poly;poly={}
  local function distance(p)return(b[1]-a[1])*(p[2]-a[2])-(b[2]-a[2])*(p[1]-a[1])end
  if #input==0 then return poly end
  local last=input[#input];local dl=distance(last)
  for _,p in ipairs(input)do local dp=distance(p)
   if(dp>=-1e-7)~=(dl>=-1e-7)then local t=dl/(dl-dp);poly[#poly+1]={last[1]+t*(p[1]-last[1]),last[2]+t*(p[2]-last[2])}end
   if dp>=-1e-7 then poly[#poly+1]=p end;last,dl=p,dp
  end
 end
 local clean={}
 for _,q in ipairs(poly)do local last=clean[#clean];if not last or math.abs(q[1]-last[1])+math.abs(q[2]-last[2])>1e-6 then clean[#clean+1]=q end end
 if #clean>1 and math.abs(clean[1][1]-clean[#clean][1])+math.abs(clean[1][2]-clean[#clean][2])<1e-6 then table.remove(clean)end
 return clean
end
function M.floor(c,plan,emit,uv)
 local x,z=c.cx*16,c.cy*16
 local polygon=M.clip({{x,z},{x+16,z},{x+16,z+16},{x,z+16}},plan.outline)
 local function p(q)return{q[1],0,q[2]}end
 local function t(q)return{uv[1][1]+(uv[2][1]-uv[1][1])*(q[1]-x)/16,uv[1][2]+(uv[3][2]-uv[1][2])*(q[2]-z)/16}end
 for i=2,#polygon-1 do local a,b,d=polygon[1],polygon[i],polygon[i+1];emit({p(a),p(b),p(d),p(d)},{t(a),t(b),t(d),t(d)},1)end
end
function M.geometry(p,side,opened)
 local plan=p.serviceRoom;local outline=plan.outline;local height=p.height
 local v,indices={},{}
 local function face(points,uv,shade)
  local n=#v;for i,q in ipairs(points)do local t=uv and uv[i]or{.5/8,.5};v[#v+1]={q[1],q[2],q[3],t[1],t[2],shade or 1}end
  for _,k in ipairs(#points==3 and{1,2,3}or{1,2,3,1,3,4})do indices[#indices+1]=n+k end
 end
 local function point(q,y)return{q[1],y,q[2]}end
 local function cap(poly,y,reverse)
  for i=2,#poly-1 do local a,b,c=point(poly[1],y),point(poly[i],y),point(poly[i+1],y);face(reverse and{a,c,b}or{a,b,c},nil,.9)end
 end
 if side==5 then
  local xs,zs={p.bounds[1],p.bounds[3]},{p.bounds[2],p.bounds[4]}
  for _,q in ipairs(p.openings or{})do for _,x in ipairs{q[1],q[3]}do xs[#xs+1]=math.max(xs[1],math.min(p.bounds[3],x))end;for _,z in ipairs{q[2],q[4]}do zs[#zs+1]=math.max(p.bounds[2],math.min(p.bounds[4],z))end end
  table.sort(xs);table.sort(zs)
  for i=1,#xs-1 do for j=1,#zs-1 do
   local x0,x1,z0,z1=xs[i],xs[i+1],zs[j],zs[j+1];local cut=false
   for _,q in ipairs(p.openings or{})do if(x0+x1)/2>q[1]and(x0+x1)/2<q[3]and(z0+z1)/2>q[2]and(z0+z1)/2<q[4]then cut=true end end
   if not cut and x1>x0 and z1>z0 then
    local poly=M.clip({{x0,z0},{x1,z0},{x1,z1},{x0,z1}},outline);cap(poly,-.25);cap(poly,-4,true)
    for k,a in ipairs(poly)do local b=poly[k%#poly+1];face({point(a,-.25),point(b,-.25),point(b,-4),point(a,-4)},nil,.65)end
   end
  end end
 elseif side==6 then cap(outline,height+.05)
 else
  local along=0
  for i,a in ipairs(outline)do
   local b=outline[i%#outline+1];local dx,dz=b[1]-a[1],b[2]-a[2];local length=math.sqrt(dx*dx+dz*dz)
   if plan.sides[i]==side then
    local cuts={0,1};local horizontal=math.abs(dz)<.001;local vertical=math.abs(dx)<.001
    local axis0,axis1=horizontal and a[1]or a[2],horizontal and b[1]or b[2]
    if horizontal or vertical then for _,door in ipairs((p.doorways or{})[side]or{})do for _,edge in ipairs(door)do local t=(edge-axis0)/(axis1-axis0);if t>0 and t<1 then cuts[#cuts+1]=t end end end end
    table.sort(cuts)
    for j=1,#cuts-1 do
     local l,r=cuts[j],cuts[j+1];local y0,y1=opened and -3 or 0,opened and 0 or height
     if not opened and(horizontal or vertical)then local mid=axis0+(axis1-axis0)*(l+r)/2;for _,door in ipairs((p.doorways or{})[side]or{})do if mid>door[1]and mid<door[2]then y0=28 end end end
     local aa,bb={a[1]+dx*l,a[2]+dz*l},{a[1]+dx*r,a[2]+dz*r}
     local oa,ob=plan.outer[i],plan.outer[i%#outline+1]
     local ar,br={oa[1]+(ob[1]-oa[1])*l,oa[2]+(ob[2]-oa[2])*l},{oa[1]+(ob[1]-oa[1])*r,oa[2]+(ob[2]-oa[2])*r}
     local uv={{(along+length*l)/16,(height-y1)/height},{(along+length*r)/16,(height-y1)/height},{(along+length*r)/16,(height-y0)/height},{(along+length*l)/16,(height-y0)/height}}
     if not p.wallpaper then uv=nil end
     face({point(aa,y1),point(bb,y1),point(bb,y0),point(aa,y0)},uv,1)
     face({point(br,y1),point(ar,y1),point(ar,y0),point(br,y0)},uv,.8)
     face({point(ar,y1),point(br,y1),point(bb,y1),point(aa,y1)},uv,.9)
     face({point(aa,y0),point(bb,y0),point(br,y0),point(ar,y0)},uv,.65)
     face({point(ar,y1),point(aa,y1),point(aa,y0),point(ar,y0)},uv,.8)
     face({point(bb,y1),point(br,y1),point(br,y0),point(bb,y0)},uv,.8)
    end
   end
   along=along+length
  end
 end
 return v,indices
end
-- Wall-mounted art stays on the continuous rear plane, never on a cabinet-
-- shaped fold. Native windows/pilasters retain their own drawing and frame.
local attachments={center_screen=true,center_map=true,hoenn_center_map=true,mart_wall_notice=true,mart_rear_display=true,hoenn_mart_clock=true}
function M.fixture(p,source,openBox,sample,emit)
 if not p.serviceRoom then return false end
 local r,x,z=p.recipe,p.cx*16,p.cy*16
 if r.kind=='centerWall'and p.cy==0 then
  local mid=r.rows[1][1]
  if mid~=0x2d6 and mid~=0x2d7 and mid~=0x23f and mid~=0x25c then return true end
  openBox(x,0,3.9,x+p.w,32,4.02,sample(1,1))
  emit({{x,0,4.02},{x+p.w,0,4.02},{x+p.w,0,3.9},{x,0,3.9}},sample(1,1),.65)
  source(0,0,p.w,32,{x,32,4.04},{x+p.w,32,4.04},{x+p.w,0,4.04},{x,0,4.04},-1)
  return true
 end
 if not attachments[r.name]or p.cy~=0 then return false end
 local rect=r.facade or{0,0,p.w,p.d};local sx,sy,w,h=unpack(rect);local bottom=r.base or 11;local top=r.h or bottom+h
 openBox(x+sx,bottom,3.9,x+sx+w,top,4.22,sample(sx,sy))
 emit({{x+sx,bottom,4.22},{x+sx+w,bottom,4.22},{x+sx+w,bottom,3.9},{x+sx,bottom,3.9}},sample(sx,sy),.65)
 source(sx,sy,w,h,{x+sx,top,4.26},{x+sx+w,top,4.26},{x+sx+w,bottom,4.26},{x+sx,bottom,4.26},-1)
 return true
end
return M
