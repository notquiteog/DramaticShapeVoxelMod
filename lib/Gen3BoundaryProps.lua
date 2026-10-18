-- Reviewed native boundary drawings. No map IDs, gameplay or collision edits.
local M={}
local hedges={
 [0x23f]={0,4,16,16},[0x244]={0,0,16,16},[0x245]={0,0,16,16},
 [0x246]={0,0,16,16},[0x24c]={0,0,16,16},[0x254]={0,0,16,12},
 [0x264]={0,0,16,12},[0x265]={0,0,16,12},[0x266]={0,0,16,16},
}
function M.hoenn(primary,secondary,mid,collision)
 if primary=='general' and secondary=='petalburg' and collision==7 and hedges[mid]then
  return {kind='hedge',ground=1,height=7,bounds=hedges[mid]}
 end
end
function M.prepare(cells)
 for _,c in pairs(cells)do if c.shape.kind=='hedge'then
  c.hedgeJoin={};local b=c.shape.bounds
  for i,d in ipairs{{-1,0},{1,0},{0,-1},{0,1}}do
   local n=cells[(c.cx+d[1])..':'..(c.cy+d[2])];local q=n and n.shape.kind=='hedge'and n.shape.bounds
   c.hedgeJoin[i]=q and ((i==1 and b[1]==0 and q[3]==16 and b[2]==q[2]and b[4]==q[4])
    or(i==2 and b[3]==16 and q[1]==0 and b[2]==q[2]and b[4]==q[4])
    or(i==3 and b[2]==0 and q[4]==16 and b[1]==q[1]and b[3]==q[3])
    or(i==4 and b[4]==16 and q[2]==0 and b[1]==q[1]and b[3]==q[3]))or false
  end
 end end
end
function M.hedge(c,emit,uv)
 local s=c.shape;local b=s.bounds;local x,z=c.cx*16,c.cy*16
 local a,n,r,f=x+b[1],z+b[2],x+b[3],z+b[4];local h=s.height
 local j=c.hedgeJoin or{};local l,t,u,v=a+(j[1]and 0 or 2),n+(j[3]and 0 or 2),r-(j[2]and 0 or 2),f-(j[4]and 0 or 2)
 local function tex(l,t,u,v)
  local function p(xx,yy)return {uv[1][1]+(uv[2][1]-uv[1][1])*xx/16,uv[1][2]+(uv[3][2]-uv[1][2])*yy/16}end
  return {p(l,t),p(u,t),p(u,v),p(l,v)}
 end
 -- Separate clipped top and leafy skirt; never wrap source ground corners
 -- down the side. The two-pixel shoulder gives the hedge a closed volume.
 emit({{l,h,t},{u,h,t},{u,h,v},{l,h,v}},tex(4,4,12,8),1)
 local edges={{{a,n},{r,n},{l,t},{u,t},3},{{r,n},{r,f},{u,t},{u,v},2},
  {{r,f},{a,f},{u,v},{l,v},4},{{a,f},{a,n},{l,v},{l,t},1}}
 for _,e in ipairs(edges)do if not j[e[5]]then
  emit({{e[1][1],0,e[1][2]},{e[2][1],0,e[2][2]},{e[4][1],h-2,e[4][2]},{e[3][1],h-2,e[3][2]}},tex(2,15,14,10),.84)
  emit({{e[3][1],h-2,e[3][2]},{e[4][1],h-2,e[4][2]},{e[4][1],h,e[4][2]},{e[3][1],h,e[3][2]}},tex(4,10,12,8),.95)
 end end
end
return M
