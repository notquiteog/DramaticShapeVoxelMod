-- Lavender's full elevation spans Route 10 and the town. Keep its faceted
-- window bays, green dome and antenna; close the unseen elevations.
local M={}
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16;local W,D,H=p.w,p.front-p.back,p.wall
 local atlasW=p.w*2+4
 local function uv(l,t,r,b)return {{l/atlasW,t/p.h},{r/atlasW,t/p.h},{r/atlasW,b/p.h},{l/atlasW,b/p.h}}end
 local wall=uv(p.w*2+.5,.5,p.w*2+.5,.5)
 local trim=uv(p.w*2+2.5,.5,p.w*2+2.5,.5)
 -- The masonry podium fills the entire rectangle, including the corners
 -- beside the native cliffs. Only the windowed upper storeys are faceted.
 local base=48
 local function baseFace(vertices,tex,shade)emit(vertices,tex or wall,shade or 1)end
 baseFace({{x,base,z+p.front},{x+W,base,z+p.front},{x+W,0,z+p.front},{x,0,z+p.front}})
 baseFace({{x+W,base,z+p.back},{x,base,z+p.back},{x,0,z+p.back},{x+W,0,z+p.back}},wall,.8)
 for _,sx in ipairs({x,x+W})do
  baseFace({{sx,base,z+p.back},{sx,base,z+p.front},{sx,0,z+p.front},{sx,0,z+p.back}},wall,.86)
 end
 baseFace({{x,base,z+p.back},{x+W,base,z+p.back},{x+W,base,z+p.front},{x,base,z+p.front}},wall,.94)
 -- Keep the native doorway on the front; outside source corners contain
 -- cliff/background pixels and must not be stretched onto the masonry.
 baseFace({{x+16,base,z+p.front+.025},{x+W-16,base,z+p.front+.025},
  {x+W-16,0,z+p.front+.025},{x+16,0,z+p.front+.025}},uv(16.05,p.wallBottom-base+.05,W-16.05,p.wallBottom-.05))
 local cut=16
 local points={{cut,0},{W-cut,0},{W-4,cut},{W-4,D-cut},{W-cut,D},{cut,D},{4,D-cut},{4,cut}}
 local sourceTop=math.max(0,p.wallTop)
 local sourceHeight=p.wallBottom-sourceTop
 for i,a in ipairs(points)do
  local b=points[i%#points+1]
  local function panel(y0,y1,tex,offset)
   local dx,dz=b[1]-a[1],b[2]-a[2];local n=math.sqrt(dx*dx+dz*dz)
   local ox,oz=dz/n*(offset or 0),-dx/n*(offset or 0)
   emit({{x+a[1]+ox,y1,z+p.back+a[2]+oz},{x+b[1]+ox,y1,z+p.back+b[2]+oz},
    {x+b[1]+ox,y0,z+p.back+b[2]+oz},{x+a[1]+ox,y0,z+p.back+a[2]+oz}},tex,1)
  end
  panel(base,H,wall)
  if i>=4 and i<=6 then
   local l,r=math.min(a[1],b[1]),math.max(a[1],b[1])
   panel(base,sourceHeight,uv(r-.05,sourceTop+.05,l+.05,p.wallBottom-base-.05),.025)
  else
   local bays=math.max(1,math.floor(math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)/18))
   for j=0,bays-1 do
    local t0,t1=(j+.13)/bays,(j+.87)/bays
    local ax,az=a[1]+(b[1]-a[1])*t0,a[2]+(b[2]-a[2])*t0
    local bx,bz=a[1]+(b[1]-a[1])*t1,a[2]+(b[2]-a[2])*t1
    local dx,dz=b[1]-a[1],b[2]-a[2];local n=math.sqrt(dx*dx+dz*dz)
    local ox,oz=dz/n*.04,-dx/n*.04
    emit({{x+ax+ox,H-4,z+p.back+az+oz},{x+bx+ox,H-4,z+p.back+bz+oz},
     {x+bx+ox,48,z+p.back+bz+oz},{x+ax+ox,48,z+p.back+az+oz}},uv(32.05,sourceTop+.05,47.95,sourceTop+63.95),.9)
   end
  end
  panel(H-2,H,trim,.06)
  emit({{x+W/2,H,z+p.back+D/2},{x+b[1],H,z+p.back+b[2]},
    {x+a[1],H,z+p.back+a[2]},{x+W/2,H,z+p.back+D/2}},wall,.92)
 end
 -- Shallow copper-green dome. Its swatch is sampled from the native crown,
 -- not a fabricated replacement texture. Rings close at the pole.
 local dome=(g.northRows or 0)>0 and uv(52.5,36.5,52.5,36.5) or wall
 local rim=(g.northRows or 0)>0 and uv(16.5,40.5,16.5,40.5) or trim
 local cx,cz=x+W/2,z+p.back+D/2
 local function ring(theta,phi)
  return {cx+math.cos(theta)*math.cos(phi)*(W/2-9),H+3+math.sin(phi)*34,cz+math.sin(theta)*math.cos(phi)*(D/2-9)}
 end
 for j=0,5 do for i=0,15 do
  local a,b=i*math.pi/8,(i+1)*math.pi/8
  local t,u=j*math.pi/12,(j+1)*math.pi/12
  emit({ring(a,t),ring(b,t),ring(b,u),ring(a,u)},dome,.82+.18*math.sin((t+u)/2)+.05*math.cos((a+b)/2))
 end end
 -- Antenna is a narrow closed mast, not a camera-facing duplicated card.
 for i=0,7 do
  local a,b=i*math.pi/4,(i+1)*math.pi/4
  local r=1.3
  emit({{cx+math.cos(a)*r,H+49,cz+math.sin(a)*r},{cx+math.cos(b)*r,H+49,cz+math.sin(b)*r},
   {cx+math.cos(b)*r,H+36,cz+math.sin(b)*r},{cx+math.cos(a)*r,H+36,cz+math.sin(a)*r}},rim,.9)
  emit({{cx,H+50,cz},{cx+math.cos(b)*r,H+49,cz+math.sin(b)*r},
   {cx+math.cos(a)*r,H+49,cz+math.sin(a)*r},{cx,H+50,cz}},rim,1)
 end
end
return M
