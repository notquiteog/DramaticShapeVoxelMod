-- Exposed faces of an exact axis-aligned box union. Native artwork/UVs stay
-- on their original planes; internal contacts and duplicate faces disappear.
local M={}
local epsilon=1e-7
local faces={{2,1,.88},{3,1,.72},{3,-1,.66},{1,-1,.7},{1,1,.7},{2,-1,.65}}
function M.append(boxes,emit)
 for index,b in ipairs(boxes)do
  local l,y,n,r,h,s=b.lo[1],b.lo[2],b.lo[3],b.hi[1],b.hi[2],b.hi[3]
  local quads={{{l,h,n},{r,h,n},{r,h,s},{l,h,s}},{{l,h,s},{r,h,s},{r,y,s},{l,y,s}},
   {{r,h,n},{l,h,n},{l,y,n},{r,y,n}},{{l,h,n},{l,h,s},{l,y,s},{l,y,n}},
   {{r,h,s},{r,h,n},{r,y,n},{r,y,s}},{{l,y,s},{r,y,s},{r,y,n},{l,y,n}}}
  for face,f in ipairs(faces)do
   local axis,direction=f[1],f[2];local plane=direction>0 and b.hi[axis]or b.lo[axis]
   local axes={};for k=1,3 do if k~=axis then axes[#axes+1]=k end end
   local a,c=axes[1],axes[2];local cuts={{b.lo[a],b.hi[a]},{b.lo[c],b.hi[c]}};local others={}
   for other,o in ipairs(boxes)do
    if other~=index and o.lo[axis]<=plane+epsilon and o.hi[axis]>=plane-epsilon
     and o.lo[a]<b.hi[a]-epsilon and o.hi[a]>b.lo[a]+epsilon and o.lo[c]<b.hi[c]-epsilon and o.hi[c]>b.lo[c]+epsilon then
     others[#others+1]={box=o,index=other}
     for i,k in ipairs(axes)do for _,v in ipairs{o.lo[k],o.hi[k]}do if v>b.lo[k]+epsilon and v<b.hi[k]-epsilon then cuts[i][#cuts[i]+1]=v end end end
    end
   end
   for i,values in ipairs(cuts)do table.sort(values);local unique={}
    for _,v in ipairs(values)do if #unique==0 or v-unique[#unique]>epsilon then unique[#unique+1]=v end end;cuts[i]=unique
   end
   for i=1,#cuts[1]-1 do for j=1,#cuts[2]-1 do
    local low,high={b.lo[1],b.lo[2],b.lo[3]},{b.hi[1],b.hi[2],b.hi[3]}
    low[a],high[a]=cuts[1][i],cuts[1][i+1];low[c],high[c]=cuts[2][j],cuts[2][j+1]
    local x,z=(low[a]+high[a])/2,(low[c]+high[c])/2;local hidden=false
    for _,entry in ipairs(others)do local o=entry.box
     if x>o.lo[a]+epsilon and x<o.hi[a]-epsilon and z>o.lo[c]+epsilon and z<o.hi[c]-epsilon then
      local outside=direction>0 and o.hi[axis]>plane+epsilon or direction<0 and o.lo[axis]<plane-epsilon
      local same=math.abs((direction>0 and o.hi[axis]or o.lo[axis])-plane)<epsilon
      if outside or same and entry.index<index then hidden=true;break end
     end
    end
    if not hidden then
     local q,uv={},{}
     for _,corner in ipairs(quads[face])do
      local p={corner[1],corner[2],corner[3]}
      for _,k in ipairs(axes)do p[k]=math.abs(corner[k]-b.lo[k])<epsilon and low[k]or high[k]end
      local u,v=0,0
      for k,original in ipairs(quads[face])do local weight=1
       for _,dim in ipairs(axes)do local t=(p[dim]-b.lo[dim])/(b.hi[dim]-b.lo[dim]);weight=weight*(math.abs(original[dim]-b.lo[dim])<epsilon and 1-t or t)end
       u=u+b.uv[k][1]*weight;v=v+b.uv[k][2]*weight
      end
      q[#q+1]=p;uv[#uv+1]={u,v}
     end
     emit(q,uv,f[3])
    end
   end end
  end
 end
end
return M
