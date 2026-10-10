-- Narrow native research workstation; adjacent chair stays on native floor.
local M={}
function M.append(p,source,box,sample,emit)
 local originalBox=box
 box=function(a,b,n,c,h,f,t)
  originalBox(a,b,n,c,h,f,t)
  emit({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 local x,z=p.cx*16,p.cy*16
 if p.recipe.kind=='labSideCabinet' then
  local wood=sample(4,18)
  box(x+1,0,z+17,x+15,8,z+31,wood)
  box(x+.5,8,z+16.5,x+15.5,9,z+31.5,wood)
  source(1,16,14,3,{x+1,9.02,z+17},{x+15,9.02,z+17},{x+15,9.02,z+31},{x+1,9.02,z+31})
  source(1,19,14,11,{x+1,8,z+31.02},{x+15,8,z+31.02},{x+15,0,z+31.02},{x+1,0,z+31.02})
  return
 end
 if p.recipe.kind=='labStacks' then
  local function color(px,py)return sample(px,py+(p.recipe.sourceOffset or 0))end
  for row=0,1 do
   local n=z+row*16+(p.recipe.stackOffset or 0)
   local covers={color(4,12),color(8,10),color(7,4)}
   for layer=0,2 do
    local a=layer%2;local cover=covers[layer+1]
    box(x+1+a,layer*2,n+3,x+14-a,layer*2+.35,n+14,cover)
    box(x+1.5+a,layer*2+.35,n+3.5,x+13.5-a,layer*2+1.65,n+13.5,color(10,9))
    box(x+1+a,layer*2+1.65,n+3,x+14-a,layer*2+2,n+14,cover)
    box(x+1+a,layer*2,n+3,x+2+a,layer*2+2,n+14,cover)
   end
   source(5,row*16+1+(p.recipe.sourceOffset or 0),7,7,{x+2,6.03,n+3},{x+13,6.03,n+3},{x+13,6.03,n+13},{x+2,6.03,n+13})
  end
  return
 end
 local wood,edge,case,dark=sample(7,26),sample(3,42),sample(8,7),sample(3,9)
 box(x+1,7,z+2,x+15,9,z+43,wood)
 source(1,20,14,20,{x+1,9.02,z+18},{x+15,9.02,z+18},{x+15,9.02,z+43},{x+1,9.02,z+43})
 for _,xx in ipairs({2,12})do for _,zz in ipairs({4,38})do box(x+xx,0,z+zz,x+xx+2,7,z+zz+3,edge)end end
 box(x+2,3,z+4,x+14,4,z+6,edge)
 box(x+2,9,z+3,x+14,10,z+17,dark)
 if p.recipe.faceLeft then
  box(x+7,10,z+4,x+13,23,z+17,case)
  source(2,1,12,18,{x+6.98,23,z+4},{x+6.98,23,z+17},{x+6.98,10,z+17},{x+6.98,10,z+4})
 else
  box(x+3,10,z+4,x+9,23,z+17,case)
  source(2,1,12,18,{x+9.02,23,z+17},{x+9.02,23,z+4},{x+9.02,10,z+4},{x+9.02,10,z+17})
 end
 box(x+4,9,z+30,x+11,10.5,z+36,dark)
 source(4,30,7,6,{x+4,10.52,z+30},{x+11,10.52,z+30},{x+11,10.52,z+36},{x+4,10.52,z+36})
end
return M
