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
 -- Carve over the mask's OWN bounding box, not the whole 16x16 tile. A
 -- metatile draws its boulder in the middle with a wall behind it, so hulling
 -- the full tile makes the block as wide as the artwork and the floor stripe
 -- and the loose dirt speckle the test is about come along with it. The older
 -- ring builder trimmed each row to its own extent for the same reason, and
 -- this is the same guarantee expressed as a hull: the boulder's silhouette
 -- decides its size, and the art around it is not sampled as part of it.
 local minX,minY,maxX,maxY=16,16,-1,-1
 for y=0,15 do for x=0,15 do
  if mask[y*16+x]then
   if x<minX then minX=x end;if x+1>maxX then maxX=x+1 end
   if y<minY then minY=y end;if y+1>maxY then maxY=y+1 end
  end
 end end
 if maxX<minX or maxY<minY then return end
 local hw,hh=maxX-minX,maxY-minY
 -- `bottom` is how many of the carving box's rows sit BELOW the shape, which
 -- VoxelHull turns into height = h - bottom. It is not the height itself:
 -- passing the full height would zero the height and emit no faces at all.
 -- The metatile's own bottom padding, if any, is what belongs here.
 local bottom=15-maxY
 local H=V.require('VoxelHull')
 -- The hull is built over the BLOCK, which is hw x hh and centred on itself,
 -- so the block-local coordinate maps back to the metatile as minX + x.
 local sample=function(x,y)
  local sx,sy=minX+x,minY+y
  local r,g,b,a=c.ts.imageData:getPixel(px+sx,py+sy)
  -- Merged source colour only selects coplanar merges; draw uses the live
  -- native atlas (including its native BG2 pass) through the sampled UV.
  local uvx,uvy=unpack(tex(sx+.5,sy+.5))
  return r,g,b,mask[sy*16+sx]and a or 0,uvx,uvy
 end
 local card=V.require('TreePresentation').props:get()=='cards'
 local hull=card and H.card(hw,hh,sample,bottom,c.shape.height or 16)
  or H.build(hw,hh,sample,1,bottom,nil,'rock')
 -- VoxelHull emits a block spanning [-w/2, w/2] about the origin, so the
 -- block's centre in metatile space is (minX+minY)/2 + size/2. Offsetting by
 -- the centre -- not the minimum -- lands the silhouette back exactly where the
 -- drawing put it, so a boulder drawn left of centre stays left of centre.
 local ox,oz=minX+hw/2,minY+hh/2
 for _,q in ipairs(hull)do
  local points={};local t={q.u,q.v}
  for _,p in ipairs(q)do
   points[#points+1]={c.cx*16+ox+p[1],
    p[2]*(card and 1 or (c.shape.height or 16)/16),
    c.cy*16+oz+p[3]}
  end
  emit(points,{t,t,t,t},q.shade,card and {c.cx*16+8,c.cy*16+8,.001} or nil)
 end
end
return M
