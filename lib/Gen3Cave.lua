-- Cave masses and boulders use their native palette and silhouette. Geometry
-- is presentation-only; a wall recipe also needs the cell's solid collision.
local V=...
local M={}
function M.wall(cells,c,emit,uvFor)
 return V.require('Gen3Terrain').append(cells,c,emit,uvFor)
end
function M.rock(c,emit,uvFor)
 local mask=V.require('Gen3Outdoor').mask(c.ts,c.mid,c.shape.ground)
 if not mask then return end
 local uv=assert(uvFor(c.ts,c.mid))
 local function tex(x,y)
  return {uv[1][1]+(uv[2][1]-uv[1][1])*x/16,
   uv[1][2]+(uv[3][2]-uv[1][2])*y/16}
 end
 local rows={};local first,last
 for y=0,15 do
  local left,right=16,-1
  for x=0,15 do if mask[y*16+x] then left=math.min(left,x);right=math.max(right,x+1)end end
  if right>left then rows[y]={left,right};first=first or y;last=y end
 end
 if not first then return end
 local rings={};local height=c.shape.height or last-first+1
 local centerZ=c.cy*16+8
 for y=first,last do
  local row=rows[y]
  if row then
   local centerX=c.cx*16+(row[1]+row[2])/2
   local radius=(row[2]-row[1])/2
   local ring={}
   for j=0,11 do
    local angle=j*math.pi/6
    -- The source contour supplies each layer's asymmetry. Varying depth
    -- gently avoids a row of identical spheres while retaining that outline.
    local depth=radius*(.84+.06*math.sin(y*1.7+c.cx*.8+c.cy*.3))
    local px=(row[1]+row[2])/2+radius*math.cos(angle)
    ring[j+1]={point={centerX+radius*math.cos(angle),height*(last-y)/(last-first+1),centerZ+depth*math.sin(angle)},
     tex=tex(math.max(.5,math.min(15.5,px)),y+.5)}
   end
   rings[#rings+1]=ring
  end
 end
 for i=1,#rings-1 do for j=1,12 do
  local k=j%12+1;local a,b,d,e=rings[i][j],rings[i][k],rings[i+1][k],rings[i+1][j]
  emit({a.point,b.point,d.point,e.point},{a.tex,b.tex,d.tex,e.tex},.82+.18*math.max(0,math.sin((j-.5)*math.pi/6)))
 end end
 -- Closed caps, including the underside for free cameras. There is no
 -- opaque square supporting the rock: only its actual footprint remains.
 for _,which in ipairs({1,#rings})do
  local ring=rings[which];local center={0,ring[1].point[2],centerZ}
  for _,p in ipairs(ring)do center[1]=center[1]+p.point[1]/12 end
  local t=tex((rows[which==1 and first or last][1]+rows[which==1 and first or last][2])/2,which==1 and first+.5 or last+.5)
  for j=1,12 do local a,b=ring[j],ring[j%12+1]
   emit({center,a.point,b.point,center},{t,a.tex,b.tex,t},which==1 and 1 or .7)
  end
 end
end
return M
