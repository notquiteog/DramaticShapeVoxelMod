-- A small ground-contact shadow survives wide shadow-map texels and grazing
-- sun angles. Cast silhouettes still provide the full directional shadow.
local V=...
local R,Mat=V.require('Voxel3D'),V.require('Mat4')
local M={}
local mesh,image
function M.draw(x,z,ground,lift,width)
 if not V.require('Shadows').enabled() then return end
 lift=math.max(0,lift or 0);if lift>=16 then return end
 if not image then
  local data=love.image.newImageData(16,16)
  for y=0,15 do for x=0,15 do
   local d=((x-7.5)/8)^2+((y-7.5)/8)^2
   data:setPixel(x,y,.03,.035,.04,math.max(0,1-d)^2*.3)
  end end
  image=love.graphics.newImage(data);image:setFilter('linear','linear');data:release()
  mesh=R.newMesh({{-1,0,-1,0,0,1},{1,0,-1,1,0,1},{1,0,1,1,1,1},{-1,0,1,0,1,1}},{1,2,3,1,3,4})
 end
 if not mesh then return end
 local radius=math.max(1.5,math.min(5,(width or 16)*.23))*(1-lift/24)
 R.withEffect('alpha',function()
  love.graphics.setColor(1,1,1,1-lift/16)
  R.draw(mesh,image,Mat.mul(Mat.translate(x,(ground or 0)+.08,z),Mat.scale(radius,1,radius*.7)))
 end)
end
return M
