-- Hoenn L checkout: the back-left two source cells are the clerk aisle.
local M={}
function M.append(p,source,box,sample,emit)
 local x,z=p.cx*16,p.cy*16
 if p.recipe.kind=='martRegister' then
  local case,dark=sample(10,18),sample(2,21)
  box(x+1,0,z+17,x+15,7,z+31,sample(3,28))
  box(x+2,7,z+18,x+14,9,z+30,dark)
  emit({{x+2,9,z+18},{x+14,9,z+18},{x+14,15,z+18},{x+2,15,z+18}},case,.8)
  emit({{x+2,9,z+28},{x+14,9,z+28},{x+14,10,z+28},{x+2,10,z+28}},case,.9)
  emit({{x+2,9,z+18},{x+2,15,z+18},{x+2,10,z+28},{x+2,9,z+28}},case,.75)
  emit({{x+14,9,z+28},{x+14,10,z+28},{x+14,15,z+18},{x+14,9,z+18}},case,.85)
  source(1,9,14,14,{x+2,15.02,z+18},{x+14,15.02,z+18},{x+14,10.02,z+28},{x+2,10.02,z+28})
  source(1,23,14,8,{x+1,7,z+31.02},{x+15,7,z+31.02},{x+15,0,z+31.02},{x+1,0,z+31.02})
  emit({{x+1,0,z+31},{x+15,0,z+31},{x+15,0,z+17},{x+1,0,z+17}},dark,.65)
  return
 end
 local shell,glass=sample(7,29),sample(7,20)
 local function closed(a,n,c,f)
  box(x+a,0,z+n,x+c,7,z+f,shell)
  emit({{x+a,0,z+f},{x+c,0,z+f},{x+c,0,z+n},{x+a,0,z+n}},shell,.65)
 end
 closed(0,17,48,31);closed(33,0,48,17)
 source(0,16,48,8,{x,7.03,z+17},{x+48,7.03,z+17},{x+48,7.03,z+27},{x,7.03,z+27})
 source(0,24,48,8,{x,7,z+31.02},{x+48,7,z+31.02},{x+48,0,z+31.02},{x,0,z+31.02})
 source(32,0,16,16,{x+33,7.03,z},{x+48,7.03,z},{x+48,7.03,z+17},{x+33,7.03,z+17})
 -- Closed rear glazing/panel strips keep the service side finished.
 box(x+.5,6.8,z+17,x+32.5,7.6,z+18,glass)
 box(x+33,6.8,z+.5,x+34,7.6,z+17,glass)
end
return M
