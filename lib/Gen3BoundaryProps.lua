-- Reviewed native boundary drawings. No map IDs, gameplay or collision edits.
local V=...
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
 -- Share the actual exposed perimeter of each connected hedge. Rounded
 -- shoulders are measured from that perimeter, so neighboring top grids
 -- agree exactly and never leave a dark divider between source cells.
 local seen={}
 for _,root in pairs(cells)do if root.shape.kind=='hedge'and not seen[root]then
  local group,edges={root},{};seen[root]=true;local index=1
  while group[index]do
   local c=group[index];index=index+1
   local b=c.shape.bounds;local a,n,r,f=c.cx*16+b[1],c.cy*16+b[2],c.cx*16+b[3],c.cy*16+b[4]
   local boundary={{a,n,a,f},{r,n,r,f},{a,n,r,n},{a,f,r,f}}
   for i,d in ipairs{{-1,0},{1,0},{0,-1},{0,1}}do
    if c.hedgeJoin[i]then
     local nextCell=cells[(c.cx+d[1])..':'..(c.cy+d[2])]
     if not seen[nextCell]then seen[nextCell]=true;group[#group+1]=nextCell end
    else edges[#edges+1]=boundary[i]end
   end
  end
  for _,c in ipairs(group)do c.hedgeEdges=edges end
 end end
end
function M.hedge(c,emit)
 local model=V and V.require('Gen3Hedges')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3Hedges.lua')
 return model.append(c,emit)
end
return M
