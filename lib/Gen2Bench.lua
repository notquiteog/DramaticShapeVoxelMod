-- Open slatted park bench: a low seat, inclined back, arms and four legs.
-- The native drawing supplies its material; no floor-sized box is emitted.
local M={}
function M.build(t,data,pr,aw,ah)
 local tones={}
 for _,row in ipairs(t.tiles) do for _,tile in ipairs(row) do
  for y=0,7 do for x=0,7 do
   local ax,ay=tile%pr*8+x,math.floor(tile/pr)*8+y
   local r,g,b,a=data:getPixel(ax,ay)
   local value=(r+g+b)/3
   if a>.5 and value>.08 and value<.72 then
    tones[#tones+1]={value=value,u=(ax+.5)/aw,v=(ay+.5)/ah}
   end
  end end
 end end
 if #tones==0 then return {} end
 table.sort(tones,function(a,b)return a.value<b.value end)
 local dark=tones[math.max(1,math.floor(#tones*.25))]
 local light=tones[math.max(1,math.floor(#tones*.8))]
 local out={}
 local function box(x0,y0,z0,x1,y1,z1,tone,lean)
  local function p(x,y,z)return {x,y,z-(lean or 0)*(y-y0)} end
  local a,b,c,d=p(x0,y0,z0),p(x1,y0,z0),p(x1,y0,z1),p(x0,y0,z1)
  local e,f,g,h=p(x0,y1,z0),p(x1,y1,z0),p(x1,y1,z1),p(x0,y1,z1)
  for i,face in ipairs({{e,f,g,h},{a,d,c,b},{a,b,f,e},{b,c,g,f},{c,d,h,g},{d,a,e,h}}) do
   local uv={tone.u,tone.v}
   face.uv={uv,uv,uv,uv};face.shade=i==1 and 1 or .76
   out[#out+1]=face
  end
 end
 for _,x in ipairs({3,26}) do
  for _,z in ipairs({10,20}) do box(x,0,z,x+2,7,z+2,dark) end
  box(x,6,8,x+2,14,10,dark,.12)
  box(x-1,9,10,x+3,10.2,22,light)
 end
 for i=0,3 do box(1,5.7,10+i*3,31,7,12+i*3,light) end
 for i=0,2 do box(1,8+i*2.5,8-i*.35,31,9.8+i*2.5,9.2-i*.35,light,.12) end
 return out
end
return M
