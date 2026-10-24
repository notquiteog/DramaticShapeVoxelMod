-- Closed native-painted rock enclosure outside the playable cave bounds.
-- Adjacent strata share vertices; there are no overlapping stacked boxes.
local M={}
function M.geometry(p,side,opened)
 local b,h=p.bounds,p.height;local x0,z0,x1,z1=b[1],b[2],b[3],b[4]
 local horizontal=side==1 or side==3
 local first,last=horizontal and x0 or z0,horizontal and x1 or z1
 local line=side==1 and z0 or side==3 and z1 or side==2 and x1 or x0
 local sign=(side==1 or side==4)and-1 or 1
 local vertices,indices={},{}
 local function point(a,y,d)
  return horizontal and{a,y,line+sign*d}or{line+sign*d,y,a}
 end
 local holes
 local function depth(a,y)
  if a==first or a==last then return 0 end
  for _,q in ipairs(holes or{})do local high=q[3]+(q[4]or 32)
   if q[4]and a>=q[1]and a<=q[2]and y>=q[3]and y<=high
    and(a==q[1]or a==q[2]or y==q[3]or y==high)then return 0 end
  end
  -- Faceted, shallow stone relief remains entirely outside native floor.
  return .2+((math.floor(a/16)*7+math.floor((y+4)/12)*3+side*5)%5)*.3
 end
 local function face(q)
  local start=#vertices
  for _,v in ipairs(q)do
   local a=horizontal and v[1]or v[3]
   vertices[#vertices+1]={v[1],v[2],v[3],(a-first)/16,(h-v[2])/(p.wallpaperHeight or 28),1}
  end
  for _,i in ipairs(#q==3 and{1,2,3}or{1,2,3,1,3,4})do indices[#indices+1]=start+i end
 end
 holes={}
 for _,q in ipairs(p.passages and p.passages[side]or{})do holes[#holes+1]={q[1],q[2],q[3],q[4]}end
 table.sort(holes,function(a,c)return a[1]<c[1]end)
 local merged={}
 for _,q in ipairs(holes)do local prev=merged[#merged]
  if prev and prev[3]==q[3]and(prev[4]or 32)==(q[4]or 32)and q[1]<=prev[2]then prev[2]=math.max(prev[2],q[2])else merged[#merged+1]=q end
 end
 holes=merged
 local cuts={first,last};for a=first+16,last-1,16 do cuts[#cuts+1]=a end
 for _,q in ipairs(holes)do cuts[#cuts+1]=q[1];cuts[#cuts+1]=q[2]end
 table.sort(cuts)
 local heights={-4,h}
 if opened then heights={-4,0}else
  for y=0,h-1,12 do heights[#heights+1]=y end
  for _,q in ipairs(holes)do heights[#heights+1]=q[3];heights[#heights+1]=q[3]+(q[4]or 32)end
  table.sort(heights)
 end
 for i=1,#cuts-1 do local a,c=cuts[i],cuts[i+1]
  if c>a and a>=first and c<=last then
   for j=1,#heights-1 do local low,high=heights[j],heights[j+1];local void=false
    for _,q in ipairs(holes)do if(a+c)/2>q[1]and(a+c)/2<q[2]and(low+high)/2>=q[3]and(low+high)/2<q[3]+(q[4]or 32)then void=true end end
    if high>low and not void then
     face({point(a,low,depth(a,low)),point(c,low,depth(c,low)),point(c,high,depth(c,high)),point(a,high,depth(a,high))})
     face({point(c,low,6),point(a,low,6),point(a,high,6),point(c,high,6)})
    end
   end
   for _,y in ipairs({-4,opened and 0 or h})do
    face({point(a,y,depth(a,y)),point(c,y,depth(c,y)),point(c,y,6),point(a,y,6)})
   end
  end
 end
 if not opened then
  for _,q in ipairs(holes)do
   local low,high=q[3],q[3]+(q[4]or 32)
   for _,a in ipairs({q[1],q[2]})do
    local ys={low,high};for _,y in ipairs(heights)do if y>low and y<high then ys[#ys+1]=y end end;table.sort(ys)
    for j=1,#ys-1 do local l,u=ys[j],ys[j+1]
     if u>l then face({point(a,l,depth(a,l)),point(a,l,6),point(a,u,6),point(a,u,depth(a,u))})end
    end
   end
   for _,y in ipairs({low,high})do
    for i=1,#cuts-1 do local a,c=math.max(q[1],cuts[i]),math.min(q[2],cuts[i+1])
     if c>a then face({point(a,y,depth(a,y)),point(c,y,depth(c,y)),point(c,y,6),point(a,y,6)})end
    end
   end
  end
 end
 -- One corner wedge per side closes the external ring without intersecting
 -- adjacent wall boxes. Its front edge is the shared native bounds corner.
 local corner=({{{x0,z0},{x0,z0-6},{x0-6,z0}},{{x1,z0},{x1+6,z0},{x1,z0-6}},
  {{x1,z1},{x1,z1+6},{x1+6,z1}},{{x0,z1},{x0-6,z1},{x0,z1+6}}})[side]
 local top=opened and 0 or h
 local a,c=corner[2],corner[3]
 face({{a[1],-4,a[2]},{c[1],-4,c[2]},{c[1],top,c[2]},{a[1],top,a[2]}})
 for _,y in ipairs({-4,top})do face({{corner[1][1],y,corner[1][2]},{a[1],y,a[2]},{c[1],y,c[2]}})end
 return vertices,indices
end
return M
