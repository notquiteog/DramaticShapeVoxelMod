-- Cave masses and boulders use their native palette and silhouette. Geometry
-- is presentation-only; a wall recipe also needs the cell's solid collision.
local V=...
local M={}
local function boulderMask(mask)
 -- One metatile contains one boulder. Its source drawing may also include
 -- disconnected floor stripes or grit whose colours differ from the ground
 -- swatch; those are not extra rings of the rock's silhouette.
 local visited,best={},{}
 for start=0,255 do if mask[start] and not visited[start] then
  local component,queue={}, {start};visited[start]=true
  local at=1
  while queue[at] do
   local k=queue[at];at=at+1;component[#component+1]=k
   local x,y=k%16,math.floor(k/16)
   for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}})do
    local nx,ny=x+d[1],y+d[2];local nextKey=ny*16+nx
    if nx>=0 and nx<16 and ny>=0 and ny<16 and mask[nextKey] and not visited[nextKey] then
     visited[nextKey]=true;queue[#queue+1]=nextKey
    end
   end
  end
  if #component>#best then best=component end
 end end
 local out={};for _,k in ipairs(best)do out[k]=true end
 return out
end
function M.wall(cells,c,emit,uvFor)
 return V.require('Gen3Terrain').append(cells,c,emit,uvFor)
end
function M.rock(c,emit,uvFor)
 local mask=V.require('Gen3Outdoor').mask(c.ts,c.mid,c.shape.ground)
 if not mask then return end
 mask=boulderMask(mask)
 local uv=assert(uvFor(c.ts,c.mid))
 local function tex(x,y)
  return {uv[1][1]+(uv[2][1]-uv[1][1])*x/16,
   uv[1][2]+(uv[3][2]-uv[1][2])*y/16}
 end
 local slot=c.ts.midToSlot[c.mid]
 local px,py=slot%c.ts.cols*16,math.floor(slot/c.ts.cols)*16
 local bottom=0
 for y=15,0,-1 do
  local any=false;for x=0,15 do if mask[y*16+x]then any=true;break end end
  if any then break end;bottom=bottom+1
 end
 local hull=V.require('VoxelHull').build(16,16,function(x,y)
  local r,g,b,a=c.ts.imageData:getPixel(px+x,py+y)
  -- Merged source colour only selects coplanar merges; draw uses the live
  -- native atlas (including its native BG2 pass) through the sampled UV.
  local uvx,uvy=unpack(tex(x+.5,y+.5))
  return r,g,b,mask[y*16+x]and a or 0,uvx,uvy
 end,1,bottom)
 for _,q in ipairs(hull)do
  local points={};local t={q.u,q.v}
  for _,p in ipairs(q)do points[#points+1]={c.cx*16+8+p[1],p[2]*(c.shape.height or 16)/16,c.cy*16+8+p[3]}end
  emit(points,{t,t,t,t},q.shade)
 end
end
return M
