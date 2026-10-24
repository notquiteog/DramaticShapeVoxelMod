local L=dofile('lib/BuildingLights.lua')
local pixels,dimensions,released,writes={},nil,0,0
love={image={newImageData=function(w,h)
 dimensions={w,h}
 return {setPixel=function(_,x,y,r,g,b,a)
  assert(x>=0 and x<w and y>=0 and y<h and not pixels[y*w+x],'duplicate/outside pixel')
  pixels[y*w+x]={r,g,b,a};writes=writes+1
 end,release=function()released=released+1 end}
end},graphics={newImage=function()return {setFilter=function()end,setWrap=function()end}end}}
local parts={{lights={{-120,10,-140,30,0,1},{140,8,120,30,1,0},{140,12,120,30,0,1}}}}
local baked=L.bake(parts)
local checks=0
local field=L.texture(parts,function()checks=checks+1 end)
local nx,ny,nz=unpack(baked.size);local width,height,cols=unpack(field.atlas)
local expected=0
-- Reference the previous dense traversal, including unlit voxels and padding.
for iy=0,ny-1 do
 local ox,oz=(iy%cols)*(nx+2)+1,math.floor(iy/cols)*(nz+2)+1
 for iz=0,nz-1 do for ix=0,nx-1 do
  local v=(baked.values[(iy*nz+iz)*nx+ix+1]or 0)/1.2
  local pixel=pixels[(oz+iz)*width+ox+ix]
  if v>0 then
   expected=expected+1
   assert(pixel and pixel[1]==v and pixel[2]==v and pixel[3]==v and pixel[4]==1,'light texture value changed')
  else assert(not pixel,'unlit volume was painted')end
 end end
end
assert(writes==expected and writes<nx*ny*nz/4 and released==1 and checks>0)
assert(not field.values and dimensions[1]==width and dimensions[2]==height)
print(('PASS sparse light texture matches dense reference: %d writes / %d volume cells, upload release and cooperative checks'):format(writes,nx*ny*nz))
