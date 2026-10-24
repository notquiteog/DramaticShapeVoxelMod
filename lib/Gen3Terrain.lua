-- Native General cliff masses. Raised rock caps and their steep bevels share
-- a continuous boundary height, so adjacent tiles cannot leave open cracks.
-- Only reviewed cliff artwork is raised; this is not a collision heightmap.
local M={}
local function solid(c)
 if not c or c.caveEntrance or c.shape and (c.shape.kind=='cliff' or c.shape.kind=='caveWall') then return true end
 local g=c.civic
 return g and g.custom and g.custom.geometry=='tower' and c.cy>=g.cy+(g.northRows or 0)
end
function M.height(cells,x,z,height,rows,tops)
 local cx,cy=math.floor(x/16),math.floor(z/16)
 local distance,boundary=4,0
 local topRow=tops and tops[cy]
 local top=topRow and topRow[cx]
 if top==nil then
  local low,high=math.huge,-math.huge
  for y=cy-2,cy+2 do for xx=cx-2,cx+2 do
   local c;if rows then c=rows[y] and rows[y][xx]else c=cells[xx..':'..y]end
   if c and not solid(c) then
    local h=c.floorHigh or c.base or 0
    low,high=math.min(low,h),math.max(high,h)
   end
  end end
  top=height or 32
  local support;if rows then support=rows[cy] and rows[cy][cx]else support=cells[cx..':'..cy]end
  local terrace=support and support.museumTerrace
  if terrace then top=terrace.groundHeight or support.base or 0
  elseif high>-math.huge then
   -- A retaining face meets the upper terrace. An outer enclosure above a
   -- single floor keeps its full wall height relative to that floor.
   top=high>low and high or high+top
  end
  if tops then
   if not topRow then topRow={};tops[cy]=topRow end
   topRow[cx]=top
  end
 end
 for y=cy-1,cy+1 do for xx=cx-1,cx+1 do
  local c;if rows then c=rows[y] and rows[y][xx]else c=cells[xx..':'..y]end
  if not solid(c)then
   local dx=math.max(xx*16-x,0,x-(xx+1)*16)
   local dz=math.max(y*16-z,0,z-(y+1)*16)
   local d=math.sqrt(dx*dx+dz*dz)
   -- A farther boundary cannot affect this sample, including slope height.
   if d<=distance then
    local h=c.base or 0
    if c.floor and c.floor.high then
     local t=math.max(0,math.min(1,(z-y*16)/16))
     if c.floor.reverse then t=1-t end
     h=(c.floorHigh or c.floor.high)-(c.floor.high-c.floor.low)*t
    end
    if d<distance then distance,boundary=d,h
    elseif d==distance then boundary=math.max(boundary,h)end
   end
  end
 end end
 return boundary+(top-boundary)*math.min(1,distance/4)
end
-- One sampler per completed scene layout, never retained across world edits.
-- Adjacent cliff cells share corners and numeric rows avoid temporary string
-- keys in both neighborhood scans. Heights remain separated by wall profile.
function M.sampler(cells,tick)
 local rows,heights,profiles={},{},{}
 for _,c in pairs(cells)do
  local row=rows[c.cy];if not row then row={};rows[c.cy]=row end
  row[c.cx]=c;if tick then tick()end
 end
 return function(_,x,z,height)
  local layer=heights[height];if not layer then layer={};heights[height]=layer end
  local tops=profiles[height];if not tops then tops={};profiles[height]=tops end
  local row=layer[z];if not row then row={};layer[z]=row end
  -- Every corner within a cell shares its 5x5 support profile. Only the
  -- distance to the 3x3 boundary depends on the exact sample position.
  if row[x]==nil then row[x]=M.height(cells,x,z,height,rows,tops)end
  return row[x]
 end
end
function M.append(cells,c,emit,uvFor,heightAt)
 local x,z=c.cx*16,c.cy*16;local height=c.shape.height or 32
 local cap=assert(uvFor(c.ts,c.shape.cap or 113));local cliff=assert(uvFor(c.ts,c.shape.side or 121))
 -- Sixteen quads share twenty-five corners. Sample each exact corner
 -- once; this cache cannot outlive changes to the surrounding cells.
 local heights={}
 heightAt=heightAt or M.height
 for iz=0,4 do for ix=0,4 do heights[iz*5+ix+1]=heightAt(cells,x+ix*4,z+iz*4,height)end end
 -- A flat cap has affine UVs and uniform shading: its sixteen cells are
 -- exactly the same surface as one quad. Keep every bevel cell unchanged.
 local level=heights[1];local flatCap=level~=0
 for i=2,25 do if heights[i]~=level then flatCap=false;break end end
 if flatCap then
  emit({{x,level,z},{x+16,level,z},{x+16,level,z+16},{x,level,z+16}},cap,1)
  return
 end
 -- Each UV coordinate belongs to one of five grid lines or 25 heights.
 -- Precompute scalars only: emitted UV/vertex tables remain independently
 -- owned, while neighboring quads avoid repeated closures and slope clamps.
 local capU,capV,sideU,sideV={},{},{},{}
 local cl,ct=cap[1][1],cap[1][2]
 local cw,ch=cap[2][1]-cl,cap[3][2]-ct
 local sl,st=cliff[1][1],cliff[1][2]
 local sw,sh=cliff[2][1]-sl,cliff[3][2]-st
 for i=0,4 do
  capU[i+1]=cl+cw*(i*4)/16;capV[i+1]=ct+ch*(i*4)/16
  sideU[i+1]=sl+((i*4)/16)*sw
 end
 for i=1,25 do sideV[i]=st+(1-math.max(0,math.min(1,heights[i]/height)))*sh end
 for iz=0,3 do for ix=0,3 do
  local a,b=ix*4,iz*4;local u,v=a+4,b+4
  local k=iz*5+ix+1
  local h1,h2=heights[k],heights[k+1]
  local h3,h4=heights[k+6],heights[k+5]
  local flat=h1==h2 and h2==h3 and h3==h4 and h1~=0
  local tex
  if flat then
   tex={{capU[ix+1],capV[iz+1]},{capU[ix+2],capV[iz+1]},
        {capU[ix+2],capV[iz+2]},{capU[ix+1],capV[iz+2]}}
  else
   -- Follow the cliff's horizontal tangent on either axis. Using each
   -- quad's U=0..1 compressed four repetitions into every source tile.
   local alongZ=math.abs(h1-h2)+math.abs(h4-h3)>math.abs(h1-h4)+math.abs(h2-h3)
   local u1=sideU[(alongZ and iz or ix)+1]
   local u2=sideU[(alongZ and iz or ix+1)+1]
   local u3=sideU[(alongZ and iz+1 or ix+1)+1]
   local u4=sideU[(alongZ and iz+1 or ix)+1]
   tex={{u1,sideV[k]},{u2,sideV[k+1]},
        {u3,sideV[k+6]},{u4,sideV[k+5]}}
  end
  emit({{x+a,h1,z+b},{x+u,h2,z+b},{x+u,h3,z+v},{x+a,h4,z+v}},tex,flat and 1 or .84)
 end end
end
return M
